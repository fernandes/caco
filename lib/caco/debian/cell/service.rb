module Caco::Debian::Cell
  class Service < Trailblazer::Cell
    def description
      property(:description) || "No Description Provided"
    end

    def environment_file
      property(:environment_file)
    end

    def environment_vars
      property(:environment_vars) || []
    end

    def command
      property(:command)
    end
  end
end
