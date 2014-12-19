#
#	Tabs Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Tabs = (el, options) ->
    new Tabs::init(el, options)
  $.fn.tabs = (options) ->
    val = []
    args = Array::slice.call(arguments, 1)
    if typeof options is "string"
      @each ->
        instance = $.data(this, "tabs")
        if typeof instance isnt "undefined" and $.isFunction(instance[options])
          methodVal = instance[options].apply(instance, args)
          val.push methodVal  if methodVal isnt `undefined` and methodVal isnt instance
        else
          $.error "No such method \"" + options + "\" for Tabs"
        return

    else
      @each ->
        $.data this, "tabs", {}
        $.data this, "tabs", Tabs(this, options)
        return

    if val.length is 0
      this
    else if val.length is 1
      val[0]
    else
      val

  $.Tabs = Tabs
  $.Tabs.NAME = "tabs"
  $.Tabs.VERSION = "1.0"
  $.Tabs.opts =
    equals: false
    active: false

  
  # Functionality
  Tabs.fn = $.Tabs:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @links = @$element.find("a")
      @tabs = []
      @links.each $.proxy(@load, this)
      @setEquals()
      @setCallback "init"
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Tabs.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Tabs.NAME or namespace is $.Tabs.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    load: (i, el) ->
      $el = $(el)
      hash = $el.attr("href")
      $el.attr "rel", hash
      @tabs.push $(hash)
      $(hash).hide()  unless $el.parent().hasClass("active")
      
      # is hash in url
      @readLocationHash hash
      
      # is active
      @show hash  if @opts.active isnt false and @opts.active is hash
      $el.on "click", $.proxy(@onClick, this)
      return

    onClick: (e) ->
      e.preventDefault()
      hash = $(e.target).attr("rel")
      top.location.hash = hash
      @show hash
      return

    readLocationHash: (hash) ->
      return  if top.location.hash is "" or top.location.hash isnt hash
      @opts.active = top.location.hash
      return

    setActive: (hash) ->
      @activeHash = hash
      @activeTab = $("[rel=" + hash + "]")
      @links.parent().removeClass "active"
      @activeTab.parent().addClass "active"
      return

    getActiveHash: ->
      @activeHash

    getActiveTab: ->
      @activeTab

    show: (hash) ->
      @hideAll()
      $(hash).show()
      @setActive hash
      @setCallback "show", $("[rel=" + hash + "]"), hash
      return

    hideAll: ->
      $.each @tabs, ->
        $(this).hide()
        return

      return

    setEquals: ->
      return  unless @opts.equals
      @setMaxHeight @getMaxHeight()
      return

    setMaxHeight: (height) ->
      $.each @tabs, ->
        $(this).css "min-height", height + "px"
        return

      return

    getMaxHeight: ->
      max = 0
      $.each @tabs, ->
        h = $(this).height()
        max = (if h > max then h else max)
        return

      max

  $(window).on "load.tools.tabs", ->
    $("[data-tools=\"tabs\"]").tabs()
    return

  
  # constructor
  Tabs::init:: = Tabs::
  return
) jQuery
