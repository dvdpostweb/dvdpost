$(function() {
  search_init = $('#search_text').html();
  alert(search_init)
  $('#search-field').live('focus', function(){
    if($('#search-field').attr('value') == search_init){
      $('#search-field').val('');
    }
  });

  $('#search-field').live('blur', function(){
    if($('#search-field').attr('value') == ''){
      $('#search-field').val(search_init);
    }
  });
});