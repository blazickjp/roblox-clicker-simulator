--[[
    CodesGui - Enter codes for FREE STUFF!
    
    🎫 Type in a code
    🎁 Get free coins or eggs!
    
    Try these codes:
    - WELCOME
    - FREECOINS
    - FREEPET
    - DADISAWESOME (shh, secret!)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for events
local RedeemCode = ReplicatedStorage:WaitForChild("RedeemCode")
local CodeResult = ReplicatedStorage:WaitForChild("CodeResult")

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CodesGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "CodesPanel"
panel.Size = UDim2.new(0, 350, 0, 250)
panel.Position = UDim2.new(0.5, -175, 0.5, -125)
panel.BackgroundColor3 = Color3.fromRGB(50, 30, 50)
panel.Visible = false
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(200, 100, 200)
stroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 100, 200)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "🎫 REDEEM CODES 🎫"
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

-- Input box
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0.9, 0, 0, 50)
inputFrame.Position = UDim2.new(0.05, 0, 0, 60)
inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inputFrame.Parent = panel
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 1, -10)
textBox.Position = UDim2.new(0, 10, 0, 5)
textBox.BackgroundTransparency = 1
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Enter code here..."
textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBox.TextScaled = true
textBox.Font = Enum.Font.GothamBold
textBox.Text = ""
textBox.ClearTextOnFocus = true
textBox.Parent = inputFrame

-- Redeem button
local redeemBtn = Instance.new("TextButton")
redeemBtn.Size = UDim2.new(0.9, 0, 0, 50)
redeemBtn.Position = UDim2.new(0.05, 0, 0, 120)
redeemBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
redeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
redeemBtn.TextScaled = true
redeemBtn.Font = Enum.Font.GothamBold
redeemBtn.Text = "🎁 REDEEM! 🎁"
redeemBtn.Parent = panel
Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 15)

-- Result label
local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(0.9, 0, 0, 50)
resultLabel.Position = UDim2.new(0.05, 0, 0, 180)
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultLabel.TextScaled = true
resultLabel.Font = Enum.Font.GothamBold
resultLabel.Text = ""
resultLabel.TextWrapped = true
resultLabel.Parent = panel

-- Redeem handler
local canRedeem = true

redeemBtn.MouseButton1Click:Connect(function()
    if not canRedeem then return end
    if textBox.Text == "" then return end
    
    canRedeem = false
    redeemBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    redeemBtn.Text = "⏳ Checking..."
    resultLabel.Text = ""
    
    RedeemCode:FireServer(textBox.Text)
    
    wait(0.5)
    canRedeem = true
    redeemBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    redeemBtn.Text = "🎁 REDEEM! 🎁"
end)

-- Also redeem on Enter
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and textBox.Text ~= "" and canRedeem then
        redeemBtn.MouseButton1Click:Fire()
    end
end)

-- Code result
CodeResult.OnClientEvent:Connect(function(success, message)
    if success then
        resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        resultLabel.Text = "✅ " .. message
        textBox.Text = ""
        
        -- Success animation
        TweenService:Create(redeemBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 255, 100)}):Play()
        wait(0.1)
        TweenService:Create(redeemBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 200, 100)}):Play()
    else
        resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        resultLabel.Text = "❌ " .. message
        
        -- Fail animation (shake)
        local orig = inputFrame.Position
        for i = 1, 3 do
            inputFrame.Position = orig + UDim2.new(0, 5, 0, 0)
            wait(0.03)
            inputFrame.Position = orig - UDim2.new(0, 5, 0, 0)
            wait(0.03)
        end
        inputFrame.Position = orig
    end
end)

print("🎫 CodesGui loaded!")
