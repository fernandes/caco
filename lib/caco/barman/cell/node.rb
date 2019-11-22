module Caco::Barman::Cell
  class Node < Trailblazer::Cell
    def name
      property(:name)
    end

    def description
      property(:description)
    end

    def host
      property(:host)
    end
  end
end
