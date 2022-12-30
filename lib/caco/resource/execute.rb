class Caco::Resource::Execute < Caco::Resource::Base
  class Output < T::Struct
    prop :success, T::Boolean
    prop :exit_status, Integer
    prop :stdout, String
    prop :stderr, T.nilable(String)

    def success?
      success
    end
  end

  attr_accessor :command
  
  def make_absent
  end

  def make_present
    command_to_execute = command.present? ? command : name
    output = self.class.send(:execute, command_to_execute)
    s = output.success?
    e = output.exit_status
    o = output.stdout
    error = output.stderr

    @signal = [s, e, o, error]
    @exit_code = e
    @output = o
    @stderr = error
  end

  def result
    super.merge(
      signal: @signal,
      exit_code: @exit_code,
      output: @output,
      stderr: @stderr
    )
  end

  module ClassMethods
    extend T::Sig

    private
    sig {params(command: T.any(String,T::Array[String])).returns(Caco::Resource::Execute::Output)}
    def execute(command)
      Open3.popen3(*command) do |i, o, e, t|
        exit_status = t.value
        Caco::Resource::Execute::Output.new(
          success: exit_status.success?,
          exit_status: exit_status.exitstatus,
          stdout: o.read,
          stderr: e.read
        )
      end
    end
  end
  extend ClassMethods
end

def execute(name, **kwargs, &block)
  resource = Caco::Resource::Execute.new(name)
  kwargs.each_pair do |k, v|
    resource.send("#{k}=", v)
  end
  # resource.instance_eval(&block)
  resource.action!
  resource.result
end
