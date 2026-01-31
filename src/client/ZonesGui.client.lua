--[[
    ZonesGui - Travel to different zones!
    
    🌸 Starter Meadow - Free!
    🌲 Mystic Forest - 1 Rebirth
    🌋 Lava Lands - 3 Rebirths
    🚀 Space Station - 5 Rebirths
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for shared config
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)
local ZonesConfig
pcall(function()
    ZonesConfig = require(SharedFolder:WaitForChild("ZonesConfig", 5))
end)

-- Wait for events
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")

-- Create change zone event
local ChangeZone = ReplicatedStorage:FindFirstChild("ChangeZone") or Instance.new("RemoteEvent")
ChangeZone.Name = "ChangeZone"
if not ChangeZone.Parent then ChangeZone.Parent = ReplicatedStorage end

local currentStats = { Rebirths = 0, CurrentZone = "meadow" }

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZonesGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "ZonesPanel"
panel.Size = UDim2.new(0, 400, 0, 450)
panel.Position = UDim2.new(0.5, -200, 0.5, -225)
panel.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
panel.Visible = false
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(100, 150, 200)
stroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "🌍 ZONES 🌍"
title.Parent = panel

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

-- TELEPORT EFFECT overlay (fullscreen flash when changing zones!)
local teleportOverlay = Instance.new("Frame")
teleportOverlay.Name = "TeleportOverlay"
teleportOverlay.Size = UDim2.new(1, 0, 1, 0)
teleportOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
teleportOverlay.BackgroundTransparency = 1
teleportOverlay.Visible = false
teleportOverlay.ZIndex = 50
teleportOverlay.Parent = screenGui

local teleportText = Instance.new("TextLabel")
teleportText.Size = UDim2.new(1, 0, 0, 100)
teleportText.Position = UDim2.new(0, 0, 0.4, 0)
teleportText.BackgroundTransparency = 1
teleportText.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportText.TextScaled = true
teleportText.Font = Enum.Font.GothamBold
teleportText.Text = ""
teleportText.ZIndex = 51
teleportText.Parent = teleportOverlay

local function playTeleportEffect(zone)
    teleportOverlay.BackgroundColor3 = zone.backgroundColor
    teleportOverlay.BackgroundTransparency = 1
    teleportOverlay.Visible = true
    teleportText.Text = "✨ Traveling to " .. zone.name .. "! ✨"
    
    -- Flash IN
    TweenService:Create(teleportOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    wait(0.3)
    
    -- Hold
    wait(0.3)
    
    -- Flash OUT
    TweenService:Create(teleportOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    
    teleportOverlay.Visible = false
end

-- Zone buttons container
local zoneButtons = {}
local buttonY = 60

local function updateZoneButtons()
    if not ZonesConfig then return end
    
    for _, zone in ipairs(ZonesConfig.Zones) do
        local btn = zoneButtons[zone.id]
        if not btn then
            btn = Instance.new("TextButton")
            btn.Name = zone.id
            btn.Size = UDim2.new(0.9, 0, 0, 85)
            btn.Position = UDim2.new(0.05, 0, 0, buttonY)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.TextYAlignment = Enum.TextYAlignment.Top
            btn.Parent = panel
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)
            
            btn.MouseButton1Click:Connect(function()
                if ZonesConfig.IsUnlocked(zone.id, currentStats.Rebirths) then
                    -- Don't teleport if already in this zone
                    if currentStats.CurrentZone == zone.id then return end
                    
                    -- Play teleport effect then change zone!
                    playTeleportEffect(zone)
                    ChangeZone:FireServer(zone.id)
                    panel.Visible = false  -- Close panel after traveling
                end
            end)
            
            zoneButtons[zone.id] = btn
            buttonY = buttonY + 95
        end
        
        local isUnlocked = ZonesConfig.IsUnlocked(zone.id, currentStats.Rebirths)
        local isCurrent = currentStats.CurrentZone == zone.id
        
        if isCurrent then
            btn.BackgroundColor3 = zone.backgroundColor
            local existingStroke = btn:FindFirstChildOfClass("UIStroke")
            if not existingStroke then
                local s = Instance.new("UIStroke", btn)
                s.Color = Color3.fromRGB(255, 215, 0)
                s.Thickness = 4
            else
                existingStroke.Color = Color3.fromRGB(255, 215, 0)
            end
            btn.Text = zone.emoji .. " " .. zone.name .. " ✓\n" .. zone.description .. "\n💰 " .. zone.coinMultiplier .. "x Coins!"
        elseif isUnlocked then
            btn.BackgroundColor3 = zone.backgroundColor
            local existingStroke = btn:FindFirstChildOfClass("UIStroke")
            if existingStroke then existingStroke:Destroy() end
            btn.Text = zone.emoji .. " " .. zone.name .. "\n" .. zone.description .. "\n💰 " .. zone.coinMultiplier .. "x Coins!"
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            local existingStroke = btn:FindFirstChildOfClass("UIStroke")
            if existingStroke then existingStroke:Destroy() end
            btn.Text = "🔒 " .. zone.name .. " 🔒\nRequires " .. zone.rebirthsRequired .. " Rebirths\n(You have: " .. currentStats.Rebirths .. ")"
        end
    end
end

-- Events
StatsUpdated.OnClientEvent:Connect(function(stats)
    currentStats = stats
    updateZoneButtons()
end)

-- Initial load
wait(2)
local initialStats = GetStats:InvokeServer()
if initialStats then
    currentStats = initialStats
    updateZoneButtons()
end

print("🌍 ZonesGui loaded!")
