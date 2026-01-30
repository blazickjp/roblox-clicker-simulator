--[[
    PetsConfig - All the pets in the game!
    
    Rarities:
    🟢 Common (60% chance)
    🔵 Rare (25% chance)
    🟣 Epic (12% chance)
    🟡 Legendary (3% chance)
]]

local PetsConfig = {}

-- Rarity colors and chances
PetsConfig.Rarities = {
    Common = { chance = 60, color = Color3.fromRGB(100, 200, 100), multiplier = 1 },
    Rare = { chance = 25, color = Color3.fromRGB(100, 150, 255), multiplier = 2 },
    Epic = { chance = 12, color = Color3.fromRGB(200, 100, 255), multiplier = 5 },
    Legendary = { chance = 3, color = Color3.fromRGB(255, 215, 0), multiplier = 15 },
}

-- All pets organized by rarity
PetsConfig.Pets = {
    Common = {
        { name = "Puppy", emoji = "🐕", model = "Dog", bonus = 1 },
        { name = "Kitten", emoji = "🐱", model = "Cat", bonus = 1 },
        { name = "Bunny", emoji = "🐰", model = "Rabbit", bonus = 1.2 },
        { name = "Hamster", emoji = "🐹", model = "Hamster", bonus = 1.1 },
        { name = "Chick", emoji = "🐤", model = "Chick", bonus = 1 },
    },
    Rare = {
        { name = "Fox", emoji = "🦊", model = "Fox", bonus = 2 },
        { name = "Panda", emoji = "🐼", model = "Panda", bonus = 2.2 },
        { name = "Owl", emoji = "🦉", model = "Owl", bonus = 2.5 },
        { name = "Penguin", emoji = "🐧", model = "Penguin", bonus = 2.3 },
        { name = "Koala", emoji = "🐨", model = "Koala", bonus = 2.1 },
    },
    Epic = {
        { name = "Dragon Baby", emoji = "🐉", model = "Dragon", bonus = 5 },
        { name = "Unicorn", emoji = "🦄", model = "Unicorn", bonus = 5.5 },
        { name = "Phoenix Chick", emoji = "🔥", model = "Phoenix", bonus = 6 },
        { name = "Ice Wolf", emoji = "🐺", model = "Wolf", bonus = 5.2 },
        { name = "Rainbow Slime", emoji = "🌈", model = "Slime", bonus = 5.8 },
    },
    Legendary = {
        { name = "Golden Dragon", emoji = "✨🐉", model = "GoldenDragon", bonus = 15 },
        { name = "Cosmic Cat", emoji = "🌌🐱", model = "CosmicCat", bonus = 18 },
        { name = "Diamond Doge", emoji = "💎🐕", model = "DiamondDoge", bonus = 20 },
        { name = "Shadow Phoenix", emoji = "🖤🔥", model = "ShadowPhoenix", bonus = 25 },
    },
}

-- Egg types
PetsConfig.Eggs = {
    Basic = { cost = 500, name = "Basic Egg", emoji = "🥚", color = Color3.fromRGB(200, 200, 200) },
    Golden = { cost = 5000, name = "Golden Egg", emoji = "🥚✨", color = Color3.fromRGB(255, 215, 0) },
    Mythic = { cost = 50000, name = "Mythic Egg", emoji = "🥚🌟", color = Color3.fromRGB(200, 100, 255) },
}

-- Egg rarity chances (better eggs = better chances)
PetsConfig.EggChances = {
    Basic = { Common = 70, Rare = 25, Epic = 4.5, Legendary = 0.5 },
    Golden = { Common = 40, Rare = 40, Epic = 17, Legendary = 3 },
    Mythic = { Common = 10, Rare = 30, Epic = 45, Legendary = 15 },
}

return PetsConfig
