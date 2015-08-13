# Get the namespace
app = window.app = window.app || {}
UTIL  = require '../../vendor/ijw.UTIL' #My own home-made UTIL library

class Particle

	_locVec: undefined
	_velVec: undefined
	_accVec: undefined
	_targetVec: undefined
	_maxVel: undefined

	_ctx: undefined
	_mass: 12

	_w: undefined
	_h: undefined
	_i: undefined
	_cvw: undefined
	_cvh: undefined

	_img: undefined

	constructor: (i, h, titleW, cvW, cvH, img, ctx) ->
		@_ctx = ctx
		@_img = img

		@_cvw = cvW
		@_cvh = cvH

		@_maxVel = 2

		@_w = 1
		@_h = h
		@_i = i
		# @_mass = (Math.sin(i/10) /10) + 0.9
		# @_mass = Math.random()/5 + 0.75
		@_mass = if i%2 is 0 then 1 else 0.8
		# @_mass = Math.sin(i/30) / 10 + 0.5
		@_maxVel = @_mass * 12

		console.log @_mass

		@_targetVec =
			x: Math.round cvW/2 + i - titleW/2
			y: Math.round cvH/2 - @_h/2

		@_locVec =
			x: @_targetVec.x
			y: @_targetVec.y

		@_velVec =
			x: 0
			y: 0

		@_accVec =
			x: 0
			y: 0


	applyForce: (force) ->
		_force = {}
		_force.x = force.x / @_mass
		_force.y = force.y / @_mass

		@_accVec.x += _force.x
		@_accVec.y += _force.y

	update: (delta) ->

		# @_velVec.x+= @_accVec.x*delta
		# @_velVec.y+= @_accVec.y*delta

		if Math.abs(@_velVec.x + @_accVec.x*delta) < @_maxVel
			@_velVec.x+= @_accVec.x*delta

		if Math.abs(@_velVec.y + @_accVec.y*delta) < @_maxVel
			@_velVec.y+= @_accVec.y*delta

		# if Math.abs(@_locVec.y - @_targetVec.y) < 2
		# 	@_velVec.y = 0
		# 	@_locVec.y = @_targetVec.y


		@_locVec.x += @_velVec.x
		@_locVec.y += @_velVec.y

		@_accVec =
			x: 0
			y: 0

	
	clear: () ->
		if @_locVec
			x = @_locVec.x
			y = @_locVec.y
			w = @_w
			h = @_h
			@_ctx.clearRect x, y, w, h

	draw: () ->
		@_ctx.drawImage @_img, @_i, 0, @_w, @_h, @_locVec.x, @_locVec.y, @_w, @_h
		# maybe just use stroke here

	kill: () ->
		@_ctx = undefined
		





module.exports = Particle