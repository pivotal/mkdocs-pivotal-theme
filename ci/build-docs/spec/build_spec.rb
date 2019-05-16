require 'spec_helper'
require 'tmpdir'
require 'yaml'

RSpec.describe 'When generating a site' do
  def create_mkdocs_site(prefix: 'project', version:)
    site_name = "#{prefix}-#{version}"
    Dir.chdir(build_dir) do
      system("mkdocs new #{site_name}")
    end
    File.join(build_dir, site_name)
  end

  context 'and a single version is provided' do
    let(:build_dir) { Dir.mktmpdir }
    let(:output_dir) { Dir.mktmpdir }
    let!(:doc_path) { create_mkdocs_site version: 'v1.1' }

    before(:each) do
      BuildDocs.new(
        docs_dir: build_dir,
        docs_prefix: 'project',
        site_prefix: 'some-path',
        output_dir: output_dir,
      ).generate!
    end

    it 'does not include versions in the mkdocs.yml' do
      config = YAML.load_file(File.join(doc_path,'mkdocs.yml'))
      expect(config['versions']).to eq({})
    end

    it 'includes ensures the pivotal theme is used' do
      config = YAML.load_file(File.join(doc_path,'mkdocs.yml'))
      expect(config['theme']).to eq 'pivotal'
    end
  end

  context 'and multiple versions are provided' do
  end
end