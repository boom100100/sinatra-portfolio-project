class ConsultantsController < ApplicationController
  post '/consultants' do
    #user doesn't exist, email and pw fields not empty, pw confirmation matches
    if Consultant.find_by(email: params[:email]).nil? && params[:email] != '' && params[:password] != '' && params[:password] == params[:password_confirmation]
      consultant = Consultant.create(email: params[:email], password: params[:password])
      session[:user_id] = consultant.id
      session[:type] = 'consultant'
      consultant.admin ? session[:privilege] = 'admin' : session[:privilege] = 'agent'
      erb :'consultants/index'
    elsif !Consultant.find_by(email: params[:email]).nil?
      'This user already exists.'
    elsif params[:password] != ''
      'User must have a password.'
    elsif params[:password] == params[:password_confirmation]
      'Passwords for user must match.'
    else
      redirect '/signup'
    end
  end

  get '/consultants' do
    @consultants = Consultant.all
    erb :'consultants/index'
  end

  get '/consultants/:id' do
    @consultant = Consultant.find_by(id: params[:id])
    if session[:user_id]
      #if is self or is admin
      if (session[:user_id] == @consultant.id && session[:user_type].is_a?(Consultant)) || (session[:privilege] == 'admin')
        erb :'consultants/show'
      else
        'Only the account owner or an admin can view this page.'
      end
    else
      'Only signed in users can view this page.'
    end
  end

  post '/consultants/:id' do
    @consultant = Consultant.find_by(id: params[:id])
    #user exists, not replacing other user, email and pw fields not empty, pw confirmation matches
    if @consultant && Consultant.find_by(email: params[:email]).nil? && params[:email] != '' && params[:password] != '' && params[:password] == params[:password_confirmation]
      @consultant.email = params[:email]
    elsif @consultant.nil?
      'This user doesn\'t exist.'
    elsif !Consultant.find_by(email: params[:email]).nil?
      "Could not replace user already using email address #{params[:email]}."
    elsif params[:password] != ''
      'Password can\'t be empty.'
    elsif params[:password] == params[:password_confirmation]
      'Passwords don\'t match.'
    else
      redirect "/consultants/#{params[:id]}"
    end
  end

  get '/consultants/:id/edit' do
    @consultant = Consultant.find_by(id: params[:id])
    #user exists, visitor is self or admin
    if @consultant && ((@consultant.id == session[:user_id] && session[:type] == 'consultant') || session[:privilege] == 'admin')
      erb :'consultants/edit'
    #visitor is not self or admin
    elsif @consultant.id != session[:user_id] && session[:privilege] != 'admin'
      'You cannot edit this user\'s account.'
    #user doesn't exist
    else
      'This is an invalid user.'
    end
  end

  get '/consultants/new' do
    if session[:privilege] == 'admin'
      @consultant = Consultant.new
      erb 'consultants/new'
    else
      redirect '/consultants'
    end
  end
end
