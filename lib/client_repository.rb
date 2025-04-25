require 'json'
require 'net/http'
require 'uri'

class ClientRepository
  DATA_URL = 'https://appassets02.shiftcare.com/manual/clients.json'.freeze

  def initialize
    @clients = load_clients
  end

  def all
    @clients
  end

  private

  def load_clients
    uri = URI(DATA_URL)
    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      $stderr.puts "Error: Failed to fetch data from #{DATA_URL} (Status: #{response.code})"
      exit(1)
    end
    JSON.parse(response.body)
  rescue JSON::ParserError
    $stderr.puts "Error: Invalid JSON received from #{DATA_URL}"
    exit(1)
  rescue StandardError => e
    $stderr.puts "Error: Network issue while fetching data from #{DATA_URL} (#{e.message})"
    exit(1)
  end
end