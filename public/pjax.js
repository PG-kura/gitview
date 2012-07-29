function go(to, pjax_container)
{
  $.pjax({
    url: to,
    container: '#' + pjax_container,
    success: function(data) {}
  })
}

