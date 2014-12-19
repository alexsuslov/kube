#
#	Dropdown Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Dropdown = (el, options) ->
    new Dropdown::init(el, options)
  $.fn.dropdown = (options) ->
    @each ->
      $.data this, "dropdown", {}
      $.data this, "dropdown", Dropdown(this, options)
      return


  $.Dropdown = Dropdown
  $.Dropdown.NAME = "dropdown"
  $.Dropdown.VERSION = "1.0"
  $.Dropdown.opts =
    target: false
    targetClose: false
    height: false # number
    width: false # number

  
  # Functionality
  Dropdown.fn = $.Dropdown:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @build()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Dropdown.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Dropdown.NAME or namespace is $.Dropdown.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      @$dropdown = $(@opts.target)
      @$dropdown.hide()
      @$caret = $("<b class=\"caret\"></b>")
      @$element.append @$caret
      @setCaretUp()
      @preventBodyScroll()
      @$element.click $.proxy(@toggle, this)
      return

    setCaretUp: ->
      height = @$element.offset().top + @$element.innerHeight() + @$dropdown.innerHeight()
      return  if $(document).height() > height
      @$caret.addClass "caret-up"
      return

    toggle: (e) ->
      e.preventDefault()
      if @$element.hasClass("dropdown-in")
        @hide()
      else
        @show()
      return

    getPlacement: (height) ->
      (if ($(document).height() < height) then "top" else "bottom")

    getPosition: ->
      (if (@$element.closest(".navigation-fixed").size() isnt 0) then "fixed" else "absolute")

    setPosition: ->
      pos = @$element.position()
      elementHeight = @$element.innerHeight()
      elementWidth = @$element.innerWidth()
      height = @$dropdown.innerHeight()
      width = @$dropdown.innerWidth()
      position = @getPosition()
      placement = @getPlacement(pos.top + height + elementHeight)
      leftFix = 0
      leftFix = (width - elementWidth)  if $(window).width() < (pos.left + width)
      top = undefined
      left = pos.left - leftFix
      if placement is "bottom"
        @$caret.removeClass "caret-up"
        top = (if (position is "fixed") then elementHeight else pos.top + elementHeight)
      else
        @$caret.addClass "caret-up"
        top = (if (position is "fixed") then height else pos.top - height)
      @$dropdown.css
        position: position
        top: top + "px"
        left: left + "px"

      return

    show: ->
      $(".dropdown-in").removeClass "dropdown-in"
      $(".dropdown").removeClass("dropdown-open").hide()
      @$dropdown.css "min-height", @opts.height + "px"  if @opts.height
      @$dropdown.width @opts.width  if @opts.width
      @setPosition()
      @$dropdown.addClass("dropdown-open").show()
      @$element.addClass "dropdown-in"
      $(document).on "scroll.tools.dropdown", $.proxy(@setPosition, this)
      $(window).on "resize.tools.dropdown", $.proxy(@setPosition, this)
      $(document).on "click.tools.dropdown touchstart.tools.dropdown", $.proxy(@hide, this)
      if @opts.targetClose
        $(@opts.targetClose).on "click.tools.dropdown", $.proxy((e) ->
          e.preventDefault()
          @hide false
          return
        , this)
      $(document).on "keydown.tools.dropdown", $.proxy((e) ->
        
        # esc
        @hide()  if e.which is 27
        return
      , this)
      @setCallback "opened", @$dropdown, @$element
      return

    preventBodyScroll: ->
      @$dropdown.on "mouseover", ->
        $("html").css "overflow", "hidden"
        return

      @$dropdown.on "mouseout", ->
        $("html").css "overflow", ""
        return

      return

    hide: (e) ->
      if e
        e = e.originalEvent or e
        $target = $(e.target)
        return  if $target.hasClass("caret") or $target.hasClass("dropdown-in") or $target.closest(".dropdown-open").size() isnt 0
      @$dropdown.removeClass("dropdown-open").hide()
      @$element.removeClass "dropdown-in"
      $(document).off ".tools.dropdown"
      $(window).off ".tools.dropdown"
      @setCallback "closed", @$dropdown, @$element
      return

  $(window).on "load.tools.dropdown", ->
    $("[data-tools=\"dropdown\"]").dropdown()
    return

  
  # constructor
  Dropdown::init:: = Dropdown::
  return
) jQuery
