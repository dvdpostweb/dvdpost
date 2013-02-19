$(document).ready(function() {
  $('#featurelist-slider .tabs li a').featureList({
		output			        :	'#featurelist-slider #output li',
		start_item		      :	0,
		transition_interval : 12000
	});
	/* newsletter  */
	search_init2 = $('#public_newsletter_email').val();
  $('#public_newsletter_email').live('focus', function(){
    if($('#public_newsletter_email').attr('value') == search_init2){
      $('#public_newsletter_email').val('');
    }
  });

  $('#public_newsletter_email').live('blur', function(){
    if($('#public_newsletter_email').attr('value') == ''){
      $('#public_newsletter_email').val(search_init2);
    }
  });
	/* *********** */
  /* selection */
  $('#weekly-selection-wrap .content-tabs a').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#weekly-selection-wrap');
    html_content = $('#weekly-selection-wrap .panel-container');
    content = html_content.html()
    $('#weekly-selection-wrap .content-tabs a').removeClass('active') 
    $(this).addClass('active')
    html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
        $.ajax({
      url: url,
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_content.html(content);
      }
    });
    return false;
  });
  $('#weekly-selection-wrap .pagination a').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#weekly-selection-wrap');
    html_content = $('#weekly-selection-wrap .jc');
    content = html_content.html()
    html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
        $.ajax({
      url: url,
      dataType: 'html',
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function(data) {
        html_content.html(content);
      }
    });
    return false;
  });
  /* *** */
 /* reviews ***/
 $('#tab1, #tab2, #tab3, #tab4').live('click',function(){
   url = this.href;
   set_page(url)
   html_item = $('#community-wrap');
   html_content = $('#review_tab');
   content = html_content.html()
   $('#community-wrap li a.active').removeClass('pie') 
   $('#community-wrap li a.active').removeClass('active')
   $(this).addClass('active pie')
   html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
       $.ajax({
     url: url,
     dataType: 'html',
     type: 'GET',
     success: function(data) {
       html_item.html(data);
     },
     error: function() {
       html_content.html(content);
     }
   });
   return false;
 });
 $(".review_more").live("click", function() {
   wishlist_item = $(this);
   url = wishlist_item.attr('href');
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
 $('#review_tab a.next_page').live('click',function(){
   url = this.href;
   set_page(url)
   html_item = $('#review_tab');
   html_content = $('.panel-container');
   content = html_content.html()
   link = $(this);
   link_content = link.html()
   $(this).html("<div style='height:24px; margin:9px 0 0 0'><img src='/images/ajax-loader.gif'/></div>");
       $.ajax({
     url: url,
     dataType: 'html',
     type: 'GET',
     success: function(data) {
       /*content += data
       html_content.html(content);*/
     },
     error: function() {
       /*link.html(link_content);*/
     }
   });
   return false;
 });
/*** ***/

/*** news ***/

$('#actualites-wrap .pagination a').live('click',function(){
  url = this.href;
  set_page(url)
  html_item = $('#actualites-wrap');
  html_content = $('#actualites-wrap .jc')
  $(html_content).html("<div style='height:24px; margin:9px 0 0 0'><img src='/images/ajax-loader.gif'/></div>");
  content = html_content.html()
      $.ajax({
    url: url,
    dataType: 'html',
    type: 'GET',
    success: function(data) {
      html_item.replaceWith(data);
    },
    error: function() {
      html_content.html(content);
    }
  });
  return false;
});
  
  

  
  $(".tooltips, .tooltips_item").live('mouseover',function(){
    $('.tooltip_items').hide()
    name =$(this).attr('id')+"_popup"
    product_id = $(this).attr('id').replace('product_','')
    if($("#"+name+" .action .img_load").attr('src') == '/images/ajax-loader.gif')
    {
      url = '/?action_popup=1&product_id='+product_id;
          $.ajax({
        url: url,
        dataType: 'html',
        type: 'GET',
        success: function(data) {
          $("#"+name+" .action").html(data);
        },
        error: function() {
          html_content.html(content);
        }
      });
    }
    var bulle = $("#"+name);
    bulle.show()
    return false;
  });
  $(".tooltips").live('mouseout',function(){
    name =$(this).attr('id')+"_popup"
    var bulle = $("#"+name);
    bulle.hide();
    return false;
  });
  $("#user-info-wrap").live('mouseleave',function(){
    $('.tooltip_items').hide()
  });
  
  
  $(".tooltip_items").live('mouseleave',function(){
     $(this).hide();
     return false;
   });
  $(".tooltips").live('click',function(){
    return false;
  });

});
