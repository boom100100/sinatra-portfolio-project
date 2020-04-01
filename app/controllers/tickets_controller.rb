class TicketsController < ApplicationController
  get '/tickets' do #todo try as client
    if session[:user_id]
      if session[:type] == 'consultant'
        @tickets = Ticket.all
        erb :'tickets/index'
      elsif session[:type] == 'client'
        erb 'Clients are unable to see this page. Go to your profile page to view your tickets.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end

  get '/tickets/new' do #todo try as client
    if session[:user_id]
      @clients = Client.all
      @consultants = Consultant.all
      if session[:privilege] == 'client'
        @current_user = Client.find_by(id: session[:user_id])
        @current_user_privilege = 'client'
      elsif session[:privilege] == 'consultant'
        @current_user = Consultant.find_by(id: session[:user_id])
        @current_user_privilege = 'consultant'
      elsif session[:privilege] == 'admin'
        @current_user = Consultant.find_by(id: session[:user_id])
        @current_user_privilege = 'admin'
      end
      erb :'tickets/new'
    else
      erb 'Only signed in users can view this page.'
    end
  end

  get '/tickets/:id' do
    @ticket = Ticket.find_by(id: params[:id])
    if @ticket
      erb :'tickets/show'
    else
      erb 'Ticket doesn\'t exist.'
    end
  end
end
