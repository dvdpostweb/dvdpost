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

  def config_dialog(user_id)
    if user_id
      {:class => 'dvdpostmessage', :image => 'avatar_dvdpost.gif', :title => 'dvdpost'}
    else
      {:class => 'customessage', :image => get_avatar(current_customer), :title => 'customer'}
    end
  end

  def replace_variables(body, variables)
    extracts = variables.split(';;;')
    extracts.collect do |extract|
      raw = extract.split(':::')
      s = raw[0].gsub(/\$/,'\$')
      r = Regexp.new(s, true)
      raw[1] = '' if !raw[1]
      body = body.gsub(r, raw[1]) 
    end
    body
  end

  def get_data(variable ,variables)
    extracts = variables.split(';;;')
    extracts.collect do |extract|
      raw = extract.split(':::')
      if raw[0] == "$$$#{variable}$$$" 
        return raw[1]
      end
    end
    return false
  end
end