require 'minitest/autorun'
require 'rack/test'

require_relative '../contact_list'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def create_contact(first, last, phone, email)
    contact = {first_name: first, 
               last_name: last, 
               phone_number: phone.to_s, 
               email_address: email
              }
    session[:contacts] << [contact]
  end

  def session
    last_request.env['rack.session']
  end

  def app
    Sinatra::Application
  end

  def test_index
    get '/'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'New Contact'
  end

  def test_new_contact_form
    get '/contacts/new'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<input'
    assert_includes last_response.body, %q(<input type="submit")
  end

  def test_create_new_contact
    post '/contacts', { first_name: 'First', last_name: 'Last', 
                        phone_number: '1234567890', email_address: 'email@email.com'
                      }
    assert_equal 302, last_response.status
    assert_equal 'The contact has been created successfully.', session[:message]
    
    get '/contacts'
    assert_includes last_response.body, 'First Last'
    assert_includes last_response.body, '1234567890'
    assert_includes last_response.body, 'email@email.com'
  end

  def test_invalid_first_name_new_contact
    post '/contacts', { first_name: '', last_name: 'Last', 
                        phone_number: '1234567890', email_address: 'email@email.com'
                      }
    assert_includes last_response.body, 'First Name must only contain between 1 and 100 alphanumeric characters.'
  end
  
  def test_invalid_last_name_new_contact
    post '/contacts', { first_name: 'First', last_name: 'Last@#', 
                        phone_number: '1234567890', email_address: 'email@email.com'
                      }
    assert_includes last_response.body, 'Last Name must only contain between 1 and 100 alphanumeric characters.'
  end

  def test_invalid_phone_too_many_digits
    post '/contacts', { first_name: 'First', last_name: 'Last', 
                        phone_number: '123456789011', email_address: 'email@email.com'
                      }
    assert_includes last_response.body, 'Phone Number must only contains between 10 and 11 digits.'
  end

  def test_invalid_phone_too_many_digits
    post '/contacts', { first_name: 'First', last_name: 'Last', 
                        phone_number: '12345678901', email_address: 'emailemailcom'
                      }
    assert_includes last_response.body, 'Email Address must be a valid email address.'
  end
end
