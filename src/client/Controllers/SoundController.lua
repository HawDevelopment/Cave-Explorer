--[[
    SoundController.
    HawDevelopment
    01/23/2022
--]]

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)

local SoundController = Knit.CreateController({
    Name = "SoundController",
})

local function MountSound()
    local character = Players.LocalPlayer.Character
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    for _, v: Sound in pairs(hrp:GetChildren()) do
        if v:IsA("Sound") then
            v.RollOffMode = Enum.RollOffMode.LinearSquare
            v.Volume = 0.5
        end
    end
    
    SoundService.AmbientReverb = Enum.ReverbType.Hangar
    SoundService.RolloffScale = 0.3
end

function SoundController:KnitStart()
    local player = Players.LocalPlayer
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    MountSound()
    player.CharacterAdded:Connect(MountSound)
end

return SoundController