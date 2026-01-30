--[[
    CodesConfig - Redeem codes for FREE STUFF!
    
    Add new codes here. Kids LOVE codes!
    
    Set expiresAt to a Unix timestamp, or nil for never expires.
]]

local CodesConfig = {}

CodesConfig.Codes = {
    -- Starter codes
    ["WELCOME"] = {
        reward = { type = "coins", amount = 500 },
        description = "Welcome to the game!",
        oneTime = true,
        expiresAt = nil,
    },
    ["FREECOINS"] = {
        reward = { type = "coins", amount = 1000 },
        description = "Free coins!",
        oneTime = true,
        expiresAt = nil,
    },
    ["FREEPET"] = {
        reward = { type = "egg", eggType = "Basic" },
        description = "Free Basic Egg!",
        oneTime = true,
        expiresAt = nil,
    },
    
    -- Special codes
    ["LEGENDARY2026"] = {
        reward = { type = "coins", amount = 10000 },
        description = "Happy 2026!",
        oneTime = true,
        expiresAt = nil,
    },
    ["GOLDENSTART"] = {
        reward = { type = "egg", eggType = "Golden" },
        description = "Golden Egg code!",
        oneTime = true,
        expiresAt = nil,
    },
    ["SUPERSPEED"] = {
        reward = { type = "coins", amount = 5000 },
        description = "Go fast!",
        oneTime = true,
        expiresAt = nil,
    },
    
    -- Dad's special code ;)
    ["DADISAWESOME"] = {
        reward = { type = "coins", amount = 25000 },
        description = "Dad IS awesome!",
        oneTime = true,
        expiresAt = nil,
    },
}

function CodesConfig.GetCode(code)
    return CodesConfig.Codes[string.upper(code)]
end

function CodesConfig.IsExpired(code)
    local codeData = CodesConfig.GetCode(code)
    if not codeData then return true end
    if not codeData.expiresAt then return false end
    return os.time() > codeData.expiresAt
end

return CodesConfig
