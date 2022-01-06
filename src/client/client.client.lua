local ven = require(game:GetService("ReplicatedStorage"):WaitForChild("Venometh")):Load()

-- local Sound = ven.Packages.Sound
-- Sound:QuickPlay(ven:GetAsset("assault-unit"):Clone())

local Network = ven.Packages.Network
local defaultCommunicator = Network:GetCommunicator("DefaultCommunicator")
defaultCommunicator.PlaySound:FireServer()