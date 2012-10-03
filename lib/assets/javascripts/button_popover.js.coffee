$(document).ready ->
  $('.button-popover').popover placement: 'top', content: () ->
    $(this).next('div.button-popover-content').clone().removeAttr('style').html()
  $('.button-popover').click () ->
    $(this).popover 'toggle'
