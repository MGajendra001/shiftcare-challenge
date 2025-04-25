require 'json'
require 'net/http'
require 'uri'
require 'set'

class ClientRepository
  def initialize(data_source)
    @data_source = data_source
    @clients = load_clients
  end

  def all
    @clients
  end

  def string_fields
    fields = Set.new
    @clients.each do |client|
      client.each_key do |key|
        fields << key if client[key].is_a?(String)
      end
    end
    fields.to_a
  end

  private

  def load_clients
    if @data_source.start_with?('http://', 'https://')
      load_from_url
    else
      load_from_file
    end
  end

  def load_from_url
    uri = URI(@data_source)
    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      $stderr.puts "Error: Failed to fetch data from #{@data_source} (Status: #{response.code})"
      exit(1)
    end
    JSON.parse(response.body)
  rescue JSON::ParserError
    $stderr.puts "Error: Invalid JSON received from #{@data_source}"
    exit(1)
  rescue StandardError => e
    $stderr.puts "Error: Network issue while fetching data from #{@data_source} (#{e.message})"
    exit(1)
  end

  def load_from_file
    data = File.read(@data_source)
    JSON.parse(data)
  rescue Errno::ENOENT
    $stderr.puts "Error: File not found: #{@data_source}"
    exit(1)
  rescue JSON::ParserError
    $stderr.puts "Error: Invalid JSON in file: #{@data_source}"
    exit(1)
  end
end