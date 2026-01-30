--[[
    GameManager Script
    ==================
    This is the MAIN script that runs the game!
    It handles:
    - Players joining and leaving
    - Communication between server and players
    
    Put this in: ServerScriptService
    Type: Script (not LocalScript!)
]]

-- Get the services we need
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get our modules
local PlayerData = require(script.Parent.PlayerData)
local RebirthSystem = require(script.Parent.RebirthSystem)

-- Create RemoteEvents for talking to players
-- (These let the server and client communicate!)
local function createRemoteEvent(name)
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = ReplicatedStorage
    return event
end

local function createRemoteFunction(name)
    local func = Instance.new("RemoteFunction")
    func.Name = name
    func.Parent = ReplicatedStorage
    return func
end

-- Create our events
local CoinCollected = createRemoteEvent("CoinCollected")      -- Tell player they got coins
local StatsUpdated = createRemoteEvent("StatsUpdated")        -- Update player's UI
local BuyUpgrade = createRemoteEvent("BuyUpgrade")            -- Player wants to buy upgrade
local GetStats = createRemoteFunction("GetStats")              -- Player asks for their stats

print("🎮 GameManager loaded!")

-- When a player joins
Players.PlayerAdded:Connect(function(player)
    print("👋 Welcome " .. player.Name .. "!")
    
    -- Set up their data
    PlayerData.InitPlayer(player)
    RebirthSystem.InitPlayer(player)
    
    -- Send them their starting stats
    wait(1)  -- Small delay to let everything load
    local stats = PlayerData.GetAllStats(player)
    local rebirthStats = RebirthSystem.GetStats(player)
    if stats and rebirthStats then
        -- Merge rebirth stats
        stats.Rebirths = rebirthStats.Rebirths
        stats.RebirthMultiplier = rebirthStats.RebirthMultiplier
        stats.NextRebirthCost = rebirthStats.NextRebirthCost
        StatsUpdated:FireClient(player, stats)
    end
end)

-- When a player leaves
Players.PlayerRemoving:Connect(function(player)
    PlayerData.RemovePlayer(player)
    RebirthSystem.RemovePlayer(player)
end)

-- When a player wants their stats
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

-- When a player wants to buy an upgrade (legacy - buys click power)
BuyUpgrade.OnServerEvent:Connect(function(player)
    local success = PlayerData.BuyUpgrade(player)
    
    -- Send updated stats to the player
    local stats = PlayerData.GetAllStats(player)
    if stats then
        StatsUpdated:FireClient(player, stats)
    end
end)

-- Create events for new upgrade types
local BuyClickPower = createRemoteEvent("BuyClickPower")
local BuyAutoClick = createRemoteEvent("BuyAutoClick")
local BuyLucky = createRemoteEvent("BuyLucky")
local BuySpeed = createRemoteEvent("BuySpeed")

BuyClickPower.OnServerEvent:Connect(function(player)
    PlayerData.BuyClickPower(player)
    local stats = PlayerData.GetAllStats(player)
    if stats then StatsUpdated:FireClient(player, stats) end
end)

BuyAutoClick.OnServerEvent:Connect(function(player)
    PlayerData.BuyAutoClick(player)
    local stats = PlayerData.GetAllStats(player)
    if stats then StatsUpdated:FireClient(player, stats) end
end)

BuyLucky.OnServerEvent:Connect(function(player)
    PlayerData.BuyLucky(player)
    local stats = PlayerData.GetAllStats(player)
    if stats then StatsUpdated:FireClient(player, stats) end
end)

BuySpeed.OnServerEvent:Connect(function(player)
    PlayerData.BuySpeed(player)
    local stats = PlayerData.GetAllStats(player)
    if stats then StatsUpdated:FireClient(player, stats) end
end)

-- ===== AUTO-CLICKER SYSTEM =====
-- Every second, give coins to players with auto-clicker upgrades!
spawn(function()
    while true do
        wait(1)  -- Every 1 second
        
        for _, player in pairs(Players:GetPlayers()) do
            local autoRate = PlayerData.GetAutoClickRate(player)
            if autoRate > 0 then
                -- Apply click power AND rebirth multiplier to auto-clicks!
                local clickPower = PlayerData.GetClickPower(player)
                local rebirthMult = RebirthSystem.GetMultiplier(player)
                local totalCoins = math.floor(autoRate * clickPower * rebirthMult)
                
                PlayerData.AddCoins(player, totalCoins)
                
                -- Update UI (include rebirth stats)
                local stats = PlayerData.GetAllStats(player)
                local rebirthStats = RebirthSystem.GetStats(player)
                if stats and rebirthStats then
                    stats.Rebirths = rebirthStats.Rebirths
                    stats.RebirthMultiplier = rebirthStats.RebirthMultiplier
                    stats.NextRebirthCost = rebirthStats.NextRebirthCost
                    StatsUpdated:FireClient(player, stats)
                end
            end
        end
    end
end)

print("🤖 Auto-Clicker system running!")

-- ===== REBIRTH SYSTEM =====
local DoRebirth = createRemoteEvent("DoRebirth")

DoRebirth.OnServerEvent:Connect(function(player)
    local coins = PlayerData.GetCoins(player)
    
    local success = RebirthSystem.TryRebirth(player, coins, function()
        PlayerData.ResetForRebirth(player)
    end)
    
    if success then
        print("🌟 " .. player.Name .. " REBIRTHED!")
    end
    
    -- Send updated stats
    local stats = PlayerData.GetAllStats(player)
    local rebirthStats = RebirthSystem.GetStats(player)
    if stats and rebirthStats then
        stats.Rebirths = rebirthStats.Rebirths
        stats.RebirthMultiplier = rebirthStats.RebirthMultiplier
        stats.NextRebirthCost = rebirthStats.NextRebirthCost
    end
    StatsUpdated:FireClient(player, stats)
end)

print("🌟 Rebirth system ready!")

-- Function other scripts can call to give coins
-- This is how CoinPad.lua will add coins!
_G.GiveCoins = function(player, amount)
    local clickPower = PlayerData.GetClickPower(player)
    local rebirthMult = RebirthSystem.GetMultiplier(player)
    local totalCoins = math.floor(amount * clickPower * rebirthMult)
    
    PlayerData.AddCoins(player, totalCoins)
    
    -- Tell the player they got coins (for sound/visual effects)
    CoinCollected:FireClient(player, totalCoins)
    
    -- Update their stats display (include rebirth stats)
    local stats = PlayerData.GetAllStats(player)
    local rebirthStats = RebirthSystem.GetStats(player)
    if stats and rebirthStats then
        stats.Rebirths = rebirthStats.Rebirths
        stats.RebirthMultiplier = rebirthStats.RebirthMultiplier
        stats.NextRebirthCost = rebirthStats.NextRebirthCost
        StatsUpdated:FireClient(player, stats)
    end
    
    return totalCoins
end

print("✅ GameManager ready!")
