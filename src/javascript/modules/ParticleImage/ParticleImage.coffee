# Get the namespace
app = window.app = window.app || {}
UIModule = require '../UIModule'
UTIL = require '../../vendor/ijw.UTIL' #My own home-made UTIL library
Particle = require './Particle'
Repeller = require './Repeller'
# THREE = require 'THREE'
# Two = require '../vendor/two.js'

class ParticleImage extends UIModule
	_imgSrc: undefined

	_canvas: undefined
	_ctx: undefined
	_img: undefined
	_two: undefined

	_pixelBrights: []
	_particles: []
	_repellers: []

	_isPlaying: false
	_lastCycle: undefined
	_delta: 1

	_friction: 0.02

	_wind:
		x: 0
		y: 0

	_gravity:
		x: 0
		y: 0

	_scroll:
		x: 0
		y: 0

	_lastScrollTop: undefined


	constructor: (el) ->
		super el
		@_imgSrc = @_el.dataset.imgSrc
		@_canvas = @_el.getElementsByTagName('canvas')[0]
		@_ctx = @_canvas.getContext '2d'

	init: () ->
		@_lastScrollTop = app.scroll.top
		@_img = new Image()
		super()

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

		perams =
			# domElement: @_canvas
			width: @_width
			height: @_height
			type: Two.Types.webgl

		@_two = new Two perams
		@_two.appendTo @_el
		console.log @_two

		@_img.src = @_imgSrc


	_setupListeners: () ->
		@_listenerMap = [
			{el: @_img, event: 'load', handler: @_getImageData}
			# {event: 'mousemove', handler: @_onMouseMove}
		]

		@_subscriptionMap = [
			{event: 'viewport.resize', handler: @_onResize}
			{event: 'viewport.scroll', handler: @_onScroll}
		]

		super()

	_onMouseDown: (e) =>
		@_wind.x *= 1.5
		@_wind.y *= 1.5

	_onMouseMove: (e) =>
		@_wind =
		 	x: UTIL.Maths.convertToRange e.clientX, [0, @_width], [-0.01, 0.01]
		 	y: UTIL.Maths.convertToRange e.clientY, [0, @_height], [-0.01, 0.01]

	_onScroll: =>
		scrollForce = app.scroll.top - @_lastScrollTop
		@_lastScrollTop = app.scroll.top

		@_scroll =
			x: 0
			y: scrollForce/100

	_getImageData: () =>
		@_ctx.drawImage @_img, 0, 0, @_width, @_height
		imageData = @_ctx.getImageData(0, 0, @_width, @_height).data

		for y in [0..@_height]
			@_pixelBrights[y] = []
			for x in [0..@_width]
				r = imageData[((@_width * y) + x) * 4]
				g = imageData[((@_width * y) + x) * 4 + 1]
				b = imageData[((@_width * y) + x) * 4 + 2]
				brightness = Math.floor (r+g+b)/3
				@_pixelBrights[y][x] = brightness
		@_ctx.clearRect 0, 0, @_width, @_height
		@_setupParticles()


	_setupParticles: () ->
		console.log 'setup'
		for y in [0..@_height] by 40
			for x in [0..@_width] by 40
				brightness = @_pixelBrights[y][x]
				rad = UTIL.Maths.convertToRange brightness, [0, 255], [0, 5]
				# rad = 2
				circ = @_two.makeCircle x, y, rad
				circ.fill = 'rgba(255,255,255,0.7)'
				@_particles.push new Particle x, y, rad, @_ctx, @_width, @_height, circ

		for y in [0..@_height] by 50
			for x in [0..@_width] by 50
				strength = UTIL.Maths.convertToRange @_pixelBrights[y][x], [255, 0], [-5,5]
				@_repellers.push new Repeller x, y, strength, @_ctx

		# @_repellers.push new Repeller @_width/2, @_height/2, -10, @_ctx

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
		@_two.update()
		@_lastCycle = now

	_pause: () =>
		cancelAnimationFrame @_RAFs.animate
		@_isPlaying = false

	_update: () ->
		# for particle in @_particles
		# 	particle.clear()
		# @_ctx.clearRect 0, 0, @_width, @_height
		# @_ctx.drawImage @_img, 0, 0, @_width, @_height

		
		# for repeller in @_repellers
		# 	repeller.draw()
		for particle in @_particles
			# for repeller in @_repellers
			# 	repel = repeller.repel particle
			# 	particle.applyForce repel

			friction =
				x: particle._velVec.x * -1 * @_friction
				y: particle._velVec.y * -1 * @_friction

			particle.applyForce friction

			particle.applyForce @_gravity
			particle.applyForce @_scroll
			particle.applyForce @_wind
			particle.update @_delta
			particle.draw()

		@_scroll =
			x: 0
			y: 0


# Seperate into Image analysis and then particle system				






module.exports = ParticleImage