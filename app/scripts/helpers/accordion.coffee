define ['jquery'],($)->
  #
  class Accordion
    NAME    :  "accordion"
    VERSION :  "1.0"
    opts:
      scroll: false
      collapse: true
      toggle: true
      titleClass: ".accordion-title"
      panelClass: ".accordion-panel"

    # Инициализация
    # @param options[object]
    # @param el[] j,]trn
    constructor:(@options, @el )->
      @$el = $ @el if @el

      @loadOptions()
      @build()

      if @opts.collapse
        @closeAll()
      else
        @openAll()
      @loadFromHash()

      @

    # Загрузка параметров
    loadOptions: () ->
      @opts = $.extend({}, $.extend(true, {}, @opts), @$el.data(), @options)
      @


    setCallback: (type, e, data) ->
      events = $._data(@$el[0], "events")
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

      @

    getTitles: ->
      @titles = @$el.find(@opts.titleClass)
      @titles.append $("<span />").addClass("accordion-toggle")
      @titles.each ->
        $el = $(this)
        $el.attr "rel", $el.attr("href")
      @

    getPanels: ->
      @panels = @$el.find(@opts.panelClass)
      @

    build: ->
      @getTitles()
      @getPanels()
      @titles.on "click", $.proxy(@toggle, @)
      @

    loadFromHash: ->
      return  if top.location.hash is ""
      return  unless @opts.scroll
      return  if @$el.find("[rel=" + top.location.hash + "]").size() is 0
      @open top.location.hash
      @scrollTo top.location.hash
      @

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
      @

    open: (hash) ->
      @$title = $("[rel=" + hash + "]")
      @$panel = $(hash)
      top.location.hash = hash
      @setStatus "open"
      @$panel.show()
      @setCallback "opened", @$title, @$panel
      @

    close: (hash) ->
      @$title = $("[rel=" + hash + "]")
      @$panel = $(hash)
      @setStatus "close"
      @$panel.hide()
      @setCallback "closed", @$title, @$panel
      @

    setStatus: (command) ->
      items =
        toggle: @$title.find("span.accordion-toggle")
        title: @$title
        panel: @$panel

      $.each items, (i, s) ->
        if command is "close"
          s.removeClass("accordion-#{i}-opened").addClass "accordion-#{i}-closed"
        else
          s.removeClass("accordion-#{i}-closed").addClass "accordion-#{i}-opened"
      @

    openAll: ->
      @titles.each $.proxy( (i, s) ->
        @open $(s).attr("rel")
      , @)
      @

    closeAll: ->
      @titles.each $.proxy( (i, s) ->
        @close $(s).attr("rel")
      , @)
      @

    scrollTo: (id) ->
      $("html, body").animate
        scrollTop: $(id).offset().top - 50
      , 500
      @
  # Расширение jQuery accordion
  $.fn.accordion = (options) ->
    @each ->
      new Accordion(options, @)

  # Запустить accordion для data-tools='accordion'
  $("[data-tools='accordion']").accordion()

  Accordion
