((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.accordion = (c) ->
    @each ->
      b.data this, "accordion", {}
      b.data this, "accordion", a(this, c)
      return


  b.Accordion = a
  b.Accordion.NAME = "accordion"
  b.Accordion.VERSION = "1.0"
  b.Accordion.opts =
    scroll: false
    collapse: true
    toggle: true
    titleClass: ".accordion-title"
    panelClass: ".accordion-panel"

  a.fn = b.Accordion:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @build()
      if @opts.collapse
        @closeAll()
      else
        @openAll()
      @loadFromHash()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Accordion.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Accordion.NAME or c is b.Accordion.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    getTitles: ->
      @titles = @$element.find(@opts.titleClass)
      @titles.append b("<span />").addClass("accordion-toggle")
      @titles.each ->
        c = b(this)
        c.attr "rel", c.attr("href")
        return

      return

    getPanels: ->
      @panels = @$element.find(@opts.panelClass)
      return

    build: ->
      @getTitles()
      @getPanels()
      @titles.on "click", b.proxy(@toggle, this)
      return

    loadFromHash: ->
      return  if top.location.hash is ""
      return  unless @opts.scroll
      return  if @$element.find("[rel=" + top.location.hash + "]").size() is 0
      @open top.location.hash
      @scrollTo top.location.hash
      return

    toggle: (g) ->
      g.preventDefault()
      g.stopPropagation()
      f = b(g.target).attr("rel")
      if @opts.toggle
        c = b(g.target)
        d = c.closest(@opts.titleClass)
        h = d.hasClass("accordion-title-opened")
        @closeAll()
        @open f  unless h
      else
        if b("[rel=" + f + "]").hasClass("accordion-title-opened")
          @close f
        else
          @open f
      return

    open: (c) ->
      @$title = b("[rel=" + c + "]")
      @$panel = b(c)
      top.location.hash = c
      @setStatus "open"
      @$panel.show()
      @setCallback "opened", @$title, @$panel
      return

    close: (c) ->
      @$title = b("[rel=" + c + "]")
      @$panel = b(c)
      @setStatus "close"
      @$panel.hide()
      @setCallback "closed", @$title, @$panel
      return

    setStatus: (d) ->
      c =
        toggle: @$title.find("span.accordion-toggle")
        title: @$title
        panel: @$panel

      b.each c, (e, f) ->
        if d is "close"
          f.removeClass("accordion-" + e + "-opened").addClass "accordion-" + e + "-closed"
        else
          f.removeClass("accordion-" + e + "-closed").addClass "accordion-" + e + "-opened"
        return

      return

    openAll: ->
      @titles.each b.proxy((c, d) ->
        @open b(d).attr("rel")
        return
      , this)
      return

    closeAll: ->
      @titles.each b.proxy((c, d) ->
        @close b(d).attr("rel")
        return
      , this)
      return

    scrollTo: (c) ->
      b("html, body").animate
        scrollTop: b(c).offset().top - 50
      , 500
      return

  b(window).on "load.tools.accordion", ->
    b("[data-tools=\"accordion\"]").accordion()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.autocomplete = (c) ->
    @each ->
      b.data this, "autocomplete", {}
      b.data this, "autocomplete", a(this, c)
      return


  b.Autocomplete = a
  b.Autocomplete.NAME = "autocomplete"
  b.Autocomplete.VERSION = "1.0"
  b.Autocomplete.opts =
    url: false
    min: 2
    set: "value"

  a.fn = b.Autocomplete:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @build()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Autocomplete.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Autocomplete.NAME or c is b.Autocomplete.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      @result = b("<ul class=\"autocomplete\">").hide()
      @pos = @$element.offset()
      @elementHeight = @$element.innerHeight()
      b("body").append @result
      @placement = (if ((b(document).height() - (@pos.top + @elementHeight)) < @result.height()) then "top" else "bottom")
      b(document).on "click", b.proxy(@hide, this)
      @$element.on "keyup", b.proxy((d) ->
        c = @$element.val()
        if c.length >= @opts.min
          @$element.addClass "autocomplete-in"
          @result.addClass "autocomplete-open"
          @listen d
        else
          @hide()
        return
      , this)
      return

    lookup: ->
      b.ajax
        url: @opts.url
        type: "post"
        data: @$element.attr("name") + "=" + @$element.val()
        success: b.proxy((c) ->
          d = b.parseJSON(c)
          @result.html ""
          b.each d, b.proxy((h, j) ->
            f = b("<li>")
            g = b("<a href=\"#\" rel=\"" + j.id + "\">").html(j.value).on("click", b.proxy(@set, this))
            f.append g
            @result.append f
            return
          , this)
          e = (if (@placement is "top") then (@pos.top - @result.height() - @elementHeight) else (@pos.top + @elementHeight))
          @result.css
            top: e + "px"
            left: @pos.left + "px"

          @result.show()
          @active = false
          return
        , this)

      return

    listen: (c) ->
      return  unless @$element.hasClass("autocomplete-in")
      c.stopPropagation()
      c.preventDefault()
      switch c.keyCode
        when 40
          @select "next"
        when 38
          @select "prev"
        when 13
          @set()
        when 27
          @hide()
        else
          @lookup()

    select: (f) ->
      g = @result.find("a")
      e = g.size()
      c = @result.find("a.active")
      c.removeClass "active"
      d = (if (f is "next") then c.parent().next().children("a") else c.parent().prev().children("a"))
      d = (if (f is "next") then g.eq(0) else g.eq(e - 1))  if d.size() is 0
      d.addClass "active"
      @active = d
      return

    set: (f) ->
      c = b(@active)
      if f
        f.preventDefault()
        c = b(f.target)
      g = c.attr("rel")
      d = c.html()
      if @opts.set is "value"
        @$element.val d
      else
        @$element.val g
      @setCallback "set", g, d
      @hide()
      return

    hide: (c) ->
      return  if c and (b(c.target).hasClass("autocomplete-in") or b(c.target).hasClass("autocomplete-open") or b(c.target).parents().hasClass("autocomplete-open"))
      @$element.removeClass "autocomplete-in"
      @result.removeClass "autocomplete-open"
      @result.hide()
      return

  b(window).on "load.tools.autocomplete", ->
    b("[data-tools=\"autocomplete\"]").autocomplete()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.buttons = (c) ->
    @each ->
      b.data this, "buttons", {}
      b.data this, "buttons", a(this, c)
      return


  b.Buttons = a
  b.Buttons.NAME = "buttons"
  b.Buttons.VERSION = "1.0"
  b.Buttons.opts =
    className: "btn"
    activeClassName: "btn-active"
    target: false
    type: "switch"

  a.fn = b.Buttons:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @buttons = @getButtons()
      @value = @getValue()
      @buttons.each b.proxy((f, g) ->
        e = b(g)
        @setDefault e
        e.click b.proxy((h) ->
          h.preventDefault()
          if @opts.type is "segmented"
            @setSegmented e
          else
            if @opts.type is "toggle"
              @setToggle e
            else
              @setBasic e
          return
        , this)
        return
      , this)
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Buttons.opts), @$element.data(), c)
      return

    getButtons: ->
      (if (@opts.type is "toggle") then @$element else @$element.find("." + @opts.className))

    getValue: ->
      (if (@opts.type is "segmented") then b(@opts.target).val().split(",") else b(@opts.target).val())

    setDefault: (c) ->
      if @opts.type is "segmented" and b.inArray(c.val(), @value) isnt -1
        @setActive c
      else
        @setActive c  if (@opts.type is "toggle" and @value is 1) or @value is c.val()
      return

    setBasic: (c) ->
      @setInActive @buttons
      @setActive c
      b(@opts.target).val c.val()
      return

    setSegmented: (d) ->
      c = b(@opts.target)
      @value = c.val().split(",")
      unless d.hasClass(@opts.activeClassName)
        @setActive d
        @value.push d.val()
      else
        @setInActive d
        @value.splice @value.indexOf(d.val()), 1
      c.val @value.join(",").replace(/^,/, "")
      return

    setToggle: (c) ->
      if c.hasClass(@opts.activeClassName)
        @setInActive c
        b(@opts.target).val 0
      else
        @setActive c
        b(@opts.target).val 1
      return

    setActive: (c) ->
      c.addClass @opts.activeClassName
      return

    setInActive: (c) ->
      c.removeClass @opts.activeClassName
      return

  b(window).on "load.tools.buttons", ->
    b("[data-tools=\"buttons\"]").buttons()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.checkAll = (c) ->
    @each ->
      b.data this, "checkAll", {}
      b.data this, "checkAll", a(this, c)
      return


  b.CheckAll = a
  b.CheckAll.opts =
    classname: false
    parent: false
    highlight: "highlight"
    target: false

  a.fn = b.CheckAll:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @$elements = b("." + @opts.classname)
      @$target = b(@opts.target)
      @$element.on "click", b.proxy(@load, this)
      @setter = (if (@opts.target) then @$target.val().split(",") else [])
      @$elements.each b.proxy(@setOnStart, this)
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.CheckAll.opts), @$element.data(), c)
      return

    load: ->
      if @$element.prop("checked")
        @$elements.prop "checked", true
        if @opts.parent or @opts.target
          @$elements.each b.proxy((d, e) ->
            c = b(e)
            @setHighlight c
            @setValue c.val()
            return
          , this)
      else
        @$elements.prop "checked", false
        @$elements.each b.proxy(@removeHighlight, this)  if @opts.parent
        @$target.val ""  if @opts.target
      return

    setOnStart: (d, e) ->
      c = b(e)
      if @$element.prop("checked") or (@setter and (b.inArray(c.val(), @setter) isnt -1))
        c.prop "checked", true
        @setHighlight c
      c.on "click", b.proxy(->
        f = @$elements.filter(":checked").size()
        if c.prop("checked")
          @setValue c.val()
          @setHighlight c
        else
          @removeValue c.val()
          @removeHighlight c
        g = (if (f isnt @$elements.size()) then false else true)
        @$element.prop "checked", g
        return
      , this)
      return

    setHighlight: (c) ->
      return  unless @opts.parent
      c.closest(@opts.parent).addClass @opts.highlight
      return

    removeHighlight: (d, c) ->
      return  unless @opts.parent
      b(c).closest(@opts.parent).removeClass @opts.highlight
      return

    setValue: (d) ->
      return  unless @opts.target
      e = @$target.val()
      c = e.split(",")
      c.push d
      c = [d]  if e is ""
      @$target.val c.join(",")
      return

    removeValue: (e) ->
      return  unless @opts.target
      c = @$target.val().split(",")
      d = c.indexOf(e)
      c.splice d, 1
      @$target.val c.join(",")
      return

  b(window).on "load.tools.buttons", ->
    b("[data-tools=\"check-all\"]").checkAll()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.dropdown = (c) ->
    @each ->
      b.data this, "dropdown", {}
      b.data this, "dropdown", a(this, c)
      return


  b.Dropdown = a
  b.Dropdown.NAME = "dropdown"
  b.Dropdown.VERSION = "1.0"
  b.Dropdown.opts =
    target: false
    targetClose: false
    height: false
    width: false

  a.fn = b.Dropdown:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @build()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Dropdown.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Dropdown.NAME or c is b.Dropdown.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      @$dropdown = b(@opts.target)
      @$dropdown.hide()
      @$caret = b("<b class=\"caret\"></b>")
      @$element.append @$caret
      @setCaretUp()
      @preventBodyScroll()
      @$element.click b.proxy(@toggle, this)
      return

    setCaretUp: ->
      c = @$element.offset().top + @$element.innerHeight() + @$dropdown.innerHeight()
      return  if b(document).height() > c
      @$caret.addClass "caret-up"
      return

    toggle: (c) ->
      c.preventDefault()
      if @$element.hasClass("dropdown-in")
        @hide()
      else
        @show()
      return

    getPlacement: (c) ->
      (if (b(document).height() < c) then "top" else "bottom")

    getPosition: ->
      (if (@$element.closest(".navigation-fixed").size() isnt 0) then "fixed" else "absolute")

    setPosition: ->
      j = @$element.position()
      h = @$element.innerHeight()
      k = @$element.innerWidth()
      l = @$dropdown.innerHeight()
      d = @$dropdown.innerWidth()
      g = @getPosition()
      f = @getPlacement(j.top + l + h)
      c = 0
      c = (d - k)  if b(window).width() < (j.left + d)
      i = undefined
      e = j.left - c
      if f is "bottom"
        @$caret.removeClass "caret-up"
        i = (if (g is "fixed") then h else j.top + h)
      else
        @$caret.addClass "caret-up"
        i = (if (g is "fixed") then l else j.top - l)
      @$dropdown.css
        position: g
        top: i + "px"
        left: e + "px"

      return

    show: ->
      b(".dropdown-in").removeClass "dropdown-in"
      b(".dropdown").removeClass("dropdown-open").hide()
      @$dropdown.css "min-height", @opts.height + "px"  if @opts.height
      @$dropdown.width @opts.width  if @opts.width
      @setPosition()
      @$dropdown.addClass("dropdown-open").show()
      @$element.addClass "dropdown-in"
      b(document).on "scroll.tools.dropdown", b.proxy(@setPosition, this)
      b(window).on "resize.tools.dropdown", b.proxy(@setPosition, this)
      b(document).on "click.tools.dropdown touchstart.tools.dropdown", b.proxy(@hide, this)
      if @opts.targetClose
        b(@opts.targetClose).on "click.tools.dropdown", b.proxy((c) ->
          c.preventDefault()
          @hide false
          return
        , this)
      b(document).on "keydown.tools.dropdown", b.proxy((c) ->
        @hide()  if c.which is 27
        return
      , this)
      @setCallback "opened", @$dropdown, @$element
      return

    preventBodyScroll: ->
      @$dropdown.on "mouseover", ->
        b("html").css "overflow", "hidden"
        return

      @$dropdown.on "mouseout", ->
        b("html").css "overflow", ""
        return

      return

    hide: (d) ->
      if d
        d = d.originalEvent or d
        c = b(d.target)
        return  if c.hasClass("caret") or c.hasClass("dropdown-in") or c.closest(".dropdown-open").size() isnt 0
      @$dropdown.removeClass("dropdown-open").hide()
      @$element.removeClass "dropdown-in"
      b(document).off ".tools.dropdown"
      b(window).off ".tools.dropdown"
      @setCallback "closed", @$dropdown, @$element
      return

  b(window).on "load.tools.dropdown", ->
    b("[data-tools=\"dropdown\"]").dropdown()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.filterbox = (c) ->
    @each ->
      b.data this, "filterbox", {}
      b.data this, "filterbox", a(this, c)
      return


  b.Filterbox = a
  b.Filterbox.NAME = "filterbox"
  b.Filterbox.VERSION = "1.0"
  b.Filterbox.opts = placeholder: false
  a.fn = b.Filterbox:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @build()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Filterbox.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Filterbox.NAME or c is b.Filterbox.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      @$sourceBox = b("<div class=\"filterbox\" />")
      @$sourceSelect = b("<span class=\"filterbox-toggle\" />")
      @$sourceLayer = b("<ul class=\"filterbox-list hide\" />")
      @$source = b("<input type=\"text\" id=\"" + @$element.attr("id") + "-input\" class=\"" + @$element.attr("class") + "\" />")
      @$sourceBox.append @$source
      @$sourceBox.append @$sourceSelect
      @$sourceBox.append @$sourceLayer
      @setPlaceholder()
      @$element.hide().after @$sourceBox
      @$element.find("option").each b.proxy(@buildListItemsFromOptions, this)
      @$source.on "keyup", b.proxy(@clearSelected, this)
      @$sourceSelect.on "click", b.proxy(@load, this)
      @preventBodyScroll()
      return

    load: (f) ->
      f.preventDefault()
      if @$sourceLayer.hasClass("open")
        @close()
        return
      d = @$element.val()
      @$sourceLayer.addClass("open").show()
      c = @$sourceLayer.find("li").removeClass("active")
      @setSelectedItem c, d
      b(document).on "click.tools.filterbox", b.proxy(@close, this)
      b(document).on "keydown.tools.filterbox", b.proxy((l) ->
        h = l.which
        g = undefined
        k = undefined
        if h is 38
          l.preventDefault()
          if c.hasClass("active")
            k = c.filter("li.active")
            k.removeClass "active"
            j = k.prev()
            g = (if (j.size() isnt 0) then g = j else c.last())
          else
            g = c.last()
          g.addClass "active"
          @setScrollTop g
        else
          if h is 40
            l.preventDefault()
            if c.hasClass("active")
              k = c.filter("li.active")
              k.removeClass "active"
              i = k.next()
              g = (if (i.size() isnt 0) then i else c.first())
            else
              g = c.first()
            g.addClass "active"
            @setScrollTop g
          else
            if h is 13
              return  unless c.hasClass("active")
              k = c.filter("li.active")
              @onItemClick l, k
            else
              @close()  if h is 27
        return
      , this)
      return

    clearSelected: ->
      @$element.val 0  if @$source.val().length is 0
      return

    setSelectedItem: (c, e) ->
      f = c.filter("[rel=" + e + "]")
      if f.size() is 0
        f = false
        d = @$source.val()
        b.each c, (h, j) ->
          g = b(j)
          f = g  if g.text() is d
          return

        return  if f is false
      f.addClass "active"
      @setScrollTop f
      return

    setScrollTop: (c) ->
      @$sourceLayer.scrollTop @$sourceLayer.scrollTop() + c.position().top - 40
      return

    buildListItemsFromOptions: (d, e) ->
      c = b(e)
      g = c.val()
      return  if g is 0
      f = b("<li />")
      f.attr("rel", g).text c.html()
      f.on "click", b.proxy(@onItemClick, this)
      @$sourceLayer.append f
      return

    onItemClick: (g, f) ->
      g.preventDefault()
      d = b(f or g.target)
      c = d.attr("rel")
      h = d.text()
      @$source.val h
      @$element.val c
      @close()
      @setCallback "select",
        id: c
        value: h

      return

    preventBodyScroll: ->
      @$sourceLayer.on "mouseover", ->
        b("html").css "overflow", "hidden"
        return

      @$sourceLayer.on "mouseout", ->
        b("html").css "overflow", ""
        return

      return

    setPlaceholder: ->
      return  unless @opts.placeholder
      @$source.attr "placeholder", @opts.placeholder
      return

    close: (c) ->
      return  if c and (b(c.target).hasClass("filterbox-toggle") or b(c.target).closest("div.filterbox").size() is 1)
      @$sourceLayer.removeClass("open").hide()
      b(document).off ".tools.filterbox"
      return

  b(window).on "load.tools.filterbox", ->
    b("[data-tools=\"filterbox\"]").filterbox()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.infinityScroll = (c) ->
    @each ->
      b.data this, "infinity-scroll", {}
      b.data this, "infinity-scroll", a(this, c)
      return


  b.InfinityScroll = a
  b.InfinityScroll.NAME = "infinity-scroll"
  b.InfinityScroll.VERSION = "1.0"
  b.InfinityScroll.opts =
    url: false
    offset: 0
    limit: 20
    tolerance: 50
    pagination: false

  a.fn = b.InfinityScroll:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @hidePagination()
      @build()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.InfinityScroll.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.InfinityScroll.NAME or c is b.InfinityScroll.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      b(window).on "DOMContentLoaded.tools.infinite-scroll load.tools.infinite-scroll resize.tools.infinite-scroll scroll.tools.infinite-scroll", b.proxy(->
        c = @$element.children().last()
        @getData()  if @isElementInViewport(c[0])
        return
      , this)
      return

    getData: ->
      b.ajax
        url: @opts.url
        type: "post"
        data: "limit=" + @opts.limit + "&offset=" + @opts.offset
        success: b.proxy((c) ->
          if c is ""
            b(window).off ".tools.infinite-scroll"
            return
          @opts.offset = @opts.offset + @opts.limit
          @$element.append c
          @setCallback "loaded", c
          return
        , this)

      return

    hidePagination: ->
      return  unless @opts.pagination
      b(@opts.pagination).hide()
      return

    isElementInViewport: (c) ->
      d = c.getBoundingClientRect()
      d.top >= 0 and d.left >= 0 and d.bottom <= b(window).height() + @opts.tolerance and d.right <= b(window).width()

  b(window).on "load.tools.infinity-scroll", ->
    b("[data-tools=\"infinity-scroll\"]").infinityScroll()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.livesearch = (c) ->
    @each ->
      b.data this, "livesearch", {}
      b.data this, "livesearch", a(this, c)
      return


  b.Livesearch = a
  b.Livesearch.NAME = "livesearch"
  b.Livesearch.VERSION = "1.0"
  b.Livesearch.opts =
    url: false
    target: false
    min: 2
    params: false
    appendForms: false

  a.fn = b.Livesearch:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @build()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Livesearch.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Livesearch.NAME or c is b.Livesearch.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      @$box = b("<span class=\"livesearch-box\" />")
      @$element.after @$box
      @$box.append @$element
      @$element.off "keyup.tools.livesearch"
      @$element.on "keyup.tools.livesearch", b.proxy(@load, this)
      @$icon = b("<span class=\"livesearch-icon\" />")
      @$box.append @$icon
      @$close = b("<span class=\"close\" />").hide()
      @$box.append @$close
      @$close.off "click.tools.livesearch"
      @$close.on "click.tools.livesearch", b.proxy(->
        @search()
        @$element.val("").focus()
        @$close.hide()
        return
      , this)
      return

    toggleClose: (c) ->
      if c is 0
        @$close.hide()
      else
        @$close.show()
      return

    load: ->
      f = @$element.val()
      e = ""
      if f.length > @opts.min
        c = "q"
        c = @$element.attr("name")  unless typeof @$element.attr("name") is "undefined"
        e += "&" + c + "=" + f
        e = @appendForms(e)
        h = ""
        if @opts.params
          @opts.params = b.trim(@opts.params.replace("{", "").replace("}", ""))
          d = @opts.params.split(",")
          g = {}
          b.each d, (j, i) ->
            l = i.split(":")
            g[b.trim(l[0])] = b.trim(l[1])
            return

          h = []
          b.each g, b.proxy((j, i) ->
            h.push j + "=" + i
            return
          , this)
          h = h.join("&")
          e += "&" + h
      @toggleClose f.length
      @search e
      return

    appendForms: (c) ->
      return c  unless @opts.appendForms
      b.each @opts.appendForms, (d, e) ->
        c += "&" + b(e).serialize()
        return

      c

    search: (c) ->
      b.ajax
        url: @opts.url
        type: "post"
        data: c
        success: b.proxy((d) ->
          b(@opts.target).html d
          @setCallback "result", d
          return
        , this)

      return

  b(window).on "load.tools.livesearch", ->
    b("[data-tools=\"livesearch\"]").livesearch()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.message = (d) ->
    e = []
    c = Array::slice.call(arguments, 1)
    if typeof d is "string"
      @each ->
        g = b.data(this, "message")
        if typeof g isnt "undefined" and b.isFunction(g[d])
          f = g[d].apply(g, c)
          e.push f  if f isnt `undefined` and f isnt g
        else
          b.error "No such method \"" + d + "\" for Message"
        return

    else
      @each ->
        b.data this, "message", {}
        b.data this, "message", a(this, d)
        return

    if e.length is 0
      this
    else
      if e.length is 1
        e[0]
      else
        e

  b.Message = a
  b.Message.NAME = "message"
  b.Message.VERSION = "1.0"
  b.Message.opts =
    target: false
    delay: 10

  a.fn = b.Message:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @build()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Message.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$message[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Message.NAME or c is b.Message.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      unless @opts.target
        @$message = @$element
        @show()
      else
        @$message = b(@opts.target)
        @$message.data "message", ""
        @$message.data "message", this
        @$element.on "click", b.proxy(@show, this)
      return

    show: ->
      if @$message.hasClass("open")
        @hide()
        return
      b(".tools-message").hide().removeClass "open"
      @$message.addClass("open").fadeIn("fast").on "click.tools.message", b.proxy(@hide, this)
      b(document).on "keyup.tools.message", b.proxy(@hideHandler, this)
      setTimeout b.proxy(@hide, this), @opts.delay * 1000  if @opts.delay
      @setCallback "opened"
      return

    hideHandler: (c) ->
      return  unless c.which is 27
      @hide()
      return

    hide: ->
      return  unless @$message.hasClass("open")
      @$message.off "click.tools.message"
      b(document).off "keyup.tools.message"
      @$message.fadeOut "fast", b.proxy(->
        @$message.removeClass "open"
        @setCallback "closed"
        return
      , this)
      return

  a::init:: = a::
  b ->
    b("[data-tools=\"message\"]").message()
    return

  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.modal = (d) ->
    e = []
    c = Array::slice.call(arguments, 1)
    if typeof d is "string"
      @each ->
        g = b.data(this, "modal")
        if typeof g isnt "undefined" and b.isFunction(g[d])
          f = g[d].apply(g, c)
          e.push f  if f isnt `undefined` and f isnt g
        else
          b.error "No such method \"" + d + "\" for Modal"
        return

    else
      @each ->
        b.data this, "modal", {}
        b.data this, "modal", a(this, d)
        return

    if e.length is 0
      this
    else
      if e.length is 1
        e[0]
      else
        e

  b.Modal = a
  b.Modal.NAME = "modal"
  b.Modal.VERSION = "1.0"
  b.Modal.opts =
    title: ""
    width: 500
    blur: false

  a.fn = b.Modal:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @$element.on "click.tools.modal", b.proxy(@load, this)
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Modal.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Modal.NAME or c is b.Modal.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    load: ->
      @build()
      @enableEvents()
      @setTitle()
      @setDraggable()
      @setContent()
      return

    build: ->
      @buildOverlay()
      @$modalBox = b("<div class=\"modal-box\" />").hide()
      @$modal = b("<div class=\"modal\" />")
      @$modalHeader = b("<header />")
      @$modalClose = b("<span class=\"modal-close\" />").html("&times;")
      @$modalBody = b("<section />")
      @$modalFooter = b("<footer />")
      @$modal.append @$modalHeader
      @$modal.append @$modalClose
      @$modal.append @$modalBody
      @$modal.append @$modalFooter
      @$modalBox.append @$modal
      @$modalBox.appendTo document.body
      return

    buildOverlay: ->
      @$modalOverlay = b("<div id=\"modal-overlay\">").hide()
      b("body").prepend @$modalOverlay
      if @opts.blur
        @blurredElements = b("body").children("div, section, header, article, pre, aside, table").not(".modal, .modal-box, #modal-overlay")
        @blurredElements.addClass "modal-blur"
      return

    show: ->
      @setCallback "loading", @$modal
      @bodyOveflow = b(document.body).css("overflow")
      b(document.body).css "overflow", "hidden"
      if @isMobile()
        @showOnMobile()
      else
        @showOnDesktop()
      @$modalOverlay.show()
      @$modalBox.show()
      @setButtonsWidth()
      unless @isMobile()
        setTimeout b.proxy(@showOnDesktop, this), 0
        b(window).on "resize.tools.modal", b.proxy(@resize, this)
      @setCallback "opened", @$modal
      b(document).off "focusin.modal"
      return

    showOnDesktop: ->
      c = @$modal.outerHeight()
      e = b(window).height()
      d = b(window).width()
      if @opts.width > d
        @$modal.css
          width: "96%"
          marginTop: (e / 2 - c / 2) + "px"

        return
      if c > e
        @$modal.css
          width: @opts.width + "px"
          marginTop: "20px"

      else
        @$modal.css
          width: @opts.width + "px"
          marginTop: (e / 2 - c / 2) + "px"

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
        @$modalBody.html b(@opts.content).html()
        @show()
      else
        b.ajax
          url: @opts.content
          cache: false
          success: b.proxy((c) ->
            @$modalBody.html c
            @show()
            return
          , this)

      return

    setDraggable: ->
      return  if typeof b.fn.draggable is "undefined"
      @$modal.draggable handle: @$modalHeader
      @$modalHeader.css "cursor", "move"
      return

    createCancelButton: (c) ->
      c = "Cancel"  if typeof c is "undefined"
      d = b("<button>").addClass("btn modal-close-btn").html(c)
      d.on "click", b.proxy(@close, this)
      @$modalFooter.append d
      return

    createDeleteButton: (c) ->
      c = "Delete"  if typeof c is "undefined"
      @createButton c, "red"

    createActionButton: (c) ->
      c = "Ok"  if typeof c is "undefined"
      @createButton c, "blue"

    createButton: (c, e) ->
      d = b("<button>").addClass("btn").addClass("btn-" + e).html(c)
      @$modalFooter.append d
      d

    setButtonsWidth: ->
      c = @$modalFooter.find("button")
      d = c.size()
      return  if d is 0
      c.css "width", (100 / d) + "%"
      return

    enableEvents: ->
      @$modalClose.on "click.tools.modal", b.proxy(@close, this)
      b(document).on "keyup.tools.modal", b.proxy(@closeHandler, this)
      @$modalBox.on "click.tools.modal", b.proxy(@close, this)
      return

    disableEvents: ->
      @$modalClose.off "click.tools.modal"
      b(document).off "keyup.tools.modal"
      @$modalBox.off "click.tools.modal"
      b(window).off "resize.tools.modal"
      return

    closeHandler: (c) ->
      return  unless c.which is 27
      @close()
      return

    close: (c) ->
      if c
        return  if not b(c.target).hasClass("modal-close-btn") and c.target isnt @$modalClose[0] and c.target isnt @$modalBox[0]
        c.preventDefault()
      return  unless @$modalBox
      @disableEvents()
      @$modalOverlay.remove()
      @$modalBox.fadeOut "fast", b.proxy(->
        @$modalBox.remove()
        b(document.body).css "overflow", @bodyOveflow
        @blurredElements.removeClass "modal-blur"  if @opts.blur and typeof @blurredElements isnt "undefined"
        @setCallback "closed"
        return
      , this)
      return

    isMobile: ->
      c = window.matchMedia("(max-width: 767px)")
      (if (c.matches) then true else false)

  b(window).on "load.tools.modal", ->
    b("[data-tools=\"modal\"]").modal()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.navigationFixed = (c) ->
    @each ->
      b.data this, "navigationFixed", {}
      b.data this, "navigationFixed", a(this, c)
      return


  b.NavigationFixed = a
  b.NavigationFixed.NAME = "navigation-fixed"
  b.NavigationFixed.VERSION = "1.0"
  b.NavigationFixed.opts = {}
  a.fn = b.NavigationFixed:: =
    init: (e, c) ->
      d = window.matchMedia("(max-width: 767px)")
      return  if d.matches
      @$element = (if e isnt false then b(e) else false)
      @loadOptions c
      @navBoxOffsetTop = @$element.offset().top
      @build()
      b(window).scroll b.proxy(@build, this)
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.NavigationFixed.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.NavigationFixed.NAME or c is b.NavigationFixed.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      if b(window).scrollTop() > @navBoxOffsetTop
        @$element.addClass "navigation-fixed"
        @setCallback "fixed"
      else
        @$element.removeClass "navigation-fixed"
        @setCallback "unfixed"
      return

  b(window).on "load.tools.navigation-fixed", ->
    b("[data-tools=\"navigation-fixed\"]").navigationFixed()
    return

  a::init:: = a::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.navigationToggle = (c) ->
    @each ->
      b.data this, "navigationToggle", {}
      b.data this, "navigationToggle", a(this, c)
      return


  b.NavigationToggle = a
  b.NavigationToggle.NAME = "navigation-toggle"
  b.NavigationToggle.VERSION = "1.0"
  b.NavigationToggle.opts = target: false
  a.fn = b.NavigationToggle:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @$target = b(@opts.target)
      @$toggle = @$element.find("span")
      @$toggle.on "click", b.proxy(@onClick, this)
      @build()
      b(window).resize b.proxy(@build, this)
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.NavigationToggle.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.NavigationToggle.NAME or c is b.NavigationToggle.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    build: ->
      c = window.matchMedia("(max-width: 767px)")
      if c.matches
        unless @$target.hasClass("navigation-target-show")
          @$element.addClass("navigation-toggle-show").show()
          @$target.addClass("navigation-target-show").hide()
      else
        @$element.removeClass("navigation-toggle-show").hide()
        @$target.removeClass("navigation-target-show").show()
      return

    onClick: (c) ->
      c.stopPropagation()
      c.preventDefault()
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

  b(window).on "load.tools.navigation-toggle", ->
    b("[data-tools=\"navigation-toggle\"]").navigationToggle()
    return

  a::init:: = a::
  return
) jQuery
((a) ->
  a.progress =
    show: ->
      if a("#tools-progress").length isnt 0
        a("#tools-progress").fadeIn()
      else
        b = a("<div id=\"tools-progress\"><span></span></div>").hide()
        a(document.body).append b
        a("#tools-progress").fadeIn()
      return

    update: (b) ->
      @show()
      a("#tools-progress").find("span").css "width", b + "%"
      return

    hide: ->
      a("#tools-progress").fadeOut 1500
      return

  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.tabs = (d) ->
    e = []
    c = Array::slice.call(arguments, 1)
    if typeof d is "string"
      @each ->
        g = b.data(this, "tabs")
        if typeof g isnt "undefined" and b.isFunction(g[d])
          f = g[d].apply(g, c)
          e.push f  if f isnt `undefined` and f isnt g
        else
          b.error "No such method \"" + d + "\" for Tabs"
        return

    else
      @each ->
        b.data this, "tabs", {}
        b.data this, "tabs", a(this, d)
        return

    if e.length is 0
      this
    else
      if e.length is 1
        e[0]
      else
        e

  b.Tabs = a
  b.Tabs.NAME = "tabs"
  b.Tabs.VERSION = "1.0"
  b.Tabs.opts =
    equals: false
    active: false

  a.fn = b.Tabs:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @links = @$element.find("a")
      @tabs = []
      @links.each b.proxy(@load, this)
      @setEquals()
      @setCallback "init"
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Tabs.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Tabs.NAME or c is b.Tabs.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    load: (d, e) ->
      c = b(e)
      f = c.attr("href")
      c.attr "rel", f
      @tabs.push b(f)
      b(f).hide()  unless c.parent().hasClass("active")
      @readLocationHash f
      @show f  if @opts.active isnt false and @opts.active is f
      c.on "click", b.proxy(@onClick, this)
      return

    onClick: (d) ->
      d.preventDefault()
      c = b(d.target).attr("rel")
      top.location.hash = c
      @show c
      return

    readLocationHash: (c) ->
      return  if top.location.hash is "" or top.location.hash isnt c
      @opts.active = top.location.hash
      return

    setActive: (c) ->
      @activeHash = c
      @activeTab = b("[rel=" + c + "]")
      @links.parent().removeClass "active"
      @activeTab.parent().addClass "active"
      return

    getActiveHash: ->
      @activeHash

    getActiveTab: ->
      @activeTab

    show: (c) ->
      @hideAll()
      b(c).show()
      @setActive c
      @setCallback "show", b("[rel=" + c + "]"), c
      return

    hideAll: ->
      b.each @tabs, ->
        b(this).hide()
        return

      return

    setEquals: ->
      return  unless @opts.equals
      @setMaxHeight @getMaxHeight()
      return

    setMaxHeight: (c) ->
      b.each @tabs, ->
        b(this).css "min-height", c + "px"
        return

      return

    getMaxHeight: ->
      c = 0
      b.each @tabs, ->
        d = b(this).height()
        c = (if d > c then d else c)
        return

      c

  b(window).on "load.tools.tabs", ->
    b("[data-tools=\"tabs\"]").tabs()
    return

  a::init:: = a::
  return
) jQuery
((a) ->
  b = (d, c) ->
    new b::init(d, c)
  a.fn.textfit = (c) ->
    @each ->
      a.data this, "textfit", {}
      a.data this, "textfit", b(this, c)
      return


  a.Textfit = b
  a.Textfit.NAME = "textfit"
  a.Textfit.VERSION = "1.0"
  a.Textfit.opts =
    min: "10px"
    max: "100px"
    compressor: 1

  b.fn = a.Textfit:: =
    init: (d, c) ->
      @$element = (if d isnt false then a(d) else false)
      @loadOptions c
      @$element.css "font-size", Math.max(Math.min(@$element.width() / (@opts.compressor * 10), parseFloat(@opts.max)), parseFloat(@opts.min))
      return

    loadOptions: (c) ->
      @opts = a.extend({}, a.extend(true, {}, a.Textfit.opts), @$element.data(), c)
      return

  a(window).on "load.tools.textfit", ->
    a("[data-tools=\"textfit\"]").textfit()
    return

  b::init:: = b::
  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.tooltip = (c) ->
    @each ->
      b.data this, "tooltip", {}
      b.data this, "tooltip", a(this, c)
      return


  b.Tooltip = a
  b.Tooltip.NAME = "tooltip"
  b.Tooltip.VERSION = "1.0"
  b.Tooltip.opts = theme: false
  a.fn = b.Tooltip:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @$element.on "mouseover", b.proxy(@show, this)
      @$element.on "mouseout", b.proxy(@hide, this)
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Tooltip.opts), @$element.data(), c)
      return

    show: ->
      b(".tooltip").hide()
      c = @$element.attr("title")
      @$element.data "cached-title", c
      @$element.attr "title", ""
      @tooltip = b("<div class=\"tooltip\" />").html(c).hide()
      @tooltip.addClass "tooltip-theme-" + @opts.theme  if @opts.theme isnt false
      @tooltip.css
        top: (@$element.offset().top + @$element.innerHeight()) + "px"
        left: @$element.offset().left + "px"

      b("body").append @tooltip
      @tooltip.show()
      return

    hide: ->
      @tooltip.fadeOut "fast", b.proxy(->
        @tooltip.remove()
        return
      , this)
      @$element.attr "title", @$element.data("cached-title")
      @$element.data "cached-title", ""
      return

  a::init:: = a::
  b ->
    b("[data-tools=\"tooltip\"]").tooltip()
    return

  return
) jQuery
((b) ->
  a = (d, c) ->
    new a::init(d, c)
  b.fn.upload = (c) ->
    @each ->
      b.data this, "upload", {}
      b.data this, "upload", a(this, c)
      return


  b.Upload = a
  b.Upload.NAME = "upload"
  b.Upload.VERSION = "1.0"
  b.Upload.opts =
    url: false
    placeholder: "Drop file here or "
    param: "file"

  a.fn = b.Upload:: =
    init: (d, c) ->
      @$element = (if d isnt false then b(d) else false)
      @loadOptions c
      @load()
      return

    loadOptions: (c) ->
      @opts = b.extend({}, b.extend(true, {}, b.Upload.opts), @$element.data(), c)
      return

    setCallback: (j, h, d) ->
      m = b._data(@$element[0], "events")
      if m and typeof m[j] isnt "undefined"
        k = []
        g = m[j].length
        f = 0

        while f < g
          c = m[j][f].namespace
          if c is "tools." + b.Upload.NAME or c is b.Upload.NAME + ".tools"
            l = m[j][f].handler
            k.push (if (typeof d is "undefined") then l.call(this, h) else l.call(this, h, d))
          f++
        if k.length is 1
          return k[0]
        else
          return k
      (if (typeof d is "undefined") then h else d)

    load: ->
      @$droparea = b("<div class=\"tools-droparea\" />")
      @$placeholdler = b("<div class=\"tools-droparea-placeholder\" />").text(@opts.placeholder)
      @$droparea.append @$placeholdler
      @$element.after @$droparea
      @$placeholdler.append @$element
      @$droparea.off ".tools.upload"
      @$element.off ".tools.upload"
      @$droparea.on "dragover.tools.upload", b.proxy(@onDrag, this)
      @$droparea.on "dragleave.tools.upload", b.proxy(@onDragLeave, this)
      @$element.on "change.tools.upload", b.proxy((c) ->
        c = c.originalEvent or c
        @traverseFile @$element[0].files[0], c
        return
      , this)
      @$droparea.on "drop.tools.upload", b.proxy((c) ->
        c.preventDefault()
        @$droparea.removeClass("drag-hover").addClass "drag-drop"
        @onDrop c
        return
      , this)
      return

    onDrop: (d) ->
      d = d.originalEvent or d
      c = d.dataTransfer.files
      @traverseFile c[0], d
      return

    traverseFile: (c, f) ->
      d = (if !!window.FormData then new FormData() else null)
      d.append @opts.param, c  if window.FormData
      b.progress.show()  if b.progress
      @sendData d, f
      return

    sendData: (d, c) ->
      f = new XMLHttpRequest()
      f.open "POST", @opts.url
      f.onreadystatechange = b.proxy(->
        if f.readyState is 4
          g = f.responseText
          g = g.replace(/^\[/, "")
          g = g.replace(/\]$/, "")
          e = ((if typeof g is "string" then b.parseJSON(g) else g))
          b.progress.hide()  if b.progress
          @$droparea.removeClass "drag-drop"
          @setCallback "success", e
        return
      , this)
      f.send d
      return

    onDrag: (c) ->
      c.preventDefault()
      @$droparea.addClass "drag-hover"
      return

    onDragLeave: (c) ->
      c.preventDefault()
      @$droparea.removeClass "drag-hover"
      return

  a::init:: = a::
  b ->
    b("[data-tools=\"upload\"]").upload()
    return

  return
) jQuery
