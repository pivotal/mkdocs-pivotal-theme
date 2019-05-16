# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'yaml'

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
  end

  context 'and multiple versions are provided' do
  end
end
