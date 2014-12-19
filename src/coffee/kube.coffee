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

#
#	Buttons Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Buttons = (el, options) ->
    new Buttons::init(el, options)
  $.fn.buttons = (options) ->
    @each ->
      $.data this, "buttons", {}
      $.data this, "buttons", Buttons(this, options)
      return


  $.Buttons = Buttons
  $.Buttons.NAME = "buttons"
  $.Buttons.VERSION = "1.0"
  $.Buttons.opts =
    className: "btn"
    activeClassName: "btn-active"
    target: false
    type: "switch" # switch, toggle, segmented

  
  # Functionality
  Buttons.fn = $.Buttons:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @buttons = @getButtons()
      @value = @getValue()
      @buttons.each $.proxy((i, s) ->
        $s = $(s)
        @setDefault $s
        $s.click $.proxy((e) ->
          e.preventDefault()
          if @opts.type is "segmented"
            @setSegmented $s
          else if @opts.type is "toggle"
            @setToggle $s
          else
            @setBasic $s
          return
        , this)
        return
      , this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Buttons.opts), @$element.data(), options)
      return

    getButtons: ->
      (if (@opts.type is "toggle") then @$element else @$element.find("." + @opts.className))

    getValue: ->
      (if (@opts.type is "segmented") then $(@opts.target).val().split(",") else $(@opts.target).val())

    setDefault: ($el) ->
      if @opts.type is "segmented" and $.inArray($el.val(), @value) isnt -1
        @setActive $el
      else @setActive $el  if (@opts.type is "toggle" and @value is 1) or @value is $el.val()
      return

    setBasic: ($el) ->
      @setInActive @buttons
      @setActive $el
      $(@opts.target).val $el.val()
      return

    setSegmented: ($el) ->
      $target = $(@opts.target)
      @value = $target.val().split(",")
      unless $el.hasClass(@opts.activeClassName)
        @setActive $el
        @value.push $el.val()
      else
        @setInActive $el
        @value.splice @value.indexOf($el.val()), 1
      $target.val @value.join(",").replace(/^,/, "")
      return

    setToggle: ($el) ->
      if $el.hasClass(@opts.activeClassName)
        @setInActive $el
        $(@opts.target).val 0
      else
        @setActive $el
        $(@opts.target).val 1
      return

    setActive: ($el) ->
      $el.addClass @opts.activeClassName
      return

    setInActive: ($el) ->
      $el.removeClass @opts.activeClassName
      return

  $(window).on "load.tools.buttons", ->
    $("[data-tools=\"buttons\"]").buttons()
    return

  
  # constructor
  Buttons::init:: = Buttons::
  return
) jQuery

#
#	CheckAll Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  CheckAll = (el, options) ->
    new CheckAll::init(el, options)
  $.fn.checkAll = (options) ->
    @each ->
      $.data this, "checkAll", {}
      $.data this, "checkAll", CheckAll(this, options)
      return


  $.CheckAll = CheckAll
  $.CheckAll.opts =
    classname: false
    parent: false
    highlight: "highlight"
    target: false

  
  # Functionality
  CheckAll.fn = $.CheckAll:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$elements = $("." + @opts.classname)
      @$target = $(@opts.target)
      
      # load
      @$element.on "click", $.proxy(@load, this)
      @setter = (if (@opts.target) then @$target.val().split(",") else [])
      @$elements.each $.proxy(@setOnStart, this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.CheckAll.opts), @$element.data(), options)
      return

    load: ->
      if @$element.prop("checked")
        @$elements.prop "checked", true
        if @opts.parent or @opts.target
          @$elements.each $.proxy((i, s) ->
            $s = $(s)
            @setHighlight $s
            @setValue $s.val()
            return
          , this)
      else
        @$elements.prop "checked", false
        @$elements.each $.proxy(@removeHighlight, this)  if @opts.parent
        @$target.val ""  if @opts.target
      return

    setOnStart: (i, el) ->
      $el = $(el)
      if @$element.prop("checked") or (@setter and ($.inArray($el.val(), @setter) isnt -1))
        $el.prop "checked", true
        @setHighlight $el
      $el.on "click", $.proxy(->
        checkedSize = @$elements.filter(":checked").size()
        if $el.prop("checked")
          @setValue $el.val()
          @setHighlight $el
        else
          @removeValue $el.val()
          @removeHighlight $el
        prop = (if (checkedSize isnt @$elements.size()) then false else true)
        @$element.prop "checked", prop
        return
      , this)
      return

    setHighlight: ($el) ->
      return  unless @opts.parent
      $el.closest(@opts.parent).addClass @opts.highlight
      return

    removeHighlight: (i, $el) ->
      return  unless @opts.parent
      $($el).closest(@opts.parent).removeClass @opts.highlight
      return

    setValue: (value) ->
      return  unless @opts.target
      str = @$target.val()
      arr = str.split(",")
      arr.push value
      arr = [value]  if str is ""
      @$target.val arr.join(",")
      return

    removeValue: (value) ->
      return  unless @opts.target
      arr = @$target.val().split(",")
      index = arr.indexOf(value)
      arr.splice index, 1
      @$target.val arr.join(",")
      return

  $(window).on "load.tools.buttons", ->
    $("[data-tools=\"check-all\"]").checkAll()
    return

  
  # constructor
  CheckAll::init:: = CheckAll::
  return
) jQuery

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

