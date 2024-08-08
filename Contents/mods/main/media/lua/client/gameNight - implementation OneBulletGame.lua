local applyItemDetails = require "gameNight - applyItemDetails"
--local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

--getMagazineType--

local OneBulletGame = {}

function OneBulletGame.setGuns()
    local allItems = ScriptManager.instance:getAllItems()
    local guns = {}
    for i=0, allItems:size()-1 do
        ---@type Item
        local itemScript = allItems:get(i)

        if itemScript:isRanged() and tostring(itemScript:getType()) == "Weapon" then

            print("ONE_BULLET:",itemScript:getFullName(), " : ", itemScript:getType())

            local itemFullName = itemScript:getFullName()
            ---@type InventoryItem|HandWeapon
            local gun = InventoryItemFactory.CreateItem(itemFullName)
            if gun:getWeaponReloadType() == "revolver" then

                local gunIcon = gun:getTexture()
                local w = gunIcon and gunIcon:getWidth() or 32
                local h = gunIcon and gunIcon:getHeight() or 32

                table.insert(guns, itemFullName)
                gamePieceAndBoardHandler.registerSpecial(itemFullName, { textureSize = {w*4,h*4}, actions = { playOneBulletGame=true, rollCylinder=true }, })
            end
        end
    end

    if #guns > 0 then
        gamePieceAndBoardHandler.registerTypes(guns)
    end
end

--[[
---@param gamePiece InventoryItem|HandWeapon
function gamePieceAndBoardHandler.rollCylinder_isValid(gamePiece, player, num)
    if gamePiece and gamePiece:getWorldItem() then return true end
    return false
end
--]]

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