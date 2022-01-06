local ven = require(game:GetService("ReplicatedStorage"):WaitForChild("Venometh"))

ven:AddContainers {
	Asset = {
		Shared = ven.ReplicatedStorage:WaitForChild("Assets");
	};
}

ven:AddPackages()

ven:Include("Network", true)
ven:Include("Sound", true)

ven.Packages.Network:AddCommunicators {
	DefaultCommunicator = {
		Events = {
			"PlaySound";
		};
		BindEvents = {
			PlaySound = function(client)
				ven.Packages.Sound:QuickPlay(ven:GetAsset("assault-unit"):Clone())
				print("Requested to play sound by "..client.Name.."!")
			end
		}
	}
}

ven:Activate()