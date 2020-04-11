class Caco::Haproxy::ConfGet < Trailblazer::Operation
  step Subprocess(Caco::FileReader),
    input: ->(_ctx, **) {{
      path: "/etc/default/haproxy",
    }},
    output: [:output]

  step ->(ctx, name:, output:, **) {
      match = output.match(/^#{name}=\"(.*)\"/)
      return false unless match

      ctx[:value] = match[1]
    },
    id: :find_value
end
