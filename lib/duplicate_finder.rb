require 'set'

class DuplicateFinder
  def initialize(repository)
    @repository = repository
    define_duplicate_methods
  end

  def self.find_by_field(clients, field)
    raise ArgumentError, "Field cannot be empty" unless field
    clients.group_by { |client| client[field] }
           .select { |key, group| key && group.size > 1 }
  end

  private

  def define_duplicate_methods
    fields = @repository.string_fields
    fields.each do |field|
      define_singleton_method("find_by_#{field}") do |clients|
        DuplicateFinder.find_by_field(clients, field)
      end
    end
  end
end