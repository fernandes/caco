module Caco::Postgres
  class ConfGet < Trailblazer::Operation
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
      if params.has_key?(:name) and params[:name].is_a?(String)
        return ProcessSingleValue
      elsif params.has_key?(:names) and params[:names].is_a?(Array)
        return ProcessMultipleValue
      else
        return false
      end
    end

    def process_single_value(ctx, name:, aug:, **)
      ctx[:value] = aug.get("/files/postgresql.conf/#{name}")
    end

    def process_multiple_values(ctx, names:, aug:, **)
      ctx[:values] = {}
      names.each do |name|
        ctx[:values][name.to_s] = aug.get("/files/postgresql.conf/#{name}")
      end
    end
  end
end
