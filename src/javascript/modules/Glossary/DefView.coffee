# Get the namespace
app = window.app = window.app || {}



class DefView
	_el: undefined

	constructor: (el) ->
		def = el.dataset.definition
		term = el.dataset.term

		@_el = document.createElement 'DIV'
		termSpan = document.createElement 'SPAN'
		defSpan = document.createElement 'SPAN'

		termSpan.innerHTML = term + '&nbsp;'
		defSpan.innerText = def

		style = window.getComputedStyle el
		rect = el.getBoundingClientRect()

		termSpan.className = '-mod-glossary--term-span'
		defSpan.className = '-mod-glossary--def-span'

		@_el.className = '-mod-glossary--def-view'
		@_el.style.position = 'fixed';
		@_el.style.top = rect.top+'px'
		@_el.style.left = rect.left+'px'
		@_el.style.fontFamily = style.fontFamily
		@_el.style.fontSize = style.fontSize
		@_el.style.fontWeight = style.fontWeight
		@_el.style.fontStyle = style.fontStyle
		@_el.style.letterSpacing = style.letterSpacing
		@_el.style.lineHeight = style.lineHeight

		@_el.appendChild termSpan
		@_el.appendChild defSpan
		document.body.appendChild @_el

	remove: () ->
		@_el.parentNode.removeChild @_el








module.exports = DefView # Export for use in browserify. Read up on CommonJS