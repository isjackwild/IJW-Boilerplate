# Our router manages our routes, history and AJAX loading.

app = window.app = window.app || {}
PubSub = require 'pubsub-js'
gator = require './vendor/gator.min'
UTIL = require './vendor/ijw.UTIL' #My own home-made UTIL library
classie = require 'desandro-classie'
ImgExtended = require './ImgExtended'
VideoExtended = require './VideoExtended'

class MediaLoader
	_isInit: false
	_activeImages: []
	_activeVideos: []
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
		@_subscriptions.push PubSub.subscribe 'image.loaded', @_loadNextImage
		@_subscriptions.push PubSub.subscribe 'image.error', @_loadNextImage
		@_subscriptions.push PubSub.subscribe 'image.timeout', @_loadNextImage
		@_loadCounter = 0

		for image in document.querySelectorAll('.incoming img.lazy-load')
			@_activeImages.push new ImgExtended image

		for video in document.querySelectorAll('.incoming video.lazy-load')
			@_activeVideos.push new VideoExtended video

		for video in @_activeVideos
			video.load()

		for i in [0...3]
			@_loadNextImage()

	_cancelLoading: =>
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription

		for image in @_activeImages
				image.kill() # Kill all our active modules from the leaving page

		for video in @_activeVideos
				video.kill() # Kill all our active modules from the leaving page
		
		@_activeImages = []
		@_activeVideos = []


	_loadNextImage: =>
		if @_loadCounter >= @_activeImages.length or @_activeImages.length is 0
			return
		@_activeImages[@_loadCounter].load()
		@_loadCounter += 1


module.exports = MediaLoader
