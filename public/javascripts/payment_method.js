$(function() {
  
  $("#payment_domiciliation").live("click", function() {
    $('#payment_ogone').removeClass('rose');
    $('#payment_domiciliation').addClass('rose');
    $('#domiciliation').removeClass('check').addClass('checkalive')
    $('#credit_card').addClass('check').removeClass('checkalive')
    $('#type').attr('value', 'domiciliation')
  })
  $("#payment_ogone").live("click", function() {
    $('#payment_domiciliation').removeClass('rose');
    $('#payment_ogone').addClass('rose');
    $('#credit_card').removeClass('check').addClass('checkalive')
    $('#domiciliation').addClass('check').removeClass('checkalive')
    $('#type').attr('value','credit_card')
    
  })
  /*$("#checkout_confirmation").submit();*/
  
})