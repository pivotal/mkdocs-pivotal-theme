# frozen_string_literal: true

require 'yaml'
require 'fileutils'

class BuildDocs
  def initialize(docs_dir:, docs_prefix:, site_prefix:, output_dir:)
    @docs_dir = docs_dir
    @docs_prefix = docs_prefix
    @site_prefix = site_prefix
    @output_dir = output_dir
  end

  def generate!
    update_mkdocs_config
    update_python_requirements
    generate_sites
  end

  private

  def generate_sites
    Dir[File.join(@docs_dir, '*')].each do |doc_dir|
      version = doc_dir.split('/').last.gsub(/^#{@docs_prefix}-/, '')
      Dir.chdir(doc_dir) do
        system('pip3 install -U -r requirements.txt')
        system('mkdocs build')
      end
      final_path = File.join(@output_dir, @site_prefix, version)
      FileUtils.mkdir_p final_path
      FileUtils.cp_r(
        File.join(doc_dir, 'site', '.'),
        final_path
      )
    end
  end

  def update_mkdocs_config
    Dir[File.join(@docs_dir, '*', 'mkdocs.yml')].each do |config_path|
      config = YAML.load_file(config_path)
      config['theme'] = 'pivotal'
      config['extra'] = { 'versions' => {} } # NOTE: https://www.mkdocs.org/user-guide/custom-themes/#extra-context
      config['strict'] = true
      File.write(config_path, config.to_yaml)
    end
  end

  def update_python_requirements
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
