--[[
    Map.
    HawDevelopment
    01/14/2022
--]]

local Map = {}
Map.__index = Map

function Map.new()
    local self = setmetatable({
        _gridSize = 200,
        _fill = math.random(50, 58), -- Percentage of the map that is filled
        _smoothNum = 4, -- How many surrounding tiles that needs to be filled to fill a tile
        radius = 2,
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
            count = count + map[x][y]
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

function Map:AddBorder(size)
    local map = self._map
    local originalSize = self._gridSize
    self._gridSize = self._gridSize + size * 2
    
    local newmap = table.create(self._gridSize)
    for x = 1, self._gridSize do
        newmap[x] = table.create(self._gridSize)
    end
    
    for x = 1, self._gridSize do
        for y = 1, self._gridSize do
            if x <= size or x >= originalSize or y <= size or y >= originalSize then
                newmap[x][y] = 1
            else
                newmap[x][y] = map[x - size][y - size]
            end
        end
    end
    
    self._map = newmap
end

function Map:_floodFill(x, y, value, visited)
    local queue = {
        Vector2.new(x, y)
    }
    local region = {
        Vector2.new(x, y)
    }
    visited[x][y] = true
    
    while #queue > 0 do
        local p = queue[#queue]
        queue[#queue] = nil 
        
        for px = p.x - 1, p.x + 1 do
            for py = p.y - 1, p.y + 1 do
                if  (px == p.x or py == p.y) and
                    (px > 1 and px < self._gridSize) and
                    (py > 1 and py < self._gridSize) and
                    self._map[px][py] == value and 
                    not visited[px][py]
                then
                    visited[px][py] = true
                    table.insert(queue, 1, Vector2.new(px, py))
                    table.insert(region, 1, Vector2.new(px, py))
                end
            end
        end
    end
    
    return region
end

function Map:GenerateRegions(value)
    -- Use flood fill to generate regions
    -- Heres the steps:
    -- 1. Start at the top left corner
    -- 2. If the tile has not been in a region, use flood fill to generate one.
    -- 3. If the tile has been in a region, skip it.
    -- 4. Repeat step 2 until all tiles have been checked.
    local regions = {}
    local visited = {}
    for x = 1, self._gridSize do
        visited[x] = table.create(self._gridSize, false)
    end
    
    for x = 2, self._gridSize - 1 do
        for y = 2, self._gridSize - 1 do
            if self._map[x][y] == value and not visited[x][y] then
                print("Doing flood fill")
                local region = self:_floodFill(x, y, value, visited)
                
                table.insert(regions, region)
                task.wait()
            end
        end
    end
    
    return regions
end

-- Gotten from https://stackoverflow.com/a/4076937
local function GetLine(a, b)
    local x0, x1, y0, y1 = a.x, b.x, a.y, b.y
    local dx = x1 - x0;
    local dy = y1 - y0;
    local stepx, stepy

    if dy < 0 then
        dy = -dy
        stepy = -1
    else
        stepy = 1
    end

    if dx < 0 then
        dx = -dx
        stepx = -1
    else
        stepx = 1
    end
    
    local line = {}
    table.insert(line, Vector2.new(x0, y0))
    if dx > dy then
        local fraction = dy - bit32.rshift(dx, 1)
        while x0 ~= x1 do
            if fraction >= 0 then
                y0 = y0 + stepy
                fraction = fraction - dx
            end
            x0 = x0 + stepx
            fraction = fraction + dy
            table.insert(line, Vector2.new(math.round(x0), math.round(y0)))
        end
    else
        local fraction = dx - bit32.rshift(dy, 1)
        while y0 ~= y1 do
            if fraction >= 0 then
                x0 = x0 + stepx
                fraction = fraction - dy
            end
            y0 = y0 + stepy
            fraction = fraction + dx
            table.insert(line, Vector2.new(math.round(x0), math.round(y0)))
        end
    end
    
    return line
end

function Map:ConnectPoints(a, b)
    -- Heres the steps:
    -- 1. Get a line of points between the two points
    -- 2. For each point in the line remove a circle around it
    
    -- Get the line
    local line = GetLine(a, b)
    
    -- Remove points in a circle around each point
    local radiusSquared = self.radius * self.radius
    for _, point in ipairs(line) do
        for x = -self.radius, self.radius do
            for y = -self.radius, self.radius do
                if (x * x + y * y) <= radiusSquared then
                    local x, y = point.x + x, point.y + y
                    if x > 1 and x <= self._gridSize - 1 and y > 1 and y <= self._gridSize - 1 then
                        self._map[x][y] = 0
                    end
                end
            end
        end
    end
end

return Map