#
#	Modal Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Modal = (el, options) ->
    new Modal::init(el, options)
  $.fn.modal = (options) ->
    val = []
    args = Array::slice.call(arguments, 1)
    if typeof options is "string"
      @each ->
        instance = $.data(this, "modal")
        if typeof instance isnt "undefined" and $.isFunction(instance[options])
          methodVal = instance[options].apply(instance, args)
          val.push methodVal  if methodVal isnt `undefined` and methodVal isnt instance
        else
          $.error "No such method \"" + options + "\" for Modal"
        return

    else
      @each ->
        $.data this, "modal", {}
        $.data this, "modal", Modal(this, options)
        return

    if val.length is 0
      this
    else if val.length is 1
      val[0]
    else
      val

  $.Modal = Modal
  $.Modal.NAME = "modal"
  $.Modal.VERSION = "1.0"
  $.Modal.opts =
    title: ""
    width: 500
    blur: false

  
  # Functionality
  Modal.fn = $.Modal:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$element.on "click.tools.modal", $.proxy(@load, this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Modal.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Modal.NAME or namespace is $.Modal.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    load: ->
      @build()
      @enableEvents()
      @setTitle()
      @setDraggable()
      @setContent()
      return

    build: ->
      @buildOverlay()
      @$modalBox = $("<div class=\"modal-box\" />").hide()
      @$modal = $("<div class=\"modal\" />")
      @$modalHeader = $("<header />")
      @$modalClose = $("<span class=\"modal-close\" />").html("&times;")
      @$modalBody = $("<section />")
      @$modalFooter = $("<footer />")
      @$modal.append @$modalHeader
      @$modal.append @$modalClose
      @$modal.append @$modalBody
      @$modal.append @$modalFooter
      @$modalBox.append @$modal
      @$modalBox.appendTo document.body
      return

    buildOverlay: ->
      @$modalOverlay = $("<div id=\"modal-overlay\">").hide()
      $("body").prepend @$modalOverlay
      if @opts.blur
        @blurredElements = $("body").children("div, section, header, article, pre, aside, table").not(".modal, .modal-box, #modal-overlay")
        @blurredElements.addClass "modal-blur"
      return

    show: ->
      
      # modal loading callback
      @setCallback "loading", @$modal
      @bodyOveflow = $(document.body).css("overflow")
      $(document.body).css "overflow", "hidden"
      if @isMobile()
        @showOnMobile()
      else
        @showOnDesktop()
      @$modalOverlay.show()
      @$modalBox.show()
      @setButtonsWidth()
      
      # resize
      unless @isMobile()
        setTimeout $.proxy(@showOnDesktop, this), 0
        $(window).on "resize.tools.modal", $.proxy(@resize, this)
      
      # modal shown callback
      @setCallback "opened", @$modal
      
      # fix bootstrap modal focus
      $(document).off "focusin.modal"
      return

    showOnDesktop: ->
      height = @$modal.outerHeight()
      windowHeight = $(window).height()
      windowWidth = $(window).width()
      if @opts.width > windowWidth
        @$modal.css
          width: "96%"
          marginTop: (windowHeight / 2 - height / 2) + "px"

        return
      if height > windowHeight
        @$modal.css
          width: @opts.width + "px"
          marginTop: "20px"

      else
        @$modal.css
          width: @opts.width + "px"
          marginTop: (windowHeight / 2 - height / 2) + "px"

      return

    showOnMobile: ->
      @$modal.css
        width: "96%"
        marginTop: "2%"

      return

    resize: ->
      if @isMobile()
        @showOnMobile()
      else
        @showOnDesktop()
      return

    setTitle: ->
      @$modalHeader.html @opts.title
      return

    setContent: ->
      if typeof @opts.content is "object" or @opts.content.search("#") is 0
        @type = "html"
        @$modalBody.html $(@opts.content).html()
        @show()
      else
        $.ajax
          url: @opts.content
          cache: false
          success: $.proxy((data) ->
            @$modalBody.html data
            @show()
            return
          , this)

      return

    setDraggable: ->
      return  if typeof $.fn.draggable is "undefined"
      @$modal.draggable handle: @$modalHeader
      @$modalHeader.css "cursor", "move"
      return

    createCancelButton: (label) ->
      label = "Cancel"  if typeof label is "undefined"
      button = $("<button>").addClass("btn modal-close-btn").html(label)
      button.on "click", $.proxy(@close, this)
      @$modalFooter.append button
      return

    createDeleteButton: (label) ->
      label = "Delete"  if typeof label is "undefined"
      @createButton label, "red"

    createActionButton: (label) ->
      label = "Ok"  if typeof label is "undefined"
      @createButton label, "blue"

    createButton: (label, className) ->
      button = $("<button>").addClass("btn").addClass("btn-" + className).html(label)
      @$modalFooter.append button
      button

    setButtonsWidth: ->
      buttons = @$modalFooter.find("button")
      buttonsSize = buttons.size()
      return  if buttonsSize is 0
      buttons.css "width", (100 / buttonsSize) + "%"
      return

    enableEvents: ->
      @$modalClose.on "click.tools.modal", $.proxy(@close, this)
      $(document).on "keyup.tools.modal", $.proxy(@closeHandler, this)
      @$modalBox.on "click.tools.modal", $.proxy(@close, this)
      return

    disableEvents: ->
      @$modalClose.off "click.tools.modal"
      $(document).off "keyup.tools.modal"
      @$modalBox.off "click.tools.modal"
      $(window).off "resize.tools.modal"
      return

    closeHandler: (e) ->
      return  unless e.which is 27
      @close()
      return

    close: (e) ->
      if e
        return  if not $(e.target).hasClass("modal-close-btn") and e.target isnt @$modalClose[0] and e.target isnt @$modalBox[0]
        e.preventDefault()
      return  unless @$modalBox
      @disableEvents()
      @$modalOverlay.remove()
      @$modalBox.fadeOut "fast", $.proxy(->
        @$modalBox.remove()
        $(document.body).css "overflow", @bodyOveflow
        
        # remove blur
        @blurredElements.removeClass "modal-blur"  if @opts.blur and typeof @blurredElements isnt "undefined"
        @setCallback "closed"
        return
      , this)
      return

    isMobile: ->
      mq = window.matchMedia("(max-width: 767px)")
      (if (mq.matches) then true else false)

  $(window).on "load.tools.modal", ->
    $("[data-tools=\"modal\"]").modal()
    return

  
  # constructor
  Modal::init:: = Modal::
  return
) jQuery

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

