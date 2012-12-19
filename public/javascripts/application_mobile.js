$(function() {
  search_init = $('#search_text').html();
  $('.search-field').live('focus', function(){
    if($(this).attr('value') == search_init){
      $(this).val('');
    }
  });

  $('.search-field').live('blur', function(){
    if($(this).attr('value') == ''){
      $(this).val(search_init);
    }
  });
});