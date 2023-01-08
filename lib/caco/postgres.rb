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

