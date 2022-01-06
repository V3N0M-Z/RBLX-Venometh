
--List of services
local services = {
	"ABTestService";
	"AdService";
	"AnalyticsService";
	"AppStorageService";
	"AppUpdateService";
	"AssetService";
	"AvatarEditorService";
	"BadgeService";
	"BrowserService";
	"CacheableContentProvider";
	"ChangeHistoryService";
	"Chat";
	"ClusterPacketCache";
	"CollectionService";
	"ContentProvider";
	"ContextActionService";
	"ControllerService";
	"CookiesService";
	"CoreGui";
	"CorePackages";
	"CoreScriptSyncService";
	"CSGDictionaryService";
	"DataStoreService";
	"Debris";
	"DebuggerManager";
	"EventIngestService";
	"FlagStandService";
	"FlyweightService";
	"FriendService";
	"GamepadService";
	"GamePassService";
	"Geometry";
	"GoogleAnalyticsConfiguration";
	"GroupService";
	"GuidRegistryService";
	"GuiService";
	"HapticService";
	"HeightmapImporterService";
	"Hopper";
	"HttpRbxApiService";
	"HttpService";
	"ILegacyStudioBridge";
	"InsertService";
	"InternalContainer";
	"InternalSyncService";
	"JointsService";
	"KeyboardService";
	"KeyframeSequenceProvider";
	"Lighting";
	"LocalizationService";
	"LocalStorageService";
	"LoginService";
	"LogService";
	"LuaWebService";
	"MarketplaceService";
	"MemStorageService";
	"MeshContentProvider";
	"MessagingService";
	"MouseService";
	"NetworkSettings";
	"NonReplicatedCSGDictionaryService";
	"NotificationService";
	"PackageService";
	"PathfindingService";
	"PermissionsService";
	"PhysicsService";
	"PlayerEmulatorService";
	"Players";
	"PluginDebugService";
	"PluginGuiService";
	"PointsService";
	"PolicyService";
	"ProximityPromptService";
	"RbxAnalyticsService";
	"ReplicatedFirst";
	"ReplicatedScriptService";
	"ReplicatedStorage";
	"RobloxPluginGuiService";
	"RobloxReplicatedStorage";
	"RunService";
	"RuntimeScriptService";
	"ScriptContext";
	"ScriptService";
	"Selection";
	"ServerScriptService";
	"ServerStorage";
	"SessionService";
	"SocialService";
	"SolidModelContentProvider";
	"SoundService";
	"SpawnerService";
	"StarterGui";
	"StarterPack";
	"StarterPlayer";
	"Stats";
	"StudioData";
	"TaskScheduler";
	"Teams";
	"TeleportService";
	"TestService";
	"TextService";
	"ThirdPartyUserService";
	"TimerService";
	"TouchInputService";
	"TweenService";
	"UGCValidationService";
	"UnvalidatedAssetService";
	"UserInputService";
	"UserService";
	"UserStorageService";
	"VersionControlService";
	"VirtualUser";
	"Visit";
	"VRService";		
}

--Used to get objects from stored Containers
local function getObject(tab, index)
	local source = string.sub(index, 4)
	
	--Return if no valid Container is found
	if not tab._containers[source] then return end
	
	--Server handler for Container
	if tab._isServer then
		local protected, shared = tab._containers[source].Protected, tab._containers[source].Shared
		local singleDir = if not (protected and shared) then protected or shared else nil
		if singleDir then
			return function(ven, instance, limit) return singleDir:WaitForChild(instance, limit or 7) end
		else
			return function(ven, instance, limit)
				local retrieved
				local elapsed = os.clock()
				task.spawn(function(instance, limit) retrieved = tab._containers[source].Protected:WaitForChild(instance, limit or 7) end)
				task.spawn(function(instance, limit) retrieved = tab._containers[source].Shared:WaitForChild(instance, limit or 7) end)
				repeat task.wait() until retrieved or os.clock() - elapsed >= (limit or 7)
				return retrieved
			end
		end
		
	--Client handler for Container
	else
		return function(ven, instance, limit) return tab._containers[source].Shared:WaitForChild(instance, limit or 7) end
	end
end

--Framework metamethod/List of services
local Venometh = {_services = (
	function()
		local t = {}
		for _, service in ipairs(services) do
			t[service] = game:GetService(service)
		end
		return t
	end
)()}
Venometh.__index = function(tab, index)
	return (string.sub(index, 1, 3) == "Get" and getObject(tab, index)) or Venometh._services[index] or Venometh[index]
end

--Framework instantiator
function Venometh.__initialize__()
	
	--Initialize variables
	local self = setmetatable({
		_packages = {};
		_packageDump = {};
		_containers = {};
		_loaded = false;
	}, Venometh)
	self._isServer = self.RunService:IsServer()
	
	--Reference to Venometh.Packages
	self.Packages = setmetatable({}, {
		__index  = function(tab, index)
			if type(self._packages[index]) == "function" then
				self:Declare(error, "Package Error: Cannot load package '"..index.."' this way. Package was not included internally.")
			end
			return self._packages[index]
		end;
	})
		
	--Setup communication between the client/server Venometh Framework
	if self._isServer then
		self._remoteE = self.new("RemoteEvent", self.ReplicatedStorage).Name("__event__").get
		self._remoteF = self.new("RemoteFunction", self.ReplicatedStorage).Name("__function__").get
		self._remoteF.OnServerInvoke = function(client, action, ...)
			repeat task.wait() until self._loaded
			if action == "GetContainers" then
					return self._containers
			elseif action == "GetPackages" then
				return self._packageDump
			elseif action == "GetCommunicator" then
				return {
					_events = self._packages["Network"]._communicators[...]._events;
					_functions = self._packages["Network"]._communicators[...]._functions;
				}
			end
		end
		
	--Get as required from to server to the client Venometh Framework
	else
		self._remoteF = self.ReplicatedStorage:WaitForChild("__function__")
		self._remoteE = self.ReplicatedStorage:WaitForChild("__event__")
		self._containers = self._remoteF:InvokeServer("GetContainers")
		self:AddPackages(self._remoteF:InvokeServer("GetPackages"))
		self._remoteE.OnClientEvent:Connect(function(action, ...)
			if action == "AddPackages" then
				self:AddPackages(...)
			end
		end)
	end
	
	return self
end

--Use this function (in a configuration script) to start using Venometh in other scripts including local scripts
function Venometh:Activate()
	self._loaded = true
end

--Use this function whenever Venometh is required in a script
function Venometh:Load()
	repeat task.wait() until self._loaded
	return self
end

--Implementation of a custom object instantiator that supports method chaining
function Venometh.new(instance, parent)
	
	local msg = "\n\n"..string.rep(" ", 2).."[Venometh] "
	if not instance or not (type(instance)  == "string" or typeof(instance) == "Instance") then
		error(msg.."Instantiation Error: Argument 1 must be a valid string or Instance.\n")
	elseif not parent or typeof(parent) ~= "Instance" then
		error(msg.."Instantiation Error: Argument 2 must be a valid Instance.\n")
	end
	
	local tab = setmetatable({
		_instance = (type(instance) == "string" and Instance.new(instance)) or instance
	}, {
		__index = function(tab, index)
			if string.lower(index) == "get" then
				return tab._instance
			else
				if not pcall(function() return tab._instance[index] end) then
					error(msg.."Instantiation Error: \".."..index.."\" is not a valid member of "..tab._instance.Name..".\n")
				end
				return function(value) tab._instance[index] = value return tab end
			end
		end
	})
	tab._instance.Parent = parent
	return tab 
end

--Used to display information or errors to the output
function Venometh:Declare(func, msg)
	
	if not func or type(func) ~= "function" then
		self:Declare(error, "Output Error: Argument 1 must be a valid function.")
	elseif not msg or type(msg) ~= "string" then
		self:Declare(error, "Output Error: Argument 2 must be a valid string.")	
	end
	
	msg = "\n\n"..string.rep(" ", 2).."[Venometh] "..msg.."\n"
	func = if func == debug.traceback then (function()
		warn(msg)
		print(debug.traceback())
	end) else func
	func(msg)
end

--Stores a function that can later be executed when a package is required in a script
function Venometh:AddPackages(packages)
	if packages and #packages == 0 and self._isServer then
		self:Declare(error, "Package Error: Cannot add Packages. Argument 1 must be a valid table of ModuleScript Instances.")
	elseif packages and #packages == 0 and not self._isServer then
		self:Declare(debug.traceback, "Package Warning: Cannot add certain Packages. Packages are not available on the client.")
	end
	
	if not packages then
		packages = game:FindFirstChild("Ven-Packages", true)
		packages = packages and packages:GetChildren()
		if not packages then
			self:Declare(error, "Package Error: Cannot get Packages automatically. Cannot find \"Ven-Packages\".")
			return
		end
	end
	
	for _, module in ipairs(packages) do
		
		if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
			self:Declare(error, "Package Error: Cannot add Packages. Argument 1 must be a valid table of ModuleScript Instances.")
		end
		
		if self._isServer then table.insert(self._packageDump, module) end
		self._packages[module.Name] = function(ven, included)
			local p = require(module)
			if p["__initialize__"] then
				return p["__initialize__"](ven, included)
			else
				return p
			end
		end
	end
	if self._isServer then self._remoteE:FireAllClients("AddPackages", packages) end
end

 --Require the package and store the table internally in the Venometh Framework
function Venometh:Include(package, include)
	
	if not package or type(package) ~= "string" then
		self:Declare("Package Error: Cannot load Package. Argument 1 must be a valid string.")
	elseif include and type(include) ~= "boolean" then
		self:Declare("Package Error: Cannot load Package. Argument 2 must be a valid boolean.")
	elseif not self._packages[package] then
		self:Declare("Package Error: Cannot load Package. Package \""..package.."\" does not exist.")
	end
	
	if type(self._packages[package]) == "table" then
		return self._packages[package]
	elseif include then
		self._packages[package] = self._packages[package](self, include)
		return self._packages[package]
	end
	return self._packages[package](self, include)
end
	
--Returns a table of packages that are internally stored in the Venometh Framework
function Venometh:GetIncluded()
	local includedPackages = {}
	for package, value in pairs(self._packages) do
		if type(value) == "table" then
			table.insert(includedPackages, package)
		end
	end
	return includedPackages
end
	
--Verify if a package is included internally in the Venometh Framework
function Venometh:IsIncluded(package)
	
	if not package or type(package) ~= "string" then
		self:Declare("Package Error: Argument 1 must be a valid string.")
	end
	
	return type(self._packages[package]) == "table"
end
	
--Adds reference to provided Containers
function Venometh:AddContainers(containers)
	
	if not containers then
		self:Declare(error, "Container Error: Cannot add Containers. Argument 1 must be a valid dictionary.")
	end
	
	for container, data in pairs(containers) do
		if type(data) ~= "table" then
			self:Declare(error, "Container Error: Cannot add Containers. The container directories for \""..container.."\" must be a valid dictionary.")
		end
		for key, value in pairs(data) do
			if typeof(value) ~= "Instance" then
				self:Declare(error, "Container Error: Invalid "..key.." directory for Container \""..container.."\".")
			end
		end
	end
	self._containers = containers
end
	
return Venometh.__initialize__()