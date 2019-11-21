require_relative "./settings_loader_monkeypatch"

module Caco
  class SettingsLoader < Trailblazer::Operation
    step Caco::Macro::NormalizeParams()
    step :setup_validate_params
    step :config_setup
    step :hiera_setup_keys
    step :set_caco_eyaml_parser
    step :facter_needed_values
    step :config_load

    def setup_validate_params(ctx, params:, **)
      ctx[:keys_path] = (params.key?(:keys_path) ? Pathname.new(params[:keys_path]) : Pathname.new(Caco.root.join("keys")))
      ctx[:data_path] = (params.key?(:data_path) ? Pathname.new(params[:data_path]) : Pathname.new(Caco.root.join("data")))
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
  end
end
