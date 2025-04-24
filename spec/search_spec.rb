require 'spec_helper'
require_relative '../lib/search'

describe Search do
  let(:clients) do
    [
      { 'full_name' => 'Alice', 'email' => 'alice@example.com' },
      { 'full_name' => 'Bob', 'email' => 'bob@example.com' },
      { 'full_name' => 'Alicia', 'email' => 'alicia@example.com' },
      { 'full_name' => nil, 'email' => 'noname@example.com' }
    ]
  end

  it 'finds clients with partial name match' do
    results = Search.by_name(clients, 'ali')
    expect(results.size).to eq(2)
    expect(results.map { |c| c['full_name'] }).to include('Alice', 'Alicia')
  end

  it 'is case-insensitive' do
    results = Search.by_name(clients, 'ALI')
    expect(results.size).to eq(2)
  end

  it 'returns empty array if no match' do
    results = Search.by_name(clients, 'xyz')
    expect(results).to be_empty
  end

  it 'handles empty query' do
    results = Search.by_name(clients, '')
    expect(results.size).to eq(3)
  end

  it 'handles clients with missing name' do
    results = Search.by_name(clients, 'bob')
    expect(results.size).to eq(1)
    expect(results.first['full_name']).to eq('Bob')
  end
end