# Our router manages our routes, history and AJAX loading.

app = window.app = window.app || {}
PubSub = require 'pubsub-js'
gator = require './vendor/gator.min'
UTIL = require './vendor/ijw.UTIL' #My own home-made UTIL library
classie = require 'desandro-classie'
ImgExtended = require './modules/ImgExtended'

class MediaLoader
	_isInit: false
	_activeMedia: []
	_subscriptions: []

	constructor: ->
		@_init()


	_init: =>
		if @_isInit
			return
		@_isInit = true

		@_addEventListeners()
		

	_addEventListeners: =>
		PubSub.subscribe 'route.success', @_loadMedia
		PubSub.subscribe 'route.loaded', @_cancelLoading


	_loadMedia: => # _Init our new modules
		@_subscriptions.push PubSub.subscribe 'media.loaded', @_loadNextMedia
		@_subscriptions.push PubSub.subscribe 'media.error', @_loadNextMedia
		@_subscriptions.push PubSub.subscribe 'media.timeout', @_loadNextMedia
		@_loadCounter = 0

		for image in document.querySelectorAll('.incoming img.lazy-load')
			@_activeMedia.push new ImgExtended image

		for i in [0...3]
			@_loadNextMedia()

	_cancelLoading: =>
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription

		for media in @_activeMedia
				media.kill() # Kill all our active modules from the leaving page
			@_activeMedia = []


	_loadNextMedia: =>
		if @_loadCounter >= @_activeMedia.length or @_activeMedia.length is 0
			return
		@_activeMedia[@_loadCounter].load()
		@_loadCounter += 1


module.exports = MediaLoader
