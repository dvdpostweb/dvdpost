$(function() {
  $(".launch_popup").live("click", function() {
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.ajax({
        url: url,
        dataType: 'html',
        type: 'GET',
        success: function(data) { jQuery.facebox(data); }
      });
    });
    return false;
  });
  $("#submit_svod").live("click", function() {
    $('#form_svod').submit()
    $(this).parent().hide()
    $('<p class="loading">loading...</p>').insertAfter($(this).parent());
  });
  
  
});
