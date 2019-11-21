module Caco::Macro
  def self.ValidateParamPresence(name)
    task = ->((ctx, flow_options), _) do
      raise Trailblazer::Operation::InvalidParam.new("Not found param #{name}") unless ctx[:params].has_key?(name)

      return Trailblazer::Activity::Right, [ctx, flow_options]
    end

    # new API
    {
      task: task,
      id:   "validate_params.presence.#{name}"
    }
  end

  def self.NormalizeParams(merge_hash: {})
    task = ->((ctx, flow_options), _) do
      ctx[:params].each_pair do |k, v|
        ctx[k] = v
      end

      return Trailblazer::Activity::Right, [ctx, flow_options]
    end

    # new API
    {
      task: task,
      id:   "normalize_params"
    }
  end
end
