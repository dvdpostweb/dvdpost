class MessageTicketsController < ApplicationController
  def create
    ticket = current_customer.tickets.find(params[:ticket_id])
    if ticket
      @message = MessageTicket.new(params[:message_ticket].merge(:ticket => ticket))
      @message.save
    end
    redirect_to messages_path 
  end
end