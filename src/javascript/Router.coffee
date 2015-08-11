# Our router manages our routes, history and AJAX loading.

app = window.app = window.app || {}
PubSub = require 'pubsub-js'
gator = require './vendor/gator.min'
$ = require 'jquery'
UTIL = require './vendor/ijw.UTIL' #My own home-made UTIL library
classie = require 'desandro-classie'
ImgExtended = require './modules/ImgExtended'
Image360 = require './modules/Image360'
ParticleImage = require './modules/ParticleImage/ParticleImage'
HeaderImage = require './modules/HeaderImage/HeaderImage'


class Router
	_isInit: false
	_currentPath: undefined
	
	_subscriptions: []
	_activeModules: []
	_permanentModules: []
	
	_routeTO: undefined
	_ajaxReq: undefined
	_allInitSubscription: undefined
	_allKilledSubscription: undefined
	_cacheImg: undefined
	
	_initModules: 0
	_pending: false
	_firstLoad: true
	_allModulesInit: false


	constructor: ->
		@_init()


	_init: =>
		if @_isInit
			return
		@_isInit = true
		
		if window.sessionStorage and !app.devices.isTabletLandscapeDown
			try
				window.sessionStorage.setItem location.href, $('.page-context', document.body)[0].outerHTML
			catch e
				console.error 'Could not add to session storage', e
				
		@_setupLinks()
		@_addEventListeners()


		PubSub.publish 'route.start'
		document.body.setAttribute 'data-page', document.getElementsByClassName('page-context')[0].id
		@_currentPath = window.location.pathname

		@_allInitSubscription = PubSub.subscribe 'module.allInit', =>
			PubSub.publish 'route.success', @_currentPath
			PubSub.unsubscribe @_allInitSubscription
		
		@_setupIncomingModules() #setup the current page modules and permanent modules
		

		history.pushState {page:location.href}, null, location.href #kinda bad hack to ignore the initial pop-state Safari does on load


	_addEventListeners: =>
		window.addEventListener 'popstate', @_onPopState # Should this be in the controller?
		PubSub.subscribe 'module.init', @_onModuleInit
		PubSub.subscribe 'module.kill', @_onModuleKill


	_onPopState: (e) =>
		if e.state and e.state.page
			e.preventDefault()
			e.stopPropagation()
			PubSub.publish 'transition.from', {type:'history', el:null}

			if window.sessionStorage and !app.devices.isMobileDown
				html = window.sessionStorage.getItem e.state.page
				if html
					PubSub.publish 'route.start', e.state.page
					PubSub.unsubscribe @_allInitSubscription
					PubSub.unsubscribe @_allKilledSubscription
					wrapper = document.createElement 'div'
					wrapper.innerHTML = html
					parsed = wrapper.firstChild
					wrapper = undefined
					@_pending = true

					@_onContentLoad parsed, e.state.page, false
				else
					@_doAjaxCall e.state.page, false, true # don't add history events to history again
			else
				@_doAjaxCall e.state.page, false, true

	_setupLinks: ->
		that = @
		if !window.history or !window.history.pushState
			return

		comp = new RegExp location.host

		gator(document).on 'tap', 'a', (e) ->
			e.preventDefault()

		gator(document).on 'click', 'a', (e) ->
			if @getAttribute('target') is 'blank' || @getAttribute('target') is '_blank'
				return
			if e.ctrlKey or e.metaKey
				return

			e.stopPropagation()

			if that._ajaxReq and !app.devices.isMobileDown
				that._ajaxReq.abort()
				PubSub.publish 'route.abort'

			href = @href

			if href.indexOf('http') isnt -1
				if href.indexOf(location.host) is -1 or href.indexOf(location.host) > 8
					return
			PubSub.publish 'transition.from', {type:'link', el:null}
			e.preventDefault() # don't reload page
			that._doAjaxCall href
			return false


	_doAjaxCall: (href, addToHistory = true, force = false) ->
		PubSub.unsubscribe @_allInitSubscription
		PubSub.unsubscribe @_allKilledSubscription
		parsedHref = UTIL.Parse.href(href)
		pathname = parsedHref.pathname

		if !force
			if parsedHref.search then pathname += parsedHref.search
			if pathname is @_currentPath
				return

		@_pending = true
		PubSub.publish 'route.start', pathname

		clearTimeout @_routeTO

		@_ajaxReq = $.ajax # do our ajax call
			url: href
		.done (data) =>
			partial = $('.page-context', data)[0]
			@_onContentLoad partial, href, addToHistory
		.fail @_onRouteError


	_onRouteError: (error) =>
		clearTimeout @_routeTO
		@_ajaxReq.abort()
		console.error 'route change error', error
		PubSub.publish 'route.error', error
		@_pending = false
		classie.remove document.body, 'pending'
		PubSub.unsubscribe @_allKilledSubscription
		PubSub.unsubscribe @_allInitSubscription

	
	_onContentLoad: (partial, _href, addToHistory) => # Maybe more half of this into the transition
		PubSub.publish 'route.loaded'
		clearTimeout @_routeTO
		pagePartial = partial

		if window.sessionStorage and addToHistory and !app.devices.isTabletLandscapeDown
			try
				window.sessionStorage.setItem _href, pagePartial.outerHTML
			catch e
				console.error 'Could not add to session storage', e

		if document.querySelectorAll('.page-context.incoming').length
			killMe = document.querySelectorAll('.page-context.incoming')[0]
			killMe.parentNode.removeChild killMe

		next = =>
			@_currentPath = UTIL.Parse.href(_href).pathname # update our current path

			@_allKilledSubscription = PubSub.subscribe 'module.allKilled', =>
				document.getElementsByClassName('page-context-wrap')[0].appendChild pagePartial
				PubSub.unsubscribe @_allKilledSubscription

				@_allInitSubscription = PubSub.subscribe 'module.allInit', =>
					document.body.setAttribute 'data-page', pagePartial.id
					PubSub.publish 'route.success', @_currentPath
					@_pending = false
					PubSub.unsubscribe @_allInitSubscription

					if addToHistory
						history.pushState {page:_href}, null, _href

				PubSub.publish 'route.appended'
				@_setupIncomingModules()
			
			PubSub.unsubscribe @_allInitSubscription
			@_removeOutgoingModules()


		if $('img.load-before-transition', pagePartial).length > 0
			coverImageSrc = $('img.load-before-transition', pagePartial)[0].getAttribute('data-src-hd')
			if !@_cacheImg or coverImageSrc isnt @_cacheImg.src
				@_cacheImg = undefined
				@_cacheImg = new Image()
				@_cacheImg.onload = next #On load, add the new page context
				@_cacheImg.src = coverImageSrc
			else if !@_cacheImg.complete
				@_cacheImg.onload = next
			else
				next()

		else
			next()

	_removeOutgoingModules: =>
		@_allModulesInit = false
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription

		if @_activeModules.length > 0
			for module in @_activeModules
				module.kill() # Kill all our active modules from the leaving page
			@_activeModules = []
		else
			@_onAllModulesKilled()


	_setupIncomingModules: => # Init our new modules
		# if @_firstLoad is true # add our permanent modules
			# @_permanentModules.push new Loader document.getElementsByClassName('loader-outer')[0]
		for img in document.querySelectorAll('.incoming .-mod-img-360')
			@_activeModules.push new Image360 img

		for img in document.querySelectorAll('.incoming .-mod-particle-image')
			@_activeModules.push new ParticleImage img

		for header in document.querySelectorAll('.incoming .-mod-header-image')
			@_activeModules.push new HeaderImage header

		@_initIncomingModules()

	_initIncomingModules: ->
		if @_activeModules.length > 0
			for module in @_activeModules
				module.init()
		else
			@_onAllModulesInit()


		if @_firstLoad is true
			classie.add document.body, 'site-loaded'
			@_firstLoad = false


	_onModuleInit: =>
		@_initModules += 1
		if @_initModules is (@_activeModules.length + @_permanentModules.length)
			@_onAllModulesInit()

	_onAllModulesInit: ->
		if @_allModulesInit
			return

		PubSub.publish 'module.allInit'
		PubSub.publish 'viewport.resize', app.viewport
		@_allModulesInit = true
		app.scroll.top = document.body.scrollTop || document.getElementsByTagName('html')[0].scrollTop


	_onModuleKill: =>
		@_allModulesInit = false
		@_initModules -= 1
		if @_initModules is @_permanentModules.length
			@_onAllModulesKilled()

	_onAllModulesKilled: ->
		@_allModulesInit = false
		PubSub.publish 'module.allKilled'


module.exports = Router
