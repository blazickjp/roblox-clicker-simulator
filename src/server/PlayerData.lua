--[[
    PlayerData Module (v2.0)
    ========================
    Now with DataStore integration and ALL the features!
    
    UPGRADE TYPES:
    1. Click Power - Get more coins per click!
    2. Auto-Clicker - Automatically earn coins over time!
    3. Lucky Bonus - Chance for DOUBLE coins!
    4. Super Speed - Click faster (lower cooldown)!
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = {}

-- Wait for shared modules
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)

-- Get DataStore manager
local DataStoreManager = require(script.Parent.DataStoreManager)

-- Get configs
local ZonesConfig
local function getZonesConfig()
    if not ZonesConfig and SharedFolder then
        local success = pcall(function()
            ZonesConfig = require(SharedFolder:WaitForChild("ZonesConfig", 5))
        end)
    end
    return ZonesConfig
end

-- ===== UPGRADE SETTINGS =====
local CLICK_POWER_BASE_COST = 50
local CLICK_POWER_MULTIPLIER = 2

local AUTO_CLICK_BASE_COST = 200
local AUTO_CLICK_COINS_PER_LEVEL = 1

local LUCKY_BASE_COST = 300
local LUCKY_CHANCE_PER_LEVEL = 5

local SPEED_BASE_COST = 400
local SPEED_REDUCTION_PER_LEVEL = 0.05

-- Calculate upgrade cost
local function calculateCost(baseCost, level)
    return math.floor(baseCost * math.pow(1.5, level))
end

-- Calculate stats from levels
local function calculateStats(data)
    return {
        ClickPower = math.pow(CLICK_POWER_MULTIPLIER, data.ClickPowerLevel),
        AutoClickRate = data.AutoClickLevel * AUTO_CLICK_COINS_PER_LEVEL,
        LuckyChance = math.min(data.LuckyLevel * LUCKY_CHANCE_PER_LEVEL, 50),
        Cooldown = math.max(0.5 - (data.SpeedLevel * SPEED_REDUCTION_PER_LEVEL), 0.1),
    }
end

-- Initialize player
function PlayerData.InitPlayer(player)
    local data = DataStoreManager.LoadData(player)
    
    -- Check daily login
    local today = math.floor(os.time() / 86400)
    if data.LastLoginDay ~= today then
        -- New day!
        if data.LastLoginDay == today - 1 then
            -- Consecutive day!
            data.LoginStreak = data.LoginStreak + 1
        else
            -- Streak broken
            data.LoginStreak = 1
        end
        data.LastLoginDay = today
        data.TotalLogins = data.TotalLogins + 1
        DataStoreManager.UpdateField(player, "LastLoginDay", today)
        DataStoreManager.UpdateField(player, "LoginStreak", data.LoginStreak)
        DataStoreManager.UpdateField(player, "TotalLogins", data.TotalLogins)
    end
    
    print("✅ " .. player.Name .. " initialized! Streak: " .. data.LoginStreak .. " days")
    return data
end

-- Remove player (save data)
function PlayerData.RemovePlayer(player)
    DataStoreManager.SaveData(player)
    DataStoreManager.ClearCache(player)
    print("👋 " .. player.Name .. " data saved!")
end

-- Get coins
function PlayerData.GetCoins(player)
    local data = DataStoreManager.GetData(player)
    return data and data.Coins or 0
end

-- Get click power
function PlayerData.GetClickPower(player)
    local data = DataStoreManager.GetData(player)
    if data then
        local stats = calculateStats(data)
        return stats.ClickPower
    end
    return 1
end

-- Get auto-click rate
function PlayerData.GetAutoClickRate(player)
    local data = DataStoreManager.GetData(player)
    if data then
        local stats = calculateStats(data)
        return stats.AutoClickRate
    end
    return 0
end

-- Get lucky chance
function PlayerData.GetLuckyChance(player)
    local data = DataStoreManager.GetData(player)
    if data then
        local stats = calculateStats(data)
        return stats.LuckyChance
    end
    return 0
end

-- Get cooldown
function PlayerData.GetCooldown(player)
    local data = DataStoreManager.GetData(player)
    if data then
        local stats = calculateStats(data)
        return stats.Cooldown
    end
    return 0.5
end

-- Get current zone multiplier
function PlayerData.GetZoneMultiplier(player)
    local data = DataStoreManager.GetData(player)
    local config = getZonesConfig()
    if data and config then
        local zone = config.GetZone(data.CurrentZone)
        return zone and zone.coinMultiplier or 1
    end
    return 1
end

-- Get pet bonus (total from all equipped pets)
function PlayerData.GetPetBonus(player)
    local data = DataStoreManager.GetData(player)
    if not data then return 1 end
    
    local totalBonus = 1
    local PetsConfig
    pcall(function()
        if SharedFolder then
            PetsConfig = require(SharedFolder:WaitForChild("PetsConfig", 5))
        end
    end)
    
    if PetsConfig and data.EquippedPets then
        for _, petId in ipairs(data.EquippedPets) do
            for _, pet in ipairs(data.Pets) do
                if pet.id == petId then
                    totalBonus = totalBonus + (pet.bonus or 0)
                end
            end
        end
    end
    
    return totalBonus
end

-- Add coins
function PlayerData.AddCoins(player, amount)
    local data = DataStoreManager.GetData(player)
    if data then
        data.Coins = data.Coins + amount
        data.TotalCoinsEarned = data.TotalCoinsEarned + amount
        return data.Coins
    end
    return 0
end

-- Increment clicks
function PlayerData.IncrementClicks(player)
    DataStoreManager.IncrementField(player, "Clicks", 1)
end

-- Get rebirths
function PlayerData.GetRebirths(player)
    local data = DataStoreManager.GetData(player)
    return data and data.Rebirths or 0
end

-- ===== BUY UPGRADES =====

function PlayerData.BuyClickPower(player)
    local data = DataStoreManager.GetData(player)
    if not data then return false end
    
    local cost = calculateCost(CLICK_POWER_BASE_COST, data.ClickPowerLevel)
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.ClickPowerLevel = data.ClickPowerLevel + 1
        print("⚡ " .. player.Name .. " upgraded Click Power to level " .. data.ClickPowerLevel)
        return true
    end
    return false
end

function PlayerData.BuyAutoClick(player)
    local data = DataStoreManager.GetData(player)
    if not data then return false end
    
    local cost = calculateCost(AUTO_CLICK_BASE_COST, data.AutoClickLevel)
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.AutoClickLevel = data.AutoClickLevel + 1
        print("🤖 " .. player.Name .. " upgraded Auto-Clicker to level " .. data.AutoClickLevel)
        return true
    end
    return false
end

function PlayerData.BuyLucky(player)
    local data = DataStoreManager.GetData(player)
    if not data then return false end
    if data.LuckyLevel >= 10 then return false end
    
    local cost = calculateCost(LUCKY_BASE_COST, data.LuckyLevel)
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.LuckyLevel = data.LuckyLevel + 1
        print("🍀 " .. player.Name .. " upgraded Lucky to level " .. data.LuckyLevel)
        return true
    end
    return false
end

function PlayerData.BuySpeed(player)
    local data = DataStoreManager.GetData(player)
    if not data then return false end
    if data.SpeedLevel >= 8 then return false end
    
    local cost = calculateCost(SPEED_BASE_COST, data.SpeedLevel)
    if data.Coins >= cost then
        data.Coins = data.Coins - cost
        data.SpeedLevel = data.SpeedLevel + 1
        print("🏃 " .. player.Name .. " upgraded Speed to level " .. data.SpeedLevel)
        return true
    end
    return false
end

-- Legacy
function PlayerData.BuyUpgrade(player)
    return PlayerData.BuyClickPower(player)
end

-- Get upgrade costs
function PlayerData.GetUpgradeCosts(player)
    local data = DataStoreManager.GetData(player)
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

function PlayerData.GetUpgradeCost(player)
    local costs = PlayerData.GetUpgradeCosts(player)
    return costs and costs.ClickPower or CLICK_POWER_BASE_COST
end

-- Get all stats
function PlayerData.GetAllStats(player)
    local data = DataStoreManager.GetData(player)
    if not data then return nil end
    
    local stats = calculateStats(data)
    local costs = PlayerData.GetUpgradeCosts(player)
    
    return {
        -- Basic
        Coins = data.Coins,
        TotalCoinsEarned = data.TotalCoinsEarned,
        Clicks = data.Clicks,
        
        -- Calculated stats
        ClickPower = stats.ClickPower,
        AutoClickRate = stats.AutoClickRate,
        LuckyChance = stats.LuckyChance,
        Cooldown = stats.Cooldown,
        
        -- Levels
        ClickPowerLevel = data.ClickPowerLevel,
        AutoClickLevel = data.AutoClickLevel,
        LuckyLevel = data.LuckyLevel,
        SpeedLevel = data.SpeedLevel,
        
        -- Costs
        UpgradeCosts = costs,
        
        -- Rebirth
        Rebirths = data.Rebirths,
        
        -- Zone
        CurrentZone = data.CurrentZone,
        ZoneMultiplier = PlayerData.GetZoneMultiplier(player),
        
        -- Pets
        Pets = data.Pets,
        EquippedPets = data.EquippedPets,
        PetBonus = PlayerData.GetPetBonus(player),
        
        -- Achievements
        UnlockedAchievements = data.UnlockedAchievements,
        
        -- Daily
        LoginStreak = data.LoginStreak,
        TotalLogins = data.TotalLogins,
        
        -- Legacy
        Upgrades = data.ClickPowerLevel,
        NextUpgradeCost = costs and costs.ClickPower or 50,
    }
end

-- Reset for rebirth
function PlayerData.ResetForRebirth(player)
    local data = DataStoreManager.GetData(player)
    if data then
        data.Coins = 0
        data.ClickPowerLevel = 0
        data.AutoClickLevel = 0
        data.LuckyLevel = 0
        data.SpeedLevel = 0
        data.Rebirths = data.Rebirths + 1
        print("🔄 " .. player.Name .. " rebirthed! Now at " .. data.Rebirths)
    end
end

-- Change zone
function PlayerData.ChangeZone(player, zoneId)
    local data = DataStoreManager.GetData(player)
    local config = getZonesConfig()
    
    if data and config then
        if config.IsUnlocked(zoneId, data.Rebirths) then
            data.CurrentZone = zoneId
            print("🌍 " .. player.Name .. " moved to " .. zoneId)
            return true
        end
    end
    return false
end

return PlayerData
