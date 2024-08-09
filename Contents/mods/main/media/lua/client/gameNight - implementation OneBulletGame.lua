local applyItemDetails = require "gameNight - applyItemDetails"
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

local OneBulletGame = {}

OneBulletGame.guns = {}

function OneBulletGame.registerSpecial(gun, itemFullName)
    local gunIcon = gun:getTexture()
    local w = gunIcon and gunIcon:getWidth() or 32
    local h = gunIcon and gunIcon:getHeight() or 32
    table.insert(OneBulletGame.guns, itemFullName)
    gamePieceAndBoardHandler.registerSpecial(itemFullName, {
        ignoreCategory=true, category="Weapon", textureSize = {w*4,h*4}, actions = { playOneBulletGame=true, rollCylinder=true },
    })
end


function OneBulletGame.setGuns()
    local allItems = getScriptManager():getAllItems()

    for i=0, allItems:size()-1 do
        ---@type Item
        local itemScript = allItems:get(i)
        if itemScript:isRanged() and tostring(itemScript:getType()) == "Weapon" then
            local itemFullName = itemScript:getFullName()
            ---@type InventoryItem|HandWeapon
            local gun = InventoryItemFactory.CreateItem(itemFullName)
            if gun and gun:getWeaponReloadType() == "revolver" then
                OneBulletGame.registerSpecial(gun, itemFullName)
            end
        end
    end

    if #OneBulletGame.guns > 0 then gamePieceAndBoardHandler.registerTypes(OneBulletGame.guns) end
end


function OneBulletGame.addGun(moduleType) table.insert(OneBulletGame.guns, moduleType) end

---EXAMPLE:
--
-- local OneBulletGame = require "gameNight - implementation OneBulletGame"
-- OneBulletGame.addGun("module.type")
--



---@param gamePiece InventoryItem|HandWeapon
function gamePieceAndBoardHandler.rollCylinder_isValid(gamePiece, player, num)
    ---@type InventoryItem|HandWeapon
    local gun = gamePiece
    local dumbass = (gun:getMagazineType() or gun:isRackAfterShoot())
    if dumbass then return false end
    --if gun and gun:getWorldItem() then return true end
    return true
end


function gamePieceAndBoardHandler.rollCylinder(gamePiece, player, x, y, z)

    ---@type InventoryItem|HandWeapon
    local gun = gamePiece
    local maxRounds = gun:getMaxAmmo()
    local nextUp = ZombRand(maxRounds)+1

    gamePieceAndBoardHandler.playSound(gamePiece, player, "rollCylinder")
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_oneBulletGame_nextChamber", nextUp}, nil, x, y, z)
end

--[[
function gamePieceAndBoardHandler.playOneBulletGame_isValid(gamePiece, player, num)
    if gamePiece and gamePiece:getWorldItem() then return true end
    return false
end
--]]

require "TimedActions/ISReloadWeaponAction.lua"
local oneBulletGameTimedAction = require "gameNight - oneBulletGameTimedAction.lua"
---@param player IsoPlayer|IsoGameCharacter|IsoLivingCharacter|IsoObject
function gamePieceAndBoardHandler.playOneBulletGame(gamePiece, player, x, y, z)
    gamePieceAndBoardHandler.pickupGamePiece(player, gamePiece, nil, nil)

    ---@type InventoryItem|HandWeapon
    local gun = gamePiece
    if isForceDropHeavyItem(player:getPrimaryHandItem()) then ISTimedActionQueue.add(ISUnequipAction:new(player, player:getPrimaryHandItem(), 10)) end
    local twoHands = gun:isTwoHandWeapon()
    ISTimedActionQueue.add(ISEquipWeaponAction:new(player, gun, 5, true, twoHands))
    ISTimedActionQueue.add(oneBulletGameTimedAction:new(player, gun))
end


return OneBulletGame


--TODO: LOOK AT THIS
---function ISUI3DScene:instantiate()
--	self.javaObject = UI3DScene.new(self)