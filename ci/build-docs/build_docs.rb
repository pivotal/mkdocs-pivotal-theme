require 'yaml'

class BuildDocs
  def initialize(docs_dir:, docs_prefix:, site_prefix:, output_dir:)
    @docs_dir = docs_dir
  end

  def generate!
    Dir[File.join(@docs_dir, '*', 'mkdocs.yml')].each do |config_path|
      config = YAML.load_file(config_path)
      config['theme'] = 'pivotal'
      config['versions'] = {}
      File.write(config_path, config.to_yaml)
    end
  end
end