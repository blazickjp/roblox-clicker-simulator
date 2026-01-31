--[[
    DailyRewardsGui - Login every day for rewards!
    
    📅 7-day calendar
    🎁 Better rewards each day
    🥚 Day 7 = FREE GOLDEN EGG!
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for shared config
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)
local DailyRewardsConfig
pcall(function()
    DailyRewardsConfig = require(SharedFolder:WaitForChild("DailyRewardsConfig", 5))
end)

-- Wait for events
local ClaimDailyReward = ReplicatedStorage:WaitForChild("ClaimDailyReward")
local DailyRewardClaimed = ReplicatedStorage:WaitForChild("DailyRewardClaimed")
local GetDailyRewardStatus = ReplicatedStorage:WaitForChild("GetDailyRewardStatus")

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DailyRewardsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "DailyPanel"
panel.Size = UDim2.new(0, 500, 0, 350)
panel.Position = UDim2.new(0.5, -250, 0.5, -175)
panel.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
panel.Visible = false
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(100, 200, 200)
stroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(100, 200, 200)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "📅 DAILY REWARDS 📅"
title.Parent = panel

-- Streak label
local streakLabel = Instance.new("TextLabel")
streakLabel.Size = UDim2.new(1, 0, 0, 30)
streakLabel.Position = UDim2.new(0, 0, 0, 45)
streakLabel.BackgroundTransparency = 1
streakLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
streakLabel.TextScaled = true
streakLabel.Font = Enum.Font.GothamBold
streakLabel.Text = "🔥 Current Streak: 0 days"
streakLabel.Parent = panel

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.Parent = panel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

closeBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

-- Day boxes container
local daysFrame = Instance.new("Frame")
daysFrame.Size = UDim2.new(1, -20, 0, 150)
daysFrame.Position = UDim2.new(0, 10, 0, 80)
daysFrame.BackgroundTransparency = 1
daysFrame.Parent = panel

local dayBoxes = {}
local boxWidth = 60
local boxSpacing = 8
local startX = (daysFrame.AbsoluteSize.X - (7 * boxWidth + 6 * boxSpacing)) / 2

for day = 1, 7 do
    local dayBox = Instance.new("Frame")
    dayBox.Name = "Day" .. day
    dayBox.Size = UDim2.new(0, boxWidth, 0, 130)
    dayBox.Position = UDim2.new(0, 10 + (day - 1) * (boxWidth + boxSpacing), 0, 10)
    dayBox.BackgroundColor3 = Color3.fromRGB(50, 60, 60)
    dayBox.Parent = daysFrame
    Instance.new("UICorner", dayBox).CornerRadius = UDim.new(0, 10)
    
    local dayLabel = Instance.new("TextLabel")
    dayLabel.Size = UDim2.new(1, 0, 0, 25)
    dayLabel.BackgroundTransparency = 1
    dayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    dayLabel.TextScaled = true
    dayLabel.Font = Enum.Font.GothamBold
    dayLabel.Text = "Day " .. day
    dayLabel.Parent = dayBox
    
    local rewardEmoji = Instance.new("TextLabel")
    rewardEmoji.Name = "Emoji"
    rewardEmoji.Size = UDim2.new(1, 0, 0, 50)
    rewardEmoji.Position = UDim2.new(0, 0, 0, 25)
    rewardEmoji.BackgroundTransparency = 1
    rewardEmoji.TextColor3 = Color3.fromRGB(255, 255, 255)
    rewardEmoji.TextScaled = true
    rewardEmoji.Font = Enum.Font.GothamBold
    rewardEmoji.Text = day == 7 and "🥚✨" or "🎁"
    rewardEmoji.Parent = dayBox
    
    local rewardText = Instance.new("TextLabel")
    rewardText.Name = "RewardText"
    rewardText.Size = UDim2.new(1, -4, 0, 35)
    rewardText.Position = UDim2.new(0, 2, 0, 75)
    rewardText.BackgroundTransparency = 1
    rewardText.TextColor3 = Color3.fromRGB(255, 215, 0)
    rewardText.TextScaled = true
    rewardText.Font = Enum.Font.Gotham
    rewardText.TextWrapped = true
    rewardText.Text = ""
    rewardText.Parent = dayBox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 0, 20)
    checkmark.Position = UDim2.new(0, 0, 1, -20)
    checkmark.BackgroundTransparency = 1
    checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
    checkmark.TextScaled = true
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Text = ""
    checkmark.Parent = dayBox
    
    dayBoxes[day] = dayBox
end

