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
    -- 3. Add a border
    -- 4. Find all regions, and fill or remove small regions
    -- 5. Connect all regions
    -- 6. Find player spawn
    -- 7. Apply marching squares
    
    -- First, generate a random map
    local map = Map.new()
    
    -- Smooth the map
    map:Smooth()
    
    map:AddBorder(10)
    
    -- Find regions and remove small
    local airRegions, wallRegions = Generator.FindAndRemoveRegions(map)
    
    -- Connect all regions
    local mainRegion = Generator.ConnectRegions(map, airRegions)
    
    map:Smooth()
    map:Smooth()
    
    -- Find spawn for player
    local spawn = Generator.FindSpawn(map, mainRegion) 
    
    -- Apply marching squares
    local meshedMap = Marcher.new(map._map)
    meshedMap.Parent = workspace
    
    return meshedMap, spawn * 2
end

function Generator.FindAndRemoveRegions(map)
    -- Find all regions.
    local airRegions = map:GenerateRegions(0)
    local wallRegions = map:GenerateRegions(1)
    
    -- Fill and remove small regions
    local survivedAirRegions = {}
    local survivedWallRegions = {}
    for index, region in pairs(airRegions) do
        if #region < 30 then
            for i = 1, #region do
                map._map[region[i].x][region[i].y] = 1
            end
        else
            table.insert(survivedAirRegions, region)
        end
    end
    for _, region in pairs(wallRegions) do
        if #region < 10 then
            for i = 1, #region do
                map._map[region[i].x][region[i].y] = 0
            end
        else
            table.insert(survivedWallRegions, region)
        end
    end
    return survivedAirRegions, survivedWallRegions
end

function Generator.ConnectRegions(map, regions)
    -- Find the lowest and highest points in each air region
    local mainRegion, lowestPoint
    for _, region in pairs(regions) do
        local lowest, highest
        for i = 1, #region do
            if not lowest or region[i].y < lowest.y then lowest = region[i] end
            if not highest or region[i].y > highest.y then highest = region[i] end
        end
        
        if not lowestPoint or lowestPoint.y > lowest.y then
            lowestPoint = lowest
            mainRegion = region
        end
    end
    
    -- Find the middle most point in the main region
    local middlePoints = {}
    for i = 1, #regions do
        local region = regions[i]
        local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
        for j = 1, #region do
            local point = region[j]
            if point.x < minx then minx = point.x end
            if point.y < miny then miny = point.y end
            if point.x > maxx then maxx = point.x end
            if point.y > maxy then maxy = point.y end
        end
        local x = (minx + maxx) / 2
        local y = (miny + maxy) / 2
        middlePoints[region] = Vector2.new(math.round(x), math.round(y))
    end
    
    -- Connect the regions
    local connected = {}
    for i = 1, #regions do connected[regions[i]] = {} end
    
    for _ = 1, 6 do
        for i = 1, #regions do
            local region = regions[i]
            if connected[region][mainRegion] then
                -- Already connected
                continue
            end
            
            local length
            local point, bestPoint
            local bestRegion
            
            for j = 1, #regions do
                if i == j then
                    continue
                end
                local pointA, pointB = middlePoints[region], middlePoints[regions[j]]
                local newLength = (pointA - pointB).magnitude
                
                if not length or (newLength < length and not connected[region][regions[j]]) then
                    length = newLength
                    point = pointA
                    bestPoint = pointB
                    bestRegion = regions[j]
                end
            end
            
            if point and bestPoint and bestRegion then
                map:ConnectPoints(point, bestPoint)
                
                -- Add the regions to the connected list
                connected[region][bestRegion] = true
                connected[bestRegion][region] = true
                
                if connected[region][mainRegion] then connected[bestRegion][mainRegion] = true end
                if connected[bestRegion][mainRegion] then connected[region][mainRegion] = true end
            end
        end
    end
    
    -- Connect all not connected to the main region
    for i = 1, #regions do
        local region = regions[i]
        if not connected[region][mainRegion] then
            local pointA, pointB = middlePoints[region], middlePoints[mainRegion]
            map:ConnectPoints(pointA, pointB)
            connected[region][mainRegion] = true
            connected[mainRegion][region] = true
        end
    end
    
    return mainRegion
end

function Generator.FindSpawn(map, region)
    local bestPoint
    
    for i = 1, #region do
        local point = region[i]
        if map._map[point.x][point.y] == 1 then
            continue
        end
        
        if not bestPoint or (
            point.y < bestPoint.y and
            map._map[point.x][point.y] == 0 and
            map._map[point.x][point.y + 1] == 0 and
            map._map[point.x][point.y - 1] == 1
        ) then
            bestPoint = point
        end
    end
    
    return bestPoint
end

return Generator
