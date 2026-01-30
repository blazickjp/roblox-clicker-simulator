--[[
    RebirthSystem - Start over with a PERMANENT multiplier!
    
    🌟 When you rebirth:
    - Coins reset to 0
    - Upgrades reset to 0
    - BUT you get a multiplier that makes EVERYTHING faster!
    
    Now integrated with DataStore for persistence!
]]

local RebirthSystem = {}

-- Settings
local BASE_REBIRTH_COST = 10000
local REBIRTH_MULTIPLIER = 1.5

-- Get DataStore manager
local DataStoreManager = require(script.Parent.DataStoreManager)

-- Initialize (data comes from DataStore now)
function RebirthSystem.InitPlayer(player)
    print("🔄 Rebirth system ready for " .. player.Name)
end

-- Clean up (DataStore handles saving)
function RebirthSystem.RemovePlayer(player)
    -- Data saved by DataStoreManager
end

-- Get rebirth cost
function RebirthSystem.GetRebirthCost(player)
    local data = DataStoreManager.GetData(player)
    if data then
        return BASE_REBIRTH_COST * math.pow(2, data.Rebirths)
    end
    return BASE_REBIRTH_COST
end

-- Get multiplier
function RebirthSystem.GetMultiplier(player)
    local data = DataStoreManager.GetData(player)
    if data then
        return math.pow(REBIRTH_MULTIPLIER, data.Rebirths)
    end
    return 1
end

-- Get number of rebirths
function RebirthSystem.GetRebirths(player)
    local data = DataStoreManager.GetData(player)
    if data then
        return data.Rebirths
    end
    return 0
end

-- Try to rebirth
function RebirthSystem.TryRebirth(player, currentCoins, resetFunction)
    local data = DataStoreManager.GetData(player)
    if not data then return false end
    
    local cost = RebirthSystem.GetRebirthCost(player)
    
    if currentCoins >= cost then
        -- Rebirth happens in PlayerData.ResetForRebirth
        -- which increments data.Rebirths
        
        if resetFunction then
            resetFunction()
        end
        
        print("🌟 " .. player.Name .. " REBIRTHED! Now at " .. data.Rebirths .. " rebirths!")
        print("   New multiplier: " .. RebirthSystem.GetMultiplier(player) .. "x")
        
        return true
    end
    
    return false
end

-- Get all stats
function RebirthSystem.GetStats(player)
    local data = DataStoreManager.GetData(player)
    if data then
        return {
            Rebirths = data.Rebirths,
            RebirthMultiplier = math.pow(REBIRTH_MULTIPLIER, data.Rebirths),
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
