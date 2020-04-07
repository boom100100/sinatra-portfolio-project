class ConsultantsController < ApplicationController
  get '/consultants/?' do
    if session[:user_id]
      if session[:type] == 'consultant'
        @session_privilege = session[:privilege]
        @consultants = Consultant.all
        erb :'consultants/index'
      elsif session[:type] == 'client'
        erb 'Clients are unable to see this page.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end

  post '/consultants' do

    #user doesn't exist, email and pw fields not empty, pw confirmation matches
    if Consultant.find_by(email: params[:email]).nil? && email_and_pw_good?(params[:email], params[:password], params[:password_confirmation])
      consultant = Consultant.create(email: params[:email], admin: params[:admin], password: params[:password])
      session[:user_id] = consultant.id
      session[:type] = 'consultant'
      if consultant.admin
        session[:privilege] = 'admin'
      else
        session[:privilege] = 'consultant'
      end

      redirect '/consultants'

    elsif !Consultant.find_by(email: params[:email]).nil?
      erb 'This user already exists.'
    elsif params[:password] != ''
      erb 'Consultant must have a password.'
    elsif params[:password] == params[:password_confirmation]
      erb 'Passwords for consultant must match.'
    else
      redirect '/consultants'
    end

  end

  get '/consultants/new/?' do
    if session[:user_id]
      if session[:privilege] == 'admin'
        @consultant = Consultant.new
        erb :'consultants/new'
      else
        erb 'Only an admin can view this page.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end

  get '/consultants/:id/?' do
    @consultant = Consultant.find_by(id: params[:id])
    if @consultant

      if session[:user_id]
        #visitor is self or is admin
        @edit_access = session[:privilege] == 'consultant' && session[:user_id] == @consultant.id

        if @edit_access || session[:type] == 'consultant'
          @session_privilege = session[:privilege]
          erb :'consultants/show'
        else
          erb 'Only a consultant can view this page.'
        end
      else
        erb 'Only signed in users can view this page.'
      end
    else
      erb 'Consultant doesn\'t exist.'
    end
  end

  post '/consultants/:id' do
    @consultant = Consultant.find_by(id: params[:id])

    if @consultant
      #visitor is self or admin, not duplicating email, email and pw fields not empty, pw confirmation matches
      if self_or_admin?(@consultant.id, session[:type], 'consultant', session[:privilege]) && (Consultant.find_by(email: params[:email]).nil? || Consultant.find_by(email: params[:email]) == @consultant) && email_and_pw_good?(params[:email], params[:password], params[:password_confirmation])
        @consultant.email = params[:email]
        params[:account_type] ? (params[:account_type] == 'admin' ? @consultant.admin = true : @consultant.admin = false) : nil
        @consultant.password = params[:password]
        @consultant.save
        redirect "/consultants/#{params[:id]}"

      #email not taken, is current user or doesn't exist, no password
      elsif !email_empty?(params[:email]) && (Consultant.find_by(email: params[:email]).nil? || Consultant.find_by(email: params[:email]) == @consultant) && params[:password] == ''
        @consultant.email = params[:email]
        params[:account_type] == 'admin' ? @consultant.admin = true : @consultant.admin = false
        @consultant.save
        redirect "/consultants/#{params[:id]}"
      elsif @consultant.nil?
        erb 'This consultant doesn\'t exist.'
      elsif !Consultant.find_by(email: params[:email]).nil?
        erb "Could not replace consultant already using email address #{params[:email]}."
      elsif params[:password] != ''
        erb 'Password can\'t be empty.'
      elsif params[:password] == params[:password_confirmation]
        erb 'Passwords don\'t match.'
      else
        redirect "/consultants/#{params[:id]}"
      end
    else
      erb 'Consultant doesn\'t exist.'
    end
  end

  get '/consultants/:id/edit/?' do
    @consultant = Consultant.find_by(id: params[:id])

    if session[:user_id]
      #user exists, visitor is self or admin
      if @consultant && self_or_admin?(@consultant.id, session[:type], 'consultant', session[:privilege])
        @session_privilege = session[:privilege]
        erb :'consultants/edit'
      elsif @consultant.id != session[:user_id] && session[:privilege] != 'admin'
        erb 'You cannot edit this user\'s account.'
      #user doesn't exist
      else
        erb 'This is an invalid user.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end

  delete '/consultants/:id' do # TODO:
    if session[:user_id]
      @consultant = Consultant.find_by(id: params[:id])
      if @consultant
        id = @consultant.id
        if self_or_admin?(id, session[:type], 'consultant', session[:privilege])
          @consultant.destroy
          if is_self?(id, session[:privilege], 'consultant')
            redirect '/login'
          else
            redirect '/consultants'
          end
        else
          erb 'Only the account owner or an admin can view this page.'
        end
      else
        erb 'This user doesn\'t exist.'
      end
    else
      erb 'Only signed in users can view this page.'
    end
  end

  private
  def is_self?(id, session_type, type_comparison)
    (id == session[:user_id] && session_type == type_comparison)
  end

  def self_or_admin?(id, session_type, type_comparison, session_privilege)
    is_self?(id, session_type, type_comparison) || session_privilege == 'admin'
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
