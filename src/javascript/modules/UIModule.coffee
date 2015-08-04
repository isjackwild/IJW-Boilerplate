# Get the namespace
app = window.app = window.app || {}
PubSub = require 'pubsub-js'

class UIModule
	_isInit: false
	_el: undefined

	_subscriptions: []

	constructor: (el) ->
		@_el = el
		

	init: () => # Start it up
		if @_isInit
			return
		@_isInit = true
		@_addEventListeners()
		PubSub.publish 'module.init'


	kill: () -> # Cleanup.
		@_removeEventListeners()
		PubSub.publish 'module.kill'
		setTimeout =>
			@_el = undefined
		,0


	_addEventListeners: () ->


	_removeEventListeners: () ->
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription




module.exports = UIModule # Export for use in browserify. Read up on CommonJS