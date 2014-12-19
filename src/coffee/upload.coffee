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
