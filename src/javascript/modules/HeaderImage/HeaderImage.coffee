# Get the namespace
app = window.app = window.app || {}
UIModule = require '../UIModule'
UTIL = require '../../vendor/ijw.UTIL' #My own home-made UTIL library
Particle = require './Particle'
# THREE = require 'THREE'
# Two = require '../vendor/two.js'

class HeaderImage extends UIModule
	_canvas: undefined
	_ctx: undefined

	_particles: []
	_repellers: []

	_isPlaying: false
	_lastCycle: undefined
	_delta: 1

	_scroll:
		x: 0
		y: 0

	_friction: 0.09

	_lastScrollTop: undefined

	_fontSize: 50

	_titleRect:
		x: 0
		y: 0
		w: 500
		h: 0


	constructor: (el) ->
		super el
		@_canvas = @_el.getElementsByTagName('canvas')[0]
		@_ctx = @_canvas.getContext '2d'
		@_title = @_el.dataset.title
		@_devicePixelRatio = window.devicePixelRatio || 1
		@_backingStoreRatio = @_ctx.webkitBackingStorePixelRatio ||
							@_ctx.mozBackingStorePixelRatio ||
							@_ctx.msBackingStorePixelRatio ||
							@_ctx.oBackingStorePixelRatio ||
							@_ctx.backingStorePixelRatio || 1

		@_titleRect.h = @_fontSize + 10

	init: () ->
		super()
		@_ratio = @_devicePixelRatio / @_backingStoreRatio
		setTimeout =>
			@_setupParticles()
		,111


	_setupListeners: () ->
		@_subscriptionMap = [
			{event: 'viewport.resize', handler: @_onResize}
			{event: 'viewport.scroll', handler: @_onScroll}
		]

		super()

	_onResize: () =>
		super()
		@_lastScrollTop = app.scroll.top
		@_ratio = @_devicePixelRatio / @_backingStoreRatio

		@_canvas.style.height = Math.round @_height * @_ratio
		@_canvas.style.width = Math.round @_width * @_ratio
		@_canvas.width = Math.round @_width * @_ratio
		@_canvas.height = Math.round @_height * @_ratio

		# @_ctx.scale @_ratio, @_ratio


	_onScroll: =>
		scrollForce = app.scroll.top - @_lastScrollTop
		@_lastScrollTop = app.scroll.top

		@_scroll =
			x: 0
			y: scrollForce/100


	_getImageTexture: () ->
		textCvs = document.createElement 'canvas'

		textCvs.width = 1000*@_ratio
		textCvs.height = @_fontSize + 10
		textCtx = textCvs.getContext '2d'
		textCtx.font = @_fontSize*@_ratio + "px Helvetica, sans-serif"

		@_titleRect.w = Math.ceil textCtx.measureText(@_title).width/@_ratio
		@_titleRect.x = Math.round (@_width-@_titleRect.w)*0.5

		textCtx.fillStyle = 'rgba(255,255,255,1)'
		textCtx.fillText @_title, 0, @_fontSize - 10

		return textCvs

	_setupParticles: () ->
		img = new Image()
		img.src = @_getImageTexture().toDataURL()

		dx = Math.ceil @_width/2-(@_titleRect.w/2)
		dy = Math.ceil  @_height/2-(@_titleRect.h/2)
		dw = @_titleRect.w
		dh = @_titleRect.h

		# @_ctx.drawImage img, 0, 0, @_titleRect.w, @_titleRect.h, dx, dy, dw, dh

		for i in [0..@_titleRect.w]
			@_particles.push new Particle i, @_titleRect.h, @_titleRect.w, @_width, @_height, img, @_ctx

		# for particle in @_particles
		# 	particle.draw()
		@_animate()

	
	_animate: () =>
		@_isPlaying = true
		now = new Date().getTime()

		if @_lastCycle
			@_delta = now - @_lastCycle
			@_delta /= 16.666
		@_RAFs.animate = requestAnimationFrame @_animate

		@_update()
		@_lastCycle = now

	_pause: () =>
		cancelAnimationFrame @_RAFs.animate
		@_isPlaying = false

	_update: () ->
		for particle, i in @_particles
			particle.clear()


			friction =
				x: particle._velVec.x * -1 * @_friction
				y: particle._velVec.y * -1 * @_friction
			particle.applyForce friction

			#TO DO — Make these not private vars, or make function to change targetVec
			#TO DO — Keep 1/2 in VP
			particle._targetVec.y = Math.round (@_height/2 - @_titleRect.h/2)+ app.scroll.top/2
			desiredVel =
				x: (particle._targetVec.x - particle._locVec.x) / 11 
				y: (particle._targetVec.y - particle._locVec.y) / 11
			particle.applyForce desiredVel

			particle.applyForce @_scroll
			particle.update @_delta
			particle.draw()

		@_scroll =
			x: 0
			y: 0

	






module.exports = HeaderImage