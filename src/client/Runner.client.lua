--[[
    Runner.
    HawDevelopment
    01/14/2022
--]]

local Players = game:GetService("Players")
local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Fission = require(Packages.Fission)
local Generator = require(script.Parent:WaitForChild("Generator"))

local GeneratorController = Knit.CreateController({
    Name = "GeneratorController",
})

local lastMap = nil

local function MountUI()
    
    return Fission.New("ScreenGui")({
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        
        [Fission.Children] = Fission.New("TextButton")({
            Size = UDim2.new(0, 100, 0, 50),
            Position = UDim2.new(0.5, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 1),
            TextSize = 24,
            Text = "Generate",
            
            
            [Fission.OnEvent("MouseButton1Click")] = function()
                if lastMap then
                    lastMap:Destroy()
                    task.wait(1) -- Give some breathing time
                end
                
                lastMap = Generator.new()
            end,
        })
    })
end

function GeneratorController:KnitStart()
    local player = Players.LocalPlayer
    
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    MountUI()
    player.CharacterAdded:Connect(MountUI)
end

Knit.Start():catch(function()
    print("Knit failed to start")
end)