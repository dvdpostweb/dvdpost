class MessagesController < ApplicationController
  def show
    @message = current_customer.messages.find(params[:id])
    @message.update_attribute(:is_read, true) unless @message.is_read
    render :layout => false
  end

  def index
    @messages = current_customer.messages.ordered.paginate(:page => params[:page] || 1)
  end

  def destroy
    @message = Message.destroy(params[:id])
    flash[:notice] = "Message #{@message.id} was removed from your messages."
    respond_to do |format|
      format.html {redirect_to messages_path}
      format.js   {render :status => :ok, :layout => false}
    end
  end
end
