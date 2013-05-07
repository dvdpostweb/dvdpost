module CustomersSvodHelper
  def svod_title(user)
    case user.svod_adult
      when 0
        '.activate'
      when 1
        '.deactivate'
      when 2
        '.deactivate'
      when 3
        '.break'
      when 4
        '.break'
    end
  end

  def svod_btn(user)
    case user.svod_adult
      when 0
        '.activate_btn'
      when 1
        '.deactivate_btn'
      when 2
        '.deactivate_btn'
      when 3
        '.break_btn'
      when 4
        '.break_btn'
    end
  end
  def price_link(user)
    if user
      user.is_freetest? ? edit_customer_reconduction_path(:customer_id => user.to_param) : edit_customer_subscription_path(:customer_id => user.to_param)
    else
      info_path(:page_name => :price)
    end
  end
  def self.next_reconduction_at(user)
    if user
      if user.svod_adult == 1 || user.svod_adult == 3
        (user.customers_svod.validityto + 1.month).strftime('%d/%m/%Y') 
      elsif user.svod_adult == 2 || user.svod_adult == 4
        user.customers_svod.validityto.strftime('%d/%m/%Y')
      else
        nil
      end
    else
      nil
    end
  end

  def next_reconduction_at(user)
    CustomersSvodHelper.next_reconduction_at(user)
  end
end
