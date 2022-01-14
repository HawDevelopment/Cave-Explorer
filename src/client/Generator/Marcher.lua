--[[
    Marcher.
    HawDevelopment
    01/14/2022
--]]

local Marcher = {}
Marcher.__index = Marcher


function Marcher.new(map)
    local size = 2
    local parent = Instance.new("Folder")
    
    for x = 1, #map do
        for y = 1, #map[x] do
            
            local inst = Instance.new("Part")
            inst.Anchored = true
            inst.CanCollide = false
            inst.Size = Vector3.new(size, size, size)
            inst.Position = Vector3.new(x * size, y * size, 0)
            inst.Color = map[x][y] == 1 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
            inst.Parent = parent
        end
    end
    parent.Parent = workspace
    
    return parent
end

return Marcher
