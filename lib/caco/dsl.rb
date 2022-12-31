# typed: true
module Caco
  extend T::Sig

  def self.execute(name, **kwargs, &block)
    resource = Caco::Resource::Execute.new(name)
    kwargs.each_pair do |k, v|
      resource.send("#{k}=", v)
    end
    # resource.instance_eval(&block)
    resource.action!
    resource.result
  end

  sig {
    params(
      name: String,
      content: String
    ).
    returns(T::Hash[String, String])
  }
  def self.file(name, content:)
    resource = Caco::Resource::File.new(name)
    resource.content = content
    unless resource.valid?
      raise Caco::Resource::Invalid.new(
        "Invalid `file' with errors: #{resource.errors.full_messages}"
      )
    end
    resource.action!
    resource.result
  end

  sig {
    params(
      name: String,
      guard: Symbol,
      source: T.nilable(Symbol),
      provider: T.nilable(Symbol)
    ).
    returns(T::Hash[String, String])
  }
  def self.package(name, guard: :present, source: nil, provider: nil)
    resource = Caco::Resource::Package.new(name)
    resource.guard = guard
    resource.source = source
    resource.provider = provider
    unless resource.valid?
      raise Caco::Resource::Invalid.new(
        "Invalid `package' with errors: #{resource.errors.full_messages}"
      )
    end
    resource.action!
    resource.result
  end
end

def caco(&block)
  Caco.instance_eval(&block) if block_given?
end

