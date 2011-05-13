module PaymentMethodHelper
  def choose_partial
    result = params[:type] || 'index'
    if result == 'credit_card_modificatio'
      result = 'credit_card_modification'
    end
    result
  end
end
