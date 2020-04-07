class CommentsController < ApplicationController
  post '/comments' do
    if session[:user_id]
      if params[:content] != '' && params[:ticket_id] != ''
        ticket = Ticket.find_by(id: params[:ticket_id])
        #visitor is ticket creator (client) or consultant
        if session[:type] == 'consultant' || Client.find_by(id: ticket.client_id).id == session[:user_id]
          comment = Comment.create(content: params[:content], ticket_id: params[:ticket_id])

          if session[:type] == 'consultant'
            comment.consultant_id = session[:user_id]
          elsif session[:type] == 'client'
            comment.client_id = session[:user_id]
          end

          comment.save

          redirect "/tickets/#{comment.ticket_id}"
        else
          erb 'Only the ticket creator or a consultant can comment on a ticket.'
        end
      else
        erb 'Comment must have content.'
      end
    else
      erb 'You must sign in to create a comment.'
    end
  end

  put '/comments/:id' do
    if session[:user_id]
      @comment = Comment.find_by(id: params[:id])

      if @comment
        #check visitor identity
        if is_creator?(@comment)
          if params[:content] != ''
            @comment.content = params[:content]
            @comment.save
            redirect "/tickets/#{@comment.ticket_id}"
          else
            erb 'A comment must not have empty content.'
          end
        else
          erb 'Only a comment\'s creator or an admin can edit a comment.'
        end
      else
        erb 'Comment doesn\'t exist.'
      end
    else
      erb 'You must sign in to edit a comment.'
    end
  end

  delete '/comments/:id' do # TODO: deleting ticket must delete associated comments
    if session[:user_id]
      @comment = Comment.find_by(id: params[:id])

      if @comment
        if is_creator?(@comment) || session[:privilege] == 'admin'
          ticket_id = @comment.ticket_id
          @comment.destroy
          redirect "/tickets/#{ticket_id}"
        else
          erb 'Only the comment creator or an admin can delete a comment.'
        end
      else
        erb 'Comment not found.'
      end
    else
      erb 'You must sign in to delete a comment.'
    end
  end

  get '/comments/:id/edit/?' do
    @comment = Comment.find_by(id: params[:id])
    if session[:user_id]
      if @comment
        @client = Client.find_by(id: @comment.client_id)
        @consultant = Consultant.find_by(id: @comment.consultant_id)

        #only creator can edit their comment
        if (session[:type] == 'client' && session[:user_id] == @comment.client_id) || (session[:type] == 'consultant' && session[:user_id] == @comment.consultant_id)
          @session_type = session[:type]
          @comments = Comment.all.select {|comment| comment.ticket_id == @comment.ticket_id}
          erb :'comments/edit'
        else
          erb 'You can only edit your own comments.'
        end
      else
        erb 'Ticket doesn\'t exist.'
      end
    else
      erb 'You must sign in to view this page.'
    end
  end

  private

  def is_creator?(comment)
    comment.consultant_id ? comment_creator_type = 'consultant' : comment.client_id ? comment_creator_type = 'client' : nil
    comment_creator_type == 'consultant' ? creator = comment.consultant : comment_creator_type == 'client' ? creator = comment.client : nil
    (session[:type] == comment_creator_type && (creator.id == comment.consultant_id || creator.id == comment.client_id)) ? true : false

  end
end
