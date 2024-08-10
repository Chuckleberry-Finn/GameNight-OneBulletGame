--- CREDIT TO AITERON
require "TimedActions/ISBaseTimedAction"
local OneBulletGameAnim = ISBaseTimedAction:derive("OneBulletGameAnim")
function OneBulletGameAnim:isValid() return true end

function OneBulletGameAnim:update()
    local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then UIManager.getSpeedControls():SetCurrentGameSpeed(1) end

    ---@type IsoPlayer|IsoGameCharacter|IsoLivingCharacter|IsoObject
    local player = self.character
    ---@type InventoryItem|HandWeapon
    local gun = self.item

    if self:getJobDelta() > self.shotTime and not self.doAction then
        self.doAction = true

        local dumbass = (gun:getMagazineType() or gun:isRackAfterShoot())

        local maxRounds = gun:getMaxAmmo()
        local currentChamber = (not dumbass) and gun:getModData()["gameNight_oneBulletGame_nextChamber"] or 1

        if (not dumbass) then
            local nextUp = (currentChamber or 0) + 1
            if nextUp > maxRounds then nextUp = 1 end
            gun:getModData()["gameNight_oneBulletGame_nextChamber"] = nextUp
        end

        local ammo = gun:getCurrentAmmoCount() or 0

        if ammo >= currentChamber then
            player:playSound(gun:getSwingSound())
            local radius = gun:getSoundRadius()
            if isClient() then radius = radius / 1.8 end
            player:addWorldSoundUnlessInvisible(radius, gun:getSoundVolume(), false)
            player:startMuzzleFlash()
            ISReloadWeaponAction.onShoot(player, gun)

            if (not player:isGodMod()) then player:Kill(player) end

            player:splatBloodFloorBig()
        else
            self:forceComplete()
            player:playSound(gun:getClickSound())
        end
    end

    if self:getJobDelta() >= 1 then self:forceComplete() end
end

function OneBulletGameAnim:start() self:setActionAnim(self.anim) end

function OneBulletGameAnim:new(character, item)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.item = item

    o.anim = "OneBulletGame"
    o.shotTime = 0.35
    o.maxTime = 100

    return o
end

return OneBulletGameAnim