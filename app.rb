require 'sinatra'
require 'csv'
require 'json'

set :views, Proc.new { File.join(root, "templates") }

get '/' do
  erb :index
end

get '/count_per_day.json' do
  headers "Content-Type" => "application/json"

  index = 0
  [54, 15, 25, 30, 90, 81, 60, 10, 86, 6].map do |value|
    index += 1
    {
      timestamp: Time.new(2014, 7, index).to_i*1000,
      value: value
    }
  end.to_json
end
