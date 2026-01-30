--[[
    PlayerData Module
    =================
    This keeps track of each player's coins and upgrades.
    
    NOW WITH MULTIPLE UPGRADE TYPES! 🎉
    
    UPGRADE TYPES:
    1. Click Power - Get more coins per click!
    2. Auto-Clicker - Automatically earn coins over time!
    3. Lucky Bonus - Chance for DOUBLE coins!
    4. Super Speed - Click faster (lower cooldown)!
    
    ⭐ CHANGE THESE NUMBERS TO MAKE THE GAME EASIER OR HARDER! ⭐
]]

local PlayerData = {}

-- ===== UPGRADE SETTINGS =====
-- Click Power: Each level doubles your coins per click!
local CLICK_POWER_BASE_COST = 50
local CLICK_POWER_MULTIPLIER = 2

-- Auto-Clicker: Earns coins automatically every second!
local AUTO_CLICK_BASE_COST = 200
local AUTO_CLICK_COINS_PER_LEVEL = 1  -- Coins per second per level

-- Lucky Bonus: Chance for double coins on each click!
local LUCKY_BASE_COST = 300
local LUCKY_CHANCE_PER_LEVEL = 5  -- 5% more chance per level (max 50%)

-- Super Speed: Reduces cooldown between clicks!
local SPEED_BASE_COST = 400
local SPEED_REDUCTION_PER_LEVEL = 0.05  -- 0.05 seconds faster per level

-- This table stores everyone's data
local playerStats = {}

-- When a player joins, set up their data
function PlayerData.InitPlayer(player)
    playerStats[player.UserId] = {
        Coins = 0,
        -- Upgrade levels
        ClickPowerLevel = 0,
        AutoClickLevel = 0,
        LuckyLevel = 0,
        SpeedLevel = 0,
        -- Calculated stats
        ClickPower = 1,
        AutoClickRate = 0,
        LuckyChance = 0,
        Cooldown = 0.5,
    }
    print("✅ " .. player.Name .. " joined! Starting coins: 0")
end

-- When a player leaves, clean up their data
function PlayerData.RemovePlayer(player)
    playerStats[player.UserId] = nil
    print("👋 " .. player.Name .. " left!")
end

-- Get a player's coins
function PlayerData.GetCoins(player)
    local data = playerStats[player.UserId]
    if data then
        return data.Coins
    end
    return 0
end

-- Get a player's click power
function PlayerData.GetClickPower(player)
    local data = playerStats[player.UserId]
    if data then
        return data.ClickPower
    end
    return 1
end

-- Get auto-click rate (coins per second)
function PlayerData.GetAutoClickRate(player)
    local data = playerStats[player.UserId]
    if data then
        return data.AutoClickRate
    end
    return 0
end

-- Get lucky chance (0-50%)
function PlayerData.GetLuckyChance(player)
    local data = playerStats[player.UserId]
    if data then
        return data.LuckyChance
    end
    return 0
end

-- Get cooldown time
function PlayerData.GetCooldown(player)
    local data = playerStats[player.UserId]
    if data then
        return data.Cooldown
    end
    return 0.5
end

-- Add coins to a player
function PlayerData.AddCoins(player, amount)
    local data = playerStats[player.UserId]
    if data then
        data.Coins = data.Coins + amount
        print("💰 " .. player.Name .. " now has " .. data.Coins .. " coins!")
        return data.Coins
    end
    return 0
end

-- Calculate upgrade cost (each level costs more!)
local function calculateCost(baseCost, level)
    return math.floor(baseCost * math.pow(1.5, level))
end

-- Recalculate all stats after an upgrade
local function recalculateStats(data)
    -- Click Power: 2^level
    data.ClickPower = math.pow(CLICK_POWER_MULTIPLIER, data.ClickPowerLevel)
    
    -- Auto-Click: coins per second
    data.AutoClickRate = data.AutoClickLevel * AUTO_CLICK_COINS_PER_LEVEL
    
    -- Lucky: chance for double (capped at 50%)
    data.LuckyChance = math.min(data.LuckyLevel * LUCKY_CHANCE_PER_LEVEL, 50)
    
    -- Speed: cooldown reduction (minimum 0.1 seconds)
    data.Cooldown = math.max(0.5 - (data.SpeedLevel * SPEED_REDUCTION_PER_LEVEL), 0.1)
end

-- ===== BUY UPGRADE FUNCTIONS =====

