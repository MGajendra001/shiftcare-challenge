require 'rspec'
require_relative '../lib/client_repository'
require 'json'

describe ClientRepository do
  let(:json_data) { [{ "name" => "Alice", "email" => "alice@example.com" }, { "name" => "Bob", "email" => "bob@example.com" }] }
  let(:file_path) { "test_clients.json" }

  before do
    File.write(file_path, JSON.generate(json_data))
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe "#all" do
    it "loads clients from a valid JSON file" do
      repo = ClientRepository.new(file_path)
      expect(repo.all).to eq(json_data)
    end

    it "handles a missing file gracefully" do
      expect { ClientRepository.new("nonexistent.json") }
        .to output(/File not found/).to_stderr
        .and raise_error(SystemExit)
    end

    it "handles invalid JSON gracefully" do
      File.write(file_path, "invalid json")
      expect { ClientRepository.new(file_path) }
        .to output(/Invalid JSON/).to_stderr
        .and raise_error(SystemExit)
    end
  end
end