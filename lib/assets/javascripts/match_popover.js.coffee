$(document).ready ->
  $('button.match-popover').popover placement: 'top', content: () ->
    $(this).next('div.match-popover-content').clone().removeAttr('style').html()
  $('button.match-popover').click () ->
    $(this).popover 'toggle'
