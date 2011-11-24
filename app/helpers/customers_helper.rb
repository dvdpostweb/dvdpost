module CustomersHelper
  def abo_type(customer)
    if customer.new_price?
      "#{customer.credit_per_month} #{t('customer.credits')} <br />#{customer.subscription_type.qty_dvd_max} films tous formats<br />et #{customer.credit_per_month-customer.subscription_type.qty_dvd_max} vod"
    else
      if customer.credit_per_month == 0
        t('.unlimited')
      else
        "#{customer.credit_per_month} DVD"
      end
    end
  end

  def current_credits(customer)
    if customer.new_price?
      "#{customer.customers_abo_dvd_remain} films tous formats et #{customer.credits-customer.customers_abo_dvd_remain} vod"
    else
      if customer.credit_per_month == 0 
        customer.credits
      else
        "#{customer.credits} DVD"
      end
    end
  end
end
