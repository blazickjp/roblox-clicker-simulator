--[[
    DataStoreManager - SAVES EVERYTHING!
    
    This makes sure your progress isn't lost when you leave.
    Uses Roblox DataStore to save:
    - Coins & Upgrades
    - Pets
    - Achievements
    - Daily login streak
    - Redeemed codes
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataStoreManager = {}

-- The main data store
local playerStore = DataStoreService:GetDataStore("ClickerSimulator_v1")

-- Default data for new players
local DEFAULT_DATA = {
    -- Basic stats
    Coins = 0,
    TotalCoinsEarned = 0,
    Clicks = 0,
    
    -- Upgrades
    ClickPowerLevel = 0,
    AutoClickLevel = 0,
    LuckyLevel = 0,
    SpeedLevel = 0,
    
    -- Rebirth
    Rebirths = 0,
    
    -- Pets (array of pet data)
    Pets = {},
    EquippedPets = {},  -- IDs of equipped pets (max 3)
    
    -- Zone
    CurrentZone = "meadow",
    
    -- Achievements (array of unlocked achievement IDs)
    UnlockedAchievements = {},
    
    -- Codes (array of redeemed code strings)
    RedeemedCodes = {},
    
    -- Daily rewards
    LastLoginDay = 0,  -- Day number (os.time() / 86400)
    LoginStreak = 0,
    TotalLogins = 0,
    
    -- Stats tracking
    EggsHatched = 0,
    RaresHatched = 0,
    EpicsHatched = 0,
    LegendariesHatched = 0,
}

-- Cache for player data (so we don't hit DataStore constantly)
local dataCache = {}

-- Deep copy function
local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Load player data
function DataStoreManager.LoadData(player)
    local key = "Player_" .. player.UserId
    local success, data = pcall(function()
        return playerStore:GetAsync(key)
    end)
    
    if success and data then
        -- Merge with defaults (in case we added new fields)
        local mergedData = deepCopy(DEFAULT_DATA)
        for k, v in pairs(data) do
            mergedData[k] = v
        end
        dataCache[player.UserId] = mergedData
        print("✅ Loaded data for " .. player.Name)
    else
        -- New player!
        dataCache[player.UserId] = deepCopy(DEFAULT_DATA)
        print("🆕 New player: " .. player.Name)
    end
    
    return dataCache[player.UserId]
end

-- Save player data
function DataStoreManager.SaveData(player)
    local data = dataCache[player.UserId]
    if not data then return false end
    
    local key = "Player_" .. player.UserId
    local success, err = pcall(function()
        playerStore:SetAsync(key, data)
    end)
    
    if success then
        print("💾 Saved data for " .. player.Name)
    else
        warn("❌ Failed to save data for " .. player.Name .. ": " .. tostring(err))
    end
    
    return success
end

-- Get player data (from cache)
function DataStoreManager.GetData(player)
    return dataCache[player.UserId]
end

-- Update a specific field
function DataStoreManager.UpdateField(player, field, value)
    local data = dataCache[player.UserId]
    if data then
        data[field] = value
    end
end

-- Increment a field
function DataStoreManager.IncrementField(player, field, amount)
    local data = dataCache[player.UserId]
    if data and data[field] then
        data[field] = data[field] + (amount or 1)
    end
end

-- Add to array field
function DataStoreManager.AddToArray(player, field, value)
    local data = dataCache[player.UserId]
    if data and data[field] then
        table.insert(data[field], value)
    end
end

-- Check if array contains value
function DataStoreManager.ArrayContains(player, field, value)
    local data = dataCache[player.UserId]
    if data and data[field] then
        for _, v in ipairs(data[field]) do
            if v == value then
                return true
            end
        end
    end
    return false
end

-- Clear player from cache (on leave)
function DataStoreManager.ClearCache(player)
    dataCache[player.UserId] = nil
end

-- Auto-save every 60 seconds
spawn(function()
    while true do
        wait(60)
        for _, player in pairs(Players:GetPlayers()) do
            DataStoreManager.SaveData(player)
        end
    end
end)

print("💾 DataStoreManager loaded!")

return DataStoreManager
