# typed: true
module Caco
  extend T::Sig

  sig {
    params(
      name: String,
      command: T.nilable(T.any(String, T::Array[String]))
    ).
    returns(Caco::Resource::Result)
  }
  def self.execute(name, command: nil)
    resource = Caco::Resource::Execute.new(name)
    resource.command = command
    validate_resource(resource, "execute")
    perform_resource(resource)
  end

  sig {
    params(
      name: String,
      content: String
    ).
    returns(Caco::Resource::Result)
  }
  def self.file(name, content:)
    resource = Caco::Resource::File.new(name)
    resource.content = content
    validate_resource(resource, "file")
    perform_resource(resource)
  end

  sig {
    params(
      name: String,
      guard: Symbol,
      source: T.nilable(Symbol),
      provider: T.nilable(Symbol)
    ).
    returns(Caco::Resource::Result)
  }
  def self.package(name, guard: :present, source: nil, provider: nil)
    resource = Caco::Resource::Package.new(name)
    resource.guard = guard
    resource.source = source
    resource.provider = provider
    validate_resource(resource, "package")
    perform_resource(resource)
  end

  private
  sig {
    params(
      resource: Caco::Resource::Base,
      name: String
    ).void
  }
  def self.validate_resource(resource, name)
    unless resource.valid?
      raise Caco::Resource::Invalid.new(
        "Invalid `#{name}' with errors: #{resource.errors.full_messages}"
      )
    end
  end

  sig {
    params(
      resource: Caco::Resource::Base
    ).
    returns(Caco::Resource::Result)
  }
  def self.perform_resource(resource)
    resource.action!
    resource.result
  end
end

def caco(&block)
  Caco.instance_eval(&block) if block_given?
end

