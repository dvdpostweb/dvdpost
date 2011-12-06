$(function() {
  $('#show_all').live('click',function(){
    $('.abo, .new_abo').show();
    $(this).hide();
    return false;
  });
  sel=parseInt($('#div_selected').html());
  if(sel > 0)
  {
    selected= sel;
  }
  else
  {
    selected = 0
  }
  $('#left_content .choice').live('click',function(){
    selected=1
    $('#left_content').addClass('active');
    $('#right_content').removeClass('active');
    $('.abo .check, .new_abo .check').removeClass('active');
    $('.abo, .new_abo').removeClass('active');
    $('#customer_next_abo_type_id').attr('value','')
    $('#left_content .date_recondutcion').show();
    $('#right_content .date_recondutcion').hide();
  });
  
  $('#right_content .choice').live('click',function(){
    right()
  });
  
  $('.abo .check, .new_abo .check').live('click',function(){
    $('.abo .check, .new_abo .check').removeClass('active');
    $('.abo, .new_abo').removeClass('active');
    $(this).addClass('active');
    $(this).parent().parent().addClass('active');
    id = $(this).attr('id')
    $('#customer_next_abo_type_id').attr('value',id);

    right()
  });
  
  $('.button_confirm').live('click',function(){
    if(selected==0)
    {
      alert($('#error1').html())
      return false;
      
    }
    else if (selected==2)
    {
      value = $('#customer_next_abo_type_id').attr('value');
      if(!parseInt(value) > 0)
      {
        alert($('#error2').html())
        return false;
        
      }
    }
  });
  
  function right()
  {
    selected=2
    $('#left_content').removeClass('active');
    $('#right_content').addClass('active');
    $('#left_content .date_recondutcion').hide();
    $('#right_content .date_recondutcion').show();
  }
});
