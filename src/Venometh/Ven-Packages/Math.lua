local mathPackage = {}
mathPackage.__index = mathPackage

function mathPackage.__initialize__(ven)
	return setmetatable({_ven = ven}, mathPackage)
end

function mathPackage:MapRange(input, output)
	local inputMin, inputMax = unpack(input)
	local outputMin, outputMax = unpack(output)
	return function(x) return((x - inputMin) * (outputMax - outputMin) / (inputMax - inputMin) + outputMin) end
end

return mathPackage