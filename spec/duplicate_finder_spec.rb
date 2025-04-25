require 'spec_helper'
require_relative '../lib/duplicate_finder'
require_relative '../lib/client_repository'

describe DuplicateFinder do
  let(:clients) do
    [
      { 'name' => 'Alice', 'email' => 'alice@example.com', 'phone' => '123-456-7890', 'age' => 30 },
      { 'name' => 'Bob', 'email' => 'alice@example.com', 'phone' => '987-654-3210', 'age' => 25 },
      { 'name' => 'Charlie', 'email' => 'charlie@example.com', 'phone' => '123-456-7890', 'age' => 30 },
      { 'name' => 'David', 'email' => nil, 'phone' => nil, 'age' => 40 },
      { 'name' => 'Eve', 'email' => 'eve@example.com', 'phone' => '', 'age' => 28 }
    ]
  end
  let(:repository) { instance_double(ClientRepository, all: clients, string_fields: ['name', 'email', 'phone']) }
  let(:finder) { DuplicateFinder.new(repository) }

  describe '.find_by_field' do
    it 'finds duplicates by email' do
      result = DuplicateFinder.find_by_field(clients, 'email')
      expect(result.keys).to contain_exactly('alice@example.com')
      expect(result['alice@example.com'].map { |c| c['name'] }).to contain_exactly('Alice', 'Bob')
    end

    it 'finds duplicates by phone' do
      result = DuplicateFinder.find_by_field(clients, 'phone')
      expect(result.keys).to contain_exactly('123-456-7890')
      expect(result['123-456-7890'].map { |c| c['name'] }).to contain_exactly('Alice', 'Charlie')
    end

    it 'excludes nil values from duplicates' do
      result = DuplicateFinder.find_by_field(clients, 'email')
      expect(result).not_to have_key(nil)
    end

    it 'excludes empty strings from duplicates' do
      result = DuplicateFinder.find_by_field(clients, 'phone')
      expect(result).not_to have_key('')
    end

    it 'returns empty hash if no duplicates' do
      result = DuplicateFinder.find_by_field(clients, 'name')
      expect(result).to be_empty
    end

    it 'handles non-string fields gracefully' do
      result = DuplicateFinder.find_by_field(clients, 'age')
      expect(result.keys).to contain_exactly(30)
      expect(result[30].map { |c| c['name'] }).to contain_exactly('Alice', 'Charlie')
    end

    it 'returns empty hash for empty client list' do
      result = DuplicateFinder.find_by_field([], 'email')
      expect(result).to be_empty
    end
  end

  describe 'dynamic duplicate methods' do
    it 'defines find_by methods for all string fields' do
      expect(finder).to respond_to(:find_by_name)
      expect(finder).to respond_to(:find_by_email)
      expect(finder).to respond_to(:find_by_phone)
      expect(finder).not_to respond_to(:find_by_age)

      result = finder.find_by_email(clients)
      expect(result.keys).to contain_exactly('alice@example.com')
      expect(result['alice@example.com'].map { |c| c['name'] }).to contain_exactly('Alice', 'Bob')

      result = finder.find_by_phone(clients)
      expect(result.keys).to contain_exactly('123-456-7890')
      expect(result['123-456-7890'].map { |c| c['name'] }).to contain_exactly('Alice', 'Charlie')

      result = finder.find_by_name(clients)
      expect(result).to be_empty
    end

    it 'defines no methods if no string fields exist' do
      allow(repository).to receive(:string_fields).and_return([])
      finder = DuplicateFinder.new(repository)
      expect(finder).not_to respond_to(:find_by_name)
      expect(finder).not_to respond_to(:find_by_email)
      expect(finder).not_to respond_to(:find_by_phone)
    end

    it 'defines methods based on repository string fields' do
      allow(repository).to receive(:string_fields).and_return(['custom_field'])
      finder = DuplicateFinder.new(repository)
      expect(finder).to respond_to(:find_by_custom_field)
      expect(finder).not_to respond_to(:find_by_email)

      clients_with_custom = [
        { 'custom_field' => 'value1' },
        { 'custom_field' => 'value1' },
        { 'custom_field' => 'value2' }
      ]
      result = finder.find_by_custom_field(clients_with_custom)
      expect(result.keys).to contain_exactly('value1')
      expect(result['value1'].size).to eq(2)
    end
  end
end