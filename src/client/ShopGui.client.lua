--[[
    ShopGui - Buy upgrades to get more coins!
    
    ⚡ Click Power - More coins per click!
    🤖 Auto-Clicker - Earn coins automatically!
    🍀 Lucky Bonus - Chance for DOUBLE coins!
    🏃 Super Speed - Click faster!
    🌟 REBIRTH - Reset everything for a permanent multiplier!
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for events
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")
local BuyClickPower = ReplicatedStorage:WaitForChild("BuyClickPower")
local BuyAutoClick = ReplicatedStorage:WaitForChild("BuyAutoClick")
local BuyLucky = ReplicatedStorage:WaitForChild("BuyLucky")
local BuySpeed = ReplicatedStorage:WaitForChild("BuySpeed")
local DoRebirth = ReplicatedStorage:WaitForChild("DoRebirth")

local currentStats = { Coins = 0, UpgradeCosts = {} }

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.Size = UDim2.new(0, 420, 0, 520)
panel.Position = UDim2.new(0.5, -210, 0.5, -260)
panel.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
panel.Visible = false
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(100, 200, 100)
stroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(100, 255, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "🛒 UPGRADE SHOP 🛒"
title.Parent = panel

-- Coins display
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(1, -20, 0, 35)
coinsLabel.Position = UDim2.new(0, 10, 0, 48)
coinsLabel.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.TextScaled = true
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.Text = "💰 0 coins"
coinsLabel.Parent = panel
Instance.new("UICorner", coinsLabel).CornerRadius = UDim.new(0, 10)

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

-- Helper functions
local function formatNumber(num)
    if type(num) == "string" then return num end
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    end
    return tostring(math.floor(num))
end

local function createUpgradeButton(name, emoji, color, yPos, buyEvent, statKey, levelKey, costKey, statFormat)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.92, 0, 0, 60)
    btn.Position = UDim2.new(0.04, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.Parent = panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local function update()
        local level = currentStats[levelKey] or 0
        local stat = currentStats[statKey] or 0
        local cost = currentStats.UpgradeCosts and currentStats.UpgradeCosts[costKey] or 50
        local statText = string.format(statFormat, stat)
        
        if cost == "MAX" then
            btn.Text = emoji .. " " .. name .. " (MAX)\n" .. statText
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        else
            local canAfford = currentStats.Coins >= cost
            btn.Text = emoji .. " " .. name .. " (Lv." .. level .. ")\n" .. statText .. " | Cost: " .. formatNumber(cost)
            btn.BackgroundColor3 = canAfford and color or Color3.fromRGB(80, 80, 80)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        local cost = currentStats.UpgradeCosts and currentStats.UpgradeCosts[costKey]
        if cost and cost ~= "MAX" and currentStats.Coins >= cost then
            buyEvent:FireServer()
            -- Feedback animation
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = btn.Size + UDim2.new(0, 10, 0, 5)}):Play()
            wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.92, 0, 0, 60)}):Play()
        else
            -- Shake for can't afford
            local orig = btn.Position
            for i = 1, 3 do
                btn.Position = orig + UDim2.new(0, 5, 0, 0)
                wait(0.03)
                btn.Position = orig - UDim2.new(0, 5, 0, 0)
                wait(0.03)
            end
            btn.Position = orig
        end
    end)
    
    return btn, update
end

-- Create upgrade buttons
local buttonY = 95
local buttons = {}

local clickPowerBtn, updateClickPower = createUpgradeButton(
    "Click Power", "⚡", Color3.fromRGB(80, 120, 200), buttonY,
    BuyClickPower, "ClickPower", "ClickPowerLevel", "ClickPower", "%.0fx power"
)
buttons[#buttons + 1] = updateClickPower
buttonY = buttonY + 70

local autoClickBtn, updateAutoClick = createUpgradeButton(
    "Auto-Clicker", "🤖", Color3.fromRGB(100, 160, 80), buttonY,
    BuyAutoClick, "AutoClickRate", "AutoClickLevel", "AutoClick", "%d/sec"
)
buttons[#buttons + 1] = updateAutoClick
buttonY = buttonY + 70

local luckyBtn, updateLucky = createUpgradeButton(
    "Lucky Bonus", "🍀", Color3.fromRGB(80, 180, 80), buttonY,
    BuyLucky, "LuckyChance", "LuckyLevel", "Lucky", "%.0f%% chance"
)
buttons[#buttons + 1] = updateLucky
buttonY = buttonY + 70

local speedBtn, updateSpeed = createUpgradeButton(
    "Super Speed", "🏃", Color3.fromRGB(200, 120, 50), buttonY,
    BuySpeed, "Cooldown", "SpeedLevel", "Speed", "%.2fs cooldown"
)
buttons[#buttons + 1] = updateSpeed
buttonY = buttonY + 80

-- Rebirth button (special)
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Name = "Rebirth"
rebirthBtn.Size = UDim2.new(0.92, 0, 0, 70)
rebirthBtn.Position = UDim2.new(0.04, 0, 0, buttonY)
rebirthBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
rebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthBtn.TextScaled = true
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.Text = "🌟 REBIRTH 🌟\nReset & get permanent multiplier!"
rebirthBtn.Parent = panel
Instance.new("UICorner", rebirthBtn).CornerRadius = UDim.new(0, 15)

local rebirthStroke = Instance.new("UIStroke", rebirthBtn)
rebirthStroke.Color = Color3.fromRGB(255, 200, 255)
rebirthStroke.Thickness = 2

local function updateRebirth()
    local rebirths = currentStats.Rebirths or 0
    local mult = currentStats.RebirthMultiplier or 1
    local cost = currentStats.NextRebirthCost or 10000
    local nextMult = math.pow(1.5, rebirths + 1)
    local canAfford = currentStats.Coins >= cost
    
    rebirthBtn.Text = "🌟 REBIRTH 🌟 (" .. rebirths .. " done)\nCurrent: " .. string.format("%.1fx", mult) .. " | Next: " .. string.format("%.1fx", nextMult) .. "\nCost: " .. formatNumber(cost)
    rebirthBtn.BackgroundColor3 = canAfford and Color3.fromRGB(200, 100, 200) or Color3.fromRGB(80, 50, 80)
end
buttons[#buttons + 1] = updateRebirth

rebirthBtn.MouseButton1Click:Connect(function()
    local cost = currentStats.NextRebirthCost or 10000
    if currentStats.Coins >= cost then
        DoRebirth:FireServer()
        -- Big celebration animation
        TweenService:Create(rebirthBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 100)}):Play()
        wait(0.5)
    end
end)

-- Update all buttons
local function updateAll()
    coinsLabel.Text = "💰 " .. formatNumber(currentStats.Coins) .. " coins"
    for _, update in ipairs(buttons) do
        update()
    end
end

-- Events
StatsUpdated.OnClientEvent:Connect(function(stats)
    currentStats = stats
    updateAll()
end)

-- Initial load
wait(2)
local initialStats = GetStats:InvokeServer()
if initialStats then
    currentStats = initialStats
    updateAll()
end

print("🛒 ShopGui loaded!")
