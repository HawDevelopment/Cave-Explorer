--[[
    GeneratorController.
    HawDevelopment
    01/17/2022
--]]

local Players = game:GetService("Players")
local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Fusion = require(Packages.Fusion)
local Generator = require(script.Parent.Parent:WaitForChild("Generator"))
local Cache = require(script.Parent.Parent.Generator:WaitForChild("Cache"))

local GeneratorController = Knit.CreateController({
    Name = "GeneratorController",
})

local function DestroyMap(map)
    for _, v in pairs(map:GetChildren()) do
        if v.ClassName == "WedgePart" then
            Cache.GiveWedge(v)
            v.Anchored = true
            v.CanCollide = false
            v.Position = Vector3.new(0, 0, -400)
            v.Parent = nil
        elseif v.ClassName == "Part" then
            Cache.GivePart(v)
            v.Anchored = true
            v.CanCollide = false
            v.Position = Vector3.new(0, 0, -400)
            v.Parent = nil
        else
            v:Destroy()
        end
    end
end

local lastMap = nil
local function GenerateMap()
    local CameraController = Knit.GetController("CameraController")
    local hrp = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    
    hrp.Anchored = true
    CameraController.Enabled = false
    if lastMap then
        DestroyMap(lastMap)
        lastMap:Destroy()
        task.wait(0.1) -- Give some breathing time
    end
    
    local newMap, spawn = Generator.new()
    lastMap = newMap
    
    hrp.Anchored = false
    Players.LocalPlayer.Character:PivotTo(CFrame.new(Vector3.new(spawn.x, spawn.y + 1, -1)))
    CameraController.Enabled = true
end

GeneratorController.Transition = Fusion.State(true)
local transitionInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1)

local function MountUI()
    
    return Fusion.New("ScreenGui")({
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        IgnoreGuiInset = true,
        
        [Fusion.Children] = {
            Fusion.New("TextButton")({
                Size = UDim2.new(0, 100, 0, 50),
                Position = UDim2.new(0.5, 0, 1, 10),
                AnchorPoint = Vector2.new(0.5, 1),
                TextSize = 24,
                Text = "Generate",
                
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if not GeneratorController.Transition:get() then
                        GeneratorController.Transition:set(true)
                        task.wait(0.6)
                        GenerateMap()
                        task.wait(0.3)
                        GeneratorController.Transition:set(false)
                    end
                end,
                
                [Fusion.Children] = Fusion.New("UICorner")({
                    CornerRadius = UDim.new(0, 10),
                })
            }),
            
            Fusion.New("Frame")({
                Size = UDim2.new(1, 0, 0.5, 0),
                Position = Fusion.Tween(Fusion.Computed(function()
                    return GeneratorController.Transition:get() and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0, 0)
                end), transitionInfo),
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.new(0, 0, 0),
            }),
            Fusion.New("Frame")({
                Size = UDim2.new(1, 0, 0.5, 0),
                Position = Fusion.Tween(Fusion.Computed(function()
                    return GeneratorController.Transition:get() and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1, 0)
                end), transitionInfo),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.new(0, 0, 0),
            })
        }
    })
end

function GeneratorController:KnitStart()
    local player = Players.LocalPlayer
    
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    MountUI()
    player.CharacterAdded:Connect(MountUI)
    
    GenerateMap()
    task.wait(0.3)
    GeneratorController.Transition:set(false)
end

return GeneratorController