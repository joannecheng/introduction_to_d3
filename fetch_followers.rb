require 'faraday'
require 'json'
require 'pry'

if ARGV.count < 1
  puts "USAGE: fetch_following.rb"
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
      following: @github_user.following_users
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

  def following_users
    following.usernames_and_counts
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
    body.map { |b| b["login"]}
  end

  def users
    @users ||= logins.map do |login|
      GithubUser.new(login)
    end
  end

  def usernames_and_counts
    users.map do |user|
      puts user.public_repos
      puts user.username
      {
        username: user.username,
        public_repos: user.public_repos,
      }
    end
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

#output_formatted = JSON.parse open("output.json").read
#all_usernames = output_formatted.map { |o| [o["username"], o["following"]] }.flatten.uniq
