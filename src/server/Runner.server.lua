--[[
    Runner.
    HawDevelopment
    01/14/2022
--]]

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages.Knit)

Knit.Start():catch(function()
    warn("Knit failed to start")
end)