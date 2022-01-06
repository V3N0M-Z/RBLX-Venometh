local network = {}
network.__index = network

function network.__initialize__(ven, included)
	local self = setmetatable({
		_ven = ven;
		_com = ven.new("Folder", ven.ReplicatedStorage).Name("Communicators").get;
		_communicators = {};
	}, network)
	if not included then
		self._ven:Declare(error, "Package Error: Package \"Network\" must be included internally. Use Include(\"Network\", true) instead.")
	end
	return self
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

function network:GetCommunicator(com)
	return (self._ven._isServer and setmetatable({
		_events = self._communicators[com]._events;
		_functions = self._communicators[com]._functions;
	}, communicator)) or setmetatable(self._ven._remoteF:InvokeServer("GetCommunicator", com), communicator)
end

function network:AddCommunicators(communicators)
	for communicator, data in pairs(communicators) do
		local communicatorFolder = self._ven.new("Folder", self._com).Name(communicator).get
		self._communicators[communicator] = {_events = {}, _functions = {}}
		data = setmetatable(data, {__index = function() return {} end})
		for _, event in ipairs(data.Events) do
			self._communicators[communicator]._events[event] = self._ven.new("RemoteEvent", communicatorFolder).Name("").get
		end
		for event, func in pairs(data.BindEvents) do
			self._communicators[communicator]._events[event].OnServerEvent:Connect(func)
		end
		for _, bFunc in ipairs(data.Functions) do
			self._communicators[communicator]._functions[bFunc] = self._ven.new("RemoteFunction", communicatorFolder).Name("").get
		end
		for bFunc, func in pairs(data.BindFunctions) do
			self._communicators[communicator]._functions[bFunc].OnServerInvoke = func
		end
	end
end

return network