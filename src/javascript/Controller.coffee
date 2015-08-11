# Our controller manages our global states, such as resize, etc.

app = window.app = window.app || {}

gator = require './vendor/gator.min'
_ = require 'lodash'
PubSub = require 'pubsub-js'
classie = require 'desandro-classie'
$ = require 'jquery'

Router = require './Router'
PageTransitionEngine = require './engines/PageTransitionEngine'
MediaLoader = require './MediaLoader'
UIEngine = require './engines/UIEngine'
GlossaryController = require './modules/Glossary/GlossaryController'

app.devices =
	isMobileDown : null
	isTabletPortraitDown : null
	isTabletLandscapeDown : null
	isXlUp : null

app.viewport =
	w : null
	h : null

app.scroll =
	top : 0
	bottom : 0
	pastFold : false

app.mouse = 
	x: 0
	y: 0


class Controller
	_router: undefined
	_mouseMoveRafPending: false
	_scrollRafPending: false
	_isScrollingTO: undefined
	_isScrolling: false
	_pageTransitionEngine: undefined
	_UIEngine: undefined

	constructor: ->
		@_init()
		@_router = new Router
		@_pageTransitionEngine = new PageTransitionEngine
		@_UIEngine = new UIEngine
		@_GlossaryController = new GlossaryController
		@_mediaLoader = new MediaLoader

		

	_init: ->
		@_onResize()
		@_addListeners()


	_addListeners: ->
		window.addEventListener 'resize', _.debounce(@_onResize, 400)

		scrollHandler = (e) =>
			if @_scrollRafPending
				return
			@_scrollRafPending = true
			window.requestAnimationFrame =>
				@_scrollRafPending = false
				@_onScroll e
		window.addEventListener 'scroll', scrollHandler

		mouseMoveHandler = (e) =>
			if @_mouseMoveRafPending
				return
			@_mouseMoveRafPending = true
			window.requestAnimationFrame =>
				@_mouseMoveRafPending = false
				@_onMouseMove e
		window.addEventListener 'mousemove', mouseMoveHandler
		


	_onScroll: (e) =>
		app.scroll.top = document.body.scrollTop || document.getElementsByTagName('html')[0].scrollTop
		app.scroll.bottom = app.scroll.top + app.viewport.h
		PubSub.publish 'viewport.scroll', app.scroll.top
		
		clearTimeout @_isScrollingTO
		if !@_isScrolling
			@_isScrolling = true
			classie.add document.body, 'is-scrolling'
		@_isScrollingTO = setTimeout =>
			@_isScrolling = false
			classie.remove document.body, 'is-scrolling'
		,333


		if app.scroll.top >= (app.viewport.h + 30) and app.scroll.pastFold is false
			classie.add document.body, 'past-fold'
			app.scroll.pastFold = true
		else if app.scroll.top < (app.viewport.h + 30) and app.scroll.pastFold is true
			classie.remove document.body, 'past-fold'
			app.scroll.pastFold = false


	_onResize: =>
		app.viewport =
			w : window.innerWidth || html.clientWidth || body.clientWidth || screen.availWidth
			h : window.innerHeight || html.clientHeight || body.clientHeight || screen.availHeight
		@_getDeviceState()
		PubSub.publish 'viewport.resize', app.viewport
		@_onScroll()

	_onMouseMove: (e) =>
		xy = 
			x: e.clientX
			y: e.clientY
		app.mouse = xy
		PubSub.publish 'mouse.move', app.mouse


	_getDeviceState: ->
		isMobileDown = window.getComputedStyle(document.querySelector('.state-checks .is-mobile-down'), ':before').getPropertyValue('content')
		isTabletPortraitDown = window.getComputedStyle(document.querySelector('.state-checks .is-tablet-portrait-down'), ':before').getPropertyValue('content')
		isTabletLandscapeDown = window.getComputedStyle(document.querySelector('.state-checks .is-tablet-landscape-down'), ':before').getPropertyValue('content')
		isXlUp = window.getComputedStyle(document.querySelector('.state-checks .is-xl-up'), ':before').getPropertyValue('content')

		app.devices =
			isMobileDown : isMobileDown
			isTabletPortraitDown : isTabletPortraitDown
			isTabletLandscapeDown : isTabletLandscapeDown
			isXlUp : isXlUp
	

module.exports = Controller
