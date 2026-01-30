--[[
    AchievementsConfig - Unlock badges for doing cool stuff!
    
    Each achievement gives a reward when unlocked!
]]

local AchievementsConfig = {}

AchievementsConfig.Achievements = {
    -- Coin achievements
    {
        id = "first_coin",
        name = "First Steps",
        description = "Collect your first coin!",
        emoji = "🪙",
        reward = { type = "coins", amount = 10 },
        requirement = { type = "coins_collected", amount = 1 },
    },
    {
        id = "coin_100",
        name = "Pocket Change",
        description = "Collect 100 coins",
        emoji = "💰",
        reward = { type = "coins", amount = 50 },
        requirement = { type = "coins_collected", amount = 100 },
    },
    {
        id = "coin_1000",
        name = "Money Bags",
        description = "Collect 1,000 coins",
        emoji = "💰💰",
        reward = { type = "coins", amount = 500 },
        requirement = { type = "coins_collected", amount = 1000 },
    },
    {
        id = "coin_10000",
        name = "Rich Kid",
        description = "Collect 10,000 coins",
        emoji = "🤑",
        reward = { type = "coins", amount = 5000 },
        requirement = { type = "coins_collected", amount = 10000 },
    },
    {
        id = "coin_100000",
        name = "Millionaire Mindset",
        description = "Collect 100,000 coins",
        emoji = "💎",
        reward = { type = "coins", amount = 25000 },
        requirement = { type = "coins_collected", amount = 100000 },
    },
    {
        id = "coin_million",
        name = "LEGENDARY RICH",
        description = "Collect 1,000,000 coins!",
        emoji = "👑",
        reward = { type = "coins", amount = 100000 },
        requirement = { type = "coins_collected", amount = 1000000 },
    },
    
    -- Rebirth achievements
    {
        id = "first_rebirth",
        name = "Born Again",
        description = "Rebirth for the first time!",
        emoji = "🌟",
        reward = { type = "coins", amount = 1000 },
        requirement = { type = "rebirths", amount = 1 },
    },
    {
        id = "rebirth_5",
        name = "Rebirth Master",
        description = "Rebirth 5 times",
        emoji = "⭐⭐",
        reward = { type = "coins", amount = 10000 },
        requirement = { type = "rebirths", amount = 5 },
    },
    {
        id = "rebirth_10",
        name = "Rebirth Legend",
        description = "Rebirth 10 times!",
        emoji = "🌟🌟🌟",
        reward = { type = "coins", amount = 50000 },
        requirement = { type = "rebirths", amount = 10 },
    },
    
    -- Pet achievements
    {
        id = "first_pet",
        name = "Pet Parent",
        description = "Hatch your first pet!",
        emoji = "🐣",
        reward = { type = "coins", amount = 200 },
        requirement = { type = "pets_owned", amount = 1 },
    },
    {
        id = "pet_5",
        name = "Pet Collector",
        description = "Own 5 pets",
        emoji = "🐾",
        reward = { type = "coins", amount = 1000 },
        requirement = { type = "pets_owned", amount = 5 },
    },
    {
        id = "pet_rare",
        name = "Rare Find!",
        description = "Hatch a Rare pet",
        emoji = "🔵",
        reward = { type = "coins", amount = 500 },
        requirement = { type = "rarity_hatched", rarity = "Rare" },
    },
    {
        id = "pet_epic",
        name = "Epic Discovery!",
        description = "Hatch an Epic pet",
        emoji = "🟣",
        reward = { type = "coins", amount = 2000 },
        requirement = { type = "rarity_hatched", rarity = "Epic" },
    },
    {
        id = "pet_legendary",
        name = "LEGENDARY!!!",
        description = "Hatch a Legendary pet!",
        emoji = "🟡👑",
        reward = { type = "coins", amount = 10000 },
        requirement = { type = "rarity_hatched", rarity = "Legendary" },
    },
    
    -- Click achievements
    {
        id = "click_100",
        name = "Clicker",
        description = "Click 100 times",
        emoji = "👆",
        reward = { type = "coins", amount = 50 },
        requirement = { type = "clicks", amount = 100 },
    },
    {
        id = "click_1000",
        name = "Click Master",
        description = "Click 1,000 times",
        emoji = "👆👆",
        reward = { type = "coins", amount = 500 },
        requirement = { type = "clicks", amount = 1000 },
    },
    
    -- Zone achievements
    {
        id = "unlock_forest",
        name = "Forest Explorer",
        description = "Unlock the Mystic Forest",
        emoji = "🌲",
        reward = { type = "coins", amount = 2000 },
        requirement = { type = "zone_unlocked", zone = "forest" },
    },
    {
        id = "unlock_lava",
        name = "Heat Seeker",
        description = "Unlock the Lava Lands",
        emoji = "🌋",
        reward = { type = "coins", amount = 5000 },
        requirement = { type = "zone_unlocked", zone = "lava" },
    },
    {
        id = "unlock_space",
        name = "Space Cadet",
        description = "Unlock the Space Station",
        emoji = "🚀",
        reward = { type = "coins", amount = 20000 },
        requirement = { type = "zone_unlocked", zone = "space" },
    },
    
    -- Daily streak
    {
        id = "streak_7",
        name = "Week Warrior",
        description = "Login 7 days in a row!",
        emoji = "📅",
        reward = { type = "coins", amount = 5000 },
        requirement = { type = "login_streak", amount = 7 },
    },
}

return AchievementsConfig
