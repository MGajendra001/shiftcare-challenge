require 'json'

class ClientRepository
  def initialize(file_path)
    @file_path = file_path
    @clients = load_clients
  end

  def all
    @clients
  end

  private

  def load_clients
    data = File.read(@file_path)
    JSON.parse(data)
  rescue Errno::ENOENT
    puts "Error: File not found: #{@file_path}"
    exit(1)
  rescue JSON::ParserError
    puts "Error: Invalid JSON in file: #{@file_path}"
    exit(1)
  end
end