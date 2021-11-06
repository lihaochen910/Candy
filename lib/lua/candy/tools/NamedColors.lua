-- module
local NamedColorsModule = {}

local NamedColors = {
	mediumseagreen = "#3cb371",
	orchid = "#da70d6",
	darkcyan = "#008b8b",
	rosybrown = "#bc8f8f",
	floralwhite = "#fffaf0",
	lavenderblush = "#fff0f5",
	lightskyblue = "#87cefa",
	lawngreen = "#7cfc00",
	lime = "#00ff00",
	peachpuff = "#ffdab9",
	olive = "#808000",
	linen = "#faf0e6",
	mediumorchid = "#ba55d3",
	navajowhite = "#ffdead",
	olivedrab = "#6b8e23",
	darkmagenta = "#8b008b",
	magenta = "#ff00ff",
	black = "#000000",
	darkblue = "#00008b",
	coral = "#ff7f50",
	seashell = "#fff5ee",
	palegreen = "#98fb98",
	cornsilk = "#fff8dc",
	deepskyblue = "#00bfff",
	blanchedalmond = "#ffebcd",
	beige = "#f5f5dc",
	dimgray = "#696969",
	lightgoldenrodyellow = "#fafad2",
	salmon = "#fa8072",
	cadetblue = "#5f9ea0",
	seagreen = "#2e8b57",
	oldlace = "#fdf5e6",
	orangered = "#ff4500",
	goldenrod = "#daa520",
	mintcream = "#f5fffa",
	lightsteelblue = "#b0c4de",
	lightslategray = "#778899",
	lemonchiffon = "#fffacd",
	paleturquoise = "#afeeee",
	plum = "#dda0dd",
	brown = "#a52a2a",
	darkviolet = "#9400d3",
	hotpink = "#ff69b4",
	ivory = "#fffff0",
	purple = "#800080",
	darkgreen = "#006400",
	gray = "#808080",
	darksalmon = "#e9967a",
	saddlebrown = "#8b4513",
	teal = "#008080",
	tomato = "#ff6347",
	whitesmoke = "#f5f5f5",
	greenyellow = "#adff2f",
	pink = "#ffc0cb",
	khaki = "#f0e68c",
	chocolate = "#d2691e",
	yellowgreen = "#9acd32",
	mediumvioletred = "#c71585",
	aquamarine = "#7fffd4",
	chartreuse = "#7fff00",
	royalblue = "#4169e1",
	silver = "#c0c0c0",
	mediumpurple = "#9370db",
	burlywood = "#deb887",
	sienna = "#a0522d",
	palevioletred = "#db7093",
	darkslateblue = "#483d8b",
	turquoise = "#40e0d0",
	darkorchid = "#9932cc",
	lightcoral = "#f08080",
	slategray = "#708090",
	mediumturquoise = "#48d1cc",
	peru = "#cd853f",
	papayawhip = "#ffefd5",
	mediumspringgreen = "#00fa9a",
	mediumblue = "#0000cd",
	limegreen = "#32cd32",
	forestgreen = "#228b22",
	maroon = "#800000",
	wheat = "#f5deb3",
	white = "#ffffff",
	violet = "#ee82ee",
	darkgray = "#a9a9a9",
	darkgoldenrod = "#b8860b",
	cyan = "#00ffff",
	lightgrey = "#d3d3d3",
	mediumaquamarine = "#66cdaa",
	slateblue = "#6a5acd",
	yellow = "#ffff00",
	springgreen = "#00ff7f",
	red = "#ff0000",
	lightgreen = "#90ee90",
	lavender = "#e6e6fa",
	blue = "#0000ff",
	darkseagreen = "#8fbc8f",
	skyblue = "#87ceeb",
	palegoldenrod = "#eee8aa",
	darkred = "#8b0000",
	thistle = "#d8bfd8",
	indianred = "#cd5c5c",
	lightsalmon = "#ffa07a",
	honeydew = "#f0fff0",
	indigo = "#4b0082",
	mediumslateblue = "#7b68ee",
	darkturquoise = "#00ced1",
	darkorange = "#ff8c00",
	lightblue = "#add8e6",
	deeppink = "#ff1493",
	crimson = "#dc143c",
	moccasin = "#ffe4b5",
	darkslategray = "#2f4f4f",
	navy = "#000080",
	snow = "#fffafa",
	midnightblue = "#191970",
	lightcyan = "#e0ffff",
	dodgerblue = "#1e90ff",
	powderblue = "#b0e0e6",
	green = "#008000",
	darkkhaki = "#bdb76b",
	azure = "#f0ffff",
	blueviolet = "#8a2be2",
	lightseagreen = "#20b2aa",
	aliceblue = "#f0f8ff",
	darkolivegreen = "#556b2f",
	gold = "#ffd700",
	lightpink = "#ffb6c1",
	orange = "#ffa500",
	lightyellow = "#ffffe0",
	cornflowerblue = "#6495ed",
	gainsboro = "#dcdcdc",
	firebrick = "#b22222",
	bisque = "#ffe4c4",
	antiquewhite = "#faebd7",
	mistyrose = "#ffe4e1",
	sandybrown = "#f4a460",
	ghostwhite = "#f8f8ff",
	steelblue = "#4682b4",
	tan = "#d2b48c"
}

function getNamedColor ( name, alpha )
	name = string.lower ( name )
	local hex = NamedColors[ name ]
	if not hex then
		return 0, 0, 0, alpha or 1
	else
		return hexcolor ( hex, alpha )
	end
end

function getNamedColorHex ( name )
	name = string.lower ( name )
	local hex = NamedColors[ name ]
	return hex
end

NamedColorsModule.getNamedColor = getNamedColor
NamedColorsModule.getNamedColorHex = getNamedColorHex

return NamedColorsModule