require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'

  set :erb, :escape_html => true
end

def valid_contact?(contact)
  if !valid_name?(contact[:first_name])
    'First Name must only contain between 1 and 100 alphanumeric characters.'
  elsif !valid_name?(contact[:last_name])
    'Last Name must only contain between 1 and 100 alphanumeric characters.'
  elsif !valid_phone_number?(contact[:phone_number])
    'Phone Number must only contains between 10 and 11 digits.'
  elsif !valid_email?(contact[:email_address])
    'Email Address must be a valid email address.'
  end
end

def valid_name?(name)
  name =~ /^[\w]{1,100}$/
end

def valid_phone_number?(number)
  number =~ /^\d{10,11}$/
end

def valid_email?(email)
  email =~ /@.+\..+/
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
  fname = params[:first_name].strip
  lname = params[:last_name].strip
  phone = params[:phone_number].strip
  email = params[:email_address].strip

  contact = {first_name: fname, last_name: lname, phone_number: phone, email_address: email}
  error = valid_contact?(contact)
  
  if error
    session[:message] = error
    erb :new_contact
  else
    session[:contacts] << contact
    session[:message] = 'The contact has been created successfully.'
    redirect '/contacts'
  end
end

# delete contact fromn contact list
post '/contacts/:contact_id/destroy' do
  contact_id = params[:contact_id].to_i
  session[:contacts].delete_at(contact_id)
  session[:message] = 'The contact has been deleted.'

  redirect '/contacts'
end