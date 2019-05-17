# frozen_string_literal: true

require 'yaml'
require 'fileutils'

class BuildDocs
  def initialize(
    docs_dir:,
    docs_prefix:,
    site_prefix:,
    output_dir:,
    domains:
  )
    @domains = domains
    @docs_dir = docs_dir
    @docs_prefix = docs_prefix
    @site_prefix = site_prefix
    @output_dir = output_dir
  end

  def generate!
    update_mkdocs_config
    update_python_requirements
    generate_sites
    generate_nginx
    generate_cf_manifest
  end

  private

  def generate_cf_manifest
    manifest = File.join(@output_dir, 'manifest.yml')
    File.write(manifest, {
      'memory' => '64M',
      'disk_quota' => '256M',
      'routes' => @domains.map do |domain|
                    { 'route' => "#{domain}/#{@site_prefix}" }
                  end
    }.to_yaml)
  end

  def generate_nginx
    location_conf = File.join(@output_dir, 'nginx', 'conf', 'redirect.conf')
    FileUtils.mkdir_p(File.dirname(location_conf))
    old_style_redirects = versions.map do |version|
      old_style_version = version.gsub('.', '-').gsub(/^v/, '')
      if old_style_version != version
        "rewrite ^/#{@site_prefix}/#{old_style_version}/(.*) /#{@site_prefix}/#{version}/$1 redirect;"
      end
    end.compact
    latest_version = versions.first

    File.write(location_conf, <<~CONF)
      #{old_style_redirects.join("\n")}
      rewrite ^/#{@site_prefix}/?$ /#{@site_prefix}/#{latest_version}/ redirect;
    CONF
  end

  def versions
    @versions ||= Dir[File.join(@docs_dir, '*')].sort.reverse.map do |doc_dir|
      doc_dir.split('/').last.gsub(/^#{@docs_prefix}-/, '')
    end
  end

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
    Dir[File.join(@docs_dir, '*')].each do |doc_dir|
      config_path = File.join(doc_dir, 'mkdocs.yml')
      current_version = doc_dir.split('/').last.gsub(/^#{@docs_prefix}-/, '')
      config = YAML.load_file(config_path)
      config['theme'] = 'pivotal'
      config['extra'] = {
        'versions' => versions.map do |version|
          [version, "/#{@site_prefix}/#{version}"]
        end.to_h,
        'current_version' => current_version
      } # NOTE: https://www.mkdocs.org/user-guide/custom-themes/#extra-context
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
