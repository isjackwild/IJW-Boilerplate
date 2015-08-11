# Get the namespace
app = window.app = window.app || {}
UTIL  = require '../../vendor/ijw.UTIL' #My own home-made UTIL library

class Particle

	_locVec: undefined
	_velVec: undefined
	_accVec: undefined

	_ctx: undefined
	_radius: 0
	_mass: 1.2

	_maxVel: undefined
	_maxX: undefined
	_maxY: undefined

	_circ: undefined

	_x: undefined
	_y: undefined

	constructor: (x, y, rad, ctx, w, h, circ) ->
		@_ctx = ctx
		@_circ = circ
		@_radius = rad
		@_maxVel = rad
		@_x = x
		@_y = y
		@_mass = UTIL.Maths.convertToRange rad, [0, 3], [3, 10]

		@_maxX = w-rad
		@_maxY = h-rad

		@_locVec =
			x: x
			y: y

		@_velVec =
			x: Math.random()/10 - 0.05
			y: Math.random()/10 - 0.05

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
		if Math.abs(@_velVec.x + @_accVec.x*delta) < @_maxVel
			@_velVec.x+= @_accVec.x*delta

		# else
		# 	@_velVec.x = 0

		if Math.abs(@_velVec.y + @_accVec.y*delta) < @_maxVel
			@_velVec.y+= @_accVec.y*delta
		# else
		# 	@_velVec.y = 0

		if @_locVec.x+@_velVec.x > @_radius and @_locVec.x+@_velVec.x < @_maxX
			@_locVec.x += @_velVec.x
		else
			@_velVec.x*= -@_radius/10

		if @_locVec.y+@_velVec.y > @_radius and @_locVec.y+@_velVec.y < @_maxY
			@_locVec.y += @_velVec.y
		else
			@_velVec.y*= -@_radius/10


		@_accVec =
			x: 0
			y: 0

	
	clear: () ->
		if @_locVec
			@_ctx.clearRect @_locVec.x-@_radius-10, @_locVec.y-@_radius-10, @_radius*2+10, @_radius*2+10

	draw: () ->
		# @_ctx.fillStyle = 'rgba(255,255,255,0.66)'
		# @_ctx.beginPath()
		# @_ctx.arc @_locVec.x, @_locVec.y, @_radius, 0, 2*Math.PI, false
		# @_ctx.fill()
		# console.log @_circ
		@_circ.translation.set @_locVec.x, @_locVec.y

	kill: () ->
		@_ctx = undefined
		





module.exports = Particle