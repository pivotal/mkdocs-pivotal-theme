#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'pathname'

class BuildDocs
  def initialize(
    docs_dir:,
    docs_prefix:,
    site_prefix:,
    output_dir:,
    domains:,
    ignore_directories: [],
    exclude_from_dropdown: []
  )
    @domains = domains
    @docs_dir = docs_dir
    @docs_prefix = docs_prefix
    @site_prefix = site_prefix
    @output_dir = output_dir
    @ignore_directories = ignore_directories.map do |path|
      if Pathname.new(path).absolute?
        path
      else
        File.join(@docs_dir, path)
      end
    end
    @exclude_from_dropdown = exclude_from_dropdown
  end

  def generate!
    update_mkdocs_config
    generate_sites
    generate_nginx
    generate_cf_manifest
  end

  private

  def generate_cf_manifest
    manifest = File.join(@output_dir, 'manifest.yml')
    File.write(manifest, {
      'instances' => 2,
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

    File.write(File.join(@output_dir, 'Staticfile'), {
      'http_strict_transport_security' => true,
      'force_https' => true,
      'location_include' => 'redirect.conf',
      'status_codes' => {
        '404' => "/#{@site_prefix}/#{latest_version}/404.html"
      }
    }.to_yaml)
  end

  def docs_dirs
    Dir[File.join(@docs_dir, "#{@docs_prefix}-*")] - @ignore_directories
  end

  def versions
    @versions ||= docs_dirs.sort.reverse.map do |doc_dir|
      doc_dir.split('/').last.gsub(/^#{@docs_prefix}-/, '')
    end - @exclude_from_dropdown
  end

  def generate_sites
    docs_dirs.each do |doc_dir|
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
    docs_dirs.each do |doc_dir|
      config_path = File.join(doc_dir, 'mkdocs.yml')
      current_version = doc_dir.split('/').last.gsub(/^#{@docs_prefix}-/, '')
      config = YAML.load_file(config_path)
      config['theme'] ||= 'pivotal'
      config['site_url'] = "http://#{@domains.first}/#{@site_prefix}/#{current_version}"
      config['extra'] = {
        'versions' => versions.map do |version|
          [version, "/#{@site_prefix}/#{version}"]
        end.to_h,
        'current_version' => current_version
      } # NOTE: https://www.mkdocs.org/user-guide/custom-themes/#extra-context
      config['strict'] = true

      modifier = proc do |current_dir|
        current_dir_name = File.basename(File.expand_path(current_dir))
        dir = File.join(@docs_dir, "#{current_dir_name}-#{current_version}")
        if Dir.exist?(dir)
          dir
        else
          current_dir
        end
      end
      config['plugins'] = modify_in_place(config['plugins'], modifier)
      config['markdown_extensions'] = modify_in_place(config['markdown_extensions'], modifier)
      File.write(config_path, config.to_yaml)
    end
  end

  def modify_in_place(obj, fn)
    case obj
    when Hash
      obj.each do |key, value|
        obj[key] = modify_in_place(value, fn)
      end
    when Array
      obj.each_with_index do |value, index|
        obj[index] = modify_in_place(value, fn)
      end
    when String
      obj = fn.call(obj)
    end

    obj
  end
end

if $PROGRAM_NAME == __FILE__
  require 'optparse'
  options = {
    exclude_from_dropdown: '',
    ignore_directories: ''
  }
  OptionParser.new do |opts|
    opts.banner = 'Usage: ./build_docs.rb [options]'
    opts.on('--output-dir=DIR') do |v|
      options[:output_dir] = v
    end
    opts.on('--docs-dir=DIR') do |v|
      options[:docs_dir] = v
    end
    opts.on('--docs-prefix=PREFIX') do |v|
      options[:docs_prefix] = v
    end
    opts.on('--site-prefix=PREFIX') do |v|
      options[:site_prefix] = v
    end
    opts.on('--domains=DOMAINS') do |v|
      options[:domains] = v
    end
    opts.on('--ignore-directories=DIRS') do |v|
      options[:ignore_directories] = v
    end
    opts.on('--exclude-from-dropdown=VERSIONS') do |v|
      options[:exclude_from_dropdown] = v
    end
  end.parse!
  # running as a binary (`ruby ./build_docs.rb`)
  BuildDocs.new(
    docs_dir: File.expand_path(options[:docs_dir]),
    docs_prefix: options[:docs_prefix],
    site_prefix: options[:site_prefix],
    output_dir: File.expand_path(options[:output_dir]),
    domains: options[:domains].split(' '),
    ignore_directories: options[:ignore_directories].split(','),
    exclude_from_dropdown: options[:exclude_from_dropdown].split(',')
  ).generate!
end
