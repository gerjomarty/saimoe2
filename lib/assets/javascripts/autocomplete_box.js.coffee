$(document).ready ->
  $('#autocomplete_name').removeAttr('style')
  $('#autocomplete_name').autocomplete({
    source: $('#autocomplete_name').attr('data-source-path'),
    minLength: 3,
    position: {my: 'right top', at: 'right bottom'},
    select: (event, ui) ->
      window.open($('#autocomplete_name').attr('data-target-path') + '/' + ui.item.id, '_self')
  })
