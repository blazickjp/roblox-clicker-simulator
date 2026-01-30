--[[
    DailyRewardsSystem - Login every day for rewards!
    
    📅 7-day streak calendar
    🎁 Better rewards each day
    🥚 Day 7 = FREE GOLDEN EGG!
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared folder
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)

local DailyRewardsConfig
local DataStoreManager
local PlayerData

-- Load dependencies
local function loadDependencies()
    if not DailyRewardsConfig and SharedFolder then
        pcall(function()
            DailyRewardsConfig = require(SharedFolder:WaitForChild("DailyRewardsConfig", 5))
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

-- Create RemoteEvents
local ClaimDailyReward = Instance.new("RemoteEvent")
ClaimDailyReward.Name = "ClaimDailyReward"
ClaimDailyReward.Parent = ReplicatedStorage

local DailyRewardClaimed = Instance.new("RemoteEvent")
DailyRewardClaimed.Name = "DailyRewardClaimed"
DailyRewardClaimed.Parent = ReplicatedStorage

local GetDailyRewardStatus = Instance.new("RemoteFunction")
GetDailyRewardStatus.Name = "GetDailyRewardStatus"
GetDailyRewardStatus.Parent = ReplicatedStorage

-- Track who claimed today (to prevent double claims in same session)
local claimedToday = {}

-- Get daily reward status
GetDailyRewardStatus.OnServerInvoke = function(player)
    loadDependencies()
    if not DataStoreManager or not DailyRewardsConfig then return nil end
    
    local data = DataStoreManager.GetData(player)
    if not data then return nil end
    
    local today = math.floor(os.time() / 86400)
    local canClaim = (data.LastLoginDay == today) and not claimedToday[player.UserId]
    
    -- Get current reward info
    local rewardInfo = DailyRewardsConfig.GetReward(data.LoginStreak)
    
    return {
        canClaim = canClaim,
        streak = data.LoginStreak,
        currentReward = rewardInfo,
        claimedToday = claimedToday[player.UserId] or false,
    }
end

-- Claim daily reward
ClaimDailyReward.OnServerEvent:Connect(function(player)
    loadDependencies()
    if not DataStoreManager or not DailyRewardsConfig then return end
    
    local data = DataStoreManager.GetData(player)
    if not data then return end
    
    -- Check if already claimed today
    if claimedToday[player.UserId] then
        DailyRewardClaimed:FireClient(player, false, "Already claimed today!")
        return
    end
    
    -- Get reward
    local rewardInfo = DailyRewardsConfig.GetReward(data.LoginStreak)
    if not rewardInfo then return end
    
    -- Give reward
    local rewardText = ""
    if rewardInfo.reward.type == "coins" then
        data.Coins = data.Coins + rewardInfo.reward.amount
        data.TotalCoinsEarned = data.TotalCoinsEarned + rewardInfo.reward.amount
        rewardText = "+" .. rewardInfo.reward.amount .. " Coins! 💰"
        
    elseif rewardInfo.reward.type == "egg" then
        if _G.GiveEgg then
            local pet = _G.GiveEgg(player, rewardInfo.reward.eggType or "Basic")
            if pet then
                rewardText = "FREE " .. (rewardInfo.reward.eggType or "Basic") .. " EGG! You got: " .. pet.name .. "! 🐣"
            end
        end
    end
    
    -- Mark as claimed
    claimedToday[player.UserId] = true
    
    print("📅 " .. player.Name .. " claimed Day " .. rewardInfo.day .. " reward! (Streak: " .. data.LoginStreak .. ")")
    
    DailyRewardClaimed:FireClient(player, true, rewardText, rewardInfo)
    
    -- Update stats
    local StatsUpdated = ReplicatedStorage:FindFirstChild("StatsUpdated")
    if StatsUpdated and PlayerData then
        local stats = PlayerData.GetAllStats(player)
        if stats then
            StatsUpdated:FireClient(player, stats)
        end
    end
    
    -- Check achievements
    if _G.CheckAchievements then
        _G.CheckAchievements(player)
    end
end)

-- Clear claimed status at midnight (server time)
spawn(function()
    while true do
        wait(60)
        local now = os.time()
        local currentDay = math.floor(now / 86400)
        local nextMidnight = (currentDay + 1) * 86400
        local timeUntilMidnight = nextMidnight - now
        
        if timeUntilMidnight <= 60 then
            -- About to be midnight, wait and reset
            wait(timeUntilMidnight + 1)
            claimedToday = {}
            print("📅 Daily rewards reset for new day!")
        end
    end
end)

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
    claimedToday[player.UserId] = nil
end)

print("📅 DailyRewardsSystem loaded!")
