--[[
    CoinPad Script (v2.0)
    =====================
    Click the pads to get coins!
    
    Now with:
    - Zone multipliers
    - Pet bonuses
    - Lucky doubles
    - Cool animations!
    
    HOW TO USE:
    1. Create a Part in Workspace
    2. Name it "CoinPad"
    3. This script finds all CoinPads automatically!
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Base coins per click
local COINS_PER_CLICK = 1

-- Cooldowns per player
local cooldowns = {}

-- Get modules
local PlayerData = require(script.Parent.PlayerData)

-- Wait for shared folder
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)
local SoundConfig
pcall(function()
    SoundConfig = require(SharedFolder:WaitForChild("SoundConfig", 5))
end)

-- Create particle effect
local function createCoinBurst(part)
    local attachment = Instance.new("Attachment")
    attachment.Parent = part
    
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxassetid://243660364"  -- Sparkle
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Rate = 0
    particles.Speed = NumberRange.new(5, 10)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    return particles
end

-- Setup a coin pad
local function setupCoinPad(pad)
    -- Add ClickDetector if needed
    local clickDetector = pad:FindFirstChild("ClickDetector")
    if not clickDetector then
        clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 20
        clickDetector.Parent = pad
        print("➕ Added ClickDetector to " .. pad.Name)
    end
    
    -- Add particle emitter
    local particles = createCoinBurst(pad)
    
    -- Store original properties
    local originalColor = pad.Color
    local originalSize = pad.Size
    
    -- Make it glow
    pad.Material = Enum.Material.Neon
    
    -- Click handler
    clickDetector.MouseClick:Connect(function(player)
        -- Check cooldown
        local playerCooldown = PlayerData.GetCooldown(player)
        local lastClick = cooldowns[player.UserId]
        if lastClick and (tick() - lastClick) < playerCooldown then
            return
        end
        cooldowns[player.UserId] = tick()
        
        -- Check for lucky bonus
        local luckyChance = PlayerData.GetLuckyChance(player)
        local isLucky = math.random(1, 100) <= luckyChance
        
        local baseCoins = COINS_PER_CLICK
        if isLucky then
            baseCoins = baseCoins * 2
        end
        
        -- Give coins (GiveCoins handles all multipliers)
        if _G.GiveCoins then
            local amount = _G.GiveCoins(player, baseCoins)
            
            -- Animations!
            -- Bounce
            TweenService:Create(pad, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {
                Size = originalSize * 0.85
            }):Play()
            
            wait(0.1)
            
            TweenService:Create(pad, TweenInfo.new(0.15, Enum.EasingStyle.Bounce), {
                Size = originalSize
            }):Play()
            
            -- Particles
            particles:Emit(isLucky and 30 or 10)
            
            -- Color flash for lucky
            if isLucky then
                pad.Color = Color3.fromRGB(255, 215, 0)  -- Gold!
                print("🍀 LUCKY! " .. player.Name .. " got DOUBLE!")
                wait(0.2)
                pad.Color = originalColor
            end
        end
    end)
    
    -- Hover effects
    clickDetector.MouseHoverEnter:Connect(function()
        TweenService:Create(pad, TweenInfo.new(0.1), {
            Size = originalSize * 1.1
        }):Play()
    end)
    
    clickDetector.MouseHoverLeave:Connect(function()
        TweenService:Create(pad, TweenInfo.new(0.1), {
            Size = originalSize
        }):Play()
    end)
    
    print("✅ CoinPad ready: " .. pad.Name)
end

-- Find all existing CoinPads
print("🔍 Looking for CoinPads...")
for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") and part.Name == "CoinPad" then
        setupCoinPad(part)
    end
end

-- Watch for new CoinPads
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BasePart") and descendant.Name == "CoinPad" then
        wait(0.1)
        setupCoinPad(descendant)
    end
end)

print("✅ CoinPad system ready!")
print("💡 TIP: Create a Part, name it 'CoinPad', and click it to earn coins!")
