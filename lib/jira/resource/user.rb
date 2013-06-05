module JIRA
  module Resource

    class UserFactory < JIRA::BaseFactory # :nodoc:
    end

    class User < JIRA::Base
      def self.singular_path(client, key, prefix = '/')
        # produces path like /rest/api/2/user?username=KEY
        collection_path(client, prefix) + '?username=' + key
      end

      def self.search_path(client, key)
        '/rest/api/2/user/search?username=' + key
      end

      def self.search(client, search_string, email_filter='')
        path = self.search_path(client, search_string)
        response = client.get(path)
        json = parse_json(response.body)
        users = json.map do |user|
          if user['emailAddress'].match(email_filter)
            client.User.build(user)
          end
        end
        # remove nils that result from filtering above
        return users.compact
      end

      # this is the easiest way to get this data...
      # no single API exists for getting it
      def self.all(client, email_filter='')
        users = []
        ('a'..'z').each do |letter|
          temp_users = self.search(client, letter, email_filter)
          users = users + temp_users
        end
        return users
      end

    end

  end
end
