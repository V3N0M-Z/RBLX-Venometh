--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local accessibles = {
	Client = "_client";
	PlayerGui = "_playerGui";
}
local client = {}
client.__index = function(tab, index)
	return client[index] or (accessibles[index] and tab[accessibles[index]])
end

-- Store Player Instance and PlayerGui at initalization
function client.__initialize__(ven)
	return setmetatable({
		_ven = ven;
		_client = ven.Players.LocalPlayer;
		_playerGui = ven.Players.LocalPlayer:WaitForChild("PlayerGui");
	}, client)
end

-- Get character method
function client:GetCharacter(yield)
	if self._client.Character and self._client.Character.Parent ~= nil then
		return self._client.Character, self._client.Character.Humanoid, self._client.Character.HumanoidRootPart
	end
	if not yield then return nil end
	return self._client.CharacterAdded:Wait(), self._client.Character:WaitForChild("Humanoid"), self._client.Character:WaitForChild("HumanoidRootPart")
end
return client