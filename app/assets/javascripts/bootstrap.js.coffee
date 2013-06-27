jQuery ->
  $("a[rel=popover]").popover()
  $("a[rel=html_popover]").popover html: true, content: () ->
    $(this).next('div[rel=html_popover_content]').clone().html()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()