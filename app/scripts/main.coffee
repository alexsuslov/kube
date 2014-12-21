'use strict'
require.config
  waitSeconds: 0
  shim:{}
  paths:
    jquery  : '../bower_components/jquery/dist/jquery.min'
    async: '../bower_components/async/lib/async'
    wcHelper: 'helper'
    accordion: 'helpers/accordion'
    autocomplete: 'helpers/autocomplete'

    message: 'helpers/message'
    view: 'helpers/view'

require [
  'jquery'
  'async'
  'wcHelper'
  'accordion'
  'autocomplete'
  'message'
  ],($, async, wcHelper, Accordion, Autocomplete, Message)->

  #############
  # wcHelper  #
  #############
  # Показать исходные коды
  $.fn.wcHelper = (options)->
    @each (i, el)->
      new wcHelper options, el

  $('.wc-help').wcHelper()


  #############
  # Accordion #
  #############
  # Расширение jQuery accordion
  $.fn.accordion = (options) ->
    @each ->
      new Accordion(options, @)

  # Запустить accordion для data-tools='accordion'
  $("[data-tools='accordion']").accordion()

  ################
  # autocomplete #
  ################
  $.fn.autocomplete = (options) ->
    @each ->
      new Autocomplete(options, @)

  # Запустить autocomplete для data-tools='autocomplete'
  $("[data-tools='autocomplete']").autocomplete()


  ################
  # Message      #
  ################
  $.fn.message = (options) ->
    @each ->
      new Message(options, @)
  $("[data-tools='message']").message()


  #############
  # wcDo      #
  #############
  if window.wcDo
    async.parallel window.wcDo, (err, results)->
      console.log err if err


