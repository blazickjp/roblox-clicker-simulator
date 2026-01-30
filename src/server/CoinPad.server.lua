--[[
    CoinPad Script
    ==============
    This makes the coin pads work!
    
    When you click a pad, you get coins!
    
    HOW TO USE:
    1. Create a Part in Workspace
    2. Name it "CoinPad" (or it won't work!)
    3. Add a ClickDetector inside the part
    4. This script finds all CoinPads automatically!
    
    ⭐ CHANGE THIS NUMBER TO GIVE MORE COINS! ⭐
]]

-- How many coins you get per click (before upgrades!)
local COINS_PER_CLICK = 1    -- Try changing this to 10, 100, or 9999!

-- Keep track of cooldowns
local cooldowns = {}

-- Get PlayerData module for cooldown and lucky stats
local PlayerData = require(script.Parent.PlayerData)

-- Function to set up a coin pad
local function setupCoinPad(pad)
    -- Find or create a ClickDetector
    local clickDetector = pad:FindFirstChild("ClickDetector")
    if not clickDetector then
        clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 20  -- How close you need to be
        clickDetector.Parent = pad
        print("➕ Added ClickDetector to " .. pad.Name)
    end
    
    -- When someone clicks the pad
    clickDetector.MouseClick:Connect(function(player)
        -- Get player's cooldown from upgrades (Speed upgrade makes this faster!)
        local playerCooldown = PlayerData.GetCooldown(player)
        
        -- Check cooldown
        local lastClick = cooldowns[player.UserId]
        if lastClick and (tick() - lastClick) < playerCooldown then
            return  -- Too fast! Wait a bit
        end
        cooldowns[player.UserId] = tick()
        
        -- Give coins! (GiveCoins is created by GameManager)
        if _G.GiveCoins then
            local baseCoins = COINS_PER_CLICK
            
            -- Check for lucky bonus (chance for DOUBLE coins!)
            local luckyChance = PlayerData.GetLuckyChance(player)
            local isLucky = math.random(1, 100) <= luckyChance
            
            if isLucky then
                baseCoins = baseCoins * 2
                print("🍀 LUCKY! " .. player.Name .. " got DOUBLE coins!")
            end
            
            local amount = _G.GiveCoins(player, baseCoins)
            
            -- Make the pad do a little bounce animation!
            local originalSize = pad.Size
            pad.Size = originalSize * 0.9
            wait(0.1)
            pad.Size = originalSize
            
            -- Extra sparkle for lucky hits!
            if isLucky then
                pad.Color = Color3.fromRGB(255, 215, 0)  -- Gold!
                wait(0.2)
                pad.Color = Color3.fromRGB(100, 200, 100)  -- Back to green
            end
            
            print("🪙 " .. player.Name .. " clicked and got " .. amount .. " coins!")
        end
    end)
    
    -- Make the pad glow a bit
    pad.Material = Enum.Material.Neon
    
    print("✅ CoinPad ready: " .. pad.Name)
end

-- Find all existing CoinPads and set them up
print("🔍 Looking for CoinPads...")
for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") and part.Name == "CoinPad" then
        setupCoinPad(part)
    end
end

-- Watch for new CoinPads being added
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BasePart") and descendant.Name == "CoinPad" then
        wait(0.1)  -- Small delay to make sure it's fully loaded
        setupCoinPad(descendant)
    end
end)

print("✅ CoinPad system ready!")
print("💡 TIP: Create a Part, name it 'CoinPad', and click it to earn coins!")
