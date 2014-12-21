###
   @@@    @@     @@ @@@@@@@@  @@@@@@@   @@@@@@   @@@@@@@  @@     @@ @@@@@@@@
  @@ @@   @@     @@    @@    @@     @@ @@    @@ @@     @@ @@@   @@@ @@     @@
 @@   @@  @@     @@    @@    @@     @@ @@       @@     @@ @@@@ @@@@ @@     @@
@@     @@ @@     @@    @@    @@     @@ @@       @@     @@ @@ @@@ @@ @@@@@@@@
@@@@@@@@@ @@     @@    @@    @@     @@ @@       @@     @@ @@     @@ @@
@@     @@ @@     @@    @@    @@     @@ @@    @@ @@     @@ @@     @@ @@
@@     @@  @@@@@@@     @@     @@@@@@@   @@@@@@   @@@@@@@  @@     @@ @@
###

define ['jquery','accordion'],($, Accordion)->
  # view
  class View
    constructor:(@opt)->
      @$el = $("<ul class='autocomplete'>").hide()
      $("body").append @$el
      @

    template:(data)->
      "<li rel='#{data.id}' >
        <a href='#'>#{data.value}</a>
      </li>"

    render:->
      click = @click
      @$el.empty()
      @items = []
      @cur = 0
      @data.forEach (item, i)=>
        $item = $ @template item
        $item.children("a").addClass "active" unless i
        @items.push $item
        ((i)->$item.on 'click', (e)=>
          click i if click
          )(item)
        @$el.append $item

      @$el.css
        top     : @opt.offset.top + @opt.height
        left    : @opt.offset.left
        width   : @opt.width
      @$el.show()
      @

    select:(cmd, el)->
      @items[@cur].children("a").removeClass "active"
      @cur +=1 if cmd  is "next"
      @cur -=1 if cmd  is "prev"
      @cur = 0 if @cur >= @items.length
      @cur = @items.length - 1 if @cur < 0
      @items[@cur].children("a").addClass "active"
      @items[@cur].children("a").focus()
      el.focus()
      @

    click:(item)->
      @opt.onSelect item if @opt?.onSelect
      @

    hide:()->
      @$el.empty()
      @$el.hide()

  # Обработка input
  class Autocomplete extends Accordion
    NAME: "autocomplete"
    VERSION: "1.0"
    filter:{}
    opts:
      url: false
      min: 2
      set: "value"
      type: 'get'

    constructor:(@options, @el )->
      @$el = $ @el if @el
      @loadOptions()
      # init view
      @view = new View
        offset: @$el.offset()
        height: @$el.innerHeight()
        width: @$el.innerWidth()

      @events()
      @

    events:->
      # document event
      $(document).on "click", $.proxy(@hide, @)
      # element event
      @$el.on "keyup", $.proxy( @keyUp, @)

    keyUp:(e)->
      switch e.keyCode
        when 40 # down arrow
          @view.select "next", @$el
        when 38 # up arrow
          @view.select "prev", @$el
        when 13 # enter
          @set()
        when 27 # escape
          @hide()
        else
          @filter[e.target.name] = e.target.value
          if e.target.value.length >= @opts.min
            @fetch()
          else
            @hide()
    set:->
      @$el.val @view.data[@view.cur].value
      @hide()
      @


    fetch:()->
      $.ajax
        url: @opts.url
        type: @opts.type
        dataType:'json'
        data: @filter
        success: $.proxy @render, @
        error: @onError
      @

    render:( data, textStatus, jqXHR )->
      @view.data = data
      @view.render()
      @

    onError:( jqXHR, textStatus, errorThrown )->
      console.log 'error'
      console.log textStatus
      @

    hide:()->
      @view.hide()
      @
