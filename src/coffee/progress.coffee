#
#	Progress Tool
#
#	http://imperavi.com/kube/
#
#	Copyright (c) 2009-2014, Imperavi LLC.
#
(($) ->
  $.progress =
    show: ->
      if $("#tools-progress").length isnt 0
        $("#tools-progress").fadeIn()
      else
        $progress = $("<div id=\"tools-progress\"><span></span></div>").hide()
        $(document.body).append $progress
        $("#tools-progress").fadeIn()
      return

    update: (value) ->
      @show()
      $("#tools-progress").find("span").css "width", value + "%"
      return

    hide: ->
      $("#tools-progress").fadeOut 1500
      return

  return
) jQuery
