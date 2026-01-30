--[[
    MainGui - The main game interface!
    
    Shows:
    💰 Coins display
    🛒 Shop button
    🐾 Pets button
    🌍 Zones button
    🏆 Achievements button
    🎫 Codes button
    📅 Daily Rewards button
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for events
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local CoinCollected = ReplicatedStorage:WaitForChild("CoinCollected")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")

-- Current stats
local currentStats = { Coins = 0 }

-- ===== MAIN SCREEN GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ===== HELPER FUNCTIONS =====
local function formatNumber(num)
    if num >= 1000000000 then
        return string.format("%.1fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    end
    return tostring(math.floor(num))
end

local function createButton(name, emoji, color, position, size)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = size or UDim2.new(0, 70, 0, 70)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Text = emoji
    btn.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = (size or UDim2.new(0, 70, 0, 70)) + UDim2.new(0, 10, 0, 10)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = size or UDim2.new(0, 70, 0, 70)}):Play()
    end)
    
    return btn
end

-- ===== COINS DISPLAY =====
local coinFrame = Instance.new("Frame")
coinFrame.Name = "CoinFrame"
coinFrame.Size = UDim2.new(0, 250, 0, 70)
coinFrame.Position = UDim2.new(0.5, -125, 0, 15)
coinFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
coinFrame.BackgroundTransparency = 0.2
coinFrame.Parent = screenGui

local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 20)
coinCorner.Parent = coinFrame

local coinStroke = Instance.new("UIStroke")
coinStroke.Color = Color3.fromRGB(255, 215, 0)
coinStroke.Thickness = 3
coinStroke.Parent = coinFrame

local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinLabel"
coinLabel.Size = UDim2.new(1, -20, 1, 0)
coinLabel.Position = UDim2.new(0, 10, 0, 0)
coinLabel.BackgroundTransparency = 1
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextScaled = true
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Text = "💰 0"
coinLabel.Parent = coinFrame

-- ===== STATS DISPLAY =====
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(0, 200, 0, 100)
statsFrame.Position = UDim2.new(0, 15, 0, 15)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statsFrame.BackgroundTransparency = 0.3
statsFrame.Parent = screenGui

Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 15)

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, -10, 1, -10)
statsLabel.Position = UDim2.new(0, 5, 0, 5)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.Text = "⚡ 1x Power\n🤖 0/s Auto\n🌟 0 Rebirths"
statsLabel.Parent = statsFrame

-- ===== MENU BUTTONS (Right side) =====
local buttonY = 120
local buttonSpacing = 80

local shopBtn = createButton("Shop", "🛒", Color3.fromRGB(100, 180, 100), UDim2.new(1, -85, 0, buttonY))
buttonY = buttonY + buttonSpacing

local petsBtn = createButton("Pets", "🐾", Color3.fromRGB(200, 150, 100), UDim2.new(1, -85, 0, buttonY))
buttonY = buttonY + buttonSpacing

local zonesBtn = createButton("Zones", "🌍", Color3.fromRGB(100, 150, 200), UDim2.new(1, -85, 0, buttonY))
buttonY = buttonY + buttonSpacing

local achievementsBtn = createButton("Achievements", "🏆", Color3.fromRGB(255, 200, 50), UDim2.new(1, -85, 0, buttonY))
buttonY = buttonY + buttonSpacing

local codesBtn = createButton("Codes", "🎫", Color3.fromRGB(200, 100, 200), UDim2.new(1, -85, 0, buttonY))
buttonY = buttonY + buttonSpacing

local dailyBtn = createButton("Daily", "📅", Color3.fromRGB(100, 200, 200), UDim2.new(1, -85, 0, buttonY))

-- ===== UPDATE DISPLAY =====
local function updateDisplay(stats)
    if not stats then return end
    currentStats = stats
    
    coinLabel.Text = "💰 " .. formatNumber(stats.Coins)
    
    local powerText = "⚡ " .. formatNumber(stats.ClickPower or 1) .. "x Power"
    local autoText = "🤖 " .. formatNumber(stats.AutoClickRate or 0) .. "/s Auto"
    local rebirthText = "🌟 " .. (stats.Rebirths or 0) .. " Rebirths"
    local petText = "🐾 " .. string.format("%.1fx", stats.PetBonus or 1) .. " Pet Bonus"
    
    statsLabel.Text = powerText .. "\n" .. autoText .. "\n" .. rebirthText .. "\n" .. petText
end

-- ===== COIN COLLECTED ANIMATION =====
CoinCollected.OnClientEvent:Connect(function(amount)
    -- Bounce the coin display
    local originalSize = coinFrame.Size
    TweenService:Create(coinFrame, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {
        Size = originalSize + UDim2.new(0, 20, 0, 10)
    }):Play()
    
    wait(0.1)
    TweenService:Create(coinFrame, TweenInfo.new(0.1), {Size = originalSize}):Play()
    
    -- Flash gold
    local originalColor = coinStroke.Color
    coinStroke.Color = Color3.fromRGB(255, 255, 150)
    wait(0.15)
    coinStroke.Color = originalColor
end)

-- ===== STATS UPDATE =====
StatsUpdated.OnClientEvent:Connect(function(stats)
    updateDisplay(stats)
end)

-- ===== BUTTON CLICKS =====
-- These will open other GUIs (which are separate scripts)
shopBtn.MouseButton1Click:Connect(function()
    local shopGui = playerGui:FindFirstChild("ShopGui")
    if shopGui then
        local panel = shopGui:FindFirstChild("ShopPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)

petsBtn.MouseButton1Click:Connect(function()
    local petsGui = playerGui:FindFirstChild("PetsGui")
    if petsGui then
        local panel = petsGui:FindFirstChild("PetsPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)

zonesBtn.MouseButton1Click:Connect(function()
    local zonesGui = playerGui:FindFirstChild("ZonesGui")
    if zonesGui then
        local panel = zonesGui:FindFirstChild("ZonesPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)

achievementsBtn.MouseButton1Click:Connect(function()
    local achGui = playerGui:FindFirstChild("AchievementsGui")
    if achGui then
        local panel = achGui:FindFirstChild("AchievementsPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)

codesBtn.MouseButton1Click:Connect(function()
    local codesGui = playerGui:FindFirstChild("CodesGui")
    if codesGui then
        local panel = codesGui:FindFirstChild("CodesPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)

dailyBtn.MouseButton1Click:Connect(function()
    local dailyGui = playerGui:FindFirstChild("DailyRewardsGui")
    if dailyGui then
        local panel = dailyGui:FindFirstChild("DailyPanel")
        if panel then panel.Visible = not panel.Visible end
    end
end)

-- ===== INITIAL LOAD =====
wait(1)
local initialStats = GetStats:InvokeServer()
updateDisplay(initialStats)

print("✅ MainGui loaded!")
