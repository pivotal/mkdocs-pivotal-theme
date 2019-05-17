# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'tempfile'
require 'yaml'
require 'net/http'
require 'uri'

RSpec.describe 'When generating a site' do
  def create_mkdocs_site(prefix: 'project', version:)
    site_name = "#{prefix}-#{version}"
    Dir.chdir(build_dir) do
      system("mkdocs new #{site_name}")
    end
    path = File.join(build_dir, site_name)
    File.write(File.join(path, 'requirements.txt'), 'mkdocs')
    path
  end

  def start_nginx!(conf_path)
    nginx_conf = Tempfile.new
    File.write(nginx_conf.path, <<~CONF)
    daemon on;
    events {
      worker_connections  4096;  ## Default: 1024
    }
    http{
      server {
        listen 8000;
        root #{output_dir};

        #{File.read(conf_path)}
      }
    }
    CONF

    end_nginx!
    system("nginx -c #{nginx_conf.path}")
  end

  def end_nginx!
    system('kill -9 $(lsof -t -i :8000)')
  end
  
  def get(path)
    request = Net::HTTP.get_response(URI("http://127.0.0.1:8000#{path}"))
    puts request.inspect
    puts request.to_hash
    return request
  end

  context 'and a single version is provided' do
    let(:build_dir) { Dir.mktmpdir }
    let(:output_dir) { Dir.mktmpdir }
    let!(:doc_path) { create_mkdocs_site prefix: 'project', version: 'v1.1' }

    def build_the_site!
      BuildDocs.new(
        docs_dir: build_dir,
        docs_prefix: 'project',
        site_prefix: 'some-path',
        output_dir: output_dir
      ).generate!
    end

    it 'does not include versions in the mkdocs.yml and is strict' do
      build_the_site!
      config = YAML.load_file(File.join(doc_path, 'mkdocs.yml'))
      expect(config['extra']['versions']).to eq({})
      expect(config['strict']).to be_truthy
    end

    it 'includes ensures the pivotal theme is used in requirements.txt' do
      build_the_site!
      config = YAML.load_file(File.join(doc_path, 'mkdocs.yml'))
      expect(config['theme']).to eq 'pivotal'
      requirements = File.read(File.join(doc_path, 'requirements.txt'))
      expect(requirements).to include 'git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal'
      expect(requirements).to include 'mkdocs-material'
      expect(requirements).to include 'mkdocs'
    end

    context 'when no requirements.txt is provided' do
      it 'ensures that it is created' do
        File.delete(File.join(doc_path, 'requirements.txt'))

        build_the_site!
        config = YAML.load_file(File.join(doc_path, 'mkdocs.yml'))
        expect(config['theme']).to eq 'pivotal'
        requirements = File.read(File.join(doc_path, 'requirements.txt')).split("\n")
        expect(requirements).to include 'git+https://github.com/pivotal/mkdocs-pivotal-theme#egg=mkdocs-pivotal'
        expect(requirements).to include 'mkdocs-material'
        expect(requirements).to include 'mkdocs'
      end
    end

    it 'copies the generated doc site to the output dir' do
      build_the_site!
      versioned_site = File.join(output_dir, 'some-path', 'v1.1', 'index.html')
      expect(File).to exist(versioned_site)
    end

    it 'creates an nginx.conf that handles all the redirects' do
      build_the_site!

      nginx_conf = File.join(output_dir, 'nginx', 'conf', 'redirect.conf')
      start_nginx!(nginx_conf)
      expect(get('/some-path/v1.1/').code).to eq '200'
      expect(get('/some-path/1-1/')['location']).to include '/some-path/v1.1'
      expect(get('/some-path/')['location']).to include '/some-path/v1.1'
      end_nginx!
    end

    xit 'creates a manifest.yml for a `cf push`' do
    end
  end

  xcontext 'and multiple versions are provided' do
  end
end
