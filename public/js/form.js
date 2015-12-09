$('document').ready( function() {
  $(".form-image").click( function() {
    $(this).next().trigger('click');
  });
  $('input[type="checkbox"] + label').click( function() {
    $(this).prev().trigger('click');
  });
});
