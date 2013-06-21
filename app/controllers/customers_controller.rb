class CustomersController < ApplicationController
  def show
    @customer = current_customer
    @streaming_available = current_customer.get_all_tokens
    if params[:kind] == :adult
      @review_count = current_customer.reviews.approved.find(:all,:joins => :product, :conditions => { :products => {:products_status => [-2,0,1]}}).count
      @wishlist_adult_size = current_customer.wishlist_items.available.by_kind(:adult).current.include_products.count || 0
      wishlist_size
    else
      @review_count = current_customer.reviews.approved.find(:all,:joins => :product, :conditions => { :products => {:products_type => 'DVD_NORM', :products_status => [-2,0,1]}}).count
      wishlist_size
    end
   
  end

  def edit
    @customer = current_customer
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    if params[:customer][:address_attributes]
      params[:customer][:address_attributes][:first_name] = params[:customer][:first_name]
      params[:customer][:address_attributes][:last_name] = params[:customer][:last_name]
      params[:customer][:address_attributes][:gender] = params[:customer][:gender]
      params[:customer][:address_attributes][:customers_id] = current_customer.to_param
    end
    @customer = current_customer
    params[:customer][:birthday] = "#{params[:date][:year]}-#{params[:date][:month]}-#{params[:date][:day]}"
    if @customer.update_attributes(params[:customer])
      respond_to do |format|
        format.html do
          flash[:notice] = t(:customer_modify)
          if current_customer.customers_registration_step != 100 && current_customer.customers_registration_step != 95
            current_customer.update_attribute(:customers_registration_step, 33)
          end
          redirect_after_registration customer_path
        end
        format.js
      end
    else
      respond_to do |format|
        format.html do
          if current_customer.customers_registration_step.to_i == 31
            @countries = Country.all
            params[:id] = 2
            render :template => "/steps/show"
          else
            render :action => :edit
          end
        end
        format.js do
          render :action => :edit, :layout => false
        end
      end
    end
  end

  def newsletter
    @customer = current_customer
    @customer.newsletter!(params[:type], params[:value])
    if params[:type] == 'newsletter'
      data = @customer.newsletter
    else
      data = @customer.newsletter_parnter
    end
    respond_to do |format|
      format.html do
        redirect_to customer_path(:id => current_customer.to_param)
      end
      format.js {render :partial => 'customers/show/active', :locals => {:active => data, :type => params[:type]}}
    end
  end

  def mail_copy
    @customer = current_customer
    @customer.customer_attribute.update_attribute(:mail_copy, params[:value])
    respond_to do |format|
      format.html do
        redirect_to customer_path(:id => current_customer.to_param)
      end
      format.js {render :partial => 'customers/show/mail_copy', :locals => {:mail_copy => @customer.customer_attribute.mail_copy}}
    end
  end
  
  def only_vod
    @customer = current_customer
    @customer.customer_attribute.update_attribute(:only_vod, params[:value])
    respond_to do |format|
      format.html do
        redirect_to customer_path(:id => current_customer.to_param)
      end
      format.js {render :partial => 'customers/show/only_vod', :locals => {:only_vod => @customer.customer_attribute.only_vod}}
    end
  end
  
  def newsletters_x
    @customer = current_customer
    @customer.customer_attribute.update_attribute(:newsletters_x, params[:value])
    respond_to do |format|
      format.html do
        redirect_to customer_path(:id => current_customer.to_param)
      end
      format.js {render :partial => 'customers/show/newsletters_x', :locals => {:newsletters_x => @customer.customer_attribute.newsletters_x}}
    end
  end
  
  def newsletter_x
    respond_to do |format|
      format.html 
      format.js {render :layout => false}
    end
  end
  
  def sexuality
    @customer = current_customer
    @customer.customer_attribute.update_attribute(:sexuality, params[:value])
    session[:sexuality] = params[:value].to_i
    redirect_to root_path
  end

  def rotation_dvd
    @customer = Customer.find(current_customer)
    @customer.rotation_dvd!(params[:type],1)
    respond_to do |format|
      format.html do
        redirect_to customer_path(:id => current_customer.to_param)
      end
      format.js {
        @wishlist_adult_size = current_customer.wishlist_items.available.by_kind(:adult).current.include_products.count
        render :partial => 'customers/show/rotation', :locals => {:customer => @customer}
        }
    end
  end

  def unsubscribe
    if params[:type] == 'profile_part'
      customer = Customer.find_by_email(params[:email])
      if customer
        customer.update_attribute(:newsletter_parnter, false)
      end
      vision = EmailVisionCustomer.find_by_email(params[:email])
      if vision
        vision.update_attribute(:newsletters_partners, false)
      end
      
    end
  end
end
