local interface = {}

function interface.__initialize__(ven)
	interface._ven = ven
	interface._sound = ven.Packages.Sound
	return interface
end

function interface.TypeWrite(component, text, timestep)
	
	if component:GetAttribute("TypeWriteActive") then
		component:SetAttribute("TypeWriteActive", nil)
	end
	component:SetAttribute("TypeWriteActive", true)
	
	component.MaxVisibleGraphemes = 0
	component.Text = text
	
	local connection
	connection = component.AttributeChanged:Connect(function()
		if not component:GetAttribute("TypeWriteActive") then
			connection:Disconnect()
			component = nil
		end
	end)
	
	local complete
	task.defer(function()
		for i = 1, string.len(text) do
			if not component then
				complete = true
				return
			end
			component.MaxVisibleGraphemes = i			
			task.wait(timestep or 0.01)
		end
		if component then
			component.MaxVisibleGraphemes = -1
			component:SetAttribute("TypeWriteActive", nil)
			complete = true
		end
	end)
	
	return {
		Wait = function()
			repeat task.wait() until complete
		end;
	}
	
end

return interface