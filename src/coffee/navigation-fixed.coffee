#
#	Navigation Fixed Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  NavigationFixed = (el, options) ->
    new NavigationFixed::init(el, options)
  $.fn.navigationFixed = (options) ->
    @each ->
      $.data this, "navigationFixed", {}
      $.data this, "navigationFixed", NavigationFixed(this, options)
      return


  $.NavigationFixed = NavigationFixed
  $.NavigationFixed.NAME = "navigation-fixed"
  $.NavigationFixed.VERSION = "1.0"
  $.NavigationFixed.opts = {}
  
  # settings
  
  # Functionality
  NavigationFixed.fn = $.NavigationFixed:: =
    
    # Initialization
    init: (el, options) ->
      mq = window.matchMedia("(max-width: 767px)")
      return  if mq.matches
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @navBoxOffsetTop = @$element.offset().top
      @build()
      $(window).scroll $.proxy(@build, this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.NavigationFixed.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.NavigationFixed.NAME or namespace is $.NavigationFixed.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      if $(window).scrollTop() > @navBoxOffsetTop
        @$element.addClass "navigation-fixed"
        @setCallback "fixed"
      else
        @$element.removeClass "navigation-fixed"
        @setCallback "unfixed"
      return

  $(window).on "load.tools.navigation-fixed", ->
    $("[data-tools=\"navigation-fixed\"]").navigationFixed()
    return

  
  # constructor
  NavigationFixed::init:: = NavigationFixed::
  return
) jQuery
