require 'spec_helper'
require_relative '../lib/client_repository'
require 'json'
require 'set'

describe ClientRepository do
  let(:json_data) do
    [
      { 'name' => 'Alice', 'email' => 'alice@example.com', 'age' => 30 },
      { 'name' => 'Bob', 'email' => 'bob@example.com', 'phone' => '987-654-3210' }
    ]
  end
  let(:file_path) { 'test_clients.json' }
  let(:url) { 'https://example.com/clients.json' }

  describe '#all' do
    context 'when loading from a file' do
      before do
        File.write(file_path, JSON.generate(json_data))
      end

      after do
        File.delete(file_path) if File.exist?(file_path)
      end

      it 'loads clients from a valid JSON file' do
        repo = ClientRepository.new(file_path)
        expect(repo.all).to eq(json_data)
      end

      it 'handles a missing file gracefully' do
        expect { ClientRepository.new('nonexistent.json') }
          .to output(/File not found/).to_stderr
          .and raise_error(SystemExit)
      end

      it 'handles invalid JSON gracefully' do
        File.write(file_path, 'invalid json')
        expect { ClientRepository.new(file_path) }
          .to output(/Invalid JSON/).to_stderr
          .and raise_error(SystemExit)
      end
    end

    context 'when loading from a URL' do
      it 'loads clients from a valid JSON URL' do
        stub_request(:get, url)
          .to_return(status: 200, body: JSON.generate(json_data))
        repo = ClientRepository.new(url)
        expect(repo.all).to eq(json_data)
      end

      it 'handles a failed HTTP request gracefully' do
        stub_request(:get, url)
          .to_return(status: 404, body: '')
        expect { ClientRepository.new(url) }
          .to output(/Failed to fetch data.*404/).to_stderr
          .and raise_error(SystemExit)
      end

      it 'handles invalid JSON gracefully' do
        stub_request(:get, url)
          .to_return(status: 200, body: 'invalid json')
        expect { ClientRepository.new(url) }
          .to output(/Invalid JSON/).to_stderr
          .and raise_error(SystemExit)
      end

      it 'handles network errors gracefully' do
        stub_request(:get, url)
          .to_raise(StandardError.new('Connection timed out'))
        expect { ClientRepository.new(url) }
          .to output(/Network issue.*Connection timed out/).to_stderr
          .and raise_error(SystemExit)
      end
    end
  end

  describe '#string_fields' do
    before do
      File.write(file_path, JSON.generate(json_data))
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
    end

    it 'returns all fields with string values' do
      repo = ClientRepository.new(file_path)
      expect(repo.string_fields).to contain_exactly('name', 'email', 'phone')
    end

    it 'returns an empty array if no string fields exist' do
      empty_data = [{ 'age' => 30, 'active' => true }]
      File.write(file_path, JSON.generate(empty_data))
      repo = ClientRepository.new(file_path)
      expect(repo.string_fields).to be_empty
    end
  end
end