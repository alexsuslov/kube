# View
define ['jquery'],($)->
  class View
    constructor:(@options, @el)->
      @$el = $ @el if @el
      @

    # Загрузка параметров
    loadOptions: () ->
      @opts = $.extend({}, $.extend(true, {}, @opts), @$el.data(), @options)
      @

    template:(data)->
      data

    render:->
      @$el.html @template @data
      @

