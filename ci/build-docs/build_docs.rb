# frozen_string_literal: true

require 'yaml'
require 'fileutils'

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
    Dir[File.join(@docs_dir, '*')].each do |doc_dir|
      requirements_path = File.join(doc_dir, 'requirements.txt')
      FileUtils.touch(requirements_path) unless File.exist?(requirements_path)
      packages = File.read(requirements_path).split("\n")
      %w[mkdocs mkdocs-material git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal].each do |package|
        packages << package unless packages.include? package
      end
      File.write(requirements_path, packages.join("\n"))
    end
  end
end
