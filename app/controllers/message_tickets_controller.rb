class MessageTicketsController < ApplicationController
  def create
    if !params[:message].empty?
      
      ticket = current_customer.tickets.find(params[:ticket_id])
      if ticket
        @message = MessageTicket.new(:ticket => ticket, :mail_id => DVDPost.email[:message_free], :data => "$$$content$$$:::#{params[:message].gsub(/\n/, '<br />')};;;")
        @message.save
      end
      redirect_to message_path(:id => params[:ticket_id])
    else
      flash[:error] = t 'message.create.message_not_sent' # "Message not sent successfully"
      respond_to do |format|
        format.html {redirect_to message_path :id => params[:ticket_id] }
        format.js {@error = true}
      end
    end
  end
end