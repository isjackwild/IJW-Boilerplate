# Get the namespace
app = window.app = window.app || {}
UIModule = require '../UIModule'
UTIL = require '../vendor/ijw.UTIL' #My own home-made UTIL library
Particle = require '../particleSystem/Particle'
# THREE = require 'THREE'
# Two = require '../vendor/two.js'

class HeaderImage extends UIModule
	_canvas: undefined
	_ctx: undefined

	_particles: []
	_repellers: []

	_isPlaying: false
	_animateRAF: undefined
	_lastCycle: undefined
	_delta: 1

	_scroll:
		x: 0
		y: 0

	_lastScrollTop: undefined


	constructor: (el) ->
		super el
		@_canvas = @_el.getElementsByTagName('canvas')[0]
		@_ctx = @_canvas.getContext '2d'


	kill: () ->
		cancelAnimationFrame @_animateRAF
		super()


	_setupListeners: () ->
		@_subscriptionMap = [
			{event: 'viewport.resize', handler: @_onResize}
			{event: 'viewport.scroll', handler: @_onScroll}
		]

		super()

	_onResize: () =>
		super()
		@_lastScrollTop = app.scroll.top
		devicePixelRatio = window.devicePixelRatio || 1
		backingStoreRatio = @_ctx.webkitBackingStorePixelRatio ||
							@_ctx.mozBackingStorePixelRatio ||
							@_ctx.msBackingStorePixelRatio ||
							@_ctx.oBackingStorePixelRatio ||
							@_ctx.backingStorePixelRatio || 1
		ratio = devicePixelRatio / backingStoreRatio

		@_canvas.width = @_width * ratio
		@_canvas.height = @_height * ratio

		@_ctx.scale ratio, ratio


	_onScroll: =>
		scrollForce = app.scroll.top - @_lastScrollTop
		@_lastScrollTop = app.scroll.top

		@_scroll =
			x: 0
			y: scrollForce/100


	_setupParticles: () ->
		
		@_animate()

	
	_animate: () =>
		@_isPlaying = true
		now = new Date().getTime()

		if @_lastCycle
			@_delta = now - @_lastCycle
			@_delta /= 16.666
		@_animateRAF = requestAnimationFrame @_animate

		@_update()
		@_two.update()
		@_lastCycle = now

	_pause: () =>
		cancelAnimationFrame @_animateRAF
		@_isPlaying = false

	_update: () ->
		for particle in @_particles
			particle.clear()
			particle.applyForce @_scroll
			particle.update @_delta
			particle.draw()

		@_scroll =
			x: 0
			y: 0


# Seperate into Image analysis and then particle system				






module.exports = HeaderImage