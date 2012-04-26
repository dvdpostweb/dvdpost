$(function() {
  $("#content img").live("click", function() {
    img = "<div><img src='"+$(this).attr('src')+"' /></div>"
    jQuery.facebox(img);
  });
  
});
