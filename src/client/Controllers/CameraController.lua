--[[
    CameraController.
    HawDevelopment
    01/17/2022
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)

local CameraController = Knit.CreateController({
    Name = "CameraController",
})

CameraController.Enabled = true
workspace:SetAttribute("CameraEnabled", true)

local function MountCamera()
    local camera = workspace.CurrentCamera
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local mouse = player:GetMouse()
    
    RunService:BindToRenderStep("Camera", Enum.RenderPriority.First.Value, function(dt)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = 45
        
        if character and character:FindFirstChild("HumanoidRootPart") and CameraController.Enabled and workspace:GetAttribute("CameraEnabled") == true then
            local lookAt = character.HumanoidRootPart.Position
            local position = lookAt + Vector3.new(0, 3, 70)
            local cframe = CFrame.new(position, lookAt)
            
            -- Transform the position using mouse position
            local direction = mouse.UnitRay.Direction
            cframe = cframe:Lerp(CFrame.lookAt(position, position + direction), 0.1)
            
            -- Move the camera
            camera.CFrame = cframe
        end
    end)
end

function CameraController:KnitStart()
    MountCamera()
end

return CameraController