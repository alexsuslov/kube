#
#	Autocomplete Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->

  # Plugin

  # Initialization
  Autocomplete = (el, options) ->
    new Autocomplete::init(el, options)
  $.fn.autocomplete = (options) ->
    @each ->
      $.data this, "autocomplete", {}
      $.data this, "autocomplete", Autocomplete(this, options)
      return


  $.Autocomplete = Autocomplete
  $.Autocomplete.NAME = "autocomplete"
  $.Autocomplete.VERSION = "1.0"
  $.Autocomplete.opts =
    url: false
    min: 2
    set: "value" # value or id


  # Functionality
  Autocomplete.fn = $.Autocomplete:: =

    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @build()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Autocomplete.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Autocomplete.NAME or namespace is $.Autocomplete.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      @result = $("<ul class=\"autocomplete\">").hide()
      @pos = @$element.offset()
      @elementHeight = @$element.innerHeight()
      $("body").append @result
      @placement = (if (($(document).height() - (@pos.top + @elementHeight)) < @result.height()) then "top" else "bottom")
      $(document).on "click", $.proxy(@hide, this)
      @$element.on "keyup", $.proxy((e) ->
        value = @$element.val()
        if value.length >= @opts.min
          @$element.addClass "autocomplete-in"
          @result.addClass "autocomplete-open"
          @listen e
        else
          @hide()
        return
      , this)
      return

    lookup: ->
      $.ajax
        url: @opts.url
        type: "post"
        data: @$element.attr("name") + "=" + @$element.val()
        success: $.proxy((json) ->
          data = $.parseJSON(json)
          @result.html ""
          $.each data, $.proxy((i, s) ->
            li = $("<li>")
            a = $("<a href=\"#\" rel=\"" + s.id + "\">").html(s.value).on("click", $.proxy(@set, this))
            li.append a
            @result.append li
            return
          , this)
          top = (if (@placement is "top") then (@pos.top - @result.height() - @elementHeight) else (@pos.top + @elementHeight))
          @result.css
            top: top + "px"
            left: @pos.left + "px"

          @result.show()
          @active = false
          return
        , this)

      return

    listen: (e) ->
      return  unless @$element.hasClass("autocomplete-in")
      e.stopPropagation()
      e.preventDefault()
      switch e.keyCode
        when 40 # down arrow
          @select "next"
        when 38 # up arrow
          @select "prev"
        when 13 # enter
          @set()
        when 27 # escape
          @hide()
        else
          @lookup()

    select: (type) ->
      $links = @result.find("a")
      size = $links.size()
      $active = @result.find("a.active")
      $active.removeClass "active"
      $item = (if (type is "next") then $active.parent().next().children("a") else $active.parent().prev().children("a"))
      $item = (if (type is "next") then $links.eq(0) else $links.eq(size - 1))  if $item.size() is 0
      $item.addClass "active"
      @active = $item
      return

    set: (e) ->
      $el = $(@active)
      if e
        e.preventDefault()
        $el = $(e.target)
      id = $el.attr("rel")
      value = $el.html()
      if @opts.set is "value"
        @$element.val value
      else
        @$element.val id
      @setCallback "set", id, value
      @hide()
      return

    hide: (e) ->
      return  if e and ($(e.target).hasClass("autocomplete-in") or $(e.target).hasClass("autocomplete-open") or $(e.target).parents().hasClass("autocomplete-open"))
      @$element.removeClass "autocomplete-in"
      @result.removeClass "autocomplete-open"
      @result.hide()
      return

  $(window).on "load.tools.autocomplete", ->
    $("[data-tools=\"autocomplete\"]").autocomplete()
    return


  # constructor
  Autocomplete::init:: = Autocomplete::
  return
) jQuery
