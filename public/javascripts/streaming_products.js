$(function() {
  $('.qualityvod').live("click", function() {
    content = $('#player').html()
    loader = 'loading.gif';
    $('.error').html('');
    $('#player').html("<div style='height:389px'><div class='load'><img src='/images/"+loader+"'/></div></div>")
    $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        $('#player').html(data);
      },
      error: function() {
        $(this).html(content);
      }
      
    });
    return false;
  });

  response="#r1"
  $('.q').live('click', function(){
    id = $(this).attr('id');
    try
    {
        $(response).hide();
    }
    catch(e)
    {
    }
    response = "#" + id.replace('q', 'r');
    $(response).show();

    return false;
  })
});