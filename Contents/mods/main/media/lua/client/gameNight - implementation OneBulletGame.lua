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
                table.insert(guns, itemFullName)
                gamePieceAndBoardHandler.registerSpecial(itemFullName, { textureSize = {140,140}, actions = { rollCylinder=true }, })
            end
        end
    end

    if #guns > 0 then
        gamePieceAndBoardHandler.registerTypes(guns)
    end
end


function gamePieceAndBoardHandler.rollCylinder(gamePiece, player, x, y, z)

    ---@type InventoryItem|HandWeapon
    local gun = gamePiece
    local maxRounds = gun:getMaxAmmo()

    local chance = ZombRand(maxRounds)+1



    gamePieceAndBoardHandler.playSound(gamePiece, player, "rollCylinder")
    gamePieceAndBoardHandler.pickupGamePiece(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_oneBulletGame_Current", chance}, nil)
end


return OneBulletGame