# Get the namespace
app = window.app = window.app || {}
UTIL  = require '../../vendor/ijw.UTIL' #My own home-made UTIL library

class Repeller

	_locVec: undefined
	
	_strength: undefined

	_radius: 10

	_ctx: undefined


	constructor: (x, y, strength, ctx) ->
		@_ctx = ctx
		@_locVec =
			x: x
			y: y

		@_strength = strength
		@_radius = UTIL.Maths.convertToRange @_strength, [-1,1], [0,10]


	repel: (particle) =>
		dir =
			x: @_locVec.x - particle._locVec.x
			y: @_locVec.y - particle._locVec.y

		d = Math.sqrt(dir.x*dir.x + dir.y*dir.y);
		# d = Math.max d, 100


		if d > 50
			dir.x = 0
			dir.y = 0
		else
			force = @_strength / (d * d)
			dir.x *= force
			dir.y *= force

		return dir

	draw: () =>
		@_ctx.fillStyle = 'rgba(255,0,0,1)'
		@_ctx.beginPath()
		@_ctx.arc @_locVec.x, @_locVec.y, @_radius, 0, 2*Math.PI, false
		@_ctx.fill()


# TO DO : DELTA



module.exports = Repeller