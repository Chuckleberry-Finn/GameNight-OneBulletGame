local oneBulletDamage = require("gameNight-oneBulletDamage.lua")

if isServer() then
    local function onClientCommand(_module, _command, _player, _data)
        if _module ~= "gameNightOneBullet" then return end
        if _command == "damage" then
            oneBulletDamage.fromWeapon(_data.gun, _player)
        end
    end
    Events.OnClientCommand.Add(onClientCommand)--what the server gets from the client
end