'use strict'
require.config
  waitSeconds: 0
  shim:{}
  paths:
    jquery  : '../bower_components/jquery/dist/jquery.min'
    async: '../bower_components/async/lib/async'
    wcHelper: 'helper'
    accordion: 'helpers/accordion'

require [
  'jquery'
  'async'
  'wcHelper'
  'accordion'
  ],($, async, wcHelper)->
  # Показать исходные коды
  $.fn.wcHelper = (options)->
    @each (i, el)->
      new wcHelper options, el

  $('.wc-help').wcHelper()

  if window.wcDo
    async.parallel window.wcDo, (err, results)->
      console.log err if err


