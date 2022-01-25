--[[
    JetpackController.
    HawDevelopment
    17/01/2022
--]]

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

local Jetpack = ReplicatedStorage:WaitForChild("Jetpack") or error("Jetpack not found, use the build!")

local JetpackController = Knit.CreateController({
    Name = "JetpackController",
})

local lastConnection = false

local function MountJetpack()
    local character = Players.LocalPlayer.Character :: any
    if lastConnection then
        lastConnection:Disconnect()
    end
    
    local jetpack = Jetpack:Clone() :: any
    jetpack.Handle.CFrame = character:WaitForChild("UpperTorso").CFrame + Vector3.new(0, 0, 0.5)
    jetpack.Parent = character
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = character.UpperTorso
    weld.Part1 = jetpack.Handle
    weld.Parent = character.UpperTorso
    
    local force = Instance.new("BodyForce")
    force.force = Vector3.new(0, 0, 0)
    force.Parent = character:WaitForChild("HumanoidRootPart")
    
    local totalMass = 0
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            totalMass = totalMass + (part :: Part):GetMass()
        end
    end
    
    local sound: Sound = SoundService:WaitForChild("Rumble"):Clone()
    sound.Parent = character.HumanoidRootPart
    sound.Looped = true
    sound.Volume = 0.6
    sound.PlaybackSpeed = 1.5
    sound.RollOffMode = Enum.RollOffMode.LinearSquare
    
    local enabled = false
    ContextActionService:BindAction("Jetpack", function(_, state)
        if state == Enum.UserInputState.Begin then
            enabled = true
            
            -- For some reason, roblox likes to stick humanoids onto the ground.
            -- This should get them off the ground.
            if character.Humanoid.FloorMaterial then
                character.Humanoid.Jump = true
            else
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            end
            
            force.force = Vector3.new(0, (totalMass * workspace.Gravity + 2000), 0)
            task.delay(0.15,  function()
                if enabled then
                    character.Humanoid.PlatformStand = false
                    force.force = Vector3.new(0, (totalMass * workspace.Gravity + 500), 0)
                end
            end)
            
            -- Enable paticles
            jetpack.Particle1.ParticleEmitter.Enabled = true
            jetpack.Particle2.ParticleEmitter.Enabled = true
            
            sound:Resume()
            
        elseif state == Enum.UserInputState.End then
            enabled = false
            force.force = Vector3.new(0, 0, 0)
            
            -- Disable particles
            jetpack.Particle1.ParticleEmitter.Enabled = false
            jetpack.Particle2.ParticleEmitter.Enabled = false
            
            sound:Pause()
        end
    end, false, Enum.KeyCode.Space)
    
    lastConnection = RunService.RenderStepped:Connect(function(dt)
        if enabled and character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end)
end

function JetpackController:KnitStart()
    local player = Players.LocalPlayer
    
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    MountJetpack()
    player.CharacterAdded:Connect(MountJetpack)
end

return JetpackController