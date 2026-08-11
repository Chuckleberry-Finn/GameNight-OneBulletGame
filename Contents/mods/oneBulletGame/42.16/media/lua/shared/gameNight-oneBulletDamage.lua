local oneBulletDamage = {}

---@param player IsoObject|IsoGameCharacter|IsoLivingCharacter|IsoPlayer
---@param weapon HandWeapon
function oneBulletDamage.fromWeapon(weapon, player)

    if isClient() then
        sendClientCommand(player, "gameNightOneBullet", "damage", {gun=weapon})
        return
    end

    local damage = weapon and weapon:getMinDamage() or 0
    if damage <=0 then return end

    local bodyDamage = player:getBodyDamage()
    local head = BodyPartType.Head
    local BodyPart = bodyDamage:getBodyPart(head)
    local partIndex = BodyPart:getIndex()
    local stats = player:getStats()

    local clothingProtection = player:getBodyPartClothingDefense(partIndex, false, true)

    player:helmetFall(true)

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

        if bodyDamage.setInfectionLevel then bodyDamage:setInfectionLevel(0) end

        stats:set(CharacterStat.ZOMBIE_INFECTION, 0)

        ---player:doDeathSplatterAndSounds(weapon, player, true)
        player:Kill(player)
    end
end

return oneBulletDamage