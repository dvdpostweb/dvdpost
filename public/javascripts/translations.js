$(function() {
  $('.edit').each(function(){
    $(this).editable(submitEditable, {
      name      : 'translation[text]',
      indicator : 'Saving...',
      tooltip   : 'Click to edit...',
      cancel    : 'cancel',
      type      : 'textarea',
      submit    : 'OK'
    });
    function submitEditable(value, settings){
      result = value;
      html_item = $(this);
      url = html_item.parent().children('#url').attr('value');
      if (url.match(/\/locales\/(\d*)\/translations\/(\d*)/)) {
        method = 'PUT';
      } else {
        method = 'POST';
      }
      $.ajax({dataType: 'html',
        url: url,
        type: method,
        data: ({'translation[text]': value}),
        success: function(data) {
          html_item.parent().removeClass('miss susp old');
          html_item.parent().children('#url').attr('value', data)
          /*result = data;*/
        }
      });
      return result;
    };
  });
});
