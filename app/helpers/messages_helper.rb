module MessagesHelper
  def radio_question_for(form, attr, id)
    render :partial => 'messages/index/radio_question', :locals => {:f => form, :attr => attr, :id => id}
  end

  def tab_item_class(tab, active)
    tab == active ? 'active' : ''
  end

  def offline_payment_type(type)
    case type
      when 1
  			t '.message_payment_ogone_failed'
  		when 3
  			t '.message_payment_bank_transfer_failed'
  		when 2
  			t '.message_payment_dom_failed'
  		else
  			t '.unspecified'
  	end
  end

  def message_title(kind)
    case kind
      when :number 
        t('messages.index.radio_question.labels.number')
      when :billing_price 
        t('messages.index.radio_question.labels.billing_price')
      when :billing_dvd
        t('messages.index.radio_question.labels.billing_dvd')
      when :dom
        t('messages.index.radio_question.labels.transfer')
    end
  end
end