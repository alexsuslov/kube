#
#	Accordion Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Accordion = (el, options) ->
    new Accordion::init(el, options)
  $.fn.accordion = (options) ->
    @each ->
      $.data this, "accordion", {}
      $.data this, "accordion", Accordion(this, options)
      return


  $.Accordion = Accordion
  $.Accordion.NAME = "accordion"
  $.Accordion.VERSION = "1.0"
  $.Accordion.opts =
    scroll: false
    collapse: true
    toggle: true
    titleClass: ".accordion-title"
    panelClass: ".accordion-panel"

  
  # Functionality
  Accordion.fn = $.Accordion:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @build()
      if @opts.collapse
        @closeAll()
      else
        @openAll()
      @loadFromHash()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Accordion.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Accordion.NAME or namespace is $.Accordion.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    getTitles: ->
      @titles = @$element.find(@opts.titleClass)
      @titles.append $("<span />").addClass("accordion-toggle")
      @titles.each ->
        $el = $(this)
        $el.attr "rel", $el.attr("href")
        return

      return

    getPanels: ->
      @panels = @$element.find(@opts.panelClass)
      return

    build: ->
      @getTitles()
      @getPanels()
      @titles.on "click", $.proxy(@toggle, this)
      return

    loadFromHash: ->
      return  if top.location.hash is ""
      return  unless @opts.scroll
      return  if @$element.find("[rel=" + top.location.hash + "]").size() is 0
      @open top.location.hash
      @scrollTo top.location.hash
      return

    toggle: (e) ->
      e.preventDefault()
      e.stopPropagation()
      hash = $(e.target).attr("rel")
      if @opts.toggle
        $target = $(e.target)
        $title = $target.closest(@opts.titleClass)
        opened = $title.hasClass("accordion-title-opened")
        @closeAll()
        @open hash  unless opened
      else
        if $("[rel=" + hash + "]").hasClass("accordion-title-opened")
          @close hash
        else
          @open hash
      return

    open: (hash) ->
      @$title = $("[rel=" + hash + "]")
      @$panel = $(hash)
      top.location.hash = hash
      @setStatus "open"
      @$panel.show()
      @setCallback "opened", @$title, @$panel
      return

    close: (hash) ->
      @$title = $("[rel=" + hash + "]")
      @$panel = $(hash)
      @setStatus "close"
      @$panel.hide()
      @setCallback "closed", @$title, @$panel
      return

    setStatus: (command) ->
      items =
        toggle: @$title.find("span.accordion-toggle")
        title: @$title
        panel: @$panel

      $.each items, (i, s) ->
        if command is "close"
          s.removeClass("accordion-" + i + "-opened").addClass "accordion-" + i + "-closed"
        else
          s.removeClass("accordion-" + i + "-closed").addClass "accordion-" + i + "-opened"
        return

      return

    openAll: ->
      @titles.each $.proxy((i, s) ->
        @open $(s).attr("rel")
        return
      , this)
      return

    closeAll: ->
      @titles.each $.proxy((i, s) ->
        @close $(s).attr("rel")
        return
      , this)
      return

    scrollTo: (id) ->
      $("html, body").animate
        scrollTop: $(id).offset().top - 50
      , 500
      return

  $(window).on "load.tools.accordion", ->
    $("[data-tools=\"accordion\"]").accordion()
    return

  
  # constructor
  Accordion::init:: = Accordion::
  return
) jQuery
