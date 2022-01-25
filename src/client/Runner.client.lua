--[[
    Runner.
    HawDevelopment
    01/14/2022
--]]

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)

for _, module in pairs(script.Parent:WaitForChild("Controllers"):GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end

Knit.Start():catch(function()
    print("Knit failed to start")
end)
