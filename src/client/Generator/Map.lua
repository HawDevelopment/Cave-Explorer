--[[
    Map.
    HawDevelopment
    01/14/2022
--]]

local Map = {}
Map.__index = Map

function Map.new()
    local self = setmetatable({
        _gridSize = 100,
        _fill = 63, -- Percentage of the map that is filled
        _smoothNum = 4, -- How many surrounding tiles to smooth 
    }, Map)
    
    -- Generate a random map
    local map = {}
    
    for x = 1, self._gridSize do
        map[x] = {}
        for y = 1, self._gridSize do
            
            -- If its at the boarder we want to make sure its a wall
            if x == 1 or x == self._gridSize or y == 1 or y == self._gridSize then
                map[x][y] = 1
            else
                map[x][y] = math.random(0, 100) < self._fill and 1 or 0
            end
        end
    end
    
    self._map = map
    return self
end

local function GetSurrounding(map, px, py)
    local count = 0
    for x = px - 1, px + 1 do
        for y = py - 1, py + 1 do
            
            if x ~= px or y ~= py then
                count = count + map[x][y]
            end
        end
    end
    return count
end

function Map:Smooth()
    for x = 2, self._gridSize - 1 do
        for y = 2, self._gridSize - 1 do
            self._map[x][y] = GetSurrounding(self._map, x, y) > self._smoothNum and 1 or 0
        end
    end
end

return Map
