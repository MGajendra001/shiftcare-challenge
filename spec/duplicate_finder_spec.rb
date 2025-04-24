require 'spec_helper'
require_relative '../lib/duplicate_finder'

describe DuplicateFinder do
  let(:clients) do
    [
      { 'name' => 'Alice', 'email' => 'alice@example.com' },
      { 'name' => 'Bob', 'email' => 'bob@example.com' },
      { 'name' => 'Charlie', 'email' => 'alice@example.com' },
      { 'name' => 'No Email', 'email' => nil }
    ]
  end

  it 'finds duplicates by email' do
    duplicates = DuplicateFinder.find_by_email(clients)
    expect(duplicates.size).to eq(1)
    expect(duplicates['alice@example.com'].size).to eq(2)
    expect(duplicates['alice@example.com'].map { |c| c['name'] }).to include('Alice', 'Charlie')
  end

  it 'returns empty hash if no duplicates' do
    no_duplicates = [
      { 'name' => 'Alice', 'email' => 'alice@example.com' },
      { 'name' => 'Bob', 'email' => 'bob@example.com' }
    ]
    duplicates = DuplicateFinder.find_by_email(no_duplicates)
    expect(duplicates).to be_empty
  end

  it 'excludes clients with missing email from duplicates' do
    duplicates = DuplicateFinder.find_by_email(clients)
    expect(duplicates.key?(nil)).to be false
  end
end