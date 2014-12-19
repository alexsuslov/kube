#
#	Livesearch Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Livesearch = (el, options) ->
    new Livesearch::init(el, options)
  $.fn.livesearch = (options) ->
    @each ->
      $.data this, "livesearch", {}
      $.data this, "livesearch", Livesearch(this, options)
      return


  $.Livesearch = Livesearch
  $.Livesearch.NAME = "livesearch"
  $.Livesearch.VERSION = "1.0"
  $.Livesearch.opts =
    
    # settings
    url: false
    target: false
    min: 2
    params: false
    appendForms: false

  
  # Functionality
  Livesearch.fn = $.Livesearch:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @build()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Livesearch.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Livesearch.NAME or namespace is $.Livesearch.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      @$box = $("<span class=\"livesearch-box\" />")
      @$element.after @$box
      @$box.append @$element
      @$element.off "keyup.tools.livesearch"
      @$element.on "keyup.tools.livesearch", $.proxy(@load, this)
      @$icon = $("<span class=\"livesearch-icon\" />")
      @$box.append @$icon
      @$close = $("<span class=\"close\" />").hide()
      @$box.append @$close
      @$close.off "click.tools.livesearch"
      @$close.on "click.tools.livesearch", $.proxy(->
        @search()
        @$element.val("").focus()
        @$close.hide()
        return
      , this)
      return

    toggleClose: (length) ->
      if length is 0
        @$close.hide()
      else
        @$close.show()
      return

    load: ->
      value = @$element.val()
      data = ""
      if value.length > @opts.min
        name = "q"
        name = @$element.attr("name")  unless typeof @$element.attr("name") is "undefined"
        data += "&" + name + "=" + value
        data = @appendForms(data)
        str = ""
        if @opts.params
          @opts.params = $.trim(@opts.params.replace("{", "").replace("}", ""))
          properties = @opts.params.split(",")
          obj = {}
          $.each properties, (k, v) ->
            tup = v.split(":")
            obj[$.trim(tup[0])] = $.trim(tup[1])
            return

          str = []
          $.each obj, $.proxy((k, v) ->
            str.push k + "=" + v
            return
          , this)
          str = str.join("&")
          data += "&" + str
      @toggleClose value.length
      @search data
      return

    appendForms: (data) ->
      return data  unless @opts.appendForms
      $.each @opts.appendForms, (i, s) ->
        data += "&" + $(s).serialize()
        return

      data

    search: (data) ->
      $.ajax
        url: @opts.url
        type: "post"
        data: data
        success: $.proxy((result) ->
          $(@opts.target).html result
          @setCallback "result", result
          return
        , this)

      return

  $(window).on "load.tools.livesearch", ->
    $("[data-tools=\"livesearch\"]").livesearch()
    return

  
  # constructor
  Livesearch::init:: = Livesearch::
  return
) jQuery
