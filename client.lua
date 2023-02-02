local escudoon = false
local escudoentidad = nil
local escudopistola = false

local DICT = "combat@gestures@gang@pistol_1h@beckon"
local NAME = "0"

local prop = "prop_ballistic_shield"
local pistol = GetHashKey("WEAPON_PISTOL")

RegisterCommand("escudo", function()
    if escudoon then
        DisableShield()
    else
        EnableShield()
    end
end, false)

function EnableShield()
    escudoon = true
    local ped = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(ped, false)
    
    RequestAnimDict(DICT)
    while not HasAnimDictLoaded(DICT) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(ped, DICT, NAME, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

    RequestModel(GetHashKey(prop))
    while not HasModelLoaded(GetHashKey(prop)) do
        Citizen.Wait(100)
    end

    local escudo = CreateObject(GetHashKey(prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
    escudoentidad = escudo
    AttachEntityToEntity(escudoentidad, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

    if HasPedGotWeapon(ped, pistol, 0) or GetSelectedPedWeapon(ped) == pistol then
        SetCurrentPedWeapon(ped, pistol, 1)
        escudopistola = true
    end
end

function DisableShield()
    local ped = GetPlayerPed(-1)
    DeleteEntity(escudoentidad)
    ClearPedTasksImmediately(ped)
    SetWeaponAnimationOverride(ped, GetHashKey("Default"))

    if not escudopistola then
        RemoveWeaponFromPed(ped, pistol)
    end
    SetEnableHandcuffs(ped, false)
    escudopistola = false
    escudoon = false
end

Citizen.CreateThread(function()
    while true do
        if escudoon then
            local ped = GetPlayerPed(-1)
            if not IsEntityPlayingAnim(ped, DICT, NAME, 1) then
                RequestAnimDict(DICT)
                while not HasAnimDictLoaded(DICT) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, DICT, NAME, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
        end
        Citizen.Wait(500)
    end
end)

RegisterNetEvent('keko-escudo:useitem', function()
    if escudoon then
        DisableShield()
    else
        EnableShield()
    end
end, false)