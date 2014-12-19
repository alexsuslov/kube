#
#	Infinity Scroll Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  InfinityScroll = (el, options) ->
    new InfinityScroll::init(el, options)
  $.fn.infinityScroll = (options) ->
    @each ->
      $.data this, "infinity-scroll", {}
      $.data this, "infinity-scroll", InfinityScroll(this, options)
      return


  $.InfinityScroll = InfinityScroll
  $.InfinityScroll.NAME = "infinity-scroll"
  $.InfinityScroll.VERSION = "1.0"
  $.InfinityScroll.opts =
    url: false
    offset: 0
    limit: 20
    tolerance: 50
    pagination: false

  
  # Functionality
  InfinityScroll.fn = $.InfinityScroll:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @hidePagination()
      @build()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.InfinityScroll.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.InfinityScroll.NAME or namespace is $.InfinityScroll.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      $(window).on "DOMContentLoaded.tools.infinite-scroll load.tools.infinite-scroll resize.tools.infinite-scroll scroll.tools.infinite-scroll", $.proxy(->
        $last = @$element.children().last()
        @getData()  if @isElementInViewport($last[0])
        return
      , this)
      return

    getData: ->
      $.ajax
        url: @opts.url
        type: "post"
        data: "limit=" + @opts.limit + "&offset=" + @opts.offset
        success: $.proxy((data) ->
          if data is ""
            $(window).off ".tools.infinite-scroll"
            return
          @opts.offset = @opts.offset + @opts.limit
          @$element.append data
          @setCallback "loaded", data
          return
        , this)

      return

    hidePagination: ->
      return  unless @opts.pagination
      $(@opts.pagination).hide()
      return

    isElementInViewport: (el) ->
      rect = el.getBoundingClientRect()
      rect.top >= 0 and rect.left >= 0 and rect.bottom <= $(window).height() + @opts.tolerance and rect.right <= $(window).width()

  $(window).on "load.tools.infinity-scroll", ->
    $("[data-tools=\"infinity-scroll\"]").infinityScroll()
    return

  
  # constructor
  InfinityScroll::init:: = InfinityScroll::
  return
) jQuery
