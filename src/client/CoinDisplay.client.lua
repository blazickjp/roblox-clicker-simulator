--[[
    CoinDisplay Script
    ==================
    Shows your coins on screen!
    
    HOW TO SET UP:
    1. In StarterGui, create a ScreenGui (Insert → ScreenGui)
    2. Name it "CoinGui"
    3. Inside CoinGui, create a TextLabel (Insert → TextLabel)
    4. Name it "CoinLabel"
    5. Put this script INSIDE the ScreenGui (Insert → LocalScript)
    
    This script will update the text to show your coins!
]]

-- Get the UI elements
local screenGui = script.Parent
local coinLabel = screenGui:WaitForChild("CoinLabel")

-- Get services we need
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get our player
local player = Players.LocalPlayer

-- Wait for the RemoteEvents to be created
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local CoinCollected = ReplicatedStorage:WaitForChild("CoinCollected")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")

-- Make the label look nice
coinLabel.Size = UDim2.new(0, 300, 0, 80)
coinLabel.Position = UDim2.new(0.5, -150, 0, 20)  -- Top center
coinLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coinLabel.BackgroundTransparency = 0.3
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)  -- Gold color!
coinLabel.TextScaled = true
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Text = "💰 Coins: 0"

-- Add a nice border
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = coinLabel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 3
stroke.Parent = coinLabel

print("🖥️ CoinDisplay loaded!")

-- Update the display when stats change
StatsUpdated.OnClientEvent:Connect(function(stats)
    if stats then
        coinLabel.Text = "💰 Coins: " .. tostring(stats.Coins)
        print("Updated coins display: " .. stats.Coins)
    end
end)

-- Fun animation when you collect coins!
CoinCollected.OnClientEvent:Connect(function(amount)
    -- Make the text bigger briefly
    local originalSize = coinLabel.Size
    coinLabel.Size = originalSize + UDim2.new(0, 20, 0, 10)
    
    -- Flash gold
    coinLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
    
    wait(0.1)
    
    -- Return to normal
    coinLabel.Size = originalSize
    coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    
    -- You could add a sound here!
    -- local sound = Instance.new("Sound")
    -- sound.SoundId = "rbxassetid://YOUR_SOUND_ID"
    -- sound:Play()
end)

-- Get initial stats when the game loads
wait(2)  -- Wait for everything to load
local initialStats = GetStats:InvokeServer()
if initialStats then
    coinLabel.Text = "💰 Coins: " .. tostring(initialStats.Coins)
end

print("✅ CoinDisplay ready!")
