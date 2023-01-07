require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

require_relative 'database_persistance'

configure do
  enable :sessions
  set :session_secret, 'secret'

  set :erb, :escape_html => true
end

def valid_contact?(*contact_info)
  if !valid_name?(first_name)
    'First Name must only contain between 1 and 100 alphanumeric characters.'
  elsif !valid_name?(last_name)
    'Last Name must only contain between 1 and 100 alphanumeric characters.'
  elsif !valid_phone_number?(phone_number)
    'Phone Number must only contains between 10 and 11 digits.'
  elsif !valid_email?(email_address)
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

def sort_contacts_by_group(contacts, &block)
  contacts.each { |contact| block.call(contact) }
end

before do
  # session[:contacts] ||= []
  @storage = DatabasePeristance.new(logger)
end

# render index page
get '/' do
  redirect '/contacts'
end

get '/contacts' do
  # @contacts = session[:contacts]
  @contacts = @storage.all_contacts
  erb :index
end

# render new contact page
get '/contacts/new' do
  erb :new_contact
end

# create new contact
post '/contacts' do
  first_name = params[:first_name].strip
  last_name = params[:last_name].strip
  phone_number = params[:phone_number].strip
  email_address = params[:email_address].strip
  group = params[:group_name] == '' ? nil : params[:group_name]

  # contact = { first_name: fname, last_name: lname,
  #             phone_number: phone, email_address: email,
  #             group_name: group }
  error = valid_contact?(first_name, last_name, phone_number, email_address)

  if error
    session[:message] = error
    erb :new_contact
  else
    # session[:contacts] << contact
    @storage.create_new_contact(first_name, last_name, phone_number, email_address, group)
    session[:message] = 'The contact has been created successfully.'
    redirect '/contacts'
  end
end

# delete contact from contact list
post '/contacts/:contact_id/destroy' do
  contact_id = params[:contact_id].to_i
  # session[:contacts].delete_at(contact_id)
  @storage.delete_contact_at_id(contact_id)
  session[:message] = 'The contact has been deleted.'

  redirect '/contacts'
end

# render edit contact page
get '/contacts/:contact_id/edit' do
  @contact_id = params[:contact_id].to_i
  # @contact = session[:contacts][@contact_id]
  @contact = @storage.find_contact(@contact_id)

  erb :edit_contact
end

# update contact info
post '/contacts/:contact_id' do
  @contact_id = params[:contact_id].to_i
  # @contact = session[:contacts][@contact_id]
  @contact = @storage.find_contact(@contact_id)

  first_name = params[:first_name].strip
  last_name = params[:last_name].strip
  phone_number = params[:phone_number].strip
  email_address = params[:email_address].strip
  group = params[:group_name] == '' ? nil : params[:group_name]

  error = valid_contact?(first_name, last_name, phone_number, email_address)

  if error
    session[:message] = error
    erb :edit_contact
  else
    # session[:contacts][@contact_id] = updated_contact
    @storage.update_contact(@contact_id, first_name, last_name, phone_number, email_address, group)
    session[:message] = 'The contact has been updated successfully.'
    redirect '/contacts'
  end
end

# render contacts group page
get '/contacts/groups' do
  # contacts_with_groups = session[:contacts].select { |contact| contact[:group_name] }
  # @group_names = contacts_with_groups.each_with_object([]) do |contact, arr|
  #   arr << contact[:group_name] unless arr.include?(contact[:group_name])
  # end
  @group_names = @storage.all_group_names

  erb :contact_groups
end
