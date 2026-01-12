--!strict

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer :: Player

local queueOnTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local currentAnimals = Workspace:WaitForChild("CurrentAnimals")

local queue: { Instance } = {}
local processing = false
local serverHopping = false
local timeJoinedServer = os.clock()

local MAX_TIME_ALLOWED_PER_SERVER = 5 * 60 -- 5 minutes
local USER_IDS_RUNNING_SCRIPT = { 10329188918 }
local index = table.find(USER_IDS_RUNNING_SCRIPT, localPlayer.UserId)
if index then
	table.remove(USER_IDS_RUNNING_SCRIPT, index)
end

local function serverHop()
	local servers = {}
	local response = (game :: any):HttpGet(
		`https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Desc&limit=10&excludeFullGames=true`
	)
	local body = HttpService:JSONDecode(response)
	if not (body and body.data) then
		return
	end

	for _, server in body.data do
		if
			type(server) == "table"
			and tonumber(server.playing)
			and tonumber(server.maxPlayers)
			and server.playing < server.maxPlayers
			and server.id ~= game.JobId
		then
			table.insert(servers, 1, server.id)
		end
	end

	if #servers < 1 then
		return
	end
	TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], localPlayer)
end

local function getPlayerCount()
	local playerCount = 0

	local players = Players:GetPlayers()
	for _, player in players do
		if table.find(USER_IDS_RUNNING_SCRIPT, player.UserId) then
			return 0 -- we should not be in a server with other users running the script
		end
		if player.UserId == localPlayer.UserId then
			continue
		end
		playerCount += 1
	end
	return playerCount
end

local function checkIfServerEmpty()
	if getPlayerCount() > 0 then
		return
	end
	if serverHopping then
		return
	end
	serverHopping = true
	task.delay(10, function()
		serverHopping = false
	end)
	pcall(serverHop)
end

local function checkIfServerTimeExceeded()
	if os.clock() - timeJoinedServer < MAX_TIME_ALLOWED_PER_SERVER then
		return
	end
	if serverHopping then
		return
	end
	serverHopping = true
	task.delay(10, function()
		serverHopping = false
	end)
	pcall(serverHop)
end

local function onTeleport()
	if not queueOnTeleport then
		return
	end
	queueOnTeleport(
		"loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/roblox-scripts/refs/heads/main/catch-a-zoo.luau'))()"
	)
end

local function createBodyPosition(humanoidRootPart: BasePart)
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyPosition.Position = Vector3.new(100000, 100000, 100000)
	bodyPosition.Parent = humanoidRootPart
end

local function processQueue()
	if processing then
		return
	end
	processing = true

	while #queue > 0 do
		local animal = table.remove(queue, 1)

		if not (animal and animal.Parent) then
			continue
		end
		local character = localPlayer.Character
		if not character then
			localPlayer.CharacterAdded:Wait()
			character = localPlayer.Character
		end
		if not character then
			continue
		end

		local humanoidRootPart = animal:WaitForChild("HumanoidRootPart", 5)
		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			continue
		end
		character:PivotTo(humanoidRootPart.CFrame)
		task.wait(1)
		createBodyPosition(humanoidRootPart)
		checkIfServerEmpty()
		checkIfServerTimeExceeded()
	end

	processing = false
end

local function enqueueAnimal(animal: Instance)
	table.insert(queue, animal)
	processQueue()
end

local function initialize()
	for _, animal in currentAnimals:GetChildren() do
		enqueueAnimal(animal)
	end
	currentAnimals.ChildAdded:Connect(enqueueAnimal)

	localPlayer.OnTeleport:Connect(onTeleport)
end

initialize()
