require 'spec_helper'
require_relative '../lib/client_repository'
require 'json'

describe ClientRepository do
  let(:json_data) { [{ 'name' => 'Alice', 'email' => 'alice@example.com' }, { 'name' => 'Bob', 'email' => 'bob@example.com' }] }
  let(:uri) { URI(ClientRepository::DATA_URL) }

  describe '#all' do
    it 'loads clients from the remote JSON URL' do
      stub_request(:get, ClientRepository::DATA_URL)
        .to_return(status: 200, body: JSON.generate(json_data))
      repo = ClientRepository.new
      expect(repo.all).to eq(json_data)
    end

    it 'handles a failed HTTP request gracefully' do
      stub_request(:get, ClientRepository::DATA_URL)
        .to_return(status: 404, body: '')
      expect { ClientRepository.new }
        .to output(/Failed to fetch data.*404/).to_stderr
        .and raise_error(SystemExit)
    end

    it 'handles invalid JSON gracefully' do
      stub_request(:get, ClientRepository::DATA_URL)
        .to_return(status: 200, body: 'invalid json')
      expect { ClientRepository.new }
        .to output(/Invalid JSON/).to_stderr
        .and raise_error(SystemExit)
    end

    it 'handles network errors gracefully' do
      stub_request(:get, ClientRepository::DATA_URL)
        .to_raise(StandardError.new('Connection timed out'))
      expect { ClientRepository.new }
        .to output(/Network issue.*Connection timed out/).to_stderr
        .and raise_error(SystemExit)
    end
  end
end