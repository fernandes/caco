module Caco::Resource
  class Result
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :created, :boolean
    attribute :resource
    attribute :changed, :boolean
    # TODO: array [true, 0, "out 1", nil]
    attribute :signal
    attribute :exit_code, :integer
    attribute :output, :string
    attribute :stderr, :string
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

