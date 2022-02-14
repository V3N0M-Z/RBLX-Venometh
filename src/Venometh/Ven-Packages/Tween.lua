--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local tweenService = game:GetService("TweenService")
local tween = {}
tween.__index = tween

function tween.new(object, tweenData, tweenValues)
	tweenData = (typeof(tweenData) == "number" and TweenInfo.new(tweenData)) or tweenData
	return setmetatable({
		_tween = tweenService:Create(object, tweenData, tweenValues)
	}, tween)
end

function tween:Wait(arnewThread, callback, ...)
	local args = {...}
	local function func()
		self._tween.Completed:Wait()
		if callback then callback(unpack(args)) end
	end
	if newThread then
		task.spawn(func)
	else
		func()
	end
	return self
end

function tween:Play(newThread)
	self._tween:Play()
	return self
end

function tween:Destroy()
	self._tween = nil
end

return tween