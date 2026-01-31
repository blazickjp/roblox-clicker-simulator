--[[
    PetsGui - Hatch eggs and manage your pets!
    
    🥚 Buy eggs to hatch
    🐣 Watch them hatch with cool animation
    🐾 See all your pets
    ⭐ Equip pets for bonus coins!
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for shared config
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)
local PetsConfig
pcall(function()
    PetsConfig = require(SharedFolder:WaitForChild("PetsConfig", 5))
end)

-- Wait for events
local BuyEgg = ReplicatedStorage:WaitForChild("BuyEgg")
local EquipPet = ReplicatedStorage:WaitForChild("EquipPet")
local UnequipPet = ReplicatedStorage:WaitForChild("UnequipPet")
local PetHatched = ReplicatedStorage:WaitForChild("PetHatched")
local StatsUpdated = ReplicatedStorage:WaitForChild("StatsUpdated")
local GetStats = ReplicatedStorage:WaitForChild("GetStats")

local currentStats = { Pets = {}, EquippedPets = {}, Coins = 0 }

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main panel (hidden by default)
local panel = Instance.new("Frame")
panel.Name = "PetsPanel"
panel.Size = UDim2.new(0, 500, 0, 450)
panel.Position = UDim2.new(0.5, -250, 0.5, -225)
panel.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
panel.Visible = false
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(200, 150, 100)
stroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 150, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "🐾 PETS 🐾"
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

-- ===== EGG SHOP SECTION =====
local eggSection = Instance.new("Frame")
eggSection.Size = UDim2.new(1, -20, 0, 130)  -- Taller for teaser text
eggSection.Position = UDim2.new(0, 10, 0, 55)
eggSection.BackgroundColor3 = Color3.fromRGB(50, 45, 60)
eggSection.Parent = panel
Instance.new("UICorner", eggSection).CornerRadius = UDim.new(0, 15)

local eggTitle = Instance.new("TextLabel")
eggTitle.Size = UDim2.new(1, 0, 0, 25)
eggTitle.BackgroundTransparency = 1
eggTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
eggTitle.TextScaled = true
eggTitle.Font = Enum.Font.GothamBold
eggTitle.Text = "🥚 HATCH EGGS 🥚"
eggTitle.Parent = eggSection

-- Create egg buttons
local eggButtons = {}
local eggX = 10
if PetsConfig then
    for eggType, eggData in pairs(PetsConfig.Eggs) do
        local eggBtn = Instance.new("TextButton")
        eggBtn.Name = eggType
        eggBtn.Size = UDim2.new(0, 150, 0, 90)  -- Taller for teaser
        eggBtn.Position = UDim2.new(0, eggX, 0, 32)
        eggBtn.BackgroundColor3 = eggData.color
        eggBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        eggBtn.TextScaled = true
        eggBtn.Font = Enum.Font.GothamBold
        -- Show teaser so kids know what they could get!
        local teaser = eggData.teaser or ""
        eggBtn.Text = eggData.emoji .. " " .. eggData.name .. "\n💰 " .. eggData.cost .. "\n" .. teaser
        eggBtn.Parent = eggSection
        Instance.new("UICorner", eggBtn).CornerRadius = UDim.new(0, 12)
        
        eggBtn.MouseButton1Click:Connect(function()
            BuyEgg:FireServer(eggType)
        end)
        
        eggButtons[eggType] = eggBtn
        eggX = eggX + 160
    end
end

-- ===== PETS COLLECTION SECTION =====
local collectionSection = Instance.new("Frame")
collectionSection.Size = UDim2.new(1, -20, 0, 250)
collectionSection.Position = UDim2.new(0, 10, 0, 195)  -- Adjusted for taller egg section
collectionSection.BackgroundColor3 = Color3.fromRGB(50, 45, 60)
collectionSection.Parent = panel
Instance.new("UICorner", collectionSection).CornerRadius = UDim.new(0, 15)

local collectionTitle = Instance.new("TextLabel")
collectionTitle.Size = UDim2.new(1, 0, 0, 30)
collectionTitle.BackgroundTransparency = 1
collectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
collectionTitle.TextScaled = true
collectionTitle.Font = Enum.Font.GothamBold
collectionTitle.Text = "📦 YOUR PETS (Tap to equip!) 📦"
collectionTitle.Parent = collectionSection

local petsScroll = Instance.new("ScrollingFrame")
petsScroll.Size = UDim2.new(1, -10, 1, -40)
petsScroll.Position = UDim2.new(0, 5, 0, 35)
petsScroll.BackgroundTransparency = 1
petsScroll.ScrollBarThickness = 8
petsScroll.Parent = collectionSection

local petsGrid = Instance.new("UIGridLayout")
petsGrid.CellSize = UDim2.new(0, 85, 0, 95)
petsGrid.CellPadding = UDim2.new(0, 8, 0, 8)
petsGrid.Parent = petsScroll

-- Update pets display
local function updatePetsDisplay()
    -- Clear existing
    for _, child in pairs(petsScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if not currentStats.Pets then return end
    
    for _, pet in ipairs(currentStats.Pets) do
        local petBtn = Instance.new("TextButton")
        petBtn.Name = pet.id
        petBtn.BackgroundColor3 = PetsConfig and PetsConfig.Rarities[pet.rarity] and PetsConfig.Rarities[pet.rarity].color or Color3.fromRGB(100, 100, 100)
        petBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        petBtn.TextScaled = true
        petBtn.Font = Enum.Font.GothamBold
        petBtn.TextYAlignment = Enum.TextYAlignment.Top
        petBtn.Parent = petsScroll
        Instance.new("UICorner", petBtn).CornerRadius = UDim.new(0, 10)
        
        -- Check if equipped
        local isEquipped = false
        if currentStats.EquippedPets then
            for _, equippedId in ipairs(currentStats.EquippedPets) do
                if equippedId == pet.id then
                    isEquipped = true
                    break
                end
            end
        end
        
        local equippedText = isEquipped and "⭐ EQUIPPED" or "Tap to equip"
        petBtn.Text = pet.emoji .. "\n" .. pet.name .. "\n+" .. string.format("%.1f", pet.bonus) .. "x\n" .. equippedText
        
        if isEquipped then
            local equipStroke = Instance.new("UIStroke", petBtn)
            equipStroke.Color = Color3.fromRGB(255, 215, 0)
            equipStroke.Thickness = 3
        end
        
        petBtn.MouseButton1Click:Connect(function()
            if isEquipped then
                UnequipPet:FireServer(pet.id)
            else
                EquipPet:FireServer(pet.id)
            end
        end)
    end
    
    -- Update scroll canvas size
    local rows = math.ceil(#currentStats.Pets / 5)
    petsScroll.CanvasSize = UDim2.new(0, 0, 0, rows * 103)
end

-- ===== HATCH ANIMATION =====
local hatchOverlay = Instance.new("Frame")
hatchOverlay.Size = UDim2.new(1, 0, 1, 0)
hatchOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hatchOverlay.BackgroundTransparency = 0.7
hatchOverlay.Visible = false
hatchOverlay.ZIndex = 10
hatchOverlay.Parent = screenGui

local hatchEgg = Instance.new("TextLabel")
hatchEgg.Size = UDim2.new(0, 200, 0, 200)
hatchEgg.Position = UDim2.new(0.5, -100, 0.5, -150)
hatchEgg.BackgroundTransparency = 1
hatchEgg.TextColor3 = Color3.fromRGB(255, 255, 255)
hatchEgg.TextScaled = true
hatchEgg.Font = Enum.Font.GothamBold
hatchEgg.Text = "🥚"
hatchEgg.ZIndex = 11
hatchEgg.Parent = hatchOverlay

local hatchResult = Instance.new("TextLabel")
hatchResult.Size = UDim2.new(0, 400, 0, 150)
hatchResult.Position = UDim2.new(0.5, -200, 0.5, 60)
hatchResult.BackgroundTransparency = 1
hatchResult.TextColor3 = Color3.fromRGB(255, 215, 0)
hatchResult.TextScaled = true
hatchResult.Font = Enum.Font.GothamBold
hatchResult.Text = ""
hatchResult.ZIndex = 11
hatchResult.Parent = hatchOverlay

local function playHatchAnimation(pet)
    hatchOverlay.Visible = true
    hatchEgg.Text = "🥚"
    hatchResult.Text = "Hatching..."
    
    -- Shake the egg
    for i = 1, 5 do
        TweenService:Create(hatchEgg, TweenInfo.new(0.1), {Rotation = 10}):Play()
        wait(0.1)
        TweenService:Create(hatchEgg, TweenInfo.new(0.1), {Rotation = -10}):Play()
        wait(0.1)
    end
    
    -- Egg crack
    TweenService:Create(hatchEgg, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
        Size = UDim2.new(0, 250, 0, 250),
        Position = UDim2.new(0.5, -125, 0.5, -175)
    }):Play()
    wait(0.3)
    
    -- Reveal pet!
    hatchEgg.Text = pet.emoji
    
    local rarityColor = PetsConfig and PetsConfig.Rarities[pet.rarity] and PetsConfig.Rarities[pet.rarity].color or Color3.fromRGB(255, 255, 255)
    hatchResult.TextColor3 = rarityColor
    hatchResult.Text = pet.rarity .. "!\n" .. pet.name .. "\n+" .. string.format("%.1f", pet.bonus) .. "x coins!"
    
    -- Celebration effect based on rarity
    if pet.rarity == "Legendary" then
        hatchResult.Text = "🌟 LEGENDARY! 🌟\n" .. pet.name .. "\n+" .. string.format("%.1f", pet.bonus) .. "x coins!"
        for i = 1, 3 do
            TweenService:Create(hatchResult, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 100, 255)}):Play()
            wait(0.15)
            TweenService:Create(hatchResult, TweenInfo.new(0.15), {TextColor3 = rarityColor}):Play()
            wait(0.15)
        end
    elseif pet.rarity == "Epic" then
        hatchResult.Text = "✨ EPIC! ✨\n" .. pet.name .. "\n+" .. string.format("%.1f", pet.bonus) .. "x coins!"
    elseif pet.rarity == "Rare" then
        hatchResult.Text = "💎 RARE! 💎\n" .. pet.name .. "\n+" .. string.format("%.1f", pet.bonus) .. "x coins!"
    end
    
    wait(2.5)
    
    -- Fade out
    TweenService:Create(hatchOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    hatchOverlay.Visible = false
    hatchOverlay.BackgroundTransparency = 0.7
    hatchEgg.Size = UDim2.new(0, 200, 0, 200)
    hatchEgg.Position = UDim2.new(0.5, -100, 0.5, -150)
    hatchEgg.Rotation = 0
end

-- ===== EVENTS =====
PetHatched.OnClientEvent:Connect(function(pet)
    playHatchAnimation(pet)
end)

StatsUpdated.OnClientEvent:Connect(function(stats)
    currentStats = stats
    updatePetsDisplay()
end)

-- Initial load
wait(2)
local initialStats = GetStats:InvokeServer()
if initialStats then
    currentStats = initialStats
    updatePetsDisplay()
end

print("🐾 PetsGui loaded!")
