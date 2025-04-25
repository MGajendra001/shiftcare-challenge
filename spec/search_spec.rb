require 'spec_helper'
require_relative '../lib/search'
require_relative '../lib/client_repository'

describe Search do
  let(:clients) do
    [
      { 'name' => 'Alice', 'email' => 'alice@example.com', 'phone' => '123-456-7890', 'age' => 30 },
      { 'name' => 'Bob', 'email' => 'bob@example.com', 'phone' => '987-654-3210', 'age' => 25 },
      { 'name' => 'Alicia', 'email' => 'alicia@example.com', 'phone' => '555-555-5555', 'age' => 28 },
      { 'name' => nil, 'email' => 'noname@example.com', 'phone' => nil, 'age' => 40 }
    ]
  end
  let(:repository) { instance_double(ClientRepository, all: clients, string_fields: ['name', 'email', 'phone']) }
  let(:search) { Search.new(repository) }

  describe '.by_field' do
    it 'finds clients with partial match in the specified field' do
      result = Search.by_field(clients, 'name', 'ali')
      expect(result[:results].size).to eq(2)
      expect(result[:results].map { |c| c['name'] }).to include('Alice', 'Alicia')
    end

    it 'searches case-insensitively' do
      result = Search.by_field(clients, 'name', 'ALI')
      expect(result[:results].size).to eq(2)
    end

    it 'returns empty results if no match' do
      result = Search.by_field(clients, 'name', 'xyz')
      expect(result[:results]).to be_empty
    end

    it 'handles empty query' do
      result = Search.by_field(clients, 'name', '')
      expect(result[:results].size).to eq(3) # All clients with names
    end

    it 'handles clients with missing or non-string field values' do
      result = Search.by_field(clients, 'phone', '555')
      expect(result[:results].size).to eq(1)
      expect(result[:results].first['name']).to eq('Alicia')
    end

    it 'returns an error if the field does not exist' do
      result = Search.by_field(clients, 'address', 'test')
      expect(result[:error]).to eq("Field 'address' not found in any client data")
    end
  end

  describe 'dynamic search methods' do
    it 'defines search methods for all string fields' do
      expect(search).to respond_to(:search_by_name)
      expect(search).to respond_to(:search_by_email)
      expect(search).to respond_to(:search_by_phone)
      expect(search).not_to respond_to(:search_by_age)

      result = search.search_by_name(clients, 'ali')
      expect(result[:results].size).to eq(2)
      expect(result[:results].map { |c| c['name'] }).to include('Alice', 'Alicia')

      result = search.search_by_email(clients, 'alice')
      expect(result[:results].size).to eq(1)
      expect(result[:results].map { |c| c['email'] }).to include('alice@example.com')

      result = search.search_by_phone(clients, '555')
      expect(result[:results].size).to eq(1)
      expect(result[:results].first['name']).to eq('Alicia')
    end

    it 'defines no methods if no string fields exist' do
      allow(repository).to receive(:string_fields).and_return([])
      search = Search.new(repository)
      expect(search).not_to respond_to(:search_by_name)
      expect(search).not_to respond_to(:search_by_email)
    end
  end
end