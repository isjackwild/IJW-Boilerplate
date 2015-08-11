# Get the namespace
app = window.app = window.app || {}
UIModule = require './UIModule'
THREE = require 'THREE'

class Image360 extends UIModule
	_imgSrc: undefined

	_camera: undefined
	_scene: undefined
	_geometry: undefined
	_material: undefined
	_mesh: undefined
	_renderer: undefined

	_sceneIsSetup: false
	_isPlaying: false
	_animateRAF: undefined
	_decelerateRAF: undefined

	_isInteracting: false
	_isDecelarating: false
	_onMouseDownX: 0
	_onMouseDownY: 0
	_lon: 0
	_lat: 0
	_onMouseDownLon: 0
	_onMouseDownLat: 0
	_phi: 0
	_theta: 0
	_vel: 
		x : 0
		y : 0
		vel : 0

	_autoSpinInc: 0.05
	_friction: 0.013


	constructor: (el) ->
		super el
		@_imgSrc = @_el.dataset.imgSrc

	init: () ->
		super()
		@_setupScene()

	kill: () ->
		@_sceneIsSetup = false
		@_pause()
		@_cancelDecelerate()
		super()


	_setupListeners: () ->
		@_listenerMap = [
			{event: 'mousedown', handler: @_onMouseDown}
			{event: 'mouseup', handler: @_onMouseUp}
			{event: 'mouseleave', handler: @_onMouseUp}
		]

		@_subscriptionMap = [
			{event: 'viewport.resize', handler: @_onResize}
			{event: 'viewport.scroll', handler: @_onScroll}
			{event: 'mouse.move', handler: @_onMouseMove}
		]

		super()

	_onMouseDown: (e) =>
		e.preventDefault()

		@_isInteracting = true
		@_cancelDecelerate()

		@_onMouseDownX = e.clientX
		@_onMouseDownY = e.clientY
		@_onMouseDownLon = @_lon
		@_onMouseDownLat = @_lat

		@_velCalc = @_makeVelocityCalculator()

	_onMouseUp: (e) =>
		e.preventDefault()
		@_isInteracting = false
		@_cancelDecelerate()
		if @_vel.vel > 2
			@_decelerate()


	_onMouseMove: (e, xy) => #Use mouse event in controller?
		if !@_sceneIsSetup or !@_isInteracting or !@_inVp then return

		@_lon = (@_onMouseDownX - app.mouse.x) * 0.1 + @_onMouseDownLon
		@_lat = (app.mouse.y - @_onMouseDownY) * 0.1 + @_onMouseDownLat

		@_vel = @_velCalc()

	_decelerate: () =>
		@_lon -= @_vel.x * 0.15
		@_lat += @_vel.y * 0.15

		@_vel.x *= 1-@_friction
		@_vel.y *= 1-@_friction

		@_isDecelarating = true
		@_decelerateRAF = requestAnimationFrame @_decelerate

		if Math.abs(@_vel.x) < 0.2 and Math.abs(@_vel.y) < 0.2
			@_cancelDecelerate()

	
	_cancelDecelerate: () =>
		cancelAnimationFrame @_decelerateRAF
		@_isDecelarating = false



	_makeVelocityCalculator: () -> #Move to my UTIL
		x = app.mouse.x
		y = app.mouse.y
		t = Date.now()

		calculator = ->
			newX = app.mouse.x
			newY = app.mouse.y
			newT = Date.now()
			distX = newX - x
			distY = newY - y
			interval = newT - t
			vel = Math.sqrt(distX * distX + distY * distY)/interval

			dir = 0

			x = newX
			y = newY
			t = newT

			vel =
				vel: vel
				x: distX / interval
				y: distY / interval

			return vel

		return calculator


	_onResize: () =>
		super()
		if !@_sceneIsSetup then return
		@_camera.aspect = @_aspectRatio
		@_camera.updateProjectionMatrix()
		@_renderer.setSize @_width, @_height

	_onScroll: () =>
		super()
		if @_inVp and !@_isPlaying
			@_animate()
		else if !@_inVp and @_isPlaying
			@_pause()


	_setupScene:() ->
		@_camera = new THREE.PerspectiveCamera 75, @_aspectRatio, 1, 1100
		@_camera.target = new THREE.Vector3 0, 0, 0

		@_scene = new THREE.Scene()

		@_geometry = new THREE.SphereGeometry 500, 60, 40
		@_geometry.applyMatrix new THREE.Matrix4().makeScale( -1, 1, 1 )
		
		perams = 
			map: THREE.ImageUtils.loadTexture @_imgSrc
		@_material = new THREE.MeshBasicMaterial perams
		@_mesh = new THREE.Mesh @_geometry, @_material
		
		@_scene.add @_mesh

		@_renderer = new THREE.WebGLRenderer();
		@_renderer.setPixelRatio window.devicePixelRatio
		@_renderer.setSize @_width, @_height
		

		@_el.appendChild @_renderer.domElement
		@_animate()

		@_sceneIsSetup = true


	_animate: () =>
		if !_sceneIsSetup
			return
		@_isPlaying = true
		@_animateRAF = requestAnimationFrame @_animate
		@_update()

	_pause: () =>
		cancelAnimationFrame @_animateRAF
		@_isPlaying = false

	_update: () ->
		if !@_isInteracting and !@_isDecelarating
			@_lon += @_autoSpinInc

		@_lat = Math.max -85, Math.min(85, @_lat)
		@_phi = THREE.Math.degToRad 90 - @_lat
		@_theta = THREE.Math.degToRad @_lon

		@_camera.target.x = 500 * Math.sin(@_phi) * Math.cos (@_theta)
		@_camera.target.y = 500 * Math.cos(@_phi)
		@_camera.target.z = 500 * Math.sin(@_phi) * Math.sin (@_theta)

		@_camera.lookAt @_camera.target

		@_renderer.render @_scene, @_camera


	# REMEMBER TO DISTROY EVERYTHING
	# PAUSE WHEN NOT IN VP
	# RAF on events
	# Mobile orientation
	# Momentum







module.exports = Image360