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
