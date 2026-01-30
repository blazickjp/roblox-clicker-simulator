--[[
    AchievementsSystem - Unlock badges for doing cool stuff!
    
    🏆 Get achievements for:
    - Collecting coins
    - Hatching pets
    - Rebirthing
    - And more!
    
    Each achievement gives a reward!
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared folder
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)

local AchievementsConfig
local DataStoreManager
local PlayerData
local ZonesConfig

-- Load dependencies
local function loadDependencies()
    if not AchievementsConfig and SharedFolder then
        pcall(function()
            AchievementsConfig = require(SharedFolder:WaitForChild("AchievementsConfig", 5))
        end)
    end
    if not ZonesConfig and SharedFolder then
        pcall(function()
            ZonesConfig = require(SharedFolder:WaitForChild("ZonesConfig", 5))
        end)
    end
    if not DataStoreManager then
        pcall(function()
            DataStoreManager = require(script.Parent.DataStoreManager)
        end)
    end
    if not PlayerData then
        pcall(function()
            PlayerData = require(script.Parent.PlayerData)
        end)
    end
end

-- Create RemoteEvent for achievement popups
local AchievementUnlocked = Instance.new("RemoteEvent")
AchievementUnlocked.Name = "AchievementUnlocked"
AchievementUnlocked.Parent = ReplicatedStorage

-- Check if player meets requirement
local function meetsRequirement(player, data, requirement)
    loadDependencies()
    
    if requirement.type == "coins_collected" then
        return data.TotalCoinsEarned >= requirement.amount
        
    elseif requirement.type == "rebirths" then
        return data.Rebirths >= requirement.amount
        
    elseif requirement.type == "pets_owned" then
        return #data.Pets >= requirement.amount
        
    elseif requirement.type == "clicks" then
        return data.Clicks >= requirement.amount
        
    elseif requirement.type == "login_streak" then
        return data.LoginStreak >= requirement.amount
        
    elseif requirement.type == "rarity_hatched" then
        if requirement.rarity == "Rare" then
            return data.RaresHatched > 0
        elseif requirement.rarity == "Epic" then
            return data.EpicsHatched > 0
        elseif requirement.rarity == "Legendary" then
            return data.LegendariesHatched > 0
        end
        
    elseif requirement.type == "zone_unlocked" then
        if ZonesConfig then
            return ZonesConfig.IsUnlocked(requirement.zone, data.Rebirths)
        end
    end
    
    return false
end

-- Give reward
local function giveReward(player, data, reward)
    if reward.type == "coins" then
        data.Coins = data.Coins + reward.amount
        data.TotalCoinsEarned = data.TotalCoinsEarned + reward.amount
        print("🎁 Gave " .. player.Name .. " " .. reward.amount .. " coins for achievement!")
    elseif reward.type == "egg" then
        if _G.GiveEgg then
            _G.GiveEgg(player, reward.eggType or "Basic")
        end
    end
end

-- Check all achievements for a player
local function checkAchievements(player)
    loadDependencies()
    if not AchievementsConfig or not DataStoreManager then return end
    
    local data = DataStoreManager.GetData(player)
    if not data then return end
    
    for _, achievement in ipairs(AchievementsConfig.Achievements) do
        -- Skip if already unlocked
        local alreadyUnlocked = false
        for _, unlockedId in ipairs(data.UnlockedAchievements) do
            if unlockedId == achievement.id then
                alreadyUnlocked = true
                break
            end
        end
        
        if not alreadyUnlocked then
            -- Check if requirement is met
            if meetsRequirement(player, data, achievement.requirement) then
                -- Unlock it!
                table.insert(data.UnlockedAchievements, achievement.id)
                
                -- Give reward
                giveReward(player, data, achievement.reward)
                
                -- Tell the client!
                AchievementUnlocked:FireClient(player, achievement)
                
                print("🏆 " .. player.Name .. " unlocked: " .. achievement.name)
            end
        end
    end
end

-- Check achievements periodically and on events
local function setupPlayer(player)
    -- Check on join
    wait(2)
    checkAchievements(player)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in pairs(Players:GetPlayers()) do
    spawn(function() setupPlayer(player) end)
end

-- Global function to trigger achievement check
_G.CheckAchievements = function(player)
    checkAchievements(player)
end

-- Check every 5 seconds for all players
spawn(function()
    while true do
        wait(5)
        for _, player in pairs(Players:GetPlayers()) do
            checkAchievements(player)
        end
    end
end)

print("🏆 AchievementsSystem loaded!")