-- Claim button
local claimBtn = Instance.new("TextButton")
claimBtn.Size = UDim2.new(0.8, 0, 0, 60)
claimBtn.Position = UDim2.new(0.1, 0, 0, 270)
claimBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
claimBtn.TextScaled = true
claimBtn.Font = Enum.Font.GothamBold
claimBtn.Text = "🎁 CLAIM TODAY'S REWARD! 🎁"
claimBtn.Parent = panel
Instance.new("UICorner", claimBtn).CornerRadius = UDim.new(0, 15)

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, 0, 0, 25)
resultLabel.Position = UDim2.new(0, 0, 1, -55)
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
resultLabel.TextScaled = true
resultLabel.Font = Enum.Font.GothamBold
resultLabel.Text = ""
resultLabel.Parent = panel

-- Hint text for kids (explain the streak system!)
local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, -20, 0, 20)
hintLabel.Position = UDim2.new(0, 10, 1, -28)
hintLabel.BackgroundTransparency = 1
hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
hintLabel.TextScaled = true
hintLabel.Font = Enum.Font.Gotham
hintLabel.Text = "💡 Come back every day! Miss a day = streak resets to Day 1"
hintLabel.Parent = panel

local canClaim = true
local currentStatus = nil

local function updateDisplay()
    if not DailyRewardsConfig then return end
    
    local currentDay = currentStatus and ((currentStatus.streak - 1) % 7 + 1) or 1
    local hasClaimedToday = currentStatus and currentStatus.claimedToday or false
    
    streakLabel.Text = "🔥 Current Streak: " .. (currentStatus and currentStatus.streak or 0) .. " days"
    
    for day = 1, 7 do
        local box = dayBoxes[day]
        local reward = DailyRewardsConfig.Rewards[day]
        
        -- Update reward text
        local rewardText = box:FindFirstChild("RewardText")
        if rewardText and reward then
            if reward.reward.type == "coins" then
                rewardText.Text = reward.reward.amount .. " coins"
            else
                rewardText.Text = "GOLDEN EGG!"
            end
        end
        
        -- Update visual state
        local checkmark = box:FindFirstChild("Checkmark")
        
        if day < currentDay then
            -- Past day (completed)
            box.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
            if checkmark then checkmark.Text = "✅" end
        elseif day == currentDay then
            -- Current day
            if hasClaimedToday then
                box.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
                if checkmark then checkmark.Text = "✅" end
            else
                box.BackgroundColor3 = Color3.fromRGB(80, 100, 80)
                if checkmark then checkmark.Text = "👈 TODAY" end
                -- Add glow
                local existingStroke = box:FindFirstChildOfClass("UIStroke")
                if not existingStroke then
                    local s = Instance.new("UIStroke", box)
                    s.Color = Color3.fromRGB(255, 215, 0)
                    s.Thickness = 3
                end
            end
        else
            -- Future day
            box.BackgroundColor3 = Color3.fromRGB(50, 60, 60)
            if checkmark then checkmark.Text = "" end
            local existingStroke = box:FindFirstChildOfClass("UIStroke")
            if existingStroke then existingStroke:Destroy() end
        end
    end
    
    -- Update claim button
    if hasClaimedToday then
        claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        claimBtn.Text = "✅ Already claimed today!"
        canClaim = false
    else
        claimBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        claimBtn.Text = "🎁 CLAIM TODAY'S REWARD! 🎁"
        canClaim = true
    end
end

-- Claim handler
claimBtn.MouseButton1Click:Connect(function()
    if not canClaim then return end
    
    canClaim = false
    claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    claimBtn.Text = "⏳ Claiming..."
    
    ClaimDailyReward:FireServer()
end)

-- Claim result
DailyRewardClaimed.OnClientEvent:Connect(function(success, message, rewardInfo)
    if success then
        resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        resultLabel.Text = "✅ " .. message
        
        -- Refresh status
        currentStatus = GetDailyRewardStatus:InvokeServer()
        updateDisplay()
        
        -- Celebration animation
        TweenService:Create(claimBtn, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
            Size = claimBtn.Size + UDim2.new(0, 20, 0, 10)
        }):Play()
        wait(0.2)
        TweenService:Create(claimBtn, TweenInfo.new(0.1), {Size = UDim2.new(0.8, 0, 0, 60)}):Play()
    else
        resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        resultLabel.Text = "❌ " .. message
        canClaim = true
        claimBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        claimBtn.Text = "🎁 CLAIM TODAY'S REWARD! 🎁"
    end
end)

-- Auto-show on login if reward available
spawn(function()
    wait(3)
    currentStatus = GetDailyRewardStatus:InvokeServer()
    if currentStatus then
        updateDisplay()
        -- Auto-open if can claim
        if currentStatus.canClaim and not currentStatus.claimedToday then
            panel.Visible = true
        end
    end
end)

-- Update when panel opens
panel:GetPropertyChangedSignal("Visible"):Connect(function()
    if panel.Visible then
        currentStatus = GetDailyRewardStatus:InvokeServer()
        updateDisplay()
    end
end)

print("📅 DailyRewardsGui loaded!")
