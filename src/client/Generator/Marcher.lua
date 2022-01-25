--[[
    Marcher.
    HawDevelopment
    01/14/2022
--]]

local Marcher = {}
Marcher.__index = Marcher

local Cache = require(script.Parent.Cache)

-- Cache for triangles.
local wedge
do
    wedge = Instance.new("WedgePart");
    wedge.Anchored = true
    wedge.CanCollide = false
    wedge.CastShadow = true
    wedge.Material = Enum.Material.SmoothPlastic
    wedge.BrickColor = BrickColor.new("Smoky grey")
end
local part
do
    part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.CastShadow = true
    part.Material = Enum.Material.SmoothPlastic
    part.BrickColor = BrickColor.new("Smoky grey")
end

local function draw3dTriangle(a, b, c, parent)
	
	local ab, ac, bc = b - a, c - a, c - b;
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc);
	
	if (abd > acd and abd > bcd) then
		c, a = a, c;
	elseif (acd > bcd and acd > abd) then
		a, b = b, a;
	end
	
	ab, ac, bc = b - a, c - a, c - b;
	
	local right = ac:Cross(ab).unit;
	local up = bc:Cross(right).unit;
	local back = bc.unit;
	
	local height = math.abs(ab:Dot(up));
	
	local w1 = Cache.GetWedge() or wedge:Clone();
	w1.Size = Vector3.new(0, height, math.abs(ab:Dot(back)));
	w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back);
	w1.Parent = parent;
	
	local w2 = Cache.GetWedge() or wedge:Clone();
	w2.Size = Vector3.new(0, height, math.abs(ac:Dot(back)));
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back);
	w2.Parent = parent;

    return w1, w2;
end

