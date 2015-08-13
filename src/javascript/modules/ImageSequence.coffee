# Get the namespace
app = window.app = window.app || {}
UIModule = require './UIModule'
classie = require 'desandro-classie'
UTIL = require '../vendor/ijw.UTIL' #My own home-made UTIL library

class ImageSequence extends UIModule

	_images: undefined
	_indicators: undefined

	_currentIndex: 0
	_isAuto: true
	_mouseOver: false

	_autoSpeed: 3333

	init: () ->
		super()
		@_images = @_el.getElementsByTagName 'img'
		@_indicators = @_el.getElementsByClassName 'indicator'
		classie.add @_images[0], 'show-me'

	kill: () ->
		super()


	_setupListeners: () ->
		@_listenerMap = [
			{event: 'mouseenter', handler: @_onMouseEnter}
			{event: 'mouseleave', handler: @_onMouseLeave}
			{event: 'touchstart', handler: @_onMouseEnter}
			{event: 'touchend', handler: @_onMouseLeave}
			{event: 'touchmove', handler: @_onTouchMove}
		]

		@_subscriptionMap = [
			{event: 'viewport.resize', handler: @_onResize}
			{event: 'viewport.scroll', handler: @_onScroll}
			{event: 'viewport.recache', handler: @_cachePosition}
			{event: 'mouse.move', handler: @_onMouseMove}
		]

		super()

	_onMouseEnter: () =>
		@_mouseOver = true
		@_stopAuto()

	_onMouseLeave: () =>
		@_mouseOver = false
		@_playAuto()

	_onTouchMove: () =>
		xy =
			x: e.touches[0].clientX
			y: e.touches[0].clientY
		@_onMouseMove e, xy

	_onMouseMove: (e, xy) =>
		if @_isAuto or !@_mouseOver
			return

		x = UTIL.Maths.convertToRange xy.x, [@_rect.left, @_rect.right], [0, @_images.length]
		i = Math.floor x

		if i < 0 then i = 0
		if i > @_images.length-1 then i = @_images.length-1

		@_showImage i

	_showImage: (i) =>
		if i is @_currentIndex and !@_isAuto
			return

		for image in @_images
			classie.remove image, 'show-me'

		window.requestAnimationFrame =>
			classie.add @_images[i], 'show-me'

		@_currentIndex = i

	_playAuto: () =>
		if @_isAuto or @_mouseOver
			return
		console.log 'play auto'
		@_isAuto = true

		if @_TOs.autoTicker
			clearTimeout @_TOs.autoTicker

		ticker = 0
		@_currentIndex = @_images.length-1

		classie.add @_el, 'autoplay'

		tick = =>
			@_showImage ticker%@_images.length
			ticker++
			@_TOs.autoTicker = setTimeout =>
				tick()
			,@_autoSpeed

		tick()


	_stopAuto: () ->
		if !@_isAuto
			return

		@_isAuto = false
		classie.remove @_el, 'autoplay'
		clearTimeout @_TOs.autoTicker



module.exports = ImageSequence