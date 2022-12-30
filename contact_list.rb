require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'

  set :erb, :escape_html => true
end

before do
  session[:contacts] ||= []
end

# render index page
get '/' do
  redirect '/contacts'
end

get '/contacts' do
  @contacts = session[:contacts]
  erb :index
end

# render new contact page
get '/contacts/new' do
  erb :new_contact
end

# create new contact
post '/contacts' do
  fname = params[:first_name]
  lname = params[:last_name]
  phone = params[:phone_number]
  email = params[:email_address]

  session[:contacts] << {
                          first_name: fname,
                          last_name: lname,
                          phone_number: phone,
                          email_address: email
                        }
  session[:message] = 'The contact has been created successfully.'
  redirect '/contacts'
end