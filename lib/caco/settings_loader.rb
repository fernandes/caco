# This is a monkey patch to decrypt the yaml files before loading into `Config` gem
require "config/sources/yaml_source"
class Config::Sources::YAMLSource
  def load
    result = nil

    if @path and File.exist?(@path)
      content = IO.read(@path)
      descrypted_content = decrypt_content(content)
      result = YAML.load(ERB.new(descrypted_content).result)
    end

    result || {}

    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{@path}. " \
            "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
            "Error: #{e.message}"
  end

  def decrypt_content(content)
    parsed_content = Caco.config.eyaml_parser.parse(content)
    parsed_content.each do |parsed|
      content.sub!(parsed.match, parsed.to_plain_text)
    end
    content
  end
end

module Caco
  class SettingsLoader < Trailblazer::Operation
    step :setup_validate_params
    step :config_setup
    step :hiera_setup_keys
    step :set_caco_eyaml_parser
    step :facter_needed_values
    step :config_load
    step :custom_config

    def setup_validate_params(ctx, keys_path: nil, data_path: nil, **)
      ctx[:keys_path] = !keys_path.nil? ? Pathname.new(keys_path) : Pathname.new(Caco.root.join("keys"))
      ctx[:data_path] = !data_path.nil? ? Pathname.new(data_path) : Pathname.new(Caco.root.join("data"))
    end

    def config_setup(ctx, **)
      Config.setup do |config|
        config.const_name = 'Settings'
        config.use_env = true
      end
    end

    def hiera_setup_keys(ctx, keys_path:, **)
      Hiera::Backend::Eyaml::Options[:pkcs7_public_key] = keys_path.join("public_key.pkcs7.pem")
      Hiera::Backend::Eyaml::Options[:pkcs7_private_key] = keys_path.join("private_key.pkcs7.pem")
      ctx[:parser] = Hiera::Backend::Eyaml::Parser::ParserFactory.encrypted_parser
    end

    def set_caco_eyaml_parser(ctx, parser:, **)
      Caco.configure do |config|
        config.eyaml_parser = parser
      end
    end

    def facter_needed_values(ctx, **)
      ctx[:facts] = {}
      ctx[:facts][:facter_kernel] =  Caco::Facter.("kernel")
      ctx[:facts][:facter_os_name] = Caco::Facter.("os", "name")
      ctx[:facts][:facter_distro_codename] = (ctx[:facts][:facter_kernel] == "Linux" ? Caco::Facter.("os", "distro", "codename") : nil)
      ctx[:facts][:facter_release_full] = Caco::Facter.("os", "release", "full")
      ctx[:facts][:facter_release_major] = Caco::Facter.("os", "release", "major")
      ctx[:facts][:facter_release_minor] = Caco::Facter.("os", "release", "minor")
      ctx[:facts][:facter_fqdn] = Caco::Facter.("networking", "fqdn")
    end

    def config_load(ctx, facts:, data_path:, **)
      # From more generic to specific
      Config.load_and_set_settings(
        data_path.join("common.yaml"),
        data_path.join("os", "#{facts[:facter_os_name]}.yaml"),
        data_path.join("os", "#{facts[:facter_os_name]}", "#{facts[:facter_distro_codename]}.yaml"),
        # maybe add some organizations here?
        # maybe add some roles here?
        data_path.join("nodes", "#{facts[:facter_fqdn]}"),
      )
      Settings.reload!
    end

    def custom_config(ctx, **)
      Settings.prometheus = Config::Options.new
      Settings.prometheus.root = "/opt/prometheus"
      Settings.prometheus.config_root = "/etc/prometheus"
    end
  end
end
