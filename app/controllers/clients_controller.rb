class ClientsController < ApplicationController
  get '/clients' do
    if session[:user_id]
      @session_type = session[:type]
      @clients = Client.all
      erb :'clients/index'
    else
      erb 'You must sign in to view this page.'
    end
  end

  post '/clients' do
    #user doesn't exist, email and pw fields not empty, pw confirmation matches
    if Client.find_by(email: params[:email]).nil? && email_and_pw_good?(params[:email], params[:password], params[:password_confirmation])
      client = Client.create(email: params[:email], password: params[:password])
      session[:user_id] = client.id
      session[:type] = 'client'
      session[:privilege] = 'client'
      redirect '/clients'
    elsif !Client.find_by(email: params[:email]).nil?
      erb 'This client already exists.'
    elsif params[:password] != ''
      erb 'Client must have a password.'
    elsif params[:password] == params[:password_confirmation]
      erb 'Passwords for client must match.'
    else
      redirect '/clients'
    end
  end

  get '/clients/new' do
    if session[:privilege] == 'admin'
      @client = Client.new
      erb :'clients/new'
    else
      redirect '/clients'
    end
  end

  get '/clients/:id' do
    @client = Client.find_by(id: params[:id])
    if @client
      @tickets = Ticket.all.select {|ticket| ticket.client_id == @client.id }
      if session[:user_id]
        #visitor is self or consultant
        if self_or_admin?(@client.id, session[:privilege], 'client') || session[:type] == 'consultant'
          @session_privilege = session[:privilege]
          erb :'clients/show'
        else
          erb 'Only the account owner or an admin can view this page.'
        end
      else
        erb 'Only signed in users can view this page.'
      end
    else
      erb 'Client doesn\'t exist.'
    end
  end

  post '/clients/:id' do
    @client = Client.find_by(id: params[:id])

    if @client
      #visitor is self or admin, not duplicating email, email and pw fields not empty, pw confirmation matches
      @new_client = Client.find_by(email: params[:email])
      if self_or_admin?(@client.id, session[:privilege], 'client') && (@new_client.nil? || @new_client == @client) && email_and_pw_good?(params[:email], params[:password], params[:password_confirmation])
        @client.email = params[:email]
        @client.password = params[:password]
        @client.save
        redirect "/clients/#{params[:id]}"

      #email not taken, no password
      elsif !email_empty?(params[:email]) && Client.find_by(email: params[:email]).nil? && params[:password] == ''
        @client.email = params[:email]
        @client.save
        redirect "/clients/#{params[:id]}"
      elsif @client.nil?
        erb 'This client doesn\'t exist.'
      elsif !Client.find_by(email: params[:email]).nil?
        erb "Could not replace client already using email address #{params[:email]}."
      elsif params[:password] != ''
        erb 'Password can\'t be empty.'
      elsif params[:password] == params[:password_confirmation]
        erb 'Passwords don\'t match.'
      else
        redirect "/clients/#{params[:id]}"
      end
    else
      erb 'Client doesn\'t exist.'
    end
  end

  get '/clients/:id/edit' do
    @client = Client.find_by(id: params[:id])
    #user exists, visitor is self or admin
    if @client && self_or_admin?(@client.id, session[:privilege], 'client')
      erb :'clients/edit'
    elsif @client.id != session[:user_id] && session[:privilege] != 'admin'
      erb 'You cannot edit this user\'s account.'
    #user doesn't exist
    else
      erb 'This is an invalid user.'
    end
  end

  delete '/clients/:id' do
    if session[:user_id]
      @client = Client.find_by(id: params[:id])
      id = @client.id
      if @client && self_or_admin?(id, session[:privilege], 'client')
        @client.destroy
        if is_self?(id, session[:privilege], 'client')
          redirect '/login'
        else
          redirect '/clients'
        end
      else
        erb 'Only the account owner or an admin can view this page.'
      end
    else
      erb 'Only signed in users can view this page.'
    end
  end

  private
  def is_self?(id, session_privilege, privilege_comparison)
    (id == session[:user_id] && session_privilege == privilege_comparison)
  end

  def self_or_admin?(id, session_privilege, privilege_comparison)
    is_self?(id, session_privilege, privilege_comparison) || session_privilege == 'admin'
  end

  def email_empty?(email)
    email == ''
  end
  def password_check?(password, password_confirmation)
    password != '' && password == password_confirmation
  end

  def email_and_pw_good?(email, password, password_confirmation)
    !email_empty?(email) && password_check?(password, password_confirmation)
  end
end
