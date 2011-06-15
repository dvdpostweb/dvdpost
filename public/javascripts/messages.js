$(function() {
  $('.menu_faq').live('click', function() {
    $('#faq-nav .active').parent().find("ul").first().hide();
    $('#faq-nav .active').removeClass('active');
    $(this).addClass('active');
    $(this).parent().find("ul").first().show();
  });
  $('.q').live('click', function() {
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
  });
  $('.categorie').live('click', function() {
    $('label.active').removeClass('active');
    $(this).parent('label').addClass('active');
  });

  $('#new_message').live('click', function() {
    messages_item = $(this);
    jQuery.facebox(function() {
      $.getScript(messages_item.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });

  $(".trash").live("click", function() {
    if (confirm('Are you sure?')) {
      parent_trash = $(this).parent()
      content = parent_trash.html();
      parent_trash.html("<img src='/images/ajax-loader.gif' />");
      $.ajax({
        url: $(this).attr('value'),
        type: 'DELETE',
        data: {},
        success: function() {
          parent_trash.parent().parent().remove();
        },
        error: function() {
          parent_trash.html(content);
        }
      });
    }
    ;
    return false;
  });
  $("#new_message_btn").live("click", function() {
     $('#new_ticket').submit();
     setTimeout(function() { $("#new_message_btn").parent().html("<div style='height:34px'><img src='/images/ajax-loader.gif' /></div>"); }, 500);
  })
  
  $('#sort_combo').change(function() {sort_change()});
});
var options = {}
function sort_change()
{
  $('#sort_form').submit();
}