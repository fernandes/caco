def make_dsl(name, klass)
  define_method(name) do |name, &block|
    resource = klass.new(name)
    resource.instance_eval(&block)
    resource.action!
    resource.result
  end
end

class Caco::Resource::Base
  attr_reader :name, :changed, :created, :performed

  def initialize(name)
    @name = name
    @created = false
    @changed = false
    @present = true
    @performed = false
  end

  def absent!
    @present = false
  end

  def persent!
    @present = true
  end

  def present?
    @present
  end

  def absent?
    !@present 
  end

  def performed?
    performed
  end

  def action!
    return if performed?

    make_absent if absent?
    make_present if present?

  end

  def performed!
    @performed = true
  end

  def created!
    @created = true
  end

  def changed!
    @changed = true
  end

  def result
    {
      resource: self,
      created: @created,
      changed: @changed
    }
  end
end

