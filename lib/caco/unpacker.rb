class Caco::Unpacker < Trailblazer::Operation
  pass ->(ctx, dest:, **) {
      FileUtils.mkdir_p(dest)
    },
    id: :create_dest
  
  step ->(ctx, pack:, **) {
      ctx[:mime_type] = Marcel::MimeType.for pack
    },
    id: :calculate_mime_type

  step :build_integrity_command

  step Subprocess(Caco::Executer),
    input: ->(ctx, integrity_command:, **) {{
      command: "#{integrity_command} 2> /dev/null|wc -l"
    }},
    output: ->(_ctx, exit_code:, output:, **) {
      number_of_files = Integer(output)
      { command_exit_code: exit_code, command_output: output, number_of_files: number_of_files }
    },
    id: "tar_integrity_test",
    Output(:failure) => Track(:success)

  step ->(ctx, command_exit_code:, number_of_files:, **) {
      command_exit_code == 0 && number_of_files > 0
    },
    Output(:failure) => Track(:unknown_command),
    Output(:success) => Id(:build_tar_command),
    id: :check_integrity_test

  step ->(ctx, pack:, dest:, **) {
      ctx[:command] = "tar xpf #{pack} -C #{dest}"
    },
    id: :build_tar_command

  step :find_format,
    magnetic_to: :unknown_command,
    Output(Trailblazer::Activity::Right, :success) => Track(:unknown_format)

  step :build_unknown_command,
    magnetic_to: :unknown_format,
    Output(Trailblazer::Activity::Right, :success) => Track(:success)

  step Subprocess(Class.new(Caco::Executer)),
    input: [:command],
    output: { exit_code: :command_exit_code, output: :command_output },
    id: "unpacker_command"

  fail ->(_ctx, **) {
      # puts "Command Failed with output: #{failure_reason}"
      # log to somewhere
      false
    },
    id: :command_failed

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
end