function Marcher.new(map)
    local self = setmetatable({
        walls = {},
        parent = Instance.new("Folder"),
        size = 2,
        borderSize = 40
    }, Marcher)
    
    -- Theres 3 steps we need to do:
    -- 1. Create a grid of squares
    -- 2. Calculate the index of each square
    -- 4. Triangulate the grid
    -- 5. Create the walls
    
    -- Create the grid
    local grid = {}
    for x = 1, #map - 1 do
        for y = 1, #map[x] - 1 do
            grid[#grid + 1] = {
                x = x,
                y = y,
                value = map[x][y]
            }
        end
    end
    
    -- Calculate the index of each square
    for i = 1, #grid do
        local square = grid[i]
        local a, b, c, d = map[square.x][square.y], map[square.x + 1][square.y], map[square.x + 1][square.y + 1], map[square.x][square.y + 1]
        square.index = (a * 1) + (b * 2) + (c * 4) + (d * 8)
        if square.index == 0 then
            grid[i] = nil
        end
    end
    
    -- Triangulate the grid
    for i = 1, #grid do
        if grid[i] then
            self:Triangulate(grid[i])
        end
    end
    
    -- Create the walls
    local wallsize = self.size * 3
    for i = 1, #self.walls do
        local wall = self.walls[i]
        local a, b = wall[1], wall[2]
        
        local clone = part:Clone()
        local atHalf = CFrame.new(a:Lerp(b, 0.5))
        local cframe = atHalf * CFrame.Angles(0, 0, math.atan2(b.y - a.y, b.x - a.x)) * CFrame.new(0, 0, -wallsize/2)
        clone.CFrame = cframe
        
        clone.Size = Vector3.new((a - b).Magnitude, 0, wallsize)
        clone.CanCollide = true
        clone.Parent = self.parent
    end
    
    -- Create a border
    local cornerSize = #map * self.size + self.borderSize * 2
    local borders = {
        [Vector3.new(-self.borderSize / 2 + 2, (#map * self.size) / 2, 0)] = Vector3.new(self.borderSize, cornerSize, 0),
        [Vector3.new((#map * self.size) / 2, -self.borderSize/2 + 2, 0)] = Vector3.new(cornerSize, self.borderSize, 0),
        [Vector3.new(#map * self.size + self.borderSize / 2, (#map * self.size) / 2, 0)] = Vector3.new(self.borderSize, cornerSize, 0),
        [Vector3.new((#map * self.size) / 2, #map * self.size + self.borderSize / 2, 0)] = Vector3.new(cornerSize, self.borderSize, 0),
    }
    
    for position, size in pairs(borders) do
        local clone = part:Clone()
        clone.Position = position
        clone.Size = size
        clone.Parent = self.parent
    end
    
    return self.parent
end

function Marcher:Triangulate(square)
    
    local index = square.index
    local size = self.size
    local parent = self.parent
    if index == 0 then
        return
    elseif index == 15 then
        -- Draw a square
        local clone = Cache.GetPart() or part:Clone()
        clone.Size = Vector3.new(size, size, 0)
        clone.CFrame = CFrame.new(square.x * size + size / 2, square.y * size + size / 2, 0)
        clone.Parent = parent
    elseif index == 1 then
        -- && - - - ::
        -- |         |
        -- |         |
        -- |         |
        -- :: - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
        })
    elseif index == 2 then
        -- :: - - - &&
        -- |         |
        -- |         |
        -- |         |
        -- :: - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
        })
    elseif index == 3 then
        -- && - - - &&
        -- |         |
        -- |---------|
        -- |         |
        -- :: - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
        })
    elseif index == 4 then
        -- :: - - - ::
        -- |         |
        -- |         |
        -- |         |
        -- :: - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 5 then
        -- && - - - ::
        -- |         |
        -- |         |
        -- |         |
        -- :: - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        
        local clone = Cache.GetPart() or part:Clone()
        clone.Size = Vector3.new(size, size, 0)
        clone.CFrame = CFrame.new(square.x * size + size / 2, square.y * size + size / 2, 0) * CFrame.Angles(0, 0, math.rad(45))
        clone.Parent = parent
        
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
        })
        table.insert(self.walls, {
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 6 then
        -- :: - - - &&
        -- |    |    |
        -- |    |    |
        -- |    |    |
        -- :: - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 7 then
        -- && - - - &&
        -- |         |
        -- |         |
        -- |         |
        -- :: - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 8 then
        -- :: - - - ::
        -- |         |
        -- |         |
        -- |         |
        -- && - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 9 then
        -- && - - - ::
        -- |    |    |
        -- |    |    |
        -- |    |    |
        -- && - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 10 then
        -- :: - - - &&
        -- |         |
        -- |         |
        -- |         |
        -- && - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            parent
        )
        local clone = Cache.GetPart() or part:Clone()
        clone.Size = Vector3.new(size, size, 1)
        clone.CFrame = CFrame.new(square.x * size + size / 2, square.y * size + size / 2, 0) * CFrame.Angles(0, 0, math.rad(45))
        clone.Parent = parent
        
        table.insert(self.walls, {
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
        })
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
        })
    elseif index == 11 then
        -- && - - - &&
        -- |         |
        -- |         |
        -- |         |
        -- && - - - ::
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size / 2, square.y * size + size, 0),
        })
    elseif index == 12 then
        -- :: - - - ::
        -- |         |
        -- |---------|
        -- |         |
        -- && - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
        })
    elseif index == 13 then
        -- && - - - ::
        -- |         |
        -- |         |
        -- |         |
        -- && - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size / 2, 0),
        })
    elseif index == 14 then
        -- :: - - - &&
        -- |         |
        -- |         |
        -- |         |
        -- && - - - &&
        
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            parent
        )
        draw3dTriangle(
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size, 0),
            Vector3.new(square.x * size + size, square.y * size + size, 0),
            parent
        )
        table.insert(self.walls, {
            Vector3.new(square.x * size + size / 2, square.y * size, 0),
            Vector3.new(square.x * size, square.y * size + size / 2, 0),
        })
    end
end

return Marcher
