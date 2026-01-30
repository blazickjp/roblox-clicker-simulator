--[[
    DailyRewardsConfig - Login every day for rewards!
    
    Day 7 is the BEST - FREE EGG!
]]

local DailyRewardsConfig = {}

DailyRewardsConfig.Rewards = {
    [1] = {
        day = 1,
        name = "Day 1",
        emoji = "🎁",
        reward = { type = "coins", amount = 100 },
        description = "100 Coins!",
    },
    [2] = {
        day = 2,
        name = "Day 2",
        emoji = "🎁",
        reward = { type = "coins", amount = 250 },
        description = "250 Coins!",
    },
    [3] = {
        day = 3,
        name = "Day 3",
        emoji = "🎁",
        reward = { type = "coins", amount = 500 },
        description = "500 Coins!",
    },
    [4] = {
        day = 4,
        name = "Day 4",
        emoji = "🎁",
        reward = { type = "coins", amount = 1000 },
        description = "1,000 Coins!",
    },
    [5] = {
        day = 5,
        name = "Day 5",
        emoji = "🎁",
        reward = { type = "coins", amount = 2000 },
        description = "2,000 Coins!",
    },
    [6] = {
        day = 6,
        name = "Day 6",
        emoji = "🎁✨",
        reward = { type = "coins", amount = 5000 },
        description = "5,000 Coins!",
    },
    [7] = {
        day = 7,
        name = "Day 7 JACKPOT!",
        emoji = "🥚🌟",
        reward = { type = "egg", eggType = "Golden" },
        description = "FREE GOLDEN EGG!",
    },
}

-- After day 7, it loops back but with bigger bonuses
DailyRewardsConfig.LoopBonus = 1.5  -- 50% more coins each week

function DailyRewardsConfig.GetReward(streak)
    local day = ((streak - 1) % 7) + 1
    local weekNumber = math.floor((streak - 1) / 7)
    local bonus = math.pow(DailyRewardsConfig.LoopBonus, weekNumber)
    
    local reward = DailyRewardsConfig.Rewards[day]
    if reward.reward.type == "coins" then
        return {
            day = day,
            streak = streak,
            name = reward.name,
            emoji = reward.emoji,
            description = reward.description,
            reward = {
                type = "coins",
                amount = math.floor(reward.reward.amount * bonus)
            }
        }
    else
        return reward
    end
end

return DailyRewardsConfig
