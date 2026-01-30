--[[
    CodesSystem - Redeem codes for FREE STUFF!
    
    🎫 Enter a code
    🎁 Get free coins or eggs!
    
    Codes are configured in shared/CodesConfig.lua
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared folder
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)

local CodesConfig
local DataStoreManager

-- Load dependencies
local function loadDependencies()
    if not CodesConfig and SharedFolder then
        pcall(function()
            CodesConfig = require(SharedFolder:WaitForChild("CodesConfig", 5))
        end)
    end
    if not DataStoreManager then
        pcall(function()
            DataStoreManager = require(script.Parent.DataStoreManager)
        end)
    end
end

-- Create RemoteEvents
local RedeemCode = Instance.new("RemoteEvent")
RedeemCode.Name = "RedeemCode"
RedeemCode.Parent = ReplicatedStorage

local CodeResult = Instance.new("RemoteEvent")
CodeResult.Name = "CodeResult"
CodeResult.Parent = ReplicatedStorage

-- Redeem a code
RedeemCode.OnServerEvent:Connect(function(player, codeInput)
    loadDependencies()
    if not CodesConfig or not DataStoreManager then 
        CodeResult:FireClient(player, false, "System error. Try again!")
        return 
    end
    
    local code = string.upper(codeInput)
    local codeData = CodesConfig.GetCode(code)
    
    -- Check if code exists
    if not codeData then
        CodeResult:FireClient(player, false, "Invalid code! 😢")
        return
    end
    
    -- Check if expired
    if CodesConfig.IsExpired(code) then
        CodeResult:FireClient(player, false, "This code has expired! 😢")
        return
    end
    
    local data = DataStoreManager.GetData(player)
    if not data then
        CodeResult:FireClient(player, false, "System error. Try again!")
        return
    end
    
    -- Check if already redeemed
    if codeData.oneTime then
        for _, redeemedCode in ipairs(data.RedeemedCodes) do
            if redeemedCode == code then
                CodeResult:FireClient(player, false, "You already used this code!")
                return
            end
        end
    end
    
    -- Redeem it!
    table.insert(data.RedeemedCodes, code)
    
    -- Give reward
    local reward = codeData.reward
    local rewardText = ""
    
    if reward.type == "coins" then
        data.Coins = data.Coins + reward.amount
        data.TotalCoinsEarned = data.TotalCoinsEarned + reward.amount
        rewardText = "+" .. reward.amount .. " Coins! 💰"
        
    elseif reward.type == "egg" then
        if _G.GiveEgg then
            local pet = _G.GiveEgg(player, reward.eggType or "Basic")
            if pet then
                rewardText = "Free " .. reward.eggType .. " Egg! You got: " .. pet.name .. "! 🐣"
            else
                rewardText = "Free Egg! 🥚"
            end
        else
            rewardText = "Free Egg! 🥚"
        end
    end
    
    print("🎫 " .. player.Name .. " redeemed code: " .. code)
    CodeResult:FireClient(player, true, rewardText)
    
    -- Update stats
    local StatsUpdated = ReplicatedStorage:FindFirstChild("StatsUpdated")
    local PlayerData = require(script.Parent.PlayerData)
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

print("🎫 CodesSystem loaded!")
