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
  $("#checkout_confirmation").submit();
  
  $('#ppv .button_confirm_switch, #credit_card .button_confirm_switch, #credit_card_modification .button_confirm_switch').click(function(){
    if($('.brand').size())
    {
      if($("input[type='radio']:checked").val() == undefined)
      {
      alert($('#error').html())
      return false;
      }
    }
    
  })
  
})