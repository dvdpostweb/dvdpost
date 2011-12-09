module CustomersHelper
  def abo_type(customer, show_details, inline, long = false)
    if customer.new_price?
      detail = show_details ? "(DVD/Blu-ray/VOD)" : ""
      separator = inline ? " + " : "<br />"
      long_text = long ? " #{t('home.index.wishlist.films_s')}" : " VOD"
      abo = ""
      abo += "#{pluralize(customer.subscription_type.qty_dvd_max, 'film')} #{t('home.index.wishlist.all_formats')} #{detail}#{separator}" if customer.subscription_type.qty_dvd_max > 0
      abo += "#{customer.credit_per_month-customer.subscription_type.qty_dvd_max}#{long_text}"
      abo
    else
      if customer.credit_per_month == 0
        t '.unlimited'
      else
        "#{customer.credit_per_month} DVD"
      end
    end
  end

  def current_credits(customer, inline = true)
    if customer.new_price?
      separator = inline ? " + " : "<br /> + "
      all_credits = customer.credits <= customer.customers_abo_dvd_remain ? customer.credits : customer.customers_abo_dvd_remain
      only_vod = (customer.credits-customer.customers_abo_dvd_remain)
      if all_credits > 0 && only_vod > 0
        "#{pluralize(all_credits, 'film')} #{t('home.index.wishlist.all_formats')}#{separator}#{only_vod} VOD"
      elsif all_credits > 0 && only_vod <= 0
        "#{pluralize(all_credits, 'film')} #{t('home.index.wishlist.all_formats')}"
      elsif all_credits == 0 && only_vod > 0
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
    if total_all_used > 0 && vod_used > 0
      "#{pluralize(total_all_used, 'film')} #{t('home.index.wishlist.all_formats')} + #{vod_used} VOD"
    elsif total_all_used > 0 && vod_used <= 0
      "#{pluralize(total_all_used, 'film')} #{t('home.index.wishlist.all_formats')}"
    elsif total_all_used == 0 && vod_used > 0
      "#{vod_used} VOD"
    else
      t 'home.index.wishlist.full_credits'
    end
  end

end
