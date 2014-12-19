#
#	FilterBox Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Filterbox = (el, options) ->
    new Filterbox::init(el, options)
  $.fn.filterbox = (options) ->
    @each ->
      $.data this, "filterbox", {}
      $.data this, "filterbox", Filterbox(this, options)
      return


  $.Filterbox = Filterbox
  $.Filterbox.NAME = "filterbox"
  $.Filterbox.VERSION = "1.0"
  
  # settings
  $.Filterbox.opts = placeholder: false
  
  # Functionality
  Filterbox.fn = $.Filterbox:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @build()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Filterbox.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Filterbox.NAME or namespace is $.Filterbox.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    build: ->
      @$sourceBox = $("<div class=\"filterbox\" />")
      @$sourceSelect = $("<span class=\"filterbox-toggle\" />")
      @$sourceLayer = $("<ul class=\"filterbox-list hide\" />")
      @$source = $("<input type=\"text\" id=\"" + @$element.attr("id") + "-input\" class=\"" + @$element.attr("class") + "\" />")
      @$sourceBox.append @$source
      @$sourceBox.append @$sourceSelect
      @$sourceBox.append @$sourceLayer
      @setPlaceholder()
      @$element.hide().after @$sourceBox
      @$element.find("option").each $.proxy(@buildListItemsFromOptions, this)
      @$source.on "keyup", $.proxy(@clearSelected, this)
      @$sourceSelect.on "click", $.proxy(@load, this)
      @preventBodyScroll()
      return

    load: (e) ->
      e.preventDefault()
      if @$sourceLayer.hasClass("open")
        @close()
        return
      value = @$element.val()
      @$sourceLayer.addClass("open").show()
      items = @$sourceLayer.find("li").removeClass("active")
      @setSelectedItem items, value
      $(document).on "click.tools.filterbox", $.proxy(@close, this)
      $(document).on "keydown.tools.filterbox", $.proxy((e) ->
        key = e.which
        $el = undefined
        item = undefined
        if key is 38 # up
          e.preventDefault()
          if items.hasClass("active")
            item = items.filter("li.active")
            item.removeClass "active"
            prev = item.prev()
            $el = (if (prev.size() isnt 0) then $el = prev else items.last())
          else
            $el = items.last()
          $el.addClass "active"
          @setScrollTop $el
        else if key is 40 # down
          e.preventDefault()
          if items.hasClass("active")
            item = items.filter("li.active")
            item.removeClass "active"
            next = item.next()
            $el = (if (next.size() isnt 0) then next else items.first())
          else
            $el = items.first()
          $el.addClass "active"
          @setScrollTop $el
        else if key is 13 # enter
          return  unless items.hasClass("active")
          item = items.filter("li.active")
          @onItemClick e, item
        # esc
        else @close()  if key is 27
        return
      , this)
      return

    clearSelected: ->
      @$element.val 0  if @$source.val().length is 0
      return

    setSelectedItem: (items, value) ->
      selectEl = items.filter("[rel=" + value + "]")
      if selectEl.size() is 0
        selectEl = false
        
        # if user typed value
        sourceValue = @$source.val()
        $.each items, (i, s) ->
          $s = $(s)
          selectEl = $s  if $s.text() is sourceValue
          return

        return  if selectEl is false
      selectEl.addClass "active"
      @setScrollTop selectEl
      return

    setScrollTop: ($el) ->
      @$sourceLayer.scrollTop @$sourceLayer.scrollTop() + $el.position().top - 40
      return

    buildListItemsFromOptions: (i, s) ->
      $el = $(s)
      val = $el.val()
      return  if val is 0
      item = $("<li />")
      item.attr("rel", val).text $el.html()
      item.on "click", $.proxy(@onItemClick, this)
      @$sourceLayer.append item
      return

    onItemClick: (e, item) ->
      e.preventDefault()
      $el = $(item or e.target)
      rel = $el.attr("rel")
      text = $el.text()
      @$source.val text
      @$element.val rel
      @close()
      @setCallback "select",
        id: rel
        value: text

      return

    preventBodyScroll: ->
      @$sourceLayer.on "mouseover", ->
        $("html").css "overflow", "hidden"
        return

      @$sourceLayer.on "mouseout", ->
        $("html").css "overflow", ""
        return

      return

    setPlaceholder: ->
      return  unless @opts.placeholder
      @$source.attr "placeholder", @opts.placeholder
      return

    close: (e) ->
      return  if e and ($(e.target).hasClass("filterbox-toggle") or $(e.target).closest("div.filterbox").size() is 1)
      @$sourceLayer.removeClass("open").hide()
      $(document).off ".tools.filterbox"
      return

  $(window).on "load.tools.filterbox", ->
    $("[data-tools=\"filterbox\"]").filterbox()
    return

  
  # constructor
  Filterbox::init:: = Filterbox::
  return
) jQuery
