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

--Store Player Instance and PlayerGui at initalization
function client.__initialize__(ven)
	return setmetatable({
		_ven = ven;
		_client = ven.Players.LocalPlayer;
		_playerGui = ven.Players.LocalPlayer:WaitForChild("PlayerGui");
		_tween = ven:Include("Tween");
	}, client)
end

--Get character method
function client:GetCharacter(yield)
	if self._client.Character and self._client.Character.Parent ~= nil then
		return self._client.Character, self._client.Character.Humanoid, self._client.Character.HumanoidRootPart
	end
	if not yield then return nil end
	return self._client.CharacterAdded:Wait(), self._client.Character:WaitForChild("Humanoid"), self._client.Character:WaitForChild("HumanoidRootPart")
end


--Load method
function client:Load(ui, loadingBar, callback)

	if self._playerGui:FindFirstChild("ActiveLoader") then return end
	ui.Name = "ActiveLoader"
	if loadingBar then
		loadingBar.Size = UDim2.new(0, loadingBar.Size.X.Offset, loadingBar.Size.Y.Scale, loadingBar.Size.Y.Offset)
	end
	ui.Parent = self._playerGui

	self._ven.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	self._ven.ReplicatedFirst:RemoveDefaultLoadingScreen()

	--Load content
	local content, loaded = game:GetDescendants(), 0
	self._ven.ContentProvider:PreloadAsync(content, function()
		loaded += 1
		self._tween.new(loadingBar, 1, {
			Size = UDim2.new(loaded / #content, loadingBar.Size.X.Offset, loadingBar.Size.Y.Scale, loadingBar.Size.Y.Offset);
		}):Play()
	end)

	self._tween.new(loadingBar, 1, {
		Size = UDim2.new(1, loadingBar.Size.X.Offset, loadingBar.Size.Y.Scale, loadingBar.Size.Y.Offset);
	}):Play():Wait()

	--After loading
	local overlay = self._ven.new(Instance.new("Frame"))
	.Size(UDim2.new(1, 0, 1, 0))
	.ZIndex(100)
	.BackgroundColor3(Color3.fromHSV(0, 0, 0))
	.BackgroundTransparency(1)
	.Parent(ui).get

	self._tween.new(overlay, 3, {
		BackgroundTransparency = 0
	}):Play():Wait()

	for _, component in ipairs(ui:GetDescendants()) do
		if component == overlay then continue end
		component:Destroy()
	end
	
	if callback then
		callback()
	end

	self._tween.new(overlay, 3, {
		BackgroundTransparency = 1
	}):Play():Wait()

	ui:Destroy()

end


return client