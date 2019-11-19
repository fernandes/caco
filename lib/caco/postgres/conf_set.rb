module Caco::Postgres
  class ConfSet < Trailblazer::Operation
    ProcessSingleValue = Class.new(Trailblazer::Activity::Signal)
    ProcessMultipleValue = Class.new(Trailblazer::Activity::Signal)

    step Caco::Macro::NormalizeParams()
    step Caco::Postgres::BuildAugeas()
    step :define_what_process,
      Output(ProcessSingleValue, :single_value) => Id(:process_single_value),
      Output(ProcessMultipleValue, :multiple_values) => Id(:process_multiple_values),
      Output(Trailblazer::Activity::Left, :failure) => End(:failure)
    step :process_single_value, magnetic_to: nil
    step :process_multiple_values, magnetic_to: nil

    def define_what_process(ctx, params:, **)
      if params.has_key?(:name) && params.has_key?(:value)
        return ProcessSingleValue
      elsif params.has_key?(:values) and params.is_a?(Hash)
        return ProcessMultipleValue
      else
        return false
      end
    end

    def process_single_value(ctx, name:, value:, aug:, **)
      ctx[:value] = aug.set("/files/postgresql.conf/#{name}", value)
      aug.save!
      true
    end

    def process_multiple_values(ctx, values:, aug:, **)
      ctx[:values] = {}
      values.each_pair do |name, value|
        ctx[:values][name.to_s] = aug.set("/files/postgresql.conf/#{name}", value)
      end
      aug.save!
      true
    end
  end
end
