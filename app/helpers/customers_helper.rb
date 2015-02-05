module CustomersHelper
  def subscription_description(customer, html = 0)
    sub = if html == 0
      "#{t '.current_formula'} : "
    elsif html == 1
      "<span class='title_pricing'>#{t '.current_formula'}</span><br />"
    else
      ""
    end
    if customer.subscription_type
      sub += 
      if customer.svod?
        t '.vod_unlimited'
      elsif current_customer.credit_per_month == 0
        t '.unlimited_title'
      else
        "#{current_customer.credit_per_month} #{t('.films').upcase}"
      end
    end
    sub += " <span class='month'>#{t '.per_month'}</span>" if html == 1
    sub
  end

  def abo_type(customer, show_details, inline, long = false, next_abo = false)
    if next_abo 
      sub = customer.next_subscription_type
      credits = customer.next_credit_per_month
    else
      sub = customer.subscription_type
      credits = customer.credit_per_month
    end
    if customer.new_price? || (next_abo && customer.next_new_price?)
      detail = show_details ? "(#{t_nl('home.index.wishlist.all_formats')})" : ""
      separator = inline ? " + " : "<br />"
      long_text = long ? " #{t('home.index.wishlist.films_s')}" : " VOD"
      abo = ""
      abo += "#{pluralize(sub.qty_dvd_max, 'film')} #{t_nl('home.index.wishlist.all_formats')} #{detail}" if sub.qty_dvd_max > 0
      abo += "#{separator} #{credits - sub.qty_dvd_max}#{long_text}" if credits - sub.qty_dvd_max > 0
      abo
    else
      if customer.credit_per_month == 0
        t '.unlimited', :qty => sub.qty_at_home
      else
        "#{credits} DVD"
      end
    end
  end

  def current_credits(customer, inline = true)
    if customer.new_price?
      separator = inline ? " + " : "<br /> + "
      all_credits = customer.credits <= customer.customers_abo_dvd_remain ? customer.credits : customer.customers_abo_dvd_remain
      only_vod = (customer.credits-customer.customers_abo_dvd_remain)
      if all_credits > 0 && only_vod > 0 && !nederlands?
        "#{pluralize(all_credits, 'film')} #{t_nl('home.index.wishlist.all_formats')}#{separator}#{only_vod} VOD"
      elsif all_credits > 0 && (only_vod <= 0 || nederlands?)
        "#{pluralize(all_credits, 'film')} #{t_nl('home.index.wishlist.all_formats')}"
      elsif all_credits == 0 && only_vod > 0 && !nederlands?
        "#{only_vod} VOD"
      else
        t 'home.index.wishlist.no_credit'
      end
    else
      if customer.credit_per_month == 0 
        customer.credits
      else
        "#{customer.credits} DVD"
      end
    end
  end

  def used_credits(customer)
    total_credits = customer.credit_per_month
    total_all_max = customer.dvd_max_per_month
    total_vod_max = total_credits - total_all_max
    credits_used = total_credits - customer.credits
    total_all_used = total_all_max - customer.customers_abo_dvd_remain
    vod_used = credits_used - total_all_used
    if vod_used > total_vod_max
      total_all_used = total_all_used + (vod_used - total_vod_max)
      vod_used = total_vod_max
    end
    if nederlands?
      if total_all_used > 0 || vod_used > 0
        "#{pluralize((total_all_used + vod_used), 'film')} #{t_nl('home.index.wishlist.all_formats')}"
      else
        t 'home.index.wishlist.full_credits'
      end
    else
      if total_all_used > 0 && vod_used > 0  
        "#{pluralize(total_all_used, 'film')} #{t_nl('home.index.wishlist.all_formats')} + #{vod_used} VOD"
      elsif total_all_used > 0 && vod_used <= 0
        "#{pluralize(total_all_used, 'film')} #{t_nl('home.index.wishlist.all_formats')}"
      elsif total_all_used == 0 && vod_used > 0
        "#{vod_used} VOD"
      else
        t 'home.index.wishlist.full_credits'
      end
    end
  end

end
