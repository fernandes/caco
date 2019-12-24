module Caco
  module Postgres
    module ClassMethods
      def add_shared_library(lib)
        @libraries ||= []
        @libraries << lib
        true
      end

      def shared_libraries
        @libraries ||= []
        @libraries.join(", ")
      end

      def clear_shared_library
        @libraries = []
      end

      def should_restart!
        @should_restart = true
      end

      def should_restart?
        @should_restart || false
      end
    end

    extend ClassMethods
  end
end

require 'caco/postgres/build_augeas'
require 'caco/postgres/conf_get'
require 'caco/postgres/conf_set'
require 'caco/postgres/hba_set'
require 'caco/postgres/install'
require 'caco/postgres/shell'
require 'caco/postgres/sql'

# depends on sql
require 'caco/postgres/database_create'
require 'caco/postgres/extension_create'
require 'caco/postgres/user_change_password'
require 'caco/postgres/user_create'
