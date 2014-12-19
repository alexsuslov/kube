#
#	Tooltip Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Tooltip = (el, options) ->
    new Tooltip::init(el, options)
  $.fn.tooltip = (options) ->
    @each ->
      $.data this, "tooltip", {}
      $.data this, "tooltip", Tooltip(this, options)
      return


  $.Tooltip = Tooltip
  $.Tooltip.NAME = "tooltip"
  $.Tooltip.VERSION = "1.0"
  $.Tooltip.opts = theme: false
  
  # Functionality
  Tooltip.fn = $.Tooltip:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$element.on "mouseover", $.proxy(@show, this)
      @$element.on "mouseout", $.proxy(@hide, this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Tooltip.opts), @$element.data(), options)
      return

    show: ->
      $(".tooltip").hide()
      text = @$element.attr("title")
      @$element.data "cached-title", text
      @$element.attr "title", ""
      @tooltip = $("<div class=\"tooltip\" />").html(text).hide()
      @tooltip.addClass "tooltip-theme-" + @opts.theme  if @opts.theme isnt false
      @tooltip.css
        top: (@$element.offset().top + @$element.innerHeight()) + "px"
        left: @$element.offset().left + "px"

      $("body").append @tooltip
      @tooltip.show()
      return

    hide: ->
      @tooltip.fadeOut "fast", $.proxy(->
        @tooltip.remove()
        return
      , this)
      @$element.attr "title", @$element.data("cached-title")
      @$element.data "cached-title", ""
      return

  
  # Constructor
  Tooltip::init:: = Tooltip::
  $ ->
    $("[data-tools=\"tooltip\"]").tooltip()
    return

  return
) jQuery
