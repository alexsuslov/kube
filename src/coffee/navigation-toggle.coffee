#
#	Navigation Toggle Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  NavigationToggle = (el, options) ->
    new NavigationToggle::init(el, options)
  $.fn.navigationToggle = (options) ->
    @each ->
      $.data this, "navigationToggle", {}
      $.data this, "navigationToggle", NavigationToggle(this, options)
      return


  $.NavigationToggle = NavigationToggle
  $.NavigationToggle.NAME = "navigation-toggle"
  $.NavigationToggle.VERSION = "1.0"
  $.NavigationToggle.opts = target: false
  
  # Functionality
  NavigationToggle.fn = $.NavigationToggle:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$target = $(@opts.target)
      @$toggle = @$element.find("span")
      @$toggle.on "click", $.proxy(@onClick, this)
      @build()
      $(window).resize $.proxy(@build, this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.NavigationToggle.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.NavigationToggle.NAME or namespace is $.NavigationToggle.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      mq = window.matchMedia("(max-width: 767px)")
      if mq.matches
        
        # hide
        unless @$target.hasClass("navigation-target-show")
          @$element.addClass("navigation-toggle-show").show()
          @$target.addClass("navigation-target-show").hide()
      else
        
        # show
        @$element.removeClass("navigation-toggle-show").hide()
        @$target.removeClass("navigation-target-show").show()
      return

    onClick: (e) ->
      e.stopPropagation()
      e.preventDefault()
      if @isTargetHide()
        @$element.addClass "navigation-toggle-show"
        @$target.show()
        @setCallback "show", @$target
      else
        @$element.removeClass "navigation-toggle-show"
        @$target.hide()
        @setCallback "hide", @$target
      return

    isTargetHide: ->
      (if (@$target[0].style.display is "none") then true else false)

  $(window).on "load.tools.navigation-toggle", ->
    $("[data-tools=\"navigation-toggle\"]").navigationToggle()
    return

  
  # constructor
  NavigationToggle::init:: = NavigationToggle::
  return
) jQuery
