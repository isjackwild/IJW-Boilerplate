# Get the namespace
app = window.app = window.app || {}
PubSub = require 'pubsub-js'
classie = require 'desandro-classie'
_ = require 'lodash'



class ImgExtended
	_isInit: false
	_el: undefined
	_wrap: undefined
	_spacer: null

	_timeout: 7777
	_isInViewport: false

	_loaded: false
	_subscriptions: []

	_displaySize: undefined
	_srcThumb: undefined
	_srcMed: undefined
	_srcLarge: undefined

	_naturalHeight: undefined
	_naturalWidth: undefined
	_aspectRatio: undefined


	constructor: (el, forceInit) ->
		@_el = el
		PubSub.publish 'image.added'

		@_srcThumb = @_el.getAttribute 'data-src-thumb'
		@_srcMed = @_el.getAttribute 'data-src-med'
		@_srcLarge = @_el.getAttribute 'data-src-large'
		@_displaySize = @_el.getAttribute 'data-display-size'

		@_naturalHeight = @_el.getAttribute 'height'
		@_naturalWidth = @_el.getAttribute 'width'
		@_aspectRatio = @_naturalHeight / @_naturalWidth

		@_wrap = if classie.has(@_el.parentNode, 'img-wrap') then @_el.parentNode else null
		if @_wrap
			for child in @_el.parentNode.children
				if classie.has(child, 'spacer')
					@_spacer = child
					break
				
		@_init()
		if forceInit
			@load()
		

	_init: () => # Start it up
		if @_isInit
			@_onLoaded()
			return
		@_isInit = true
		@_addEventListeners()

		if @_naturalHeight > @_naturalWidth
			classie.add @_el, 'portrait'
			if @_wrap
				classie.add @_wrap, 'portrait'
		else
			classie.add @_el, 'landscape'
			if @_wrap
				classie.add @_wrap, 'landscape'

		@_setSpacerHeight()

			

	load: () ->
		@_timeoutTimeout = setTimeout @_onTimeout, @_timeout

		switch @_displaySize
			when 'thumb'
				@_el.src = @_srcThumb
			when 'med'
				if app.devices.isMobileDown
					@_el.src = @_srcThumb
				else
					@_el.src = @_srcMed
			when 'large'
				if app.devices.isMobileDown
					@_el.src = @_srcMed
				else
					@_el.src = @_srcLarge
			else
				if app.devices.isMobileDown
					@_el.src = @_srcMed
				else
					@_el.src = @_srcLarge


	kill: () -> # Cleanup.
		clearTimeout @_timeoutTimeout
		@_removeEventListeners()
		setTimeout =>
			@_el = undefined
		,0


	_addEventListeners: () =>
		@_subscriptions.push PubSub.subscribe 'viewport.resize', @_setSpacerHeight
		if @_el.complete and @_el.getAttribute 'src'
			@_onLoaded()
			return
		@_el.addEventListener 'error', @_onError
		@_el.addEventListener 'load', @_onLoaded


	_removeEventListeners: () ->
		@_el.removeEventListener 'load', @_onLoaded
		@_el.removeEventListener 'error', @_onError
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription

	_onLoaded: =>
		@_loaded = true
		clearTimeout @_timeoutTimeout
		@_el.removeEventListener 'load', @_onLoaded
		@_el.removeEventListener 'error', @_onError
	
		PubSub.publish 'image.loaded'
		PubSub.publish 'viewport.recache'

		window.requestAnimationFrame =>
			classie.add @_el, 'ready'
			if @_wrap
				classie.add @_wrap, 'ready'


	_onError: (error) =>
		console.error 'Error loading media. ' + error
		clearTimeout @_timeoutTimeout
		PubSub.publish 'image.error', @_el
		@_el.removeEventListener 'load', @_onLoaded
		@_el.removeEventListener 'error', @_onError
		classie.add @_el, 'failed'
		if @_wrap
			classie.add @_wrap, 'failed'


	_onTimeout: => #if it's taking ages to load, start loading the next  image
		PubSub.publish 'image.timeout'


	_setSpacerHeight: =>
		if !@_spacer
			return

		window.requestAnimationFrame =>
			@_spacer.style.height = Math.round(@_el.clientWidth * @_aspectRatio) + 'px'



module.exports = ImgExtended # Export for use in browserify. Read up on CommonJS