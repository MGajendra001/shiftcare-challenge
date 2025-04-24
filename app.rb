# app.rb
require_relative 'lib/client_repository'
require_relative 'lib/search'
require_relative 'lib/duplicate_finder'

if ARGV.empty?
  puts "Usage: ruby app.rb <command> [arguments]"
  puts "Commands:"
  puts "  search <query> - Search clients by name"
  puts "  duplicates     - Find clients with duplicate emails"
  exit(1)
end

command = ARGV[0]
repository = ClientRepository.new('clients.json')
clients = repository.all

case command
when 'search'
  if ARGV.size < 2
    puts "Error: Search query is required."
    exit(1)
  end
  query = ARGV[1]
  results = Search.by_name(clients, query)

  if results.empty?
    puts "No clients found matching '#{query}'."
  else
    puts "Clients matching '#{query}':"
    results.each { |client| puts "- #{client['full_name']} (#{client['email']})" }
  end

when 'duplicates'
  duplicates = DuplicateFinder.find_by_email(clients)

  if duplicates.empty?
    puts "No duplicate emails found."
  else
    puts "Duplicate emails found:"
    duplicates.each do |email, group|
      puts "Email: #{email}"
      group.each { |client| puts "- #{client['full_name']}" }
      puts
    end
  end

else
  puts "Error: Unknown command '#{command}'."
  exit(1)
end