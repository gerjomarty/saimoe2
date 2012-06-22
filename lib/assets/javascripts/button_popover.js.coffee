$(document).ready ->
  $('button.button-popover').popover placement: 'top', content: () ->
    $(this).next('div.button-popover-content').clone().removeAttr('style').html()
  $('button.button-popover').click () ->
    $(this).popover 'toggle'
