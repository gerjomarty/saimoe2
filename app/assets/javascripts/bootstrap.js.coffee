jQuery ->
  $('[rel=popover]').popover()
  $('[rel=html_popover]').popover html: true, container: 'body', content: () ->
    $(this).next('div[rel=html_popover_content]').clone().html()
  $('[rel^="html_named_popover_"]:not([rel$="_content"])').popover html: true, container: 'body', content: () ->
    content_rel = 'html_named_popover_'.concat $(this).attr('rel').substr(19), '_content'
    $("div[rel=#{content_rel}]").html()
  $('.tooltip').tooltip()
  $('[rel=tooltip]').tooltip()
  $('a[data-disabled="true"]').on 'click', (event) ->
    event.preventDefault
    return false