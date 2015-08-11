# Our router manages our routes, history and AJAX loading.

app = window.app = window.app || {}
PubSub = require 'pubsub-js'
gator = require '../vendor/gator.min'
$ = require 'jquery'
classie = require 'desandro-classie'


class UIEngine
	_isInit: false
	_cacheImg: undefined
	_subscriptions: []
	_elementList: []

	constructor: ->
		@_init()

	_init: =>
		if @_isInit
			return
		@_isInit = true
		@_addEventListeners()


	_kill: () ->
		@_removeEventListeners()

	_addEventListeners: () ->
		@_subscriptions.push PubSub.subscribe 'transition.complete', @_bindUiEvents
		@_subscriptions.push PubSub.subscribe 'route.loaded', @_unbindUiEvents

	_removeEventListeners: () ->
		for sub in @_subscriptions
			PubSub.unsubscribe sub 

	_bindUiEvents: =>
		for el in document.getElementsByClassName 'uifx--preload-img-hover'
			el.addEventListener 'mouseover', @_preloadImgHover

		for el in document.getElementsByClassName 'uifx--touch-touched'
			el.addEventListener 'touchstart', @_touchTouchedStart
			el.addEventListener 'mousedown', @_touchTouchedStart
			el.addEventListener 'touchend', @_touchTouchedEnd
			el.addEventListener 'touchcancel', @_touchTouchedEnd
			el.addEventListener 'mouseup', @_touchTouchedEnd
			el.addEventListener 'mouseleave', @_touchTouchedEnd
			@_elementList.push el

		for el in document.getElementsByClassName 'uifx--click-pos'
			el.addEventListener 'click', @_clickPosition
			@_elementList.push el


	_unbindUiEvents: () =>
		for el in @_elementList
			el.removeEventListener 'touchstart', @_touchTouchedStart
			el.removeEventListener 'mousedown', @_touchTouchedStart
			el.removeEventListener 'touchend', @_touchTouchedEnd
			el.removeEventListener 'touchcancel', @_touchTouchedEnd
			el.removeEventListener 'mouseup', @_touchTouchedEnd
			el.removeEventListener 'mouseleave', @_touchTouchedEnd
			el.removeEventListener 'click', @_clickPosition
		@_elementList = []


	_preloadImgHover: (e) ->
		el = e.currentTarget
		toCacheSrc = el.getAttribute 'data-preload-src'

		if !toCacheSrc
			return

		if !@_cacheImg or toCacheSrc isnt @_cacheImg.src
			@_cacheImg = undefined
			@_cacheImg = new Image()
			@_cacheImg.src = toCacheSrc

	_touchTouchedStart: ->
		classie.add @, '_touched'

	_touchTouchedEnd: ->
		classie.remove @, '_touched'

	_clickPosition: (e) ->
		@setAttribute 'data-click-pos-x', e.offsetX
		@setAttribute 'data-click-pos-y', e.offsetY



module.exports = UIEngine