#
#	Progress Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  $.progress =
    show: ->
      if $("#tools-progress").length isnt 0
        $("#tools-progress").fadeIn()
      else
        $progress = $("<div id=\"tools-progress\"><span></span></div>").hide()
        $(document.body).append $progress
        $("#tools-progress").fadeIn()
      return

    update: (value) ->
      @show()
      $("#tools-progress").find("span").css "width", value + "%"
      return

    hide: ->
      $("#tools-progress").fadeOut 1500
      return

  return
) jQuery

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

#
#	TextFit Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Textfit = (el, options) ->
    new Textfit::init(el, options)
  $.fn.textfit = (options) ->
    @each ->
      $.data this, "textfit", {}
      $.data this, "textfit", Textfit(this, options)
      return


  $.Textfit = Textfit
  $.Textfit.NAME = "textfit"
  $.Textfit.VERSION = "1.0"
  $.Textfit.opts =
    min: "10px"
    max: "100px"
    compressor: 1

  
  # Functionality
  Textfit.fn = $.Textfit:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$element.css "font-size", Math.max(Math.min(@$element.width() / (@opts.compressor * 10), parseFloat(@opts.max)), parseFloat(@opts.min))
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Textfit.opts), @$element.data(), options)
      return

  $(window).on "load.tools.textfit", ->
    $("[data-tools=\"textfit\"]").textfit()
    return

  
  # constructor
  Textfit::init:: = Textfit::
  return
) jQuery

