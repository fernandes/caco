# typed: true
module Caco::Resource
  class Result
    extend T::Sig
    include ActiveModel::Model
    include ActiveModel::Attributes

    sig {returns(T.nilable(T::Boolean))}
    attr_accessor :created
    attribute :created, :boolean

    sig {returns(Caco::Resource::Base)}
    attr_accessor :resource
    attribute :resource

    sig {returns(T.nilable(T::Boolean))}
    attr_accessor :changed
    attribute :changed, :boolean

    # TODO: array [true, 0, "out 1", nil]
    sig {returns(T.nilable(T::Array[T.nilable(T.any(T::Boolean, Integer, String))]))}
    attr_accessor :signal
    attribute :signal

    sig {returns(T.nilable(Integer))}
    attr_accessor :exit_code
    attribute :exit_code, :integer

    sig {returns(T.nilable(String))}
    attr_accessor :output
    attribute :output, :string

    sig {returns(T.nilable(String))}
    attr_accessor :stderr
    attribute :stderr, :string

    sig {returns(T.nilable(String))}
    attr_accessor :stderr
    attribute :stderr, :string

    attribute_types.each_pair do |k, v|
      if v.is_a?(ActiveModel::Type::Boolean)
        define_method(:"#{k}?") do
          send(:"#{k}")
        end
      end
    end

    # Keep API compatible with hash
    def [](key)
      send(key)
    end
  end
end

