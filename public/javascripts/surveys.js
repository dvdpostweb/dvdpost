$(function() {
  selected = 0
  $('.check').live('click',function(){
    if(selected != 0)
    {
      $("#check_"+selected).removeClass('selected')
    }
    $(this).addClass('selected')
    selected = parseInt($(this).html(),10)
    $('#customer_survey_response').val(selected)
    return false;
  });
  
  
});
