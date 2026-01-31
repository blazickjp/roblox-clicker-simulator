--[[
    PetsSystem - Hatch eggs and collect pets!
    
    🥚 Buy eggs
    🐣 Hatch them for random pets
    🐾 Equip pets to boost your coins!
    
    Rarities:
    🟢 Common - 60%
    🔵 Rare - 25%
    🟣 Epic - 12%
    🟡 Legendary - 3%
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Wait for shared folder
local SharedFolder = ReplicatedStorage:WaitForChild("shared", 10)

local PetsConfig
local DataStoreManager
local PlayerData

-- Load dependencies
local function loadDependencies()
    if not PetsConfig and SharedFolder then
        pcall(function()
            PetsConfig = require(SharedFolder:WaitForChild("PetsConfig", 5))
        end)
    end
    if not DataStoreManager then
        pcall(function()
            DataStoreManager = require(script.Parent.DataStoreManager)
        end)
    end
    if not PlayerData then
        pcall(function()
            PlayerData = require(script.Parent.PlayerData)
        end)
    end
end

-- Create RemoteEvents
local BuyEgg = Instance.new("RemoteEvent")
BuyEgg.Name = "BuyEgg"
BuyEgg.Parent = ReplicatedStorage

local EquipPet = Instance.new("RemoteEvent")
EquipPet.Name = "EquipPet"
EquipPet.Parent = ReplicatedStorage

local UnequipPet = Instance.new("RemoteEvent")
UnequipPet.Name = "UnequipPet"
UnequipPet.Parent = ReplicatedStorage

local PetHatched = Instance.new("RemoteEvent")
PetHatched.Name = "PetHatched"
PetHatched.Parent = ReplicatedStorage

-- Generate unique pet ID
local function generatePetId()
    return HttpService:GenerateGUID(false)
end

-- Roll for rarity based on egg type
-- FIXED: Use ordered array instead of pairs() which has undefined order!
local RARITY_ORDER = {"Common", "Rare", "Epic", "Legendary"}

local function rollRarity(eggType)
    loadDependencies()
    if not PetsConfig then return "Common" end
    
    local chances = PetsConfig.EggChances[eggType] or PetsConfig.EggChances.Basic
    local roll = math.random(1, 1000) / 10  -- 0.1 precision for decimal chances like 4.5%
    local cumulative = 0
    
    -- Iterate in DEFINED order (Common → Rare → Epic → Legendary)
    for _, rarity in ipairs(RARITY_ORDER) do
        local chance = chances[rarity] or 0
        cumulative = cumulative + chance
        if roll <= cumulative then
            return rarity
        end
    end
    
    return "Common"
end

-- Get random pet from rarity
local function getRandomPet(rarity)
    loadDependencies()
    if not PetsConfig then return nil end
    
    local petsOfRarity = PetsConfig.Pets[rarity]
    if not petsOfRarity or #petsOfRarity == 0 then
        return PetsConfig.Pets.Common[1]
    end
    
    return petsOfRarity[math.random(1, #petsOfRarity)]
end

-- Hatch an egg!
local function hatchEgg(player, eggType)
    loadDependencies()
    if not PetsConfig or not DataStoreManager then return nil end
    
    local eggConfig = PetsConfig.Eggs[eggType]
    if not eggConfig then return nil end
    
    local data = DataStoreManager.GetData(player)
    if not data then return nil end
    
    -- Check if player can afford
    if data.Coins < eggConfig.cost then
        return nil
    end
    
    -- Deduct cost
    data.Coins = data.Coins - eggConfig.cost
    
    -- Roll for rarity
    local rarity = rollRarity(eggType)
    
    -- Get random pet of that rarity
    local petTemplate = getRandomPet(rarity)
    if not petTemplate then return nil end
    
    -- Check if this is their FIRST PET EVER! (milestone moment)
    local isFirstPet = (#data.Pets == 0)
    
    -- Create pet instance
    local rarityConfig = PetsConfig.Rarities[rarity]
    local pet = {
        id = generatePetId(),
        name = petTemplate.name,
        emoji = petTemplate.emoji,
        rarity = rarity,
        bonus = petTemplate.bonus * rarityConfig.multiplier,
        model = petTemplate.model,
        hatchedAt = os.time(),
        isFirstPet = isFirstPet,  -- Flag for extra celebration on client!
    }
    
    -- Add to player's pets
    table.insert(data.Pets, pet)
    data.EggsHatched = data.EggsHatched + 1
    
    if isFirstPet then
        print("🎉🐣 " .. player.Name .. " hatched their FIRST PET EVER! Welcome to pet ownership!")
    end
    
    -- Track rarity stats
    if rarity == "Rare" then
        data.RaresHatched = data.RaresHatched + 1
    elseif rarity == "Epic" then
        data.EpicsHatched = data.EpicsHatched + 1
    elseif rarity == "Legendary" then
        data.LegendariesHatched = data.LegendariesHatched + 1
    end
    
    print("🐣 " .. player.Name .. " hatched a " .. rarity .. " " .. pet.name .. "!")
    
    return pet
end

-- Buy and hatch egg
BuyEgg.OnServerEvent:Connect(function(player, eggType)
    local pet = hatchEgg(player, eggType)
    
    if pet then
        -- Tell the client about the new pet!
        PetHatched:FireClient(player, pet)
        
        -- Update stats
        local StatsUpdated = ReplicatedStorage:FindFirstChild("StatsUpdated")
        if StatsUpdated and PlayerData then
            local stats = PlayerData.GetAllStats(player)
            if stats then
                StatsUpdated:FireClient(player, stats)
            end
        end
    end
end)

-- Equip a pet (max 3 equipped)
EquipPet.OnServerEvent:Connect(function(player, petId)
    loadDependencies()
    if not DataStoreManager then return end
    
    local data = DataStoreManager.GetData(player)
    if not data then return end
    
    -- Check if pet exists
    local hasPet = false
    for _, pet in ipairs(data.Pets) do
        if pet.id == petId then
            hasPet = true
            break
        end
    end
    if not hasPet then return end
    
    -- Check if already equipped
    for _, id in ipairs(data.EquippedPets) do
        if id == petId then return end
    end
    
    -- Check max equipped (3)
    if #data.EquippedPets >= 3 then
        -- Remove oldest
        table.remove(data.EquippedPets, 1)
    end
    
    -- Equip!
    table.insert(data.EquippedPets, petId)
    print("🐾 " .. player.Name .. " equipped pet " .. petId)
    
    -- Update stats
    local StatsUpdated = ReplicatedStorage:FindFirstChild("StatsUpdated")
    if StatsUpdated and PlayerData then
        local stats = PlayerData.GetAllStats(player)
        if stats then
            StatsUpdated:FireClient(player, stats)
        end
    end
end)

-- Unequip a pet
UnequipPet.OnServerEvent:Connect(function(player, petId)
    loadDependencies()
    if not DataStoreManager then return end
    
    local data = DataStoreManager.GetData(player)
    if not data then return end
    
    for i, id in ipairs(data.EquippedPets) do
        if id == petId then
            table.remove(data.EquippedPets, i)
            print("🐾 " .. player.Name .. " unequipped pet " .. petId)
            break
        end
    end
    
    -- Update stats
    local StatsUpdated = ReplicatedStorage:FindFirstChild("StatsUpdated")
    if StatsUpdated and PlayerData then
        local stats = PlayerData.GetAllStats(player)
        if stats then
            StatsUpdated:FireClient(player, stats)
        end
    end
end)

-- Give free egg (for codes/rewards)
function _G.GiveEgg(player, eggType)
    loadDependencies()
    if not PetsConfig or not DataStoreManager then return nil end
    
    local data = DataStoreManager.GetData(player)
    if not data then return nil end
    
    -- Give the coins to cover the egg, then hatch
    local eggConfig = PetsConfig.Eggs[eggType]
    if eggConfig then
        data.Coins = data.Coins + eggConfig.cost
    end
    
    return hatchEgg(player, eggType)
end

print("🐾 PetsSystem loaded!")
