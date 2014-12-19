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