-- Buy Click Power upgrade
function PlayerData.BuyClickPower(player)
    local data = playerStats[player.UserId]
    if not data then return false end
    
    local cost = calculateCost(CLICK_POWER_BASE_COST, data.ClickPowerLevel)
    
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.ClickPowerLevel = data.ClickPowerLevel + 1
        recalculateStats(data)
        print("⚡ " .. player.Name .. " upgraded Click Power to level " .. data.ClickPowerLevel)
        return true
    end
    return false
end

-- Buy Auto-Clicker upgrade
function PlayerData.BuyAutoClick(player)
    local data = playerStats[player.UserId]
    if not data then return false end
    
    local cost = calculateCost(AUTO_CLICK_BASE_COST, data.AutoClickLevel)
    
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.AutoClickLevel = data.AutoClickLevel + 1
        recalculateStats(data)
        print("🤖 " .. player.Name .. " upgraded Auto-Clicker to level " .. data.AutoClickLevel)
        return true
    end
    return false
end

-- Buy Lucky Bonus upgrade
function PlayerData.BuyLucky(player)
    local data = playerStats[player.UserId]
    if not data then return false end
    
    -- Max level is 10 (50% chance)
    if data.LuckyLevel >= 10 then
        print("🍀 " .. player.Name .. " already has MAX Lucky!")
        return false
    end
    
    local cost = calculateCost(LUCKY_BASE_COST, data.LuckyLevel)
    
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.LuckyLevel = data.LuckyLevel + 1
        recalculateStats(data)
        print("🍀 " .. player.Name .. " upgraded Lucky Bonus to level " .. data.LuckyLevel)
        return true
    end
    return false
end

-- Buy Super Speed upgrade
function PlayerData.BuySpeed(player)
    local data = playerStats[player.UserId]
    if not data then return false end
    
    -- Max level is 8 (0.1 second cooldown)
    if data.SpeedLevel >= 8 then
        print("🏃 " .. player.Name .. " already has MAX Speed!")
        return false
    end
    
    local cost = calculateCost(SPEED_BASE_COST, data.SpeedLevel)
    
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.SpeedLevel = data.SpeedLevel + 1
        recalculateStats(data)
        print("🏃 " .. player.Name .. " upgraded Super Speed to level " .. data.SpeedLevel)
        return true
    end
    return false
end

-- Legacy function for old shop (buys click power)
function PlayerData.BuyUpgrade(player)
    return PlayerData.BuyClickPower(player)
end

-- Get all upgrade costs
function PlayerData.GetUpgradeCosts(player)
    local data = playerStats[player.UserId]
    if data then
        return {
            ClickPower = calculateCost(CLICK_POWER_BASE_COST, data.ClickPowerLevel),
            AutoClick = calculateCost(AUTO_CLICK_BASE_COST, data.AutoClickLevel),
            Lucky = data.LuckyLevel < 10 and calculateCost(LUCKY_BASE_COST, data.LuckyLevel) or "MAX",
            Speed = data.SpeedLevel < 8 and calculateCost(SPEED_BASE_COST, data.SpeedLevel) or "MAX",
        }
    end
    return nil
end

-- Get the cost of the next upgrade (legacy - returns click power cost)
function PlayerData.GetUpgradeCost(player)
    local data = playerStats[player.UserId]
    if data then
        return calculateCost(CLICK_POWER_BASE_COST, data.ClickPowerLevel)
    end
    return CLICK_POWER_BASE_COST
end

-- Get all stats for a player (for the UI)
function PlayerData.GetAllStats(player)
    local data = playerStats[player.UserId]
    if data then
        local costs = PlayerData.GetUpgradeCosts(player)
        return {
            Coins = data.Coins,
            ClickPower = data.ClickPower,
            AutoClickRate = data.AutoClickRate,
            LuckyChance = data.LuckyChance,
            Cooldown = data.Cooldown,
            -- Levels
            ClickPowerLevel = data.ClickPowerLevel,
            AutoClickLevel = data.AutoClickLevel,
            LuckyLevel = data.LuckyLevel,
            SpeedLevel = data.SpeedLevel,
            -- Costs
            UpgradeCosts = costs,
            -- Legacy
            Upgrades = data.ClickPowerLevel,
            NextUpgradeCost = costs.ClickPower
        }
    end
    return nil
end

-- Reset player stats (for rebirth system)
function PlayerData.ResetForRebirth(player)
    local data = playerStats[player.UserId]
    if data then
        data.Coins = 0
        data.ClickPowerLevel = 0
        data.AutoClickLevel = 0
        data.LuckyLevel = 0
        data.SpeedLevel = 0
        recalculateStats(data)
        print("🔄 " .. player.Name .. " stats reset for rebirth!")
    end
end

return PlayerData
