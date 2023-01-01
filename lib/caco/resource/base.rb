module Caco::Resource
  class Base
    include ActiveModel::Validations
    extend T::Sig

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

    def default_attributes
      {
        resource: self,
        created: @created,
        changed: @changed
      }
    end

    def resource_attributes
      {}
    end

    def result
      Caco::Resource::Result.new(default_attributes.merge(resource_attributes))
    end
  end
end

