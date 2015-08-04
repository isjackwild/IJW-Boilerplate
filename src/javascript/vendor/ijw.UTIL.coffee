window.ijw_UTIL = ijw_UTIL = {}

ijw_UTIL.Maths = {}

ijw_UTIL.Colour = {}

ijw_UTIL.Parse = {}

ijw_UTIL.Search = {}

ijw_UTIL.Position = {}


ijw_UTIL.Maths.randomNumber = (min, max, int = null) ->
	if int is "ceil"
		return Math.ceil(Math.random()*(max-min) + min)
	if int is "floor"
		return Math.floor(Math.random()*(max-min) + min)
	else
		return Math.random()*(max-min) + min


ijw_UTIL.Maths.lerpNum = (control, from, to) ->
	return Math.ceil from + (to - from) * control


ijw_UTIL.Maths.convertToRange = (value, srcRange, dstRange) ->
	if value < srcRange[0]
		return dstRange[0]
	else if value > srcRange[1]
		return dstRange[1]
	else
		srcMax = srcRange[1] - srcRange[0]
		dstMax = dstRange[1] - dstRange[0]
		adjValue = value  - srcRange[0]
		return (adjValue * dstMax / srcMax) + dstRange[0]


ijw_UTIL.Colour.lerpColour = (control, from, to) ->
	resultR = Math.ceil from.r + (to.r - from.r) * control
	resultG = Math.ceil from.g + (to.g - from.g) * control
	resultB = Math.ceil from.b + (to.b - from.b) * control

	result = {r:resultR, g:resultG, b:resultB}
	return result

ijw_UTIL.Colour.HSVtoRGB = (h,s,v, returnHex = false) =>
	# REMEMBER: h/360, s/100, v/100
	if h and s is undefined and v is undefined
		s = h.s
		v = h.v
		h = h.h
	i = Math.floor h*6
	f = h * 6 - i
	p = v * (1 - s)
	q = v * (1 - f * s)
	t = v * (1 - (1 - f) * s)

	switch i%6
		when 0
			r = v
			g = t
			b = p
			break
		when 1
			r = q
			g = v
			b = p
			break
		when 2
			r = p
			g = v
			b = t
			break
		when 3
			r = p
			g = q
			b = v
			break
		when 4
			r = t
			g = p
			b = v
			break
		when 5
			r = v
			g = p
			b = q
			break

	rgb =
		r: Math.floor(r*255)
		g: Math.floor(g*255)
		b: Math.floor(b*255)

	if returnHex is false
		return rgb
	else
		r = r.toString 16
		g = g.toString 16
		b = b.toString 16
		if r.length is 1
			r = "0" + r
		if g.length is 1
			g = "0" + g
		if b.length is 1
			b = "0" + b
		return "#" + r + g + b


ijw_UTIL.Colour.RGBtoHSV = (r,g,b) =>
	if !g and !b
		b = r.b
		g = r.g
		r = r.r
	r = r/255
	g = g/255
	b = b/255

	v = Math.max(r,g,b)
	diff = v - Math.min(r,g,b)
	
	diffc = (c) ->
		return ((v-c) / 6) / (diff + 1) / 2

	if diff is 0
		h = s = 0
	else
		s = diff / v
		rr = diffc r
		gg = diffc g
		bb = diffc b

		if r is v
			h = bb - gg
		else if g is v
			h = (1/3) + rr - bb
		else if b is v
			h = (2 / 3) + gg - rr

		if h < 0
			h+= 1
		else if h > 1
			h-= 1

	res = 
		h: Math.round h*360
		s: Math.round s*100
		v: Math.round v*100

	return res



ijw_UTIL.Colour.componentToHex = (c) =>
	hex = c.toString 16
	if hex.length is 1
		return "0" + hex
	else
		return hex


#relies on ijw_UTIL.Colour.componentToHex
ijw_UTIL.Colour.rgbToHex = (r,g,b) =>
	return "#" + ijw_UTIL.Colour.componentToHex(r) + ijw_UTIL.Colour.componentToHex(g) + ijw_UTIL.Colour.componentToHex(b)

ijw_UTIL.Colour.hexToRGB = (hex) =>
	result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
	if result
		res = 
	        r: parseInt result[1], 16
	        g: parseInt result[2], 16
	        b: parseInt result[3], 16
		return res
	else
		return null

ijw_UTIL.Search.nearestAncestorWithClass = (el, _class) =>
	loop
		break if el.classList.contains(_class) or !el.parentElement
		el = el.parentElement
	if !el.parentElement
		return false
	else
		return el


ijw_UTIL.Parse.href = (href) ->
	parser = document.createElement 'a'
	parser.href = href
	@_currentPath = parser.pathname

	parsed = 
		protocol: parser.protocol
		host: parser.host
		hostname: parser.hostname
		port: parser.port
		pathname: parser.pathname
		hash: parser.hash
		search: parser.search

	parser = undefined

	return parsed

ijw_UTIL.Position.getCoords = (elem) =>
    box = elem.getBoundingClientRect();

    body = document.body;
    docEl = document.documentElement;

    scrollTop = window.pageYOffset || docEl.scrollTop || body.scrollTop
    scrollLeft = window.pageXOffset || docEl.scrollLeft || body.scrollLeft

    clientTop = docEl.clientTop || body.clientTop || 0
    clientLeft = docEl.clientLeft || body.clientLeft || 0

    top  = box.top +  scrollTop - clientTop
    left = box.left + scrollLeft - clientLeft

    return { top: Math.round(top), left: Math.round(left) };

# ijw_UTIL.applyXBrowserStyle = (el, property, value) =>
# 	webkitProperty = 'webkit' + property.charAt(0).toUpperCase() + property.slice(1)
# 	mozProperty = 'moz' + property.charAt(0).toUpperCase() + property.slice(1)
# 	msProperty = 'ms' + property.charAt(0).toUpperCase() + property.slice(1)
# 	oProperty = 'o' + property.charAt(0).toUpperCase() + property.slice(1)
	
# 	el.style.property = value
# 	el.style.mozProperty = value
# 	el.style.msProperty = value
# 	el.style.oProperty = value

module.exports = ijw_UTIL