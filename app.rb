require_relative 'lib/client_repository'
require_relative 'lib/search'
require_relative 'lib/duplicate_finder'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby app.rb [options] <command> [arguments]\n" \
                "Commands:\n" \
                "  search <field> <query> - Search clients by field (e.g., full_name, email)\n" \
                "  duplicates - <field>      Find duplicates by field (e.g., full_name, email)\n"

  opts.on('--source SOURCE', 'Specify JSON data source (file or URL)') do |source|
    options[:source] = source
  end
end.parse!

data_source = options[:source] || 'https://appassets02.shiftcare.com/manual/clients.json'
command = ARGV[0]

unless command
  puts "Error: No command provided."
  puts "Usage: ruby app.rb [options] <command> [arguments]"
  exit(1)
end

repository = ClientRepository.new(data_source)
clients = repository.all
search = Search.new(repository)
duplicate_finder = DuplicateFinder.new(repository)

def humanize(str)
  str.to_s.gsub('_', ' ').capitalize
end

case command
when 'search'
  if ARGV.size < 3
    puts "Error: Search requires a field and query (e.g., search full_name ali)."
    exit(1)
  end
  field = ARGV[1]
  query = ARGV[2]
  result = Search.by_field(clients, field, query)

  if result[:error]
    puts result[:error]
  elsif result[:results].empty?
    puts "No clients found matching '#{query}' in field '#{humanize(field)}'."
  else
    puts "Clients matching '#{query}' in field '#{field}':"
    puts format("%-5s %-25s %-30s", "ID", "Full Name", "Email")
    puts "-" * 65
    result[:results].each do |client|
      puts format("%-5s %-25s %-30s", client['id'], client['full_name'], client['email'])
    end
  end

when 'duplicates'
  if ARGV.size < 2
    puts "Error: Duplicates requires a field (e.g., duplicates email)."
    exit(1)
  end
  field = ARGV[1]
  begin
    duplicates = DuplicateFinder.find_by_field(clients, field)
  rescue ArgumentError => e
    puts "Error: #{e.message}"
    exit(1)
  end

  if duplicates.empty?
    puts "No duplicate #{humanize(field)}s found."
  else
    puts "Duplicate #{humanize(field)}s found:"
    duplicates.each do |field_value, group|
      puts "#{humanize(field)}: #{field_value}"
      puts
      puts format("%-5s %-25s %-30s", "ID", "Full Name", "Email")
      puts "-" * 65
      group.each { |client| puts format("%-5s %-25s %-30s", client['id'], client['full_name'], client['email']) }
      puts
    end
  end

else
  puts "Error: Unknown command '#{command}'."
  exit(1)
end