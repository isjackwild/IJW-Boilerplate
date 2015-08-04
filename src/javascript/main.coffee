kickIt = ->
	require './vendor/modernizr.custom.17673'
	require './vendor/requestAnimationFramePolyfill.js'
	require './vendor/eventListenerPolyfill.js'
	require './vendor/arraymove.js'
	classie = require 'desandro-classie'
	Controller = require './Controller'

	console.log 'KICK IT!'
	
	if Modernizr.csstransforms3d is false or Modernizr.csstransforms is false
		classie.add document.body, 'browser-not-supported'
		return

	app = window.app = window.app || {}

	window.controller = new Controller

if document.addEventListener
	document.addEventListener 'DOMContentLoaded', kickIt
else
	window.attachEvent 'onload', kickIt