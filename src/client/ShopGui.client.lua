--[[
    ShopGui Script (v2.0)
    =====================
    Now with MULTIPLE UPGRADES and REBIRTH!
    
    UPGRADES:
    ⚡ Click Power - More coins per click!
    🤖 Auto-Clicker - Earn coins automatically!
    🍀 Lucky Bonus - Chance for DOUBLE coins!
    🏃 Super Speed - Click faster!
    
    🌟 REBIRTH - Reset everything but get a permanent multiplier!
    
    HOW TO SET UP:
    1. In StarterGui, create a ScreenGui named "ShopGui"
    2. Put this script INSIDE the ShopGui (Insert → LocalScript)
]]

local screenGui = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for RemoteEvents
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")
local BuyClickPower = ReplicatedStorage:WaitForChild("BuyClickPower")
local BuyAutoClick = ReplicatedStorage:WaitForChild("BuyAutoClick")
local BuyLucky = ReplicatedStorage:WaitForChild("BuyLucky")
local BuySpeed = ReplicatedStorage:WaitForChild("BuySpeed")
local DoRebirth = ReplicatedStorage:WaitForChild("DoRebirth")

-- Current stats
local currentStats = {
    Coins = 0,
    ClickPower = 1,
    AutoClickRate = 0,
    LuckyChance = 0,
    Cooldown = 0.5,
    UpgradeCosts = {
        ClickPower = 50,
        AutoClick = 200,
        Lucky = 300,
        Speed = 400
    },
    Rebirths = 0,
    RebirthMultiplier = 1,
    NextRebirthCost = 10000
}

-- ===== SHOP BUTTON =====
local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 120, 0, 50)
shopButton.Position = UDim2.new(1, -140, 0.5, -25)
shopButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
shopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shopButton.TextScaled = true
shopButton.Font = Enum.Font.GothamBold
shopButton.Text = "🛒 SHOP"
shopButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = shopButton

-- ===== MAIN SHOP PANEL =====
local shopPanel = Instance.new("Frame")
shopPanel.Name = "ShopPanel"
shopPanel.Size = UDim2.new(0, 420, 0, 520)
shopPanel.Position = UDim2.new(0.5, -210, 0.5, -260)
shopPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
shopPanel.Visible = false
shopPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 15)
panelCorner.Parent = shopPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 215, 0)
panelStroke.Thickness = 2
panelStroke.Parent = shopPanel

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "🛒 UPGRADE SHOP 🛒"
title.Parent = shopPanel

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.Parent = shopPanel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Stats display
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -20, 0, 60)
statsLabel.Position = UDim2.new(0, 10, 0, 45)
statsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.Text = "💰 0 coins | 🌟 0 rebirths (1x)"
statsLabel.Parent = shopPanel
Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 8)

-- ===== CREATE UPGRADE BUTTONS =====
local function createUpgradeButton(name, emoji, color, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Button"
    btn.Size = UDim2.new(0.9, 0, 0, 55)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Text = emoji .. " " .. name
    btn.Parent = shopPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

local clickPowerBtn = createUpgradeButton("Click Power", "⚡", Color3.fromRGB(80, 120, 200), 115)
local autoClickBtn = createUpgradeButton("Auto-Clicker", "🤖", Color3.fromRGB(100, 160, 80), 180)
local luckyBtn = createUpgradeButton("Lucky Bonus", "🍀", Color3.fromRGB(80, 180, 80), 245)
local speedBtn = createUpgradeButton("Super Speed", "🏃", Color3.fromRGB(200, 120, 50), 310)

-- Rebirth button (special!)
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Name = "RebirthButton"
rebirthBtn.Size = UDim2.new(0.9, 0, 0, 65)
rebirthBtn.Position = UDim2.new(0.05, 0, 0, 385)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 180)
rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthBtn.TextScaled = true
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.Text = "🌟 REBIRTH 🌟\nReset & get 1.5x multiplier!"
rebirthBtn.Parent = shopPanel
Instance.new("UICorner", rebirthBtn).CornerRadius = UDim.new(0, 10)

local rebirthStroke = Instance.new("UIStroke")
rebirthStroke.Color = Color3.fromRGB(255, 200, 255)
rebirthStroke.Thickness = 2
rebirthStroke.Parent = rebirthBtn

-- Info label
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 50)
infoLabel.Position = UDim2.new(0, 10, 0, 460)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.Text = "💡 Tip: Auto-Clicker earns coins while you're AFK!"
infoLabel.Parent = shopPanel

print("🛒 Shop UI created!")

-- ===== UPDATE FUNCTIONS =====
local function formatCost(cost)
    if type(cost) == "string" then return cost end
    if cost >= 1000000 then
        return string.format("%.1fM", cost / 1000000)
    elseif cost >= 1000 then
        return string.format("%.1fK", cost / 1000)
    end
    return tostring(cost)
end

