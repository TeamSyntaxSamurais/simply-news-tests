$('document').ready( function() {
  $(".form-image").click(function() {
    $(this).next().trigger('click');
  });
});
