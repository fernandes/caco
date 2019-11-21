class Caco::Unpacker < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:pack)
  step Caco::Macro::ValidateParamPresence(:dest)
  step Caco::Macro::NormalizeParams()
  pass :create_dest
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

  def create_dest(ctx, dest:, **)
    FileUtils.mkdir_p(dest)
  end

  def find_format(ctx, pack:, dest:, **)
    ctx[:unknown_file_mime] = Marcel::MimeType.for pack
  rescue StandardError
    false
  end

  def build_unknown_command(ctx, pack:, dest:, unknown_file_mime:, **)
    basename = File.basename(pack)
    return ctx[:command] = "gunzip -c #{pack} > #{dest}/#{basename}" if unknown_file_mime == "application/gzip"
    ctx[:failure_reason] = "unknown_format"
    false
  end

  def build_tar_command(ctx, pack:, dest:, **)
    ctx[:command] = "tar xpf #{pack} -C #{dest}"
  end

  def tar_integrity_test_input(original_ctx, pack:, **)
    { params: { command: "tar tzf #{pack} > /dev/null" } }
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

  def command_failed(ctx, command_exit_code:, failure_reason:, **)
    # puts "Command Failed with output: #{failure_reason}"
    # log to somewhere
    false
  end
end
