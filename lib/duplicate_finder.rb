class DuplicateFinder
  def self.find_by_email(clients)
    email_groups = clients.group_by { |client| client['email'] }
    email_groups.select { |email, group| email && group.size > 1 }
  end
end