--[[
    ZonesConfig - Different areas of the game!
    
    Each zone has better coins but requires rebirths to unlock.
    
    🌸 Starter Meadow - Free!
    🌲 Mystic Forest - 1 Rebirth
    🌋 Lava Lands - 3 Rebirths  
    🚀 Space Station - 5 Rebirths
]]

local ZonesConfig = {}

ZonesConfig.Zones = {
    {
        id = "meadow",
        name = "Starter Meadow",
        emoji = "🌸",
        description = "A peaceful meadow perfect for beginners!",
        rebirthsRequired = 0,
        coinMultiplier = 1,
        backgroundColor = Color3.fromRGB(150, 220, 150),
        padColor = Color3.fromRGB(255, 223, 0),
        unlocked = true,
    },
    {
        id = "forest",
        name = "Mystic Forest",
        emoji = "🌲",
        description = "A magical forest with glowing coins!",
        rebirthsRequired = 1,
        coinMultiplier = 3,
        backgroundColor = Color3.fromRGB(34, 100, 34),
        padColor = Color3.fromRGB(0, 255, 127),
        unlocked = false,
    },
    {
        id = "lava",
        name = "Lava Lands",
        emoji = "🌋",
        description = "Hot hot hot! But the coins are worth it!",
        rebirthsRequired = 3,
        coinMultiplier = 10,
        backgroundColor = Color3.fromRGB(80, 20, 10),
        padColor = Color3.fromRGB(255, 100, 0),
        unlocked = false,
    },
    {
        id = "space",
        name = "Space Station",
        emoji = "🚀",
        description = "Coins from another galaxy!",
        rebirthsRequired = 5,
        coinMultiplier = 25,
        backgroundColor = Color3.fromRGB(10, 10, 40),
        padColor = Color3.fromRGB(150, 100, 255),
        unlocked = false,
    },
}

-- Get zone by id
function ZonesConfig.GetZone(zoneId)
    for _, zone in ipairs(ZonesConfig.Zones) do
        if zone.id == zoneId then
            return zone
        end
    end
    return ZonesConfig.Zones[1]
end

-- Check if zone is unlocked
function ZonesConfig.IsUnlocked(zoneId, rebirths)
    local zone = ZonesConfig.GetZone(zoneId)
    return rebirths >= zone.rebirthsRequired
end

return ZonesConfig
