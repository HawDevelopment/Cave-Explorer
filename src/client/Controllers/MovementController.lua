--[[
    MovementController.
    HawDevelopment
    01/20/2022
--]]

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Fusion = require(Packages.Fusion)

local MovementController = Knit.CreateController({
    Name = "MovementController",
})

local previousConnection
local function MountMovement()
    if previousConnection then
        previousConnection:Disconnect()
    end
    
    local character = Players.LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Keep the player in the map
    Fusion.New("BodyPosition")({
        D = 1,
        P = 1000,
        Position = Vector3.new(0, 0, -1),
        MaxForce = Vector3.new(0, 0, math.huge),
        Parent = hrp,
    })
    
    -- Movement
    local left, right = 0, 0
    ContextActionService:BindAction("Move-Left", function(_, state)
        if state == Enum.UserInputState.Begin then
            left = 1
        elseif state == Enum.UserInputState.End then
            left = 0
        end
    end, false, Enum.KeyCode.A, Enum.KeyCode.Left)
    ContextActionService:BindAction("Move-Right", function(_, state)
        if state == Enum.UserInputState.Begin then
            right = 1
        elseif state == Enum.UserInputState.End then
            right = 0
        end
    end, false, Enum.KeyCode.D, Enum.KeyCode.Right)
    
    previousConnection = RunService.Heartbeat:Connect(function()
        humanoid:Move(Vector3.new(right - left, 0, 0))
    end)
end

function MovementController:KnitStart()
    local player = Players.LocalPlayer
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    MountMovement()
    player.CharacterAdded:Connect(MountMovement)
end

return MovementController