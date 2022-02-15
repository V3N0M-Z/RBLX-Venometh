--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local public = {
	Client = "_client";
	PlayerGui = "_playerGui";
}

local client = {}
client.__index = function(self, index)
	return client[index] or (public[index] and client[public[index]])
end

--Store Player Instance and PlayerGui at initalization
function client.__initialize__(ven, include)
	
	client._ven = ven;
	client._client = ven.Players.LocalPlayer;
	client._playerGui = ven.Players.LocalPlayer:WaitForChild("PlayerGui");
	client._tween = ven:Include("Tween");
	
	if not include then
		ven:IncludeError("Client")
	end
	
	return setmetatable({}, client)
end

--Get character method
function client.GetCharacter(yield)
	if client._client.Character and client._client.Character.Parent ~= nil then
		return client._client.Character, client._client.Character.Humanoid, client._client.Character.HumanoidRootPart
	end
	if not yield then return nil end
	return client._client.CharacterAdded:Wait(), client._client.Character:WaitForChild("Humanoid"), client._client.Character:WaitForChild("HumanoidRootPart")
end


--Load method
function client.Load(ui, loadingBar, callback)

	if client._playerGui:FindFirstChild("ActiveLoader") then return end
	ui.Name = "ActiveLoader"
	if loadingBar then
		loadingBar.Size = UDim2.new(0, loadingBar.Size.X.Offset, loadingBar.Size.Y.Scale, loadingBar.Size.Y.Offset)
	end
	ui.Parent = client._playerGui

	client._ven.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	client._ven.ReplicatedFirst:RemoveDefaultLoadingScreen()

	--Load content
	local content, loaded = game:GetDescendants(), 0
	client._ven.ContentProvider:PreloadAsync(content, function()
		loaded += 1
		client._tween.new(loadingBar, 1, {
			Size = UDim2.new(loaded / #content, loadingBar.Size.X.Offset, loadingBar.Size.Y.Scale, loadingBar.Size.Y.Offset);
		}):Play()
	end)

	client._tween.new(loadingBar, 1, {
		Size = UDim2.new(1, loadingBar.Size.X.Offset, loadingBar.Size.Y.Scale, loadingBar.Size.Y.Offset);
	}):Play():Wait()

	--After loading
	local overlay = client._ven.new(Instance.new("Frame"))
	.Size(UDim2.new(1, 0, 1, 0))
	.ZIndex(100)
	.BackgroundColor3(Color3.fromHSV(0, 0, 0))
	.BackgroundTransparency(1)
	.Parent(ui).get

	client._tween.new(overlay, 3, {
		BackgroundTransparency = 0
	}):Play():Wait()

	for _, component in ipairs(ui:GetDescendants()) do
		if component == overlay then continue end
		component:Destroy()
	end
	
	if callback then
		callback()
	end

	client._tween.new(overlay, 3, {
		BackgroundTransparency = 1
	}):Play():Wait()

	ui:Destroy()

end

return client