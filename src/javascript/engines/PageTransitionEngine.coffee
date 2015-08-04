# Get the namespace
app = window.app = window.app || {}
PubSub = require 'pubsub-js'
gsap = require 'gsap'
classie = require 'desandro-classie'
UTIL = require '../vendor/ijw.UTIL'


class PageTransitionEngine
	_isInit: false
	_transitionTimeout: undefined

	_transitionType: 'load'

	_pageContextWrap: null
	_incomingContext: null
	_outgoingContext: null

	_subscriptions: []



	constructor: () ->
		@init()
		
	init: () ->
		if @_isInit
			return
		@_isInit = true
		@_addEventListeners()
		@_pageContextWrap = document.getElementsByClassName('page-context-wrap')[0]


	kill: () ->
		@_removeEventListeners()


	_addEventListeners: () ->
		@_subscriptions.push PubSub.subscribe 'transition.from', @_onTransitionFrom
		@_subscriptions.push PubSub.subscribe 'route.success', @_switchViews


	_removeEventListeners: () ->
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription


	_onTransitionFrom: (e, from) =>
		@_transitionType = from.type


	_switchViews: =>
		clearTimeout @_transitionTimeout
		@_incomingContext = document.querySelectorAll('.page-context.incoming')[0]
		@_outgoingContext = if document.querySelectorAll('.page-context.outgoing') then document.querySelectorAll('.page-context.outgoing')[0] else false # On first page load, there's no outgoing project

		window.requestAnimationFrame => #Try to fix this another way.
			if @_outgoingContext then classie.add @_outgoingContext,'animate-out-active'
			classie.add @_incomingContext, 'animate-in-active'
			switch @_transitionType
				when 'load'
					@_loadTransition()
				else
					@_defaultTransition()


	_onSwitchComplete: =>
		@_outgoingContext = if document.querySelectorAll('.page-context.outgoing') then document.querySelectorAll('.page-context.outgoing')[0] else false # On first page load, there's no outgoing project
		if @_outgoingContext
			@_outgoingContext.parentNode.removeChild @_outgoingContext
		classie.remove @_incomingContext, 'incoming'
		classie.remove @_incomingContext, 'animate-in'
		classie.remove @_incomingContext, 'animate-in-active'
		classie.add @_incomingContext, 'outgoing'

		document.body.scrollTop = 0 #Scroll top the top
		document.getElementsByTagName('html')[0].scrollTop = 0

		setTimeout =>
			PubSub.publish 'transition.complete'
			@_transitionType = 'default'
			app.scroll.top = document.body.scrollTop || document.getElementsByTagName('html')[0].scrollTop
		,0


	_loadTransition: =>
		incomingCtxFrom = 
			opacity : 0

		incomingCtxTo = 
			opacity : 1
			ease : Power4.easeOut
			clearProps : 'all'

		tl = new TimelineMax()
		.fromTo @_incomingContext, 1, incomingCtxFrom, incomingCtxTo
		.addCallback @_onSwitchComplete


	_defaultTransition: =>
		incomingCtxFrom = 
			opacity : 0

		incomingCtxTo = 
			opacity : 1
			ease : Power4.easeOut
			clearProps : 'all'

		outgoingCtxFrom = 
			opacity : 1
			y : 0

		outgoingCtxTo = 
			opacity : 0
			y : 200
			ease : Power4.easeOut

		tl = new TimelineMax()
		.fromTo @_outgoingContext, 1, outgoingCtxFrom, outgoingCtxTo
		.fromTo @_incomingContext, 1, incomingCtxFrom, incomingCtxTo
		.addCallback @_onSwitchComplete



module.exports = PageTransitionEngine # Export for use in browserify. Read up on CommonJS