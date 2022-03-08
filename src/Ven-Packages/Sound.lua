--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local sound = {}
sound.__index = sound

function sound.__initialize__(ven)
	sound._ven = ven
	return sound
end

function sound.new(instance)
	return setmetatable({
		_audio = instance:Clone();
	}, sound)
end

function sound:Play(parent)
	task.defer(function()
		self._audio.Parent = parent or self._ven.SoundService
		self:Load()
		self._audio:Play()
	end)
	return self
end

function sound:QuickPlay(parent)
	task.defer(function(parent)
		self:Play(parent):Wait():Destroy()
	end)
end

function sound:Load()
	if not self._audio.IsLoaded then
		self._audio.Loaded:Wait()
	end
end

function sound:Wait()
	self._audio.Ended:Wait()
	return self
end

function sound:Destroy()
	self._audio:Destroy()
	setmetatable(self, nil)
end

return sound