define ['jquery', 'view'],($, View)->
  class Buttons extends View
    debug: false
    NAME    :  "buttons"
    VERSION :  "1.0"
    opts:
      className: "btn"
      activeClassName: "btn-active"
      target: false
      type: "switch" # switch, toggle, segmented

    constructor:(@options, @el)->
      console.log 'Buttons start' if @debug
      @$el = $ @el if @el
      @loadOptions()
      @buttons = @getButtons()
      @events()
      @

    getButtons: ->
      (
        if @opts.type is "toggle"
          @$el
        else
          @$el.find "." + @opts.className
      )

    setDefault: ($el) ->
      console.log @opts.type if @debug
      switch @opts.type
        when "segmented"
          $target = $ @opts.target
          values = $target.val().split(",")
          values.forEach (value)=>
            @setActive @$el.find("[value='#{value}']")

        when "toggle"
          @setActive $el if ( @value is 1 or @value is $el.val())

        else
          @setBasic $el

    events:->
      click = $.proxy @click, @
      @buttons.each $.proxy (idx, btn)=>
        @setDefault $(btn) unless idx
        (($btn)->
          $btn.on 'click', (e)->
            click $btn
        )($(btn))

    click:($btn)->
      console.log  $btn if @debug
      switch @opts.type
        when "segmented"
          @setSegmented $btn
        when "toggle"
          @setToggle $btn
        else
          @setBasic $btn

    setSegmented: ($el) ->
      $target = $ @opts.target
      @value = $target.val().split(",")
      unless $el.hasClass(@opts.activeClassName)
        @setActive $el
        @value.push $el.val()
      else
        @setInActive $el
        @value.splice @value.indexOf($el.val()), 1
      $target.val @value.join(",").replace(/^,/, "")
      @

    setToggle: ($el) ->
      if $el.hasClass(@opts.activeClassName)
        @setInActive $el
        $(@opts.target).val 0
      else
        @setActive $el
        $(@opts.target).val 1
      @

    setBasic:($btn)->
      @setInActive( @buttons)
        .setActive($btn)

      $(@opts.target).val $btn.val()

    setActive: ($el) ->
      $el.addClass @opts.activeClassName
      @

    setInActive: ($el) ->
      $el.removeClass @opts.activeClassName
      @
