module Caco::Repmgr::Cell
  class Conf < Trailblazer::Cell
    def node_id
      property(:node_id)
    end

    def node_name
      property(:node_name)
    end

    def primary_host
      property(:primary_host)
    end

    def primary_user
      property(:primary_user)
    end

    def primary_database
      property(:primary_database)
    end

    def node_initial_role
      property(:node_initial_role)
    end

    def postgres_version
      property(:postgres_version)
    end

    def use_barman?
      property(:use_barman) || false
    end

    def barman_host
      property(:barman_host) || "barman"
    end

    def barman_server
      property(:barman_server) || "pg"
    end
  end
end
