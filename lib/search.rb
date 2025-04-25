class Search

  def initialize(repository)
    @repository = repository
    define_search_methods
  end

  def self.by_field(clients, field, query)
    unless clients.any? { |client| client.key?(field) }
      return { error: "Field '#{field}' not found in any client data" }
    end

    query_downcase = query.is_a?(String) ? query.downcase : query
    results = clients.select do |client|
      value = client[field]
      if value.is_a?(String)
        value.downcase.include?(query_downcase)
      elsif value.is_a?(Integer)
        value.to_i == query_downcase.to_i
      end
    end

    { results: results }
  end

  # Dynamically define search methods for common fields
  def define_search_methods
    fields = @repository.string_fields
    fields.each do |field|
      define_singleton_method("search_by_#{field}") do |clients, query|
        Search.by_field(clients, field, query)
      end
    end
  end
end