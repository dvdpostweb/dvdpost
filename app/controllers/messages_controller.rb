class MessagesController < ApplicationController
  def show
    @message = current_customer.tickets.find(params[:id])
    @message.message_tickets.custer.collect do |message|
      message.update_attribute(:read, true)
    end
    
    respond_to do |format|
      format.html {}
      format.js {render :layout => false}
    end
  end

  def index
    if params[:sort] && params[:sort].to_sym == :ticket
      @messages = current_customer.tickets.active.ordered.paginate(:page => params[:page] || 1)
    else  
      @messages = current_customer.tickets.active.find(:all, :include => :message_tickets, :order => "message_tickets.id desc").paginate(:page => params[:page] || 1)
    end
  end

  def new
    @message = Ticket.new
    if params[:kind]
      kind_param = params[:kind].to_sym
      kind = DVDPost.messages_kind[kind_param]
      @message_help = MessageHelp.find(kind[:message])
      @category = kind[:category]
    end
    
  end

  def create
    @ticket = Ticket.new(params[:ticket].merge(:customer_id => current_customer.to_param))
    @ticket.save
    @message = MessageTicket.new(:message => params[:message], :ticket_id => @ticket.to_param)
    if @message.save
      flash[:notice] = t 'message.create.message_sent' #"Message sent successfully"
      
      respond_to do |format|
        format.html { redirect_to messages_path }
        format.js {@error = false}
      end
    else
      flash[:error] = t 'message.create.message_not_sent' # "Message not sent successfully"
      respond_to do |format|
        format.html {render :action => :new}
        format.js {@error = true}
      end
    end
    #@message = Message.new(params[:message])
    #@message.customers_id = current_customer.to_param
    #@message.language_id = DVDPost.product_languages[I18n.locale]
    #@message.messagesent = 0
    #if @message.save
    #  if @message.category_id == DVDPost.message_categories[:vod]
    #     #MessageReference.create(:name => 'streaming_product_id', 
    #     #                      :reference_id => params[:reference_id],
    #     #                      :message_id => @message.to_param)
    #  end
    #  flash[:notice] = t 'message.create.message_sent' #"Message sent successfully"
    #  
    #  respond_to do |format|
    #    format.html { redirect_to messages_path }
    #    format.js {@error = false}
    #  end
    #else
    #  flash[:error] = t 'message.create.message_not_sent' # "Message not sent successfully"
    #  respond_to do |format|
    #    format.html {render :action => :new}
    #    format.js {@error = true}
    #  end
    #end
  end

  def faq
    @faqs = Faq.ordered.all
  end

  def destroy
    @message = current_customer.tickets.find(params[:id])
    @message.update_attribute(:remove, true)
    respond_to do |format|
      format.html {redirect_to messages_path}
      format.js   {render :status => :ok, :nothing => true}
    end
  end

  def urgent
    @offline_request = current_customer.payment.recovery
  end
end
