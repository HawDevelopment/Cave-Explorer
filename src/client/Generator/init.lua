--[[
    Generator.
    HawDevelopment
    01/14/2022
--]]

local Map = require(script.Map)
local Marcher = require(script.Marcher)

local Generator = {}
Generator.__index = Generator

function Generator.new()
    -- Theres 3 steps we need to do:
    -- 1. Generate a random map
    -- 2. Smooth the map
    -- 3. Apply marching squares
    
    -- First, generate a random map
    local map = Map.new()
    
    -- Smooth the map
    for _ = 1, 4 do
        map:Smooth()
    end
    
    -- Apply marching squares
    local meshedMap = Marcher.new(map._map)
    
    return meshedMap
end

return Generator
