$(function() {
  
  $('.qualityvod').live("click", function() {
    url = $(this).attr('href')
    var regex = new RegExp(".*/products/([0-9]*).*");
    res = regex.exec(url)
    product_vod_id = $('#product_id').html()
    content = $('#presentation').html()
    loader = 'loading.gif';
    $('.error').html('');
    $('#presentation').html("<div id='loading'>loading...</div>")
    $(this).hide()
    $.ajax(
    {
      dataType: 'html',
      url: $(this).attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        $('#presentation').html(data);
        $('.qualityvod').show()
      },
      error: function() {
        $('#presentation').html(content);
        $('.qualityvod').show();
      }
    });
    return false;
  });

 
});