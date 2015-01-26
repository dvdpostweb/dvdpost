class SubscriptionsController < ApplicationController
  def edit
    if current_customer.is_freetest?
      flash[:notice] = t('subscriptions.edit.freetrial')
      redirect_to root_path
    end
    @list_abo = nederlands? ? ProductAbo.get_list(10) :current_customer.get_list_abo(6)
    @showing_abo = 10
    @all_style=true
    abo_max_order = ProductAbo.maximum(:ordered)
    abo_order = current_customer.subscription_type ? current_customer.subscription_type.ordered : 1
    @selected_abo = current_customer.abo_type_id > 0 ? ProductAbo.find(current_customer.abo_type_id) : 0
    @free_upgrade = 0
    if current_customer.free_upgrade == 0 && abo_max_order != abo_order
      @free_upgrade = abo_order + 1
    else
      @free_upgrade = 0
    end
    
  end

  def update
      if(params[:customer] != nil && params[:customer][:next_abo_type_id] && !params[:customer][:next_abo_type_id].empty?)
        new_abo = Subscription.subscription_change(current_customer, params[:customer][:next_abo_type_id])
        freeupgrade_ok = Subscription.freeupgrade(current_customer, new_abo)
        if freeupgrade_ok
          flash[:notice] = t('subscriptions.freeupgrade',  :reconduction_date => current_customer.subscription_expiration_date.strftime("%d/%m/%Y"), :next_abo_price => new_abo.product.price, :next_abo_credits => new_abo.credits)
        else
          flash[:notice] = t('subscriptions.change',  :reconduction_date => current_customer.subscription_expiration_date.strftime("%d/%m/%Y"), :next_abo_price => new_abo.product.price, :next_abo_credits => new_abo.credits)
        end
        redirect_to customer_path(:id => current_customer.to_param)
      else
        flash[:error] = t('subscriptions.edit.abo_missing')
        redirect_to edit_customer_subscription_path(:customer_id => current_customer.to_param)
      end
      
  end
end