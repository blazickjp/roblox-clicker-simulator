--[[
    AchievementsGui - Track your progress!
    
    🏆 See all achievements
    ✅ Check which ones you've unlocked
    🎁 Get rewards for completing them!
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for shared config
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)
local AchievementsConfig
pcall(function()
    AchievementsConfig = require(SharedFolder:WaitForChild("AchievementsConfig", 5))
end)

-- Wait for events
local AchievementUnlocked = ReplicatedStorage:WaitForChild("AchievementUnlocked")
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")

local currentStats = { UnlockedAchievements = {} }

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AchievementsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "AchievementsPanel"
panel.Size = UDim2.new(0, 450, 0, 500)
panel.Position = UDim2.new(0.5, -225, 0.5, -250)
panel.BackgroundColor3 = Color3.fromRGB(50, 45, 30)
panel.Visible = false
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(255, 200, 50)
stroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "🏆 ACHIEVEMENTS 🏆"
title.Parent = panel

-- Counter
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 0, 25)
counterLabel.Position = UDim2.new(0, 0, 0, 45)
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
counterLabel.TextScaled = true
counterLabel.Font = Enum.Font.Gotham
counterLabel.Text = "0 / 0 Completed"
counterLabel.Parent = panel

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

-- Scrolling frame for achievements
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -85)
scroll.Position = UDim2.new(0, 10, 0, 75)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scroll

local function updateAchievements()
    -- Clear existing
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not AchievementsConfig then return end
    
    local unlockedCount = 0
    local totalCount = #AchievementsConfig.Achievements
    
    for _, achievement in ipairs(AchievementsConfig.Achievements) do
        local isUnlocked = false
        if currentStats.UnlockedAchievements then
            for _, id in ipairs(currentStats.UnlockedAchievements) do
                if id == achievement.id then
                    isUnlocked = true
                    unlockedCount = unlockedCount + 1
                    break
                end
            end
        end
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 60)
        frame.BackgroundColor3 = isUnlocked and Color3.fromRGB(80, 100, 60) or Color3.fromRGB(50, 50, 50)
        frame.Parent = scroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
        local emoji = Instance.new("TextLabel")
        emoji.Size = UDim2.new(0, 50, 1, 0)
        emoji.BackgroundTransparency = 1
        emoji.TextColor3 = Color3.fromRGB(255, 255, 255)
        emoji.TextScaled = true
        emoji.Font = Enum.Font.GothamBold
        emoji.Text = isUnlocked and achievement.emoji or "🔒"
        emoji.Parent = frame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.7, -60, 0, 25)
        nameLabel.Position = UDim2.new(0, 55, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = isUnlocked and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Text = achievement.name
        nameLabel.Parent = frame
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(0.7, -60, 0, 20)
        descLabel.Position = UDim2.new(0, 55, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Text = achievement.description
        descLabel.Parent = frame
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0, 60, 0, 30)
        status.Position = UDim2.new(1, -65, 0.5, -15)
        status.BackgroundTransparency = 1
        status.TextColor3 = isUnlocked and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        status.TextScaled = true
        status.Font = Enum.Font.GothamBold
        status.Text = isUnlocked and "✅" or "❌"
        status.Parent = frame
    end
    
    counterLabel.Text = unlockedCount .. " / " .. totalCount .. " Completed"
    scroll.CanvasSize = UDim2.new(0, 0, 0, totalCount * 68)
end

-- ===== ACHIEVEMENT POPUP =====
local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 350, 0, 100)
popup.Position = UDim2.new(0.5, -175, 0, -120)
popup.BackgroundColor3 = Color3.fromRGB(50, 50, 30)
popup.Visible = false
popup.ZIndex = 20
popup.Parent = screenGui

Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 15)
local popupStroke = Instance.new("UIStroke", popup)
popupStroke.Color = Color3.fromRGB(255, 215, 0)
popupStroke.Thickness = 3

local popupText = Instance.new("TextLabel")
popupText.Size = UDim2.new(1, -20, 1, -10)
popupText.Position = UDim2.new(0, 10, 0, 5)
popupText.BackgroundTransparency = 1
popupText.TextColor3 = Color3.fromRGB(255, 215, 0)
popupText.TextScaled = true
popupText.Font = Enum.Font.GothamBold
popupText.Text = ""
popupText.ZIndex = 21
popupText.Parent = popup

local function showAchievementPopup(achievement)
    popupText.Text = "🏆 ACHIEVEMENT UNLOCKED! 🏆\n" .. achievement.emoji .. " " .. achievement.name
    popup.Visible = true
    
    -- Start small and off-screen
    popup.Size = UDim2.new(0, 50, 0, 20)
    popup.Position = UDim2.new(0.5, -25, 0.5, -10)
    popupStroke.Thickness = 1
    
    -- BOOM! Scale up with bounce (feels like an explosion!)
    TweenService:Create(popup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 350, 0, 100),
        Position = UDim2.new(0.5, -175, 0, 20)
    }):Play()
    
    TweenService:Create(popupStroke, TweenInfo.new(0.4), {
        Thickness = 3
    }):Play()
    
    wait(0.4)
    
    -- Golden pulse effect (3 pulses)
    for i = 1, 3 do
        TweenService:Create(popupStroke, TweenInfo.new(0.15), {
            Thickness = 6,
            Color = Color3.fromRGB(255, 255, 150)
        }):Play()
        wait(0.15)
        TweenService:Create(popupStroke, TweenInfo.new(0.15), {
            Thickness = 3,
            Color = Color3.fromRGB(255, 215, 0)
        }):Play()
        wait(0.15)
    end
    
    wait(2)  -- Show for 2 more seconds
    
    -- Shrink and fade out (satisfying!)
    TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(0.5, -25, 0, -50)
    }):Play()
    
    wait(0.3)
    popup.Visible = false
    
    -- Reset for next time
    popup.Size = UDim2.new(0, 350, 0, 100)
    popupStroke.Thickness = 3
end

-- Events
AchievementUnlocked.OnClientEvent:Connect(function(achievement)
    showAchievementPopup(achievement)
    -- Refresh list if panel is open
    if panel.Visible then
        updateAchievements()
    end
end)

StatsUpdated.OnClientEvent:Connect(function(stats)
    currentStats = stats
    if panel.Visible then
        updateAchievements()
    end
end)

-- Open panel handler
panel:GetPropertyChangedSignal("Visible"):Connect(function()
    if panel.Visible then
        updateAchievements()
    end
end)

-- Initial load
wait(2)
local initialStats = GetStats:InvokeServer()
if initialStats then
    currentStats = initialStats
end

print("🏆 AchievementsGui loaded!")
