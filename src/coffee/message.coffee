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
  Message = (el, options) ->
    new Message::init(el, options)
  $.fn.message = (options) ->
    val = []
    args = Array::slice.call(arguments, 1)
    if typeof options is "string"
      @each ->
        instance = $.data(this, "message")
        if typeof instance isnt "undefined" and $.isFunction(instance[options])
          methodVal = instance[options].apply(instance, args)
          val.push methodVal  if methodVal isnt `undefined` and methodVal isnt instance
        else
          $.error "No such method \"" + options + "\" for Message"
        return

    else
      @each ->
        $.data this, "message", {}
        $.data this, "message", Message(this, options)
        return

    if val.length is 0
      this
    else if val.length is 1
      val[0]
    else
      val

  $.Message = Message
  $.Message.NAME = "message"
  $.Message.VERSION = "1.0"
  $.Message.opts =
    target: false
    delay: 10 # message delay - seconds or false

  
  # Functionality
  Message.fn = $.Message:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @build()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Message.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$message[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Message.NAME or namespace is $.Message.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      unless @opts.target
        @$message = @$element
        @show()
      else
        @$message = $(@opts.target)
        @$message.data "message", ""
        @$message.data "message", this
        @$element.on "click", $.proxy(@show, this)
      return

    show: ->
      if @$message.hasClass("open")
        @hide()
        return
      $(".tools-message").hide().removeClass "open"
      @$message.addClass("open").fadeIn("fast").on "click.tools.message", $.proxy(@hide, this)
      $(document).on "keyup.tools.message", $.proxy(@hideHandler, this)
      setTimeout $.proxy(@hide, this), @opts.delay * 1000  if @opts.delay
      @setCallback "opened"
      return

    hideHandler: (e) ->
      return  unless e.which is 27
      @hide()
      return

    hide: ->
      return  unless @$message.hasClass("open")
      @$message.off "click.tools.message"
      $(document).off "keyup.tools.message"
      @$message.fadeOut "fast", $.proxy(->
        @$message.removeClass "open"
        @setCallback "closed"
        return
      , this)
      return

  
  # Constructor
  Message::init:: = Message::
  $ ->
    $("[data-tools=\"message\"]").message()
    return

  return
) jQuery
