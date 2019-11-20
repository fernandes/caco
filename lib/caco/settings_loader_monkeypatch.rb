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
