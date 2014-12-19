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
