--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local mathPackage = {}
mathPackage.__index = mathPackage

function mathPackage.__initialize__(ven)
	mathPackage._ven = ven
	return mathPackage
end

function mathPackage.MapRange(input, output)
	local inputMin, inputMax = unpack(input)
	local outputMin, outputMax = unpack(output)
	return function(x) return((x - inputMin) * (outputMax - outputMin) / (inputMax - inputMin) + outputMin) end
end

function mathPackage.InRange(range, value)
	return value >= range.Min and value <= range.Max
end

return mathPackage