-- Game link: https://www.roblox.com/games/17601705136/CRAFTING-Tycoon-RNG
-- Discord username: bardium

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local COLLECTED_TAG = "___collected"

local function onChildAdded(child: Instance)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local originalPivot = character:GetPivot()
	if not child.Name:match("Cube") or child:HasTag(COLLECTED_TAG) then
		return
	end
	local pvInstance = child:FindFirstChildWhichIsA("PVInstance", true)
	if not pvInstance then
		return
	end
	child:AddTag(COLLECTED_TAG)
	character:PivotTo(pvInstance:GetPivot())
	task.delay(0.1, function()
		character:PivotTo(originalPivot)
	end)	
end

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local originalPivot = character:GetPivot()
for _, child in Workspace:GetChildren() do
	if not child.Name:match("Cube") or child:HasTag(COLLECTED_TAG) then
		continue
	end
	local pvInstance = child:FindFirstChildWhichIsA("PVInstance", true)
	if not pvInstance then
		continue
	end
	child:AddTag(COLLECTED_TAG)
	character:PivotTo(pvInstance:GetPivot())
end
task.delay(0.1, function()
	character:PivotTo(originalPivot)
end)

Workspace.ChildAdded:Connect(onChildAdded)
