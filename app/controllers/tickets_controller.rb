class TicketsController < ApplicationController
  get '/tickets' do
    if session[:user_id]
      @tickets = Ticket.all
      if session[:type] == 'client'
        @tickets = @tickets.select {|ticket| ticket.client_id == session[:user_id]}
      end
      erb :'tickets/index'
    else
      erb 'You must sign in to view this page.'
    end
  end

  post '/tickets' do
    if session[:user_id]
      #ticket has name and details
      if params[:name] != '' && params[:details] != ''
        ticket = Ticket.create(name: params[:name], details: params[:details])
        if params[:status] == 'open'
          ticket.complete = false
        elsif params[:status] == 'complete'
          ticket.complete = true
        end

        if session[:type] == 'client'
          ticket.client_id = session[:user_id]
          #won't let client assign a consultant
          #note: delete functionality won't reassign ticket - it will just be labeled as not belonging to anyone in show
        else
          ticket.consultant_id = Consultant.find_by(id: params[:consultant]).id
          ticket.client_id = Client.find_by(id: params[:client]).id
        end
        ticket.save
        redirect '/tickets'
      elsif params[:name] == ''
        erb 'Ticket must have a name.'
      elsif params[:details] == ''
        erb 'Ticket must have a description.'
      end
    else
      erb 'You must be signed in to view this page.'
    end
  end

  get '/tickets/new' do
    if session[:user_id]
      @clients = Client.all
      @consultants = Consultant.all

      #limit dropdown menus for client users
      if session[:type] == 'client'
        @clients = @clients.select {|client| client.id == session[:user_id]}
        @consultants = @consultants.select {|consultant| false}
      end

      erb :'tickets/new'
    else
      erb 'Only signed in users can view this page.'
    end
  end

  get '/tickets/:id' do
    @ticket = Ticket.find_by(id: params[:id])
    if session[:user_id]
      if @ticket
        @client = @ticket.client
        @consultant = @ticket.consultant

        if (session[:type] == 'client' && session[:user_id] == @ticket.client_id) || (session[:type] == 'consultant')
          @session_type = session[:type]
          @user_id = session[:user_id]
          @comments = Comment.all.select {|comment| comment.ticket_id == @ticket.id}
          erb :'tickets/show'
        else
          erb 'You can only see your own tickets.'
        end

      else
        erb 'Ticket doesn\'t exist.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end

  post '/tickets/:id' do
    if session[:user_id]
      #ticket has name and details
      if params[:name] != '' && params[:details] != ''
        ticket = Ticket.find_by(id: params[:id])
        ticket.name = params[:name]
        ticket.details = params[:details]

        if params[:status] == 'open'
          ticket.complete = false
        elsif params[:status] == 'complete'
          ticket.complete = true
        end

        if session[:type] == 'consultant'
          #don't change consultant or client for client
          #note: delete functionality won't reassign ticket - it will just be labeled as not belonging to anyone in show

          ticket.consultant_id = Consultant.find_by(email: params[:consultant]).id
          ticket.client_id = Client.find_by(email: params[:client]).id
        end

        ticket.save
        redirect "/tickets/#{params[:id]}"

      elsif params[:name] == ''
        erb 'Ticket must have a name.'
      elsif params[:details] != ''
        erb 'Ticket must have a description.'
      else
        redirect "/tickets/#{params[:id]}"
      end
    else
      erb 'You must be signed in to view this page.'
    end
  end

  get '/tickets/:id/edit' do
    @ticket = Ticket.find_by(id: params[:id])
    @session_type = session[:type]

    if @ticket

      @clients = Client.all
      @consultants = Consultant.all
      #limit dropdown menus for clients
      if session[:type] == 'client'
        @clients = @clients.select {|client| client.id == session[:user_id]}
        @consultants = @consultants.select {|consultant| false}
      end

      erb :'tickets/edit'
    else
      erb 'Ticket doesn\'t exist.'
    end
  end

  delete '/tickets/:id' do
    @ticket = Ticket.find_by(params[:id])
    if session[:user_id]
      if @ticket
        if (session[:type] == 'client' && session[:user_id] == @ticket.client_id) || (session[:type] == 'consultant')
          id = @ticket.id
          @ticket.destroy
          Comment.all.select {|comment| comment.ticket_id == id }.each {|comment| comment.destroy}
          redirect '/tickets'
        else
          erb 'You can only delete your own tickets.'
        end
      else
        erb 'This ticket doesn\'t exist.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end


end
