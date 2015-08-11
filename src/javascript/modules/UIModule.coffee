# Get the namespace
app = window.app = window.app || {}
PubSub = require 'pubsub-js'

class UIModule
	_isInit: false
	_el: undefined

	_subscriptions: []
	_listenerMap: []

	_width: undefined
	_height: undefined
	_aspectRatio: undefined
	_offset:
		top: 0
		bottom: 0
		left: 0
		right: 0

	_inVp: undefined

	constructor: (el) ->
		@_el = el

	init: () -> # Start it up
		if @_isInit
			return
		@_isInit = true
		@_setupListeners()
		@_onResize()
		PubSub.publish 'module.init'


	kill: () -> # Cleanup.
		@_removeEventListeners()
		setTimeout =>
			PubSub.publish 'module.kill'
			@_el = undefined
		,0


	_setupListeners: () ->
		@_addEventListeners()

	_addEventListeners: () ->
		for obj in @_listenerMap
			if !obj.el then obj.el = @_el
			obj.el.addEventListener obj.event, obj.handler, false

		for obj in @_subscriptionMap
			@_subscriptions.push PubSub.subscribe obj.event, obj.handler


	_removeEventListeners: () ->
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription
		for obj in @_listenerMap
			if !obj.el then obj.el = @_el
			obj.el.removeEventListener obj.event, obj.handler, false

	_onResize: () =>
		rect = @_el.getBoundingClientRect()
		@_width = rect.width
		@_height = rect.height
		@_aspectRatio = @_width / @_height
		@_cachePosition rect

	
	_cachePosition: (rect) =>
		if !rect then rect = @_el.getBoundingClientRect()
		@_offset =
			top: rect.top + app.scroll.top
			bottom: rect.bottom + app.scroll.top
			left: rect.left
			right: rect.right
		@_checkInVp()


	_onScroll: () =>
		@_checkInVp()


	_checkInVp: () =>
		console.log 'check in vp'
		if @_offset.bottom > 0 and @_offset.top < app.scroll.bottom
			@_inVp = true
		else
			@_inVp = false




module.exports = UIModule # Export for use in browserify. Read up on CommonJS