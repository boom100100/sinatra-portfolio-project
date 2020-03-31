class ClientsController < ApplicationController
  post '/clients' do
    #user doesn't exist, email and pw fields not empty, pw confirmation matches
    if Client.find_by(email: params[:email]).nil? && params[:email] != '' && params[:password] != '' && params[:password] == params[:password_confirmation]
      client = Client.create(email: params[:email], password: params[:password])
      session[:user_id] = client.id
      session[:type] = 'client'
      session[:privilege] = 'client'
      erb :'clients/index'
    elsif !Client.find_by(email: params[:email]).nil?
      'This user already exists.'
    elsif params[:password] != ''
      'User must have a password.'
    elsif params[:password] == params[:password_confirmation]
      'Passwords for user must match.'
    else
      redirect '/signup'
    end
  end

  get '/clients' do
    @clients = Client.all
    erb :'clients/index'
  end

  get '/clients/:id' do
    @client = Client.find_by(id: params[:id])
    if session[:user_id]
      #if is self or is admin
      if (session[:user_id] == @client.id && session[:user_type].is_a?(Client)) || (session[:privilege] == 'admin')
        erb :'clients/show'
      else
        'Only the account owner or an admin can view this page.'
      end
    else
      'Only signed in users can view this page.'
    end
  end

  post '/clients/:id' do
    @client = Client.find_by(id: params[:id])
    #user exists, not replacing other user, email and pw fields not empty, pw confirmation matches
    if @client && Client.find_by(email: params[:email]).nil? && params[:email] != '' && params[:password] != '' && params[:password] == params[:password_confirmation]
      @client.email = params[:email]
    elsif @client.nil?
      'This user doesn\'t exist.'
    elsif !Client.find_by(email: params[:email]).nil?
      "Could not replace user already using email address #{params[:email]}."
    elsif params[:password] != ''
      'Password can\'t be empty.'
    elsif params[:password] == params[:password_confirmation]
      'Passwords don\'t match.'
    else
      redirect "/clients/#{params[:id]}"
    end
  end

  get '/clients/:id/edit' do
    @client = Client.find_by(id: params[:id])
    #user exists, visitor is self or admin
    if @client && ((@client.id == session[:user_id] && session[:type] == 'client') || session[:privilege] == 'admin')
      erb :'clients/edit'
    #visitor is not self or admin
    elsif @client.id != session[:user_id] && session[:privilege] != 'admin'
      'You cannot edit this user\'s account.'
    #user doesn't exist
    else
      'This is an invalid user.'
    end
  end

  get '/clients/new' do
    if session[:privilege] == 'admin'
      @client = Client.new
      erb 'clients/new'
    else
      redirect '/clients'
    end
  end
end
