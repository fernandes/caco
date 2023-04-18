# typed: true
module Caco
  module Dsl
    include Kernel
    extend T::Sig

    sig {
      params(
        name: String,
        user: T.nilable(String),
        cwd: T.nilable(String),
        command: T.nilable(T.any(String, T::Array[String]))
      ).
      returns(Caco::Resource::Result)
    }
    def execute(name, user: nil, cwd: nil, command: nil)
      resource = Caco::Resource::Execute.new(name)
      resource.command = command
      resource.user = user
      resource.cwd = cwd
      validate_resource(resource, "execute")
      perform_resource(resource)
    end

    sig {
      params(
        name: String,
        content: T.nilable(String),
        owner: T.nilable(String),
        group: T.nilable(String),
        mode: T.nilable(Integer),
        guard: Symbol
      ).
      returns(Caco::Resource::Result)
    }
    def file(name, content: nil, owner: nil, group: nil, mode: nil, guard: :present)
      resource = Caco::Resource::File.new(name)
      resource.content = content
      resource.guard = guard
      resource.owner = owner
      resource.group = group
      resource.mode = mode
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
    def package(name, guard: :present, source: nil, provider: nil)
      resource = Caco::Resource::Package.new(name)
      resource.guard = guard
      resource.source = source
      resource.provider = provider
      validate_resource(resource, "package")
      perform_resource(resource)
    end

    sig {
      params(
        name: String,
        guard: Symbol,
      ).
      returns(Caco::Resource::Result)
    }
    def service(name, guard: :present)
      resource = Caco::Resource::Service.new(name)
      resource.guard = guard
      validate_resource(resource, "service")
      perform_resource(resource)
    end


    private
    sig {
      params(
        resource: Caco::Resource::Base,
        name: String
      ).void
    }
    def validate_resource(resource, name)
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
    def perform_resource(resource)
      resource.action!
      resource.result
    end
  end
end

def caco(&block)
  Caco.instance_eval(&block) if block_given?
end

