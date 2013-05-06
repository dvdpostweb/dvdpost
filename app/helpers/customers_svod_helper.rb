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
end
