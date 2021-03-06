require 'spec_helper'

RSpec.describe Imperium::HTTPClient do
  let(:config) { Imperium::Configuration.new(url: 'http://consul.example.com') }
  let(:client) { Imperium::HTTPClient.new(config) }

  describe '#get(path, query: {})' do
    let(:path) { 'v1/kv/foo/bar' }

    before do
      stub_request(:get, /consul\.example\.com/)
    end

    it 'must use the URL provided by the configuration' do
      client.get(path)
      expect(WebMock).to have_requested(:get, /\Ahttp:\/\/consul\.example\.com/)
    end

    it 'must merge the supplied path with the configured url rather than replacing it' do
      config.url = 'http://consul.example.com/namespace'
      client.get(path)
      expect(WebMock).to have_requested(:get, /namespace/)
    end

    it 'must use the supplied path as the path for the url' do
      client.get(path)
      expect(WebMock).to have_requested(:get, /#{path}\z/)
    end

    it 'must use the supplied query as the query params encoded appropriately' do
      client.get(path, query: {'some_param' => 'val', 'no_value' => nil})
      expect(WebMock).to have_requested(:get, /consul\.example\.com/).
        with(query: hash_including({'some_param' => 'val', 'no_value' => nil}))
    end

    it 'must include the X-Consul-Token header when the Configuration has a token set' do
      config.token = 'totes-legit'
      client.get(path)
      expect(WebMock).to have_requested(:get, /consul\.example\.com/).
        with(headers: {'X-Consul-Token' => 'totes-legit'})
    end

    it 'must not include the X-Consul-Token header when the Configuration does not have a token set' do
      config.token = nil
      client.get(path)
      expect(WebMock).to_not have_requested(:get, /consul\.example\.com/).
        with(headers: {'X-Consul-Token' => 'totes-legit'})
    end
  end
end
