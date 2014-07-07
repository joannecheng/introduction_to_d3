require 'sinatra'

set :views, Proc.new { File.join(root, "templates") }

get '/' do
  erb :index
end
