

function go_next()
{
  $.pjax({
    url: '/1',
    container: '.main-content',
    success: function(data) {
    }
  }) 
}

function go(to)
{
  $.pjax({
    url: to,
    container: '.main-content',
    success: function(data) {}
  })
}

