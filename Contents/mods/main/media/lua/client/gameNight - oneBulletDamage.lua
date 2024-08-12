local oneBulletDamage = {}

---@param player IsoObject|IsoGameCharacter|IsoLivingCharacter|IsoPlayer
---@param weapon HandWeapon
function oneBulletDamage.fromWeapon(weapon, player)

    local damage = weapon and weapon:getMinDamage() or 0
    if damage <=0 then return end

    local bodyDamage = player:getBodyDamage()
    local head = BodyPartType.Head
    local BodyPart = bodyDamage:getBodyPart(head)
    local partIndex = BodyPart:getIndex()

    local clothingProtection = player:getBodyPartClothingDefense(partIndex, false, true)

    if (ZombRand(100) < clothingProtection) then
        player:addHoleFromZombieAttacks(BloodBodyPartType.FromIndex(partIndex), true)
    else
        player:addHole(BloodBodyPartType.FromIndex(partIndex))

        player:addBlood(BloodBodyPartType.Head, true, true, true)
        player:addBlood(BloodBodyPartType.Torso_Upper, true, false, false)
        player:addBlood(BloodBodyPartType.UpperArm_L, true, false, false)
        player:addBlood(BloodBodyPartType.UpperArm_R, true, false, false)

        player:splatBloodFloorBig()
        player:splatBloodFloorBig()
        player:splatBloodFloorBig()

        bodyDamage:setInfectionLevel(0)

        player:Kill(player)
    end
end

return oneBulletDamage