class Helper
  constructor:(@opt, @el)->
    @$el = $ @el
    html = @$el.html()
    @$el.append "<pre class='outline'>test</pre>"
    $(@$el.find('pre')[0]).text html
$ ->
  $.fn.wcHelper = (options)->
    @each (i, el)->
      new Helper options, el

  $('.wc-help').wcHelper()
