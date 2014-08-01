require 'faraday'
require 'json'
require 'pry'

if ARGV.count < 1
  puts "USAGE: fetch_following.rb USERNAME [--depth NUMBER]"
  exit
end


class OutputFormatter
  def initialize(github_user)
    @github_user = github_user
  end

  def output
    {
      username: @github_user.username,
      public_repos: @github_user.public_repos,
      following: @github_user.following_usernames
    }
  end
end

class GithubUser
  attr_reader :username

  def initialize(username)
    @token = ENV['GITHUB_ACCESS_TOKEN']
    @username = username
  end

  def public_repos
    body["public_repos"]
  end

  def following_usernames
    following.logins
  end

  private

  def following
    @following ||= GithubUserFollowing.new(username, total_following)
  end

  def body
    @body ||= JSON.parse Faraday.get(url).body
  end

  def total_following
    @total_following ||= body["following"]
  end

  def url
    "https://api.github.com/users/#{username}?access_token=#{@token}"
  end
end

class GithubUserFollowing
  def initialize(username, total_following)
    @token = ENV['GITHUB_ACCESS_TOKEN']
    @username = username
    body
  end

  def body
    @body ||= JSON.parse Faraday.get(url).body
  end

  def logins
    @body.map { |b| b["login"]}
  end

  def user_urls
    @body.map { |b| b["url"]}
  end

  def url
    "https://api.github.com/users/#{username}/following?per_page=100&access_token=#{@token}"
  end

  private
  attr_reader :username, :login, :user_url
end

output = []
username = ARGV[0]

github_user = GithubUser.new(username)
o = OutputFormatter.new github_user

output << o.output

github_user.following_usernames.each do |following_user|
  github_user = GithubUser.new(following_user)
  o = OutputFormatter.new github_user
  output << o.output
end

puts output.to_json