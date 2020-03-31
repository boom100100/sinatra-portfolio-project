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

  post '/login' do
    @type = params[:type]
    erb :login
  end

  get '/signup' do
    erb :signup
  end
end
