module Caco::Postgres::BuildAugeas
  def self.call((ctx, flow_options), **, &block)
    augeas_path = ctx[:augeas_path] ? ctx[:augeas_path] : "/"

    ctx[:aug] = aug = Augeas::open(augeas_path, nil, Augeas::NO_LOAD)
    aug.clear_transforms
    aug.transform(:lens => "Postgresql.lns", :incl => "/postgresql.conf")
    aug.load

    return Trailblazer::Activity::Right, [ctx, flow_options]
  end
end
