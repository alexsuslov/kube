
define ['jquery','view'],($, View)->
  class Message extends View
    NAME: "message"
    VERSION: "1.0"
    opts:
      target: false
      delay: 10 # message delay - seconds or false

    constructor:(@options, @el )->
      @$el = $ @el if @el
      @loadOptions()
      @render()
      @events()
      @

    render: ->
      @$el.show()
      setTimeout $.proxy(@hide, @), @opts.delay * 1000  if @opts.delay
      @

    hide:->
      @$el.fadeOut "fast"
      $(document).off "keyup"
      @

    events:->
      $(document).on "keyup", $.proxy @keyUp, @
      @$el.on 'click', $.proxy @hide, @

    keyUp:(e)->
      return  unless e.keyCode is 27
      @hide()
      @
