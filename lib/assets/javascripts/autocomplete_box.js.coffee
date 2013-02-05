$.widget("custom.catcomplete", $.ui.autocomplete, {
  _renderMenu: (ul, items) ->
    that = this
    currentCategory = ""
    $.each items, (index, item) ->
      if item.category != currentCategory
        ul.append("<li class='ui-autocomplete-category'>" + item.category + "</li>")
        currentCategory = item.category
      that._renderItemData ul, item
})

$('#autocomplete_name').removeAttr('style')
$('#autocomplete_name').catcomplete({
  source: $('#autocomplete_name').attr('data-source-path'),
  minLength: 3,
  position: {my: 'right top', at: 'right bottom'},
  select: (event, ui) ->
    event.preventDefault()
    window.open(ui.item.target_path + '/' + ui.item.id, '_self')
  focus: (event, ui) ->
    event.preventDefault()
})
