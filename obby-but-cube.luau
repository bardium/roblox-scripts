--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local firetouchinterest = firetouchinterest
local queue_on_teleport = if type(queue_on_teleport) == "function"
	then queue_on_teleport
	else if type(syn) == "table" and type(syn.queue_on_teleport) == "function"
		then syn.queue_on_teleport
		else if type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function"
			then fluxus.queue_on_teleport
			else nil

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local portalsRemoteFunction = remotes:WaitForChild("Portals") :: RemoteFunction

local localPlayer = Players.LocalPlayer :: Player
local leaderstats = localPlayer:WaitForChild("leaderstats")
local difficultyStringValue = leaderstats:WaitForChild("Difficulty") :: StringValue
local stageNumberValue = leaderstats:WaitForChild("Stage") :: NumberValue

local cachedObbies = {} :: { [string]: Model }
local isAlreadyQueuedOnTeleport = false

local function getObbyFromDifficulty(): Model?
	local obbies = Workspace:FindFirstChild("Obbies")
	local difficulty = difficultyStringValue.Value
	if not (obbies and type(difficulty) == "string" and difficulty ~= "Lobby") then
		return nil
	end

	local cachedObby = cachedObbies[difficulty]
	if cachedObby and cachedObby.Parent == obbies then
		return cachedObby
	end

	for _, child in obbies:GetChildren() do
		local childDifficulty = child:GetAttribute("Difficulty")
		childDifficulty = if childDifficulty then tostring(childDifficulty) else nil
		if not (child:IsA("Model") and childDifficulty == difficulty) then
			continue
		end
		cachedObbies[difficulty] = child
		return child
	end

	return nil
end

local function handleLobby()
	local cubeIsland = Workspace:FindFirstChild("CubeIsland")
	local portals = if cubeIsland then cubeIsland:FindFirstChild("Portals") else nil
	local nullifyingPortal = if portals then portals:FindFirstChild("NULLIFYING") else nil
	local character = localPlayer.Character
	local humanoidRootPart = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if
		not (
			nullifyingPortal
			and nullifyingPortal:IsA("Model")
			and character
			and humanoidRootPart
			and humanoidRootPart:IsA("BasePart")
		)
	then
		return
	end
	character:PivotTo(nullifyingPortal:GetPivot())
	portalsRemoteFunction:InvokeServer(nullifyingPortal)

	for _, child in nullifyingPortal:GetChildren() do
		if
			not (
				type(firetouchinterest) == "function"
				and child:FindFirstChildOfClass("TouchTransmitter")
				and child:IsA("BasePart")
			)
		then
			continue
		end

		character:PivotTo(child:GetPivot())

		task.defer(function()
			if
				humanoidRootPart
				and humanoidRootPart:IsDescendantOf(Workspace)
				and child
				and child:IsDescendantOf(Workspace)
			then
				firetouchinterest(humanoidRootPart, child, 0)
			end
		end)
	end
end

local function onHeartbeat()
	local cache = Workspace:FindFirstChild("Cache")
	local character = localPlayer.Character
	local humanoidRootPart = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local difficulty = difficultyStringValue.Value
	if difficulty == "Lobby" then
		handleLobby()
		return
	end
	if not (cache and character and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end
	local currentStage = math.floor(stageNumberValue.Value)
	local nextStage = currentStage + 1

	local isChildFound = false
	for _, child in cache:GetChildren() do
		local childStage = child:GetAttribute("Stage")
		childStage = if childStage then tonumber(childStage) else nil
		if not (child:IsA("BasePart") and child.Name == "TouchPad" and childStage == nextStage) then
			continue
		end
		isChildFound = true

		if type(firetouchinterest) == "function" and child:FindFirstChildOfClass("TouchTransmitter") then
			firetouchinterest(humanoidRootPart, child, 0)
		end
	end
	if isChildFound then
		return
	end
	local obby = getObbyFromDifficulty()
	local lobbyPortal = if obby then obby:FindFirstChild("LobbyPortal") else nil
	if not (lobbyPortal and lobbyPortal:IsA("Model")) then
		return
	end
	for _, child in lobbyPortal:GetChildren() do
		if
			not (
				type(firetouchinterest) == "function"
				and child:FindFirstChildOfClass("TouchTransmitter")
				and child:IsA("BasePart")
			)
		then
			continue
		end
		character:PivotTo(child:GetPivot())
		task.defer(function()
			if
				humanoidRootPart
				and humanoidRootPart:IsDescendantOf(Workspace)
				and child
				and child:IsDescendantOf(Workspace)
			then
				firetouchinterest(humanoidRootPart, child, 0)
			end
		end)
	end
end

local function onTeleport()
	if not (type(queue_on_teleport) == "function" and not isAlreadyQueuedOnTeleport) then
		return
	end
	isAlreadyQueuedOnTeleport = true
	queue_on_teleport(
		"loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/roblox-scripts/refs/heads/main/obby-but-cube.luau'))()"
	)
end

local function initialize()
	localPlayer.OnTeleport:Connect(onTeleport)
	RunService.Heartbeat:Connect(onHeartbeat)
end

initialize()