#
#	Tooltip Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Tooltip = (el, options) ->
    new Tooltip::init(el, options)
  $.fn.tooltip = (options) ->
    @each ->
      $.data this, "tooltip", {}
      $.data this, "tooltip", Tooltip(this, options)
      return


  $.Tooltip = Tooltip
  $.Tooltip.NAME = "tooltip"
  $.Tooltip.VERSION = "1.0"
  $.Tooltip.opts = theme: false
  
  # Functionality
  Tooltip.fn = $.Tooltip:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @$element.on "mouseover", $.proxy(@show, this)
      @$element.on "mouseout", $.proxy(@hide, this)
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Tooltip.opts), @$element.data(), options)
      return

    show: ->
      $(".tooltip").hide()
      text = @$element.attr("title")
      @$element.data "cached-title", text
      @$element.attr "title", ""
      @tooltip = $("<div class=\"tooltip\" />").html(text).hide()
      @tooltip.addClass "tooltip-theme-" + @opts.theme  if @opts.theme isnt false
      @tooltip.css
        top: (@$element.offset().top + @$element.innerHeight()) + "px"
        left: @$element.offset().left + "px"

      $("body").append @tooltip
      @tooltip.show()
      return

    hide: ->
      @tooltip.fadeOut "fast", $.proxy(->
        @tooltip.remove()
        return
      , this)
      @$element.attr "title", @$element.data("cached-title")
      @$element.data "cached-title", ""
      return

  
  # Constructor
  Tooltip::init:: = Tooltip::
  $ ->
    $("[data-tools=\"tooltip\"]").tooltip()
    return

  return
) jQuery

#
#	Upload Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  
  # Plugin
  
  # Initialization
  Upload = (el, options) ->
    new Upload::init(el, options)
  $.fn.upload = (options) ->
    @each ->
      $.data this, "upload", {}
      $.data this, "upload", Upload(this, options)
      return


  $.Upload = Upload
  $.Upload.NAME = "upload"
  $.Upload.VERSION = "1.0"
  $.Upload.opts =
    url: false
    placeholder: "Drop file here or "
    param: "file"

  
  # Functionality
  Upload.fn = $.Upload:: =
    
    # Initialization
    init: (el, options) ->
      @$element = (if el isnt false then $(el) else false)
      @loadOptions options
      @load()
      return

    loadOptions: (options) ->
      @opts = $.extend({}, $.extend(true, {}, $.Upload.opts), @$element.data(), options)
      return

    setCallback: (type, e, data) ->
      events = $._data(@$element[0], "events")
      if events and typeof events[type] isnt "undefined"
        value = []
        len = events[type].length
        i = 0

        while i < len
          namespace = events[type][i].namespace
          if namespace is "tools." + $.Upload.NAME or namespace is $.Upload.NAME + ".tools"
            callback = events[type][i].handler
            value.push (if (typeof data is "undefined") then callback.call(this, e) else callback.call(this, e, data))
          i++
        if value.length is 1
          return value[0]
        else
          return value
      (if (typeof data is "undefined") then e else data)

    load: ->
      @$droparea = $("<div class=\"tools-droparea\" />")
      @$placeholdler = $("<div class=\"tools-droparea-placeholder\" />").text(@opts.placeholder)
      @$droparea.append @$placeholdler
      @$element.after @$droparea
      @$placeholdler.append @$element
      @$droparea.off ".tools.upload"
      @$element.off ".tools.upload"
      @$droparea.on "dragover.tools.upload", $.proxy(@onDrag, this)
      @$droparea.on "dragleave.tools.upload", $.proxy(@onDragLeave, this)
      
      # change
      @$element.on "change.tools.upload", $.proxy((e) ->
        e = e.originalEvent or e
        @traverseFile @$element[0].files[0], e
        return
      , this)
      
      # drop
      @$droparea.on "drop.tools.upload", $.proxy((e) ->
        e.preventDefault()
        @$droparea.removeClass("drag-hover").addClass "drag-drop"
        @onDrop e
        return
      , this)
      return

    onDrop: (e) ->
      e = e.originalEvent or e
      files = e.dataTransfer.files
      @traverseFile files[0], e
      return

    traverseFile: (file, e) ->
      formData = (if !!window.FormData then new FormData() else null)
      formData.append @opts.param, file  if window.FormData
      $.progress.show()  if $.progress
      @sendData formData, e
      return

    sendData: (formData, e) ->
      xhr = new XMLHttpRequest()
      xhr.open "POST", @opts.url
      
      # complete
      xhr.onreadystatechange = $.proxy(->
        if xhr.readyState is 4
          data = xhr.responseText
          data = data.replace(/^\[/, "")
          data = data.replace(/\]$/, "")
          json = ((if typeof data is "string" then $.parseJSON(data) else data))
          $.progress.hide()  if $.progress
          @$droparea.removeClass "drag-drop"
          @setCallback "success", json
        return
      , this)
      xhr.send formData
      return

    onDrag: (e) ->
      e.preventDefault()
      @$droparea.addClass "drag-hover"
      return

    onDragLeave: (e) ->
      e.preventDefault()
      @$droparea.removeClass "drag-hover"
      return

  
  # Constructor
  Upload::init:: = Upload::
  $ ->
    $("[data-tools=\"upload\"]").upload()
    return

  return
) jQuery
