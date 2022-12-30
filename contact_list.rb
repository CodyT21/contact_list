require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'

  set :erb, :escape_html => true
end

before do
  session[:contacts] ||= {}
end

# render index page
get '/' do
  @contacts = session[:contacts]
  erb :index
end