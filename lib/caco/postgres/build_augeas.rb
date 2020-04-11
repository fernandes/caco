module Caco::Postgres
  def self.BuildAugeas
    task = ->((ctx, flow_options), _) do
      augeas_path = ctx[:augeas_path] ? ctx[:augeas_path] : "/"

      ctx[:aug] = aug = Augeas::open(augeas_path, nil, Augeas::NO_LOAD)
      aug.clear_transforms
      aug.transform(:lens => "Postgresql.lns", :incl => "/postgresql.conf")
      aug.load

      return Trailblazer::Activity::Right, [ctx, flow_options]
    end

    # new API
    {
      task: task,
      id:   "build_augeas"
    }
  end
end
