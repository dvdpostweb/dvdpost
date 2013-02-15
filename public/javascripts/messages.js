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
    messages_item.attr('href')
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

  $(".trash").live("click", function() {
    if (confirm('Are you sure?')) {
      parent_trash = $(this).parent()
      content = parent_trash.html();
      parent_trash.html("<img src='/images/ajax-loader.gif' />");
      $.ajax({dataType: 'html',
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
    if (!$(".content input:radio:checked").val()) {
      alert($('#error_cat').html())
      return false
    }
     $('#new_message_btn').attr("disabled", "disabled"); 
     $('#new_ticket').submit();
     
     setTimeout(function() { $("#new_message_btn").parent().html("<div style='height:34px'><img src='/images/ajax-loader.gif' /></div>"); }, 500);
  })
  $("#reply").live("click", function() {
     $('#reply').attr("disabled", "disabled"); 
     $('#new_reply').submit();
     
     setTimeout(function() { $("#reply").parent().html("<p align='rigth'><img src='/images/ajax-loader.gif' /></p>"); }, 500);
  })
  $('#sort_combo').change(function() {sort_change()});
  $(".datepicker").datepicker({
    disabled: true,
    showButtonPanel: false,
    firstDay: 1,
    dateFormat: 'dd-mm-yy',
    onSelect: function(dateText, inst) { 
      d=new Date();
      month = (d.getMonth()+1);
      if(parseInt(month)<10)
      {
        month = new String('0'+month)
      }
      day = d.getDate()
      if(parseInt(day)<10)
      {
        day = new String('0'+day)
      }
      
      if (dateText == day+"-"+month+"-"+d.getFullYear())
      {
        limit = 0
        h = d.getHours()
        if(parseInt(h)==9)
        {
          limit = 4
        }
        else if (parseInt(h)== 10)
        {
          limit = 6
        }  
        else if (parseInt(h)== 11)
        {
            limit = 8
        }
        else if (parseInt(h)== 12)
        {
            limit = 10
        }
        else if (parseInt(h)== 13)
        {
            limit = 12
        }
        else if (parseInt(h)== 14)
        {
            limit = 14
        }
        else if (parseInt(h)== 15)
        {
            limit = 16
        }
        else if (parseInt(h)== 16)
        {
            limit = 18
        }
        $.each($('#phone_request_hour').children(), function (){
          if(parseInt($(this).attr('value'))<=limit)
          {
            $(this).attr('disabled','disabled')
            $(this).hide()
          }
        })
        $("select#phone_request_hour option[selected]").removeAttr("selected");
        $("select#phone_request_hour option[value='']").attr("selected", "selected");
      }
      else
      {
        $.each($('#phone_request_hour').children(), function (){
            $(this).show()
            $(this).removeAttr('disabled');
        })
      }
    },
    minDate: new Date()});
  
});
var options = {}
function sort_change()
{
  $('#sort_form').submit();
}