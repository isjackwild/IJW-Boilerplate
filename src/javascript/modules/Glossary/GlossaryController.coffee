# Get the namespace
app = window.app = window.app || {}
PubSub = require 'pubsub-js'
$ = require 'jquery'
classie = require 'desandro-classie'

DefView = require './DefView'


# Modify jquery :contains to be case insensitive
$.expr[":"].contains = $.expr.createPseudo (arg) ->
	returnFunct = (elem) ->
		return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
	return returnFunct


class GlossaryController
	_isInit: false

	_subscriptions: []
	_listenerMap: []

	_glossaryTerms: []
	_currentTermsOnPage: []
	_defView: false

	_waitingForTerms: false

	constructor: (el) ->
		@_init()

	_init: () -> # Start it up
		if @_isInit
			return
		@_isInit = true
		@_setupListeners()
		@_getGlossaryTermsFromServer()
		PubSub.publish 'module.init'


	kill: () -> # Cleanup.
		@_removeEventListeners()
		setTimeout =>
			PubSub.publish 'module.kill'
			@_el = undefined
		,0


	_setupListeners: () ->
		@_subscriptionMap = [
			{event: 'route.success', handler: @_findTermsHandler}
		]

		@_addEventListeners()

	_addEventListeners: () ->
		for obj in @_listenerMap
			if !obj.el then obj.el = @_el
			obj.el.addEventListener obj.event, obj.handler, false

		console.log @_subscriptionMap
		for obj in @_subscriptionMap
			@_subscriptions.push PubSub.subscribe obj.event, obj.handler


	_removeEventListeners: () ->
		for subscription in @_subscriptions
			PubSub.unsubscribe subscription
		for obj in @_listenerMap
			if !obj.el then obj.el = @_el
			obj.el.removeEventListener obj.event, obj.handler, false


	_findTermsHandler: () =>
		if !@_glossaryTerms.length
			@_waitingForTerms = true
		else
			@_findTerms()

	_getGlossaryTermsFromServer: () ->
		@_glossaryTerms = [
			{term: 'Suspendisse', definition: 'this is an example definition to check if the glossary controller is working properly'}
			{term: 'Morbi', definition: 'here is another example definition for the glossary'}
		]

		if @_waitingForTerms
			@_findTerms()
			@_waitingForTerms = false
	

	_findTerms: () =>
		@_removeEventListenersFromTerms()
		if !@_glossaryTerms.length
			return

		paras = document.getElementsByTagName 'p'
		for term in @_glossaryTerms
			$("p:contains('"+term.term+"')").html (_, html) ->
				re = new RegExp term.term, "gi"
				return html.replace re, "<span class='-mod-glossary--term' data-definition='" + term.definition + "' data-term='" + term.term + "'>"+term.term+"</span>"

		@_currentTermsOnPage = document.getElementsByClassName '-mod-glossary--term'
		@_addEventListenersToTerms()


	_addEventListenersToTerms: () ->
		for term in @_currentTermsOnPage
			term.addEventListener 'mouseenter', @_onMouseOverTerm
			term.addEventListener 'mouseleave', @_onMouseOutTerm

	_removeEventListenersFromTerms: () ->
		for term in @_currentTermsOnPage
			term.removeEventListener 'mouseenter', @_onMouseOverTerm
			term.removeEventListener 'mouseleave', @_onMouseOutTerm

	_onMouseOverTerm: (e) =>
		classie.add document.body, '-mod-glossary--term-shown'
		@_defView = new DefView e.currentTarget

	_onMouseOutTerm: (e) =>
		classie.remove document.body, '-mod-glossary--term-shown'
		if @_defView
			@_defView.remove()
			@_defView = false

		# TO DO, make sure terms don't get wrapped multiple times








module.exports = GlossaryController # Export for use in browserify. Read up on CommonJS