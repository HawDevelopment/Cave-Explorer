--[[
    Cache.
    HawDevelopment
    01/20/2022
--]]

local Cache = {}
Cache.__index = Cache

local CACHE = {
    Parts = {},
    Wedges = {},
}

function Cache.GivePart(part)
    CACHE.Parts[part] = true
end
function Cache.GiveWedge(wedge)
    CACHE.Wedges[wedge] = true
end

function Cache.GetPart()
    local index, value = next(CACHE.Parts)
    if index then
        CACHE.Parts[index] = nil
        return index
    end
end
function Cache.GetWedge()
    local index, value = next(CACHE.Wedges)
    if index then
        CACHE.Wedges[index] = nil
        return index
    end
end

return Cache
