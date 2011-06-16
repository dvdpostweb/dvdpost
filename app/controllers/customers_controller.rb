class CustomersController < ApplicationController
  def show
    @customer = current_customer
    @streaming_available = current_customer.get_all_tokens
    @review_count = current_customer.reviews.approved.ordered.find(:all,:joins => :product, :conditions => { :products => {:products_type => 'DVD_NORM', :products_status => [0,1]}}).count
    @wishlist_adult_size = current_customer.wishlist_items.available.by_kind(:adult).current.include_products.count
  end

  def edit
    @customer = current_customer
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @customer = current_customer
    params[:customer][:birthday] = "#{params[:date][:year]}-#{params[:date][:month]}-#{params[:date][:day]}"
    if @customer.update_attributes(params[:customer])
      respond_to do |format|
        format.html do
          flash[:notice] = t(:customer_modify)
          redirect_to customer_path
        end
        format.js
      end
    else
      respond_to do |format|
        format.html do
          render :action => :edit
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
end
