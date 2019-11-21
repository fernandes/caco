class Caco::Unpacker < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:pack)
  step Caco::Macro::ValidateParamPresence(:dest)
  step Caco::Macro::NormalizeParams()
  pass :create_dest
  step :calculate_mime_type
  step :build_integrity_command
  step Subprocess(Caco::Executer),
    input: :tar_integrity_test_input,
    output: :tar_integrity_test_output,
    id: "tar_integrity_test",
    Output(:failure) => Track(:unknown_command),
    Output(:success) => Id(:build_tar_command)

  step :build_tar_command
  step :find_format,
    magnetic_to: :unknown_command,
    Output(Trailblazer::Activity::Right, :success) => Track(:unknown_format)
  step :build_unknown_command,
    magnetic_to: :unknown_format,
    Output(Trailblazer::Activity::Right, :success) => Track(:success)

  step Subprocess(Class.new(Caco::Executer)),
    input: :unpacker_command_input,
    output: :unpacker_command_output,
    id: "unpacker_command"
  fail :command_failed

  def calculate_mime_type(ctx, pack:, **)
    ctx[:mime_type] = Marcel::MimeType.for pack
  end

  def create_dest(ctx, dest:, **)
    FileUtils.mkdir_p(dest)
  end

  def build_integrity_command(ctx, pack:, mime_type:, **)
    return (ctx[:integrity_command] = "tar tzf #{pack}") if mime_type == "application/gzip"
    return (ctx[:integrity_command] = "tar tjf #{pack}") if mime_type == "application/x-bzip"
    return (ctx[:integrity_command] = "tar tf #{pack}") if mime_type == "application/x-tar"
    ctx[:integrity_command] = "tar tf #{pack}"
  end

  def find_format(ctx, pack:, dest:, **)
    ctx[:unknown_file_mime] = Marcel::MimeType.for pack
  rescue StandardError
    false
  end

  def build_unknown_command(ctx, pack:, dest:, mime_type:, **)
    basename = File.basename(pack)
    return ctx[:command] = "gunzip -c #{pack} > #{dest}/#{basename}" if mime_type == "application/gzip"
    ctx[:failure_reason] = "unknown_format"
    false
  end

  def build_tar_command(ctx, pack:, dest:, **)
    ctx[:command] = "tar xpf #{pack} -C #{dest}"
  end

  def tar_integrity_test_input(original_ctx, integrity_command:, **)
    { params: { command: integrity_command } }
  end

  def tar_integrity_test_output(scoped_ctx, exit_code:, output:, **)
    { command_exit_code: exit_code, command_output: output }
  end

  def unpacker_command_input(original_ctx, command:, **)
    { params: { command: command } }
  end

  def unpacker_command_output(scoped_ctx, exit_code:, output:, **)
    { command_exit_code: exit_code, command_output: output }
  end

  def command_failed(ctx, failure_reason:, **)
    # puts "Command Failed with output: #{failure_reason}"
    # log to somewhere
    false
  end
end
