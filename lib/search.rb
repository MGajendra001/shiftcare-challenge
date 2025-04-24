class Search
  def self.by_name(clients, query)
    query_downcase = query.downcase
    clients.select do |client|
      name = client['full_name']
      name && name.downcase.include?(query_downcase)
    end
  end
end