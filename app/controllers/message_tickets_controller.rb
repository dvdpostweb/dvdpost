class MessageTicketsController < ApplicationController
  def create
    ticket = current_customer.tickets.find(params[:ticket_id])
    if ticket
      @message = MessageTicket.new(:ticket => ticket, :mail_id => DVDPost.email[:message_free], :data => "$$$content$$$:::#{params[:message].gsub(/\n/, '<br />')};;;")
      @message.save
    end
    redirect_to message_path(:id => params[:ticket_id])
  end
end