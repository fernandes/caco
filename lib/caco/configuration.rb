module Caco
  class << self
    attr_accessor :config
  end

  class Configuration < KingKonf::Config
    attr_accessor :eyaml_parser

    # The prefix is used to identify environment variables. Here, we require
    # that all environment variables used for config start with `CACO_`,
    # followed by the all caps name of the variable.
    env_prefix :caco

    string :root
    boolean :write_files, default: true
    string :write_files_root, default: nil
    string :log_file, default: "/var/log/caco.log"
    boolean :interactive_writes, default: false
  end
end
