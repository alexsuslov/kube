#
#	TextFit Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Textfit = (el, options) ->
    new Textfit::init(el, options)
  $.fn.textfit = (options) ->
    @each ->
      $.data this, "textfit", {}
      $.data this, "textfit", Textfit(this, options)
      return


  $.Textfit = Textfit
  $.Textfit.NAME = "textfit"
  $.Textfit.VERSION = "1.0"
  $.Textfit.opts =
    min: "10px"
    max: "100px"
    compressor: 1

  
  # Functionality
  Textfit.fn = $.Textfit:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$element.css "font-size", Math.max(Math.min(@$element.width() / (@opts.compressor * 10), parseFloat(@opts.max)), parseFloat(@opts.min))
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Textfit.opts), @$element.data(), options)
      return

  $(window).on "load.tools.textfit", ->
    $("[data-tools=\"textfit\"]").textfit()
    return

  
  # constructor
  Textfit::init:: = Textfit::
  return
) jQuery
