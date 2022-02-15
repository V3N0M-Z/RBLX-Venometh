# Initializer

Server:
```lua linenums="1"
local ven = require(game:GetService("ReplicatedStorage"):WaitForChild("Venometh"))

ven:AddContainers {
	Asset = {
		Shared = ven.ReplicatedStorage:WaitForChild("Assets");
	}
}

ven:AddPackages(ven.ReplicatedStorage:WaitForChild("Ven-Packages"))

ven:Activate()
```

Local:
```lua linenums="1"
local ven = require(game:GetService("ReplicatedStorage"):WaitForChild("Venometh"))
ven:Activate()
```