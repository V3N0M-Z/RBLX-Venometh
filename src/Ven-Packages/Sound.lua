--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local sound = {}
sound.__index = sound

function sound.__initialize__(ven)
	return setmetatable({_ven = ven}, sound)
end

-- Quickly play sounds located directly in assets folder
function sound:QuickPlay(sound, parent)
	task.defer(function()
		local audio = sound:Clone()
		audio.Parent = parent or self._ven.SoundService
		if not audio.IsLoaded then
			audio.Loaded:Wait()
		end
		audio:Play()
		audio.Ended:Wait()
		audio:Destroy()
	end)
end

return sound