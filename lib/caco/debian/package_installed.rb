module Caco::Debian
  module PackageInstalled
    module ClassMethods
      def call(package:)
        dpkg_installed?(package: package) && dpkg_query_installed?(package: package)
      end
  
      def dpkg_installed?(package:)
        status, exit_code, output = Caco::Executer.(command: "dpkg -s #{package}")
        status
      end
  
      def dpkg_query_installed?(package:)
        Caco::Finder.(command: "dpkg-query -W -f='${Status} ${Version}\n' #{package}", regexp: /^install/)
      end
    end
  
    extend ClassMethods
  end
end
