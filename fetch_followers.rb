require 'faraday'

"USAGE: fetch_followers.rb USERNAME [--depth NUMBER]"

followers_url = "https://api.github.com/users/#{username}/followers"
