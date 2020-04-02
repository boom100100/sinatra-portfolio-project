require './config/environment'

class ApplicationController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'

    enable :sessions
    set :session_secret, 'password_security'
  end

  get '/' do
    erb :index
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    type = params[:account_type]
    user = nil
    if type == 'client'
      user = Client.find_by(email: params[:email])
    else
      user = Consultant.find_by(email: params[:email])
    end
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:type] = type
      if type == 'client'
        session[:privilege] = type
      elsif type == 'consultant'
        is_admin = user.admin
        if is_admin
          session[:privilege] = 'admin'
        else
          session[:privilege] = type
        end
      end

      redirect to "/#{type}s"
    elsif user
      erb 'Enter the correct username or password to access this account.'
    else
      erb 'User not found. You must choose the correct account type to sign in.'
    end
  end

  get '/logout' do
    if session[:user_id]
      session.clear
    end
    redirect '/login'
  end

  get '/signup' do
    erb :signup
  end
end
