--[[
    SoundConfig - All the satisfying sounds!
    
    These are Roblox asset IDs for sounds.
    Find more at: https://create.roblox.com/marketplace/audio
]]

local SoundConfig = {}

SoundConfig.Sounds = {
    -- Coin sounds
    CoinCollect = "rbxassetid://138081500",  -- Light ding
    CoinCollectBig = "rbxassetid://138081500",  -- Bigger ding
    
    -- UI sounds
    ButtonClick = "rbxassetid://876939830",  -- Click
    ButtonHover = "rbxassetid://140910211",  -- Soft hover
    
    -- Purchase sounds
    Purchase = "rbxassetid://138081500",  -- Cash register
    UpgradeBuy = "rbxassetid://138081500",  -- Power up
    
    -- Special sounds
    Rebirth = "rbxassetid://138081500",  -- Magical
    
    -- Egg sounds
    EggBuy = "rbxassetid://138081500",  -- Pop
    EggHatching = "rbxassetid://138081500",  -- Suspense
    EggHatchCommon = "rbxassetid://138081500",  -- Nice
    EggHatchRare = "rbxassetid://138081500",  -- Ooh!
    EggHatchEpic = "rbxassetid://138081500",  -- Wow!
    EggHatchLegendary = "rbxassetid://138081500",  -- AMAZING!
    
    -- Achievement
    AchievementUnlock = "rbxassetid://138081500",  -- Fanfare
    
    -- Daily reward
    DailyReward = "rbxassetid://138081500",  -- Present opening
    
    -- Code
    CodeSuccess = "rbxassetid://138081500",  -- Success chime
    CodeFail = "rbxassetid://138081500",  -- Error buzz
    
    -- Lucky
    LuckyBonus = "rbxassetid://138081500",  -- Jackpot!
}

-- Volume levels
SoundConfig.Volumes = {
    CoinCollect = 0.3,
    CoinCollectBig = 0.5,
    ButtonClick = 0.4,
    ButtonHover = 0.2,
    Purchase = 0.5,
    UpgradeBuy = 0.6,
    Rebirth = 0.8,
    EggBuy = 0.5,
    EggHatching = 0.6,
    EggHatchCommon = 0.6,
    EggHatchRare = 0.7,
    EggHatchEpic = 0.8,
    EggHatchLegendary = 1.0,
    AchievementUnlock = 0.7,
    DailyReward = 0.6,
    CodeSuccess = 0.5,
    CodeFail = 0.4,
    LuckyBonus = 0.8,
}

return SoundConfig