local function updateButton(btn, name, emoji, level, cost, stat, canAfford)
    local costText = formatCost(cost)
    btn.Text = string.format("%s %s (Lv.%d)\n%s | Cost: %s", emoji, name, level, stat, costText)
    if cost == "MAX" then
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        btn.Text = string.format("%s %s (MAX)\n%s", emoji, name, stat)
    elseif canAfford then
        btn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

local function updateShopDisplay()
    local coins = currentStats.Coins or 0
    local rebirths = currentStats.Rebirths or 0
    local mult = currentStats.RebirthMultiplier or 1
    
    statsLabel.Text = string.format("💰 %s coins | 🌟 %d rebirths (%.1fx multiplier)", 
        formatCost(coins), rebirths, mult)
    
    local costs = currentStats.UpgradeCosts or {}
    
    -- Click Power
    local cpLevel = currentStats.ClickPowerLevel or 0
    local cpStat = string.format("%dx power", currentStats.ClickPower or 1)
    updateButton(clickPowerBtn, "Click Power", "⚡", cpLevel, costs.ClickPower or 50, cpStat, coins >= (costs.ClickPower or 50))
    
    -- Auto-Clicker
    local acLevel = currentStats.AutoClickLevel or 0
    local acStat = string.format("%d/sec", currentStats.AutoClickRate or 0)
    updateButton(autoClickBtn, "Auto-Clicker", "🤖", acLevel, costs.AutoClick or 200, acStat, coins >= (costs.AutoClick or 200))
    
    -- Lucky Bonus
    local lkLevel = currentStats.LuckyLevel or 0
    local lkStat = string.format("%d%% chance", currentStats.LuckyChance or 0)
    updateButton(luckyBtn, "Lucky Bonus", "🍀", lkLevel, costs.Lucky or 300, lkStat, costs.Lucky ~= "MAX" and coins >= (costs.Lucky or 300))
    
    -- Super Speed
    local spLevel = currentStats.SpeedLevel or 0
    local spStat = string.format("%.2fs cooldown", currentStats.Cooldown or 0.5)
    updateButton(speedBtn, "Super Speed", "🏃", spLevel, costs.Speed or 400, spStat, costs.Speed ~= "MAX" and coins >= (costs.Speed or 400))
    
    -- Rebirth
    local rebirthCost = currentStats.NextRebirthCost or 10000
    local nextMult = math.pow(1.5, rebirths + 1)
    rebirthBtn.Text = string.format("🌟 REBIRTH 🌟\nCost: %s | Next: %.2fx", formatCost(rebirthCost), nextMult)
    if coins >= rebirthCost then
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 200)
    else
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 100)
    end
end

-- ===== BUTTON HANDLERS =====
local shopOpen = false

shopButton.MouseButton1Click:Connect(function()
    shopOpen = not shopOpen
    shopPanel.Visible = shopOpen
end)

closeBtn.MouseButton1Click:Connect(function()
    shopOpen = false
    shopPanel.Visible = false
end)

local function shakeButton(btn)
    local orig = btn.Position
    for i = 1, 3 do
        btn.Position = orig + UDim2.new(0, 5, 0, 0)
        wait(0.03)
        btn.Position = orig - UDim2.new(0, 5, 0, 0)
        wait(0.03)
    end
    btn.Position = orig
end

clickPowerBtn.MouseButton1Click:Connect(function()
    local cost = currentStats.UpgradeCosts and currentStats.UpgradeCosts.ClickPower or 50
    if currentStats.Coins >= cost then
        BuyClickPower:FireServer()
    else
        shakeButton(clickPowerBtn)
    end
end)

autoClickBtn.MouseButton1Click:Connect(function()
    local cost = currentStats.UpgradeCosts and currentStats.UpgradeCosts.AutoClick or 200
    if currentStats.Coins >= cost then
        BuyAutoClick:FireServer()
    else
        shakeButton(autoClickBtn)
    end
end)

luckyBtn.MouseButton1Click:Connect(function()
    local cost = currentStats.UpgradeCosts and currentStats.UpgradeCosts.Lucky
    if cost ~= "MAX" and currentStats.Coins >= cost then
        BuyLucky:FireServer()
    else
        shakeButton(luckyBtn)
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    local cost = currentStats.UpgradeCosts and currentStats.UpgradeCosts.Speed
    if cost ~= "MAX" and currentStats.Coins >= cost then
        BuySpeed:FireServer()
    else
        shakeButton(speedBtn)
    end
end)

rebirthBtn.MouseButton1Click:Connect(function()
    local cost = currentStats.NextRebirthCost or 10000
    if currentStats.Coins >= cost then
        DoRebirth:FireServer()
        -- Big celebration!
        rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
        wait(0.5)
    else
        shakeButton(rebirthBtn)
    end
end)

-- ===== EVENTS =====
StatsUpdated.OnClientEvent:Connect(function(stats)
    if stats then
        currentStats = stats
        updateShopDisplay()
    end
end)

-- Get initial stats
wait(2)
local initialStats = GetStats:InvokeServer()
if initialStats then
    currentStats = initialStats
    updateShopDisplay()
end

print("✅ Shop ready with all upgrades!")
