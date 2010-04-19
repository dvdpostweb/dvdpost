$(function() {
  // Enable fragmetChange. This will allow us to put ajax into browser history
  $.fragmentChange(true);

  // hides the slickbox as soon as the DOM is ready
  // (a little sooner than page load)
  $('#lang-box').hide();
  $('body').click(function() {
    $('#indicator-tips').hide();
  });

  // toggles the slickbox on clicking the noted link
  $('a#lang').click(function() {
    $('#lang-box').toggle(50);
    return false;
  });

  $("#indicator #n7").click(function() {
    $("#indicator-tips").toggle(0);
    $.getScript('/fr/home/indicator_closed');
    return false;
  });

  $("#close").click(function() {
    $("#indicator-tips").hide();
    $.getScript('/fr/home/indicator_closed');
    return false;
  });
});
