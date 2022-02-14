--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

--[[

CREATE STRING

str "string"


CREATE WITH FORMAT

str(format-string: string | str, ...: string | str)


USING BUILT-IN STRING METHODS

(Use any built-in string method with first param passed automatically)

str.upper()

str.rep(3)

str.sub(1, 3)


REPLACE STRING

txt = str "old string"; txt "new string"


GET EXPLICIT STRING

-str --use the '-' unary operator

tostring(str)


STRING LENGTH

#-str


CONCATENATION

str .. str

str + str


SPLIT STRING WITH DELIMITER

str / <string>


REPETITIONS

str * <number>


INDEX (string.sub)

str-<start>.<end>


]]

local str = {}

str.__index = str

str.__unm = function(t)
	return t._str
end
str.__tostring = str.__unm

str.__concat = function(a, b)
	a = if type(a) == "table" then a._str else a
	b = if type(b) == "table" then b._str else b
	return str.new(a..b)
end
str.__add = str.__concat

str.__div = function(a, b)
	if type(a) ~= "table" then a, b = b, a end
	return string.split(a._str, b)
end

str.__mul = function(a, b)
	if type(a) ~= "table" then a, b = b, a end
	return str.new(string.rep(a._str, b))
end

str.__sub = function(a, b, c)
	if type(a) ~= "table" then a, b = b, a end
	b, c = math.modf(b)
	return str.new(string.sub(a._str, b, c * 10))
end

str.__eq = function(a, b)
	return a._str == b._str
end

str.__call = function(t, ...)
	t._str = ...
	return t
end

str.__index = function(t, callback, ...)
	return function(...) 
		return string[callback](t._str, ...)
	end
end

str.new = function(s, ...)
	s = type(s) == "table" and s._str or s
	local f = {}
	for _, arg in ipairs {...} do
		table.insert(f, type(arg) == "table" and arg._str or arg)
	end
	f = if ... then string.format(s, unpack(f)) else s
	return setmetatable({_str = f}, str)
end

return function(...)
	return str.new(...)
end