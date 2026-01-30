--[[
    GameManager Script (v2.0)
    ==========================
    The MAIN script that runs everything!
    
    Now with:
    - All upgrade types
    - Rebirth system
    - Zone multipliers
    - Pet bonuses
    - DataStore saves
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared folder to be ready
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)

-- Get modules
local PlayerData = require(script.Parent.PlayerData)
local RebirthSystem = require(script.Parent.RebirthSystem)
local DataStoreManager = require(script.Parent.DataStoreManager)

-- Get zone config
local ZonesConfig
pcall(function()
    ZonesConfig = require(SharedFolder:WaitForChild("ZonesConfig", 5))
end)

-- ===== CREATE REMOTE EVENTS =====
local function createRemoteEvent(name)
    local existing = ReplicatedStorage:FindFirstChild(name)
    if existing then return existing end
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = ReplicatedStorage
    return event
end

local function createRemoteFunction(name)
    local existing = ReplicatedStorage:FindFirstChild(name)
    if existing then return existing end
    local func = Instance.new("RemoteFunction")
    func.Name = name
    func.Parent = ReplicatedStorage
    return func
end

-- Core events
local CoinCollected = createRemoteEvent("CoinCollected")
local StatsUpdated = createRemoteEvent("StatsUpdated")
local GetStats = createRemoteFunction("GetStats")

-- Upgrade events
local BuyClickPower = createRemoteEvent("BuyClickPower")
local BuyAutoClick = createRemoteEvent("BuyAutoClick")
local BuyLucky = createRemoteEvent("BuyLucky")
local BuySpeed = createRemoteEvent("BuySpeed")
local BuyUpgrade = createRemoteEvent("BuyUpgrade")

-- Rebirth
local DoRebirth = createRemoteEvent("DoRebirth")

-- Zones
local ChangeZone = createRemoteEvent("ChangeZone")

print("🎮 GameManager v2.0 loaded!")

-- ===== PLAYER HANDLERS =====

local function sendStats(player)
    local stats = PlayerData.GetAllStats(player)
    local rebirthStats = RebirthSystem.GetStats(player)
    if stats and rebirthStats then
        stats.Rebirths = rebirthStats.Rebirths
        stats.RebirthMultiplier = rebirthStats.RebirthMultiplier
        stats.NextRebirthCost = rebirthStats.NextRebirthCost
        StatsUpdated:FireClient(player, stats)
    end
end

Players.PlayerAdded:Connect(function(player)
    print("👋 Welcome " .. player.Name .. "!")
    
    -- Initialize all systems
    PlayerData.InitPlayer(player)
    RebirthSystem.InitPlayer(player)
    
    -- Send initial stats
    wait(1)
    sendStats(player)
    
    -- Check achievements
    wait(0.5)
    if _G.CheckAchievements then
        _G.CheckAchievements(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    -- Save data
    DataStoreManager.SaveData(player)
    PlayerData.RemovePlayer(player)
    RebirthSystem.RemovePlayer(player)
    print("💾 Saved data for " .. player.Name)
end)

-- ===== GET STATS =====
GetStats.OnServerInvoke = function(player)
    local stats = PlayerData.GetAllStats(player)
    local rebirthStats = RebirthSystem.GetStats(player)
    if stats and rebirthStats then
        stats.Rebirths = rebirthStats.Rebirths
        stats.RebirthMultiplier = rebirthStats.RebirthMultiplier
        stats.NextRebirthCost = rebirthStats.NextRebirthCost
    end
    return stats
end

-- ===== UPGRADE HANDLERS =====
BuyUpgrade.OnServerEvent:Connect(function(player)
    PlayerData.BuyUpgrade(player)
    sendStats(player)
    if _G.CheckAchievements then _G.CheckAchievements(player) end
end)

BuyClickPower.OnServerEvent:Connect(function(player)
    PlayerData.BuyClickPower(player)
    sendStats(player)
    if _G.CheckAchievements then _G.CheckAchievements(player) end
end)

BuyAutoClick.OnServerEvent:Connect(function(player)
    PlayerData.BuyAutoClick(player)
    sendStats(player)
    if _G.CheckAchievements then _G.CheckAchievements(player) end
end)

BuyLucky.OnServerEvent:Connect(function(player)
    PlayerData.BuyLucky(player)
    sendStats(player)
    if _G.CheckAchievements then _G.CheckAchievements(player) end
end)

BuySpeed.OnServerEvent:Connect(function(player)
    PlayerData.BuySpeed(player)
    sendStats(player)
    if _G.CheckAchievements then _G.CheckAchievements(player) end
end)

-- ===== REBIRTH HANDLER =====
DoRebirth.OnServerEvent:Connect(function(player)
    local coins = PlayerData.GetCoins(player)
    
    local success = RebirthSystem.TryRebirth(player, coins, function()
        PlayerData.ResetForRebirth(player)
    end)
    
    if success then
        print("🌟 " .. player.Name .. " REBIRTHED!")
    end
    
    sendStats(player)
    if _G.CheckAchievements then _G.CheckAchievements(player) end
end)

-- ===== ZONE HANDLER =====
ChangeZone.OnServerEvent:Connect(function(player, zoneId)
    local success = PlayerData.ChangeZone(player, zoneId)
    sendStats(player)
    if success and _G.CheckAchievements then
        _G.CheckAchievements(player)
    end
end)

-- ===== AUTO-CLICKER SYSTEM =====
spawn(function()
    while true do
        wait(1)
        
        for _, player in pairs(Players:GetPlayers()) do
            local autoRate = PlayerData.GetAutoClickRate(player)
            if autoRate > 0 then
                local clickPower = PlayerData.GetClickPower(player)
                local rebirthMult = RebirthSystem.GetMultiplier(player)
                local zoneMult = PlayerData.GetZoneMultiplier(player)
                local petBonus = PlayerData.GetPetBonus(player)
                
                local totalCoins = math.floor(autoRate * clickPower * rebirthMult * zoneMult * petBonus)
                
                PlayerData.AddCoins(player, totalCoins)
                sendStats(player)
            end
        end
    end
end)

print("🤖 Auto-Clicker system running!")

-- ===== GLOBAL GIVE COINS FUNCTION =====
_G.GiveCoins = function(player, baseAmount)
    local clickPower = PlayerData.GetClickPower(player)
    local rebirthMult = RebirthSystem.GetMultiplier(player)
    local zoneMult = PlayerData.GetZoneMultiplier(player)
    local petBonus = PlayerData.GetPetBonus(player)
    
    local totalCoins = math.floor(baseAmount * clickPower * rebirthMult * zoneMult * petBonus)
    
    PlayerData.AddCoins(player, totalCoins)
    PlayerData.IncrementClicks(player)
    
    CoinCollected:FireClient(player, totalCoins)
    sendStats(player)
    
    -- Check achievements occasionally
    if math.random(1, 10) == 1 and _G.CheckAchievements then
        _G.CheckAchievements(player)
    end
    
    return totalCoins
end

-- ===== AUTO-SAVE =====
spawn(function()
    while true do
        wait(120)  -- Save every 2 minutes
        for _, player in pairs(Players:GetPlayers()) do
            DataStoreManager.SaveData(player)
        end
        print("💾 Auto-save complete!")
    end
end)

-- ===== GAME SHUTDOWN SAVE =====
game:BindToClose(function()
    print("🛑 Game shutting down - saving all data...")
    for _, player in pairs(Players:GetPlayers()) do
        DataStoreManager.SaveData(player)
    end
    wait(2)
end)

print("✅ GameManager ready!")
