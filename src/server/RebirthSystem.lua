--[[
    RebirthSystem Script
    ====================
    REBIRTH = Start over but get a PERMANENT multiplier!
    
    When you rebirth:
    - Your coins reset to 0
    - Your upgrades reset to 0
    - BUT you get a rebirth multiplier that makes EVERYTHING faster!
    
    Each rebirth makes the next one cost more, but you get stronger!
    
    ⭐ CHANGE THESE TO MAKE REBIRTH EASIER/HARDER! ⭐
]]

local RebirthSystem = {}

-- How many coins needed for first rebirth
local BASE_REBIRTH_COST = 10000  -- Change to 1000 for easier testing!

-- How much stronger each rebirth makes you
local REBIRTH_MULTIPLIER = 1.5   -- 1.5x = 50% stronger each rebirth!

-- Store rebirth data
local rebirthData = {}

-- Initialize rebirth data for a player
function RebirthSystem.InitPlayer(player)
    rebirthData[player.UserId] = {
        Rebirths = 0,
        RebirthMultiplier = 1,
    }
    print("🔄 Rebirth system ready for " .. player.Name)
end

-- Clean up when player leaves
function RebirthSystem.RemovePlayer(player)
    rebirthData[player.UserId] = nil
end

-- Get rebirth cost for a player
function RebirthSystem.GetRebirthCost(player)
    local data = rebirthData[player.UserId]
    if data then
        -- Cost doubles each rebirth!
        return BASE_REBIRTH_COST * math.pow(2, data.Rebirths)
    end
    return BASE_REBIRTH_COST
end

-- Get rebirth multiplier (makes everything stronger!)
function RebirthSystem.GetMultiplier(player)
    local data = rebirthData[player.UserId]
    if data then
        return data.RebirthMultiplier
    end
    return 1
end

-- Get number of rebirths
function RebirthSystem.GetRebirths(player)
    local data = rebirthData[player.UserId]
    if data then
        return data.Rebirths
    end
    return 0
end

-- Try to rebirth (returns true if successful)
function RebirthSystem.TryRebirth(player, currentCoins, resetFunction)
    local data = rebirthData[player.UserId]
    if not data then return false end
    
    local cost = RebirthSystem.GetRebirthCost(player)
    
    if currentCoins >= cost then
        -- Do the rebirth!
        data.Rebirths = data.Rebirths + 1
        data.RebirthMultiplier = math.pow(REBIRTH_MULTIPLIER, data.Rebirths)
        
        -- Call the reset function to reset player's coins and upgrades
        if resetFunction then
            resetFunction()
        end
        
        print("🌟 " .. player.Name .. " REBIRTHED! Now at " .. data.Rebirths .. " rebirths!")
        print("   New multiplier: " .. data.RebirthMultiplier .. "x")
        
        return true
    end
    
    return false
end

-- Get all rebirth stats
function RebirthSystem.GetStats(player)
    local data = rebirthData[player.UserId]
    if data then
        return {
            Rebirths = data.Rebirths,
            RebirthMultiplier = data.RebirthMultiplier,
            NextRebirthCost = RebirthSystem.GetRebirthCost(player)
        }
    end
    return {
        Rebirths = 0,
        RebirthMultiplier = 1,
        NextRebirthCost = BASE_REBIRTH_COST
    }
end

return RebirthSystem
