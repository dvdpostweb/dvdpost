$(function() {
  $("#content img").live("click", function() {
    img = "<div style='width:600px; text-align:center'><img src='"+$(this).attr('src')+"' /></div>"
    jQuery.facebox(img);
  });
  
});
