# Get the namespace
app = window.app = window.app || {}
PubSub = require 'pubsub-js'
classie = require 'desandro-classie'
_ = require 'lodash'



class VideoExtended
	_isInit: false
	_el: undefined
	_wrap: undefined
	_spacer: null

	_isInViewport: false

	_loaded: false
	_subscriptions: []

	_displaySize: undefined
	_srcSD: undefined
	_srcHD: undefined
	_placeholderImg: undefined

	_autoplay: false
	_offset:
		top: 0
		bottom: 0


	constructor: (el) ->
		@_el = el

		@_srcSD = @_el.getAttribute 'data-src-sd'
		@_srcHD = @_el.getAttribute 'data-src-hd'
		@_displaySize = @_el.getAttribute 'data-display-size'

		if app.devices.isTabletLandscapeDown
			@_el.autoplay = false
			@_el.loop = false
			@_el.pause()


		@_wrap = if classie.has(@_el.parentNode, 'video-wrap') then @_el.parentNode else null
		if @_wrap
			for child in @_el.parentNode.children
				if classie.has(child, 'placeholder-img')
					@_placeholderImg = child
					break
				
		PubSub.publish 'video.added'
		@_init()

		

	_init: () => # Start it up
		if @_isInitå
			@_onLoaded()
			return
		@_isInit = true
		@_addEventListeners()
			

	load: () ->
		switch @_displaySize
			when 'thumb'
				@_el.src = @_srcSD
			when 'med'
				@_el.src = @_srcSD
			when 'large'
				if app.devices.isMobileDown
					@_el.src = @_srcSD
				else
					@_el.src = @_srcHD
			else
				if app.devices.isMobileDown
					@_el.src = @_srcSD
				else
					@_el.src = @_srcHD



	kill: () -> # Cleanup.
		@_removeEventListeners()
		setTimeout =>
			@_el = undefined
		,0


	_addEventListeners: () =>
		@_subscriptions.push PubSub.subscribe 'viewport.resize', _.debounce(@_cacheOffsets,1333)
		@_subscriptions.push PubSub.subscribe 'viewport.recache', _.debounce(@_cacheOffsets,1333)
		if !app.devices.isTabletLandscapeDown
			@_subscriptions.push PubSub.subscribe 'viewport.scroll', @_checkInVp
		window.addEventListener 'focus', @checkInVp
		if @_el.playState is 4
				@_onLoaded()
			else 
				@_el.addEventListener 'canplay', @_onLoaded


	_removeEventListeners: () ->
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription
		window.removeEventListener 'focus', @_checkInVp
		@_el.removeEventListener 'canplay', @_onLoaded

	_onLoaded: =>
		@_loaded = true	

		window.requestAnimationFrame =>
			classie.add @_el, 'ready'
			if @_wrap
				classie.add @_wrap, 'ready'
			@_cacheOffsets()
			@_checkInVp()
			PubSub.publish 'viewport.recache'



	_cacheOffsets: =>
		if !@_el
			return
		rect = @_el.getBoundingClientRect()
		@_offset =
			top: rect.top + app.scroll.top
			bottom: rect.bottom + app.scroll.top

	_checkInVp: =>
		if !@_el or !@_loaded or app.devices.isTabletLandscapeDown
			return

		if app.scroll.bottom-(app.viewport.h/3) > @_offset.top and app.scroll.top+(app.viewport.h/3) < @_offset.bottom
			if @_el.paused and @_el.autoplay
				@_el.play()
		else if !@_el.paused
				@_el.pause()


module.exports = VideoExtended # Export for use in browserify. Read up on CommonJS