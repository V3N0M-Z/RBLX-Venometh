--CREATED BY @V3N0M_Z
--PART OF THE VENOMETH FRAMEWORK: https://github.com/V3N0M-Z/RBLX-Venometh

local network = {}
network.__index = network

function network.__initialize__(ven, included)
	local self = setmetatable({
		_ven = ven;
		_storage = ven.new("Folder", ven.ReplicatedStorage).Name("Communicators").get;
		_communicators = {};
	}, network)
	if not included then
		ven:IncludeError(script.Name)
	end
	return self
end

function network.__call(tab, ...)
	return network.Get(tab, ...)
end

local runService = game:GetService("RunService")
local RBXScriptSignals = {
	"OnClientEvent";
	"OnServerEvent";
}
local function getEvent(tab, index)
	if not tab._events[index] then return end
	if runService:IsServer() then
		return {
			OnServerEvent = tab._events[index].OnServerEvent;
			FireClient = function(_, client, ...) tab._events[index]:FireClient(client, ...) end;
			FireAllClients = function(_, ...) tab._events[index]:FireAllClients(...) end;
		}
	else
		return {
			OnClientEvent = tab._events[index].OnClientEvent;
			FireServer = function(_, ...) tab._events[index]:FireServer(...) end;
		}
	end
end
local function getFunction(tab, index, func)
	if not tab._functions[index] then return end
	if runService:IsServer() then
		return setmetatable({
			InvokeClient = function(_, client, ...) return tab._functions[index]:InvokeClient(client, ...) end;
		}, {
			__newindex = function(_, _, func)
				tab._functions[index].OnServerInvoke = func
			end;
		})
	else
		return setmetatable({
			InvokeServer = function(_, ...) return tab._functions[index]:InvokeServer(...) end;
		}, {
			__newindex = function(_, _, func)
				tab._functions[index].OnClientInvoke = func
			end;
		})
	end
end

local communicator = {}
communicator.__index = function(tab, index)
	return getEvent(tab, index) or getFunction(tab, index) or communicator[index]
end

--[[OLDER METHOD]]
--function network:Get(com)
--	return (self._ven._isServer and setmetatable({
--		_events = self._communicators[com]._events;
--		_functions = self._communicators[com]._functions;
--	}, communicator)) or setmetatable(self._ven._remoteF:InvokeServer("GetCommunicator", com), communicator)
--end

function network:Get(...)
	
	local communicator, remote = table.unpack(...)
	
	if not runService:IsServer() then
		local remote = self._ven._remoteF:InvokeServer("GetRemote", communicator, remote)
		
		if remote:IsA("RemoteFunction") then
			return setmetatable({
				InvokeServer = function(_, ...)
					return remote:InvokeServer(...)
				end;
			}, {
				__newindex = function(_, index, callback)
					remote[index] = callback;
				end;
			})
		end
		
		return {
			FireServer = remote.FireServer;
			OnClientEvent = remote.OnClientEvent;
		}
	end

	return self._communicators[communicator]._events[remote] or self._communicators[communicator]._functions[remote]
	
end

function network:Add(communicators)
	for communicator, data in pairs(communicators) do
		data = setmetatable(data, {__index = function() return {} end})
		
		local communicatorFolder = self._ven.new("Folder", self._storage).Name(communicator).get
		self._communicators[communicator] = {_events = {}, _functions = {}}
		
		for _, remoteType in ipairs({ "Events", "Functions" }) do
			for _, remote in ipairs(data[remoteType]) do
				local _instance = remoteType == "Events" and Instance.new("RemoteEvent") or Instance.new("RemoteFunction")
				self._communicators[communicator]["_"..string.lower(remoteType)][remote] = self._ven.new(_instance, communicatorFolder).Name("").get
			end
		end
		
		for event, func in pairs(data.BindEvents) do
			self._communicators[communicator]._events[event].OnServerEvent:Connect(func)
		end
		for bFunc, func in pairs(data.BindFunctions) do
			self._communicators[communicator]._functions[bFunc].OnServerInvoke = func
		end
	end
end

return network