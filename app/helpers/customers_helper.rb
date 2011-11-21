module CustomersHelper
  def abo_type(customer)
    if customer.new_price?
      "#{customer.credit_per_month} #{t('customer.credits')} (dont #{customer.subscription_type.qty_dvd_max} DVD)"
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
      "#{customer.credits} #{t('customer.credits')} (dont #{customer.customers_abo_dvd_remain} DVD)"
    else
      if customer.credit_per_month == 0 
        customer.credits
      else
        "#{customer.credits} DVD"
      end
    end
  end
end
