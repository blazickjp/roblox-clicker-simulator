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

-- Base coins per click (was 1, now 3 for faster early game!)
local COINS_PER_CLICK = 3

-- STARTER BOOST: First 10 clicks give 10x coins!
-- Kids need instant gratification - this gives 300 coins in first 10 clicks
local STARTER_BOOST_CLICKS = 10
local STARTER_BOOST_MULTIPLIER = 10

-- JACKPOT: 0.5% chance for 50x coins! Rare but EXCITING
-- Creates "OMG DID YOU SEE THAT" moments kids will remember
local JACKPOT_CHANCE = 0.5  -- percent
local JACKPOT_MULTIPLIER = 50

-- Track starter boost per player
local starterBoostRemaining = {}

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
        
        -- Initialize starter boost for new clickers
        if starterBoostRemaining[player.UserId] == nil then
            starterBoostRemaining[player.UserId] = STARTER_BOOST_CLICKS
        end
        
        -- Check for JACKPOT! (0.5% chance)
        local isJackpot = math.random(1, 1000) <= (JACKPOT_CHANCE * 10)
        
        -- Check for lucky bonus
        local luckyChance = PlayerData.GetLuckyChance(player)
        local isLucky = math.random(1, 100) <= luckyChance
        
        local baseCoins = COINS_PER_CLICK
        
        -- JACKPOT overrides everything!
        if isJackpot then
            baseCoins = baseCoins * JACKPOT_MULTIPLIER
        end
        
        -- Apply starter boost if available
        local hasStarterBoost = false
        if starterBoostRemaining[player.UserId] > 0 then
            baseCoins = baseCoins * STARTER_BOOST_MULTIPLIER
            starterBoostRemaining[player.UserId] = starterBoostRemaining[player.UserId] - 1
            hasStarterBoost = true
            if starterBoostRemaining[player.UserId] == 0 then
                print("🎉 " .. player.Name .. " used all their starter boost!")
            end
        end
        
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
            
            -- Particles (more for special events!)
            local particleCount = 10
            if hasStarterBoost then particleCount = 25 end
            if isLucky then particleCount = 30 end
            if hasStarterBoost and isLucky then particleCount = 50 end
            if isJackpot then particleCount = 100 end  -- EXPLOSION!
            particles:Emit(particleCount)
            
            -- JACKPOT gets the biggest celebration!
            if isJackpot then
                -- Flash rainbow colors rapidly
                print("🎰🎰🎰 JACKPOT!!! " .. player.Name .. " got " .. JACKPOT_MULTIPLIER .. "x COINS!!!")
                for i = 1, 5 do
                    pad.Color = Color3.fromRGB(255, 0, 0)
                    wait(0.05)
                    pad.Color = Color3.fromRGB(255, 255, 0)
                    wait(0.05)
                    pad.Color = Color3.fromRGB(0, 255, 0)
                    wait(0.05)
                    pad.Color = Color3.fromRGB(0, 255, 255)
                    wait(0.05)
                    pad.Color = Color3.fromRGB(255, 0, 255)
                    wait(0.05)
                end
                pad.Color = originalColor
                -- Extra particle bursts
                particles:Emit(50)
                wait(0.1)
                particles:Emit(50)
            -- Color flash for other special events
            elseif hasStarterBoost or isLucky then
                if hasStarterBoost and isLucky then
                    pad.Color = Color3.fromRGB(255, 100, 255)  -- Purple for combo!
                    print("🎉🍀 STARTER BOOST + LUCKY! " .. player.Name .. " got MEGA COINS!")
                elseif hasStarterBoost then
                    pad.Color = Color3.fromRGB(100, 255, 255)  -- Cyan for starter boost
                    print("🚀 STARTER BOOST! " .. player.Name .. " (" .. starterBoostRemaining[player.UserId] .. " left)")
                else
                    pad.Color = Color3.fromRGB(255, 215, 0)  -- Gold for lucky
                    print("🍀 LUCKY! " .. player.Name .. " got DOUBLE!")
                end
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
