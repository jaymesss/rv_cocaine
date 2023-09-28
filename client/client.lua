local QBCore = exports[Config.CoreName]:GetCoreObject()
local CrateIsFalling = false
local AirdropObject = nil
local CocainePickedUp = false
local Plane = nil
local Blip = nil
local Timer = 0

Citizen.CreateThread(function()
    -- PLANE
    RequestModel(GetHashKey(Config.Plane.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.Plane.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.Plane.Ped.Model), Config.Plane.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports[Config.TargetName]:AddBoxZone('coke-plane', Config.Plane.Target.Coords, 1.5, 1.6, {
        name = "coke-plane",
        heading = Config.Plane.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_cocaine:client:BuyPlane",
                icon = "fas fa-sheet-plastic",
                label = Locale.Info.start_coke_job
            }
        }
    })
    -- LAB ENTER
    exports[Config.TargetName]:AddBoxZone('coke-lab-enter', Config.Lab.Enter.Target.Coords, 1.5, 1.6, {
        name = "coke-lab-enter",
        heading = Config.Lab.Enter.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_cocaine:client:EnterLab",
                icon = "fas fa-door-open",
                label = Locale.Info.enter_lab
            }
        }
    })
    -- LAB EXIT
    exports[Config.TargetName]:AddBoxZone('coke-lab-exit', Config.Lab.Exit.Target.Coords, 1.5, 1.6, {
        name = "coke-lab-exit",
        heading = Config.Lab.Exit.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_cocaine:client:LeaveLab",
                icon = "fas fa-door-open",
                label = Locale.Info.leave_lab
            }
        }
    })
    -- BREAK DOWN
    exports[Config.TargetName]:AddBoxZone('coke-break-down', Config.Lab.BreakDown.Target.Coords, 1.5, 1.6, {
        name = "coke-break-down",
        heading = Config.Lab.BreakDown.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_cocaine:client:BreakDown",
                icon = "fas fa-cubes-stacked",
                label = Locale.Info.break_down_bricks
            }
        }
    })
    -- Purify
    exports[Config.TargetName]:AddBoxZone('coke-purify', Config.Lab.Purify.Target.Coords, 1.5, 1.6, {
        name = "coke-purify",
        heading = Config.Lab.Purify.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_cocaine:client:Purify",
                icon = "fas fa-cubes-stacked",
                label = Locale.Info.purify_cocaine
            }
        }
    })
    -- Package
    exports[Config.TargetName]:AddBoxZone('coke-package', Config.Lab.Package.Target.Coords, 1.5, 1.6, {
        name = "coke-package",
        heading = Config.Lab.Package.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_cocaine:client:Package",
                icon = "fas fa-cubes-stacked",
                label = Locale.Info.package_cocaine
            }
        }
    })
end)

RegisterNetEvent('rv_cocaine:client:BuyPlane', function()
    lib.registerContext({
        id = 'coke_plane',
        title = Locale.Info.job_listing,
        options = {
            {
                title = Locale.Info.start_job,
                description = Locale.Info.start_job_description,
                icon = 'money-bill',
                onSelect = function()
                    local p = promise.new()
                    local allowed
                    QBCore.Functions.TriggerCallback('rv_cocaine:server:CanAffordDeposit', function(result)
                        p:resolve(result)
                    end)
                    allowed = Citizen.Await(p)
                    if not allowed then
                        return
                    end
                    if Plane ~= nil then
                        QBCore.Functions.Notify(Locale.Error.already_have_mission, 'error', 5000)
                        return
                    end
                    SpawnPlane()
                end
            },
            {
                title = Locale.Info.dont_start,
                description = Locale.Info.dont_start_description,
                icon = 'x',
                onSelect = function()
                    QBCore.Functions.Notify(Locale.Error.backed_out, 'error', 5000)
                end
            },           
        },
    })
    lib.showContext('coke_plane')
end)

Citizen.CreateThread(function()
    while true do
        if Plane ~= nil and AirdropObject ~= nil and not CocainePickedUp then
            local coords = GetEntityCoords(PlayerPedId(), false)
            local airdropCoords = GetEntityCoords(AirdropObject, false)
            if #(coords - airdropCoords) < 10 and GetEntitySpeed(Plane) < 10 then
                DrawMarker(2,vector3(airdropCoords.x, airdropCoords.y, airdropCoords.z + 1.5), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                DrawText3Ds(vector3(airdropCoords.x, airdropCoords.y, airdropCoords.z + 1.5), '~g~E~w~ - ' .. Locale.Info.pick_up_airdrop) 
                if IsControlJustReleased(0, 38) then
                    QBCore.Functions.Progressbar("picking", Locale.Info.picking_up_airdrop, 10000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {
                    }, {}, {}, function() -- Done
                        CocainePickedUp = true
                        QBCore.Functions.Notify(Locale.Success.back_to_airfield, 'success', 5000)
                        RemoveBlip(Blip)
                        Blip = AddBlipForCoord(Config.Plane.Spawn.Coords)
                        SetBlipSprite(Blip, 501)
                        SetBlipScale(Blip, 0.9)
                        SetBlipColour(Blip, 4)
                        SetBlipDisplay(Blip, 4)
                        SetBlipAsShortRange(Blip, false)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentSubstringPlayerName("Airstrip")
                        EndTextCommandSetBlipName(a3)
                    end, function() -- Cancel
                    end)
                end
            end
        end
        if CocainePickedUp then
            local coords = GetEntityCoords(PlayerPedId(), false)
            local airstripCoords = Config.Plane.Spawn.Coords
            if GetDistanceBetweenCoords(coords, airstripCoords) < 10 and GetEntitySpeed(Plane) < 5 then
                DrawMarker(2,vector3(airstripCoords.x, airstripCoords.y, airstripCoords.z + 1), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                DrawText3Ds(vector3(airstripCoords.x, airstripCoords.y, airstripCoords.z + 1), '~g~E~w~ - ' .. Locale.Info.return_plane) 
                if IsControlJustReleased(0, 38) then
                    QBCore.Functions.Progressbar("picking", Locale.Info.returning_plane, 2000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {
                    }, {}, {}, function() -- Done
                        SetEntityAsMissionEntity(Plane, true, true)
                        DeleteVehicle(Plane)
                        RemoveBlip(Blip)
                        CocainePickedUp = false
                        Plane = nil
                        AirdropObject = nil
                        Blip = nil
                        CrateIsFalling = false
                        if Timer <= 0 then
                            QBCore.Functions.Notify(Locale.Error.failed_mission, 'error', 5000)
                            return
                        end
                        QBCore.Functions.Notify(Locale.Success.good_job, 'success', 5000)
                        TriggerServerEvent('rv_cocaine:server:MissionComplete')
                    end, function() -- Cancel
                    end)
                end
            end
        end
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if Timer > 0 then
            Timer = Timer - 1
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('rv_cocaine:client:EnterLab', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"knock"})
    QBCore.Functions.Progressbar("entering", Locale.Info.entering_lab, 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        SetEntityCoords(PlayerPedId(), Config.Lab.Enter.Teleport.Coords)
        SetEntityHeading(PlayerPedId(), Config.Lab.Enter.Teleport.Coords.w)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_cocaine:client:LeaveLab', function()
    QBCore.Functions.Progressbar("leaving", Locale.Info.leaving_lab, 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        SetEntityCoords(PlayerPedId(), Config.Lab.Exit.Teleport.Coords)
        SetEntityHeading(PlayerPedId(), Config.Lab.Exit.Teleport.Coords.w)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_cocaine:client:BreakDown', function()
    local p = promise.new()
    local amount
    QBCore.Functions.TriggerCallback('rv_cocaine:server:GetCocaineBricks', function(result)
        p:resolve(result)
    end)
    amount = Citizen.Await(p)
    if amount <= 0 then
        return
    end
    local ped = PlayerPedId()
    local animDict = 'anim@amb@business@coc@coc_unpack_cut@'
    local anim = 'fullcut_cycle_cokecutter'
    LoadAnimDict(animDict)
    local duration = 5000 + (amount * 5000)
    TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, 8.0, duration, 0)
    QBCore.Functions.Progressbar("breaking_down", Locale.Info.breaking_down_bricks, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerServerEvent('rv_cocaine:server:BreakDownBricks', amount)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_cocaine:client:Purify', function()
    local p = promise.new()
    local amount
    QBCore.Functions.TriggerCallback('rv_cocaine:server:GetPureCocaine', function(result)
        p:resolve(result)
    end)
    amount = Citizen.Await(p)
    if amount <= 0 then
        return
    end
    local ped = PlayerPedId()
    local animDict = 'anim@amb@business@coc@coc_unpack_cut@'
    local anim = 'fullcut_cycle_cokecutter'
    LoadAnimDict(animDict)
    local duration = 5000 + (amount * 2500)
    TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, 8.0, duration, 0)
    QBCore.Functions.Progressbar("purifying", Locale.Info.purifying_cocaine, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerServerEvent('rv_cocaine:server:PurifyCocaine', amount)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_cocaine:client:Package', function()
    local p = promise.new()
    local amount
    QBCore.Functions.TriggerCallback('rv_cocaine:server:GetProcessedCocaine', function(result)
        p:resolve(result)
    end)
    amount = Citizen.Await(p)
    if amount <= 0 then
        return
    end
    local ped = PlayerPedId()
    local animDict = 'anim@amb@business@coc@coc_unpack_cut@'
    local anim = 'fullcut_cycle_cokecutter'
    LoadAnimDict(animDict)
    local duration = 5000 + (amount * 1000)
    TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, 8.0, duration, 0)
    QBCore.Functions.Progressbar("packaging", Locale.Info.packaging_cocaine, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerServerEvent('rv_cocaine:server:PackageCocaine', amount)
    end, function() -- Cancel
    end)
end)

function SpawnPlane()
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netid)
        local vehicle = NetToVeh(netid)
        exports[Config.FuelResource]:SetFuel(vehicle, 100)
        SetEntityHeading(vehicle, Config.Plane.Spawn.Coords.w)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        Plane = vehicle
    end, Config.Plane.Model, Config.Plane.Spawn.Coords, false)
    while Plane == nil do
        Citizen.Wait(1)
    end
    SetEntityHeading(Plane, Config.Plane.Spawn.Coords.w)
    Blip = AddBlipForCoord(Config.CrateLocation)
    SetBlipSprite(Blip, 94)
    SetBlipScale(Blip, 0.9)
    SetBlipColour(Blip, 4)
    SetBlipDisplay(Blip, 4)
    SetBlipAsShortRange(Blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Airdrop")
    EndTextCommandSetBlipName(ai)
    Timer = Config.Plane.MissionTime
    QBCore.Functions.Notify(Locale.Success.return_plane, 'success', 5000)
    local models = { 
        "p_cargo_chute_s", "prop_box_wood02a_pu"
    }
    for v = 1, #models do
        LoadModel(GetHashKey(models[v]))
    end
    local retval, groundZ = GetGroundZFor_3dCoord(Config.CrateLocation.x, Config.CrateLocation.y, Config.CrateLocation.z, false)
    local zCoord = retval and groundZ or Config.CrateLocation.z
    local exists, groundZ2 = GetWaterHeight(Config.CrateLocation.x, Config.CrateLocation.y, Config.CrateLocation.z)
    if exists and groundZ2 > zCoord then
        zCoord = groundZ2 - .6
    end
    local coords = vector3(Config.CrateLocation.x, Config.CrateLocation.y, zCoord + 170)
    CrateIsFalling = true
    local crate = CreateObject(-1861623876, coords.x, coords.y, coords.z, false, false, false)
    SetEntityLodDist(crate, 3500)
    ActivatePhysics(crate)
    SetDamping(crate, 2, .1)
    SetEntityVelocity(crate, .0, .0, -.3)
    SetEntityInvincible(crate, true)
    SetEntityCollision(crate, false, true)
    local chute = CreateObject(886894755, coords.x, coords.y, coords.z, false, false, false)
    SetEntityLodDist(chute, 3500)
    SetEntityVelocity(chute, .0, .0, -.3)
    SetEntityCollision(chute, false, true)
    SetEntityInvincible(chute, true)
    local sound = GetSoundId()
    PlaySoundFromEntity(sound, "Crate_Beeps", crate, "MP_CRATE_DROP_SOUNDS", true, 0)
    AttachEntityToEntity(chute, crate, 0, .0, .0, .3, .0, .0, .0, false, false, true, false, 2, true)
    FreezeEntityPosition(crate, false)
    local netId = NetworkGetNetworkIdFromEntity(crate)
    AirdropObject = crate
    CocainePickedUp = false
    local airdropCoords = GetEntityCoords(AirdropObject, false)
    while not DoesEntityExist(AirdropObject) or airdropCoords.z > zCoord do
        if not DoesEntityExist(AirdropObject) then
            AirdropObject = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId)
        end
        airdropCoords = GetEntityCoords(AirdropObject, false)
        if GetEntitySpeed(AirdropObject) < .3 then
            SetEntityVelocity(AirdropObject, 0.0, 0.0, -0.5)
            SetEntityVelocity(chute, 0.0, 0.0, -0.5)
        end
        Wait(1)
    end
    local chuteCoords = vector3(GetEntityCoords(chute, false))
    DetachEntity(chute, true, true)
    DeleteEntity(chute)
    FreezeEntityPosition(AirdropObject, true)
    SetEntityCoords(AirdropObject, Config.CrateLocation.x, Config.CrateLocation.y, zCoord, false, false, false, false)
    SetEntityCollision(crate, true, true)
    CrateIsFalling = false
    local airdropCoords = GetEntityCoords(AirdropObject, false)
    while not CocainePickedUp do
        Wait(1)
        if not DoesEntityExist(AirdropObject) then
            AirdropObject = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId)
        end
        if DoesEntityExist(AirdropObject) then
            SetEntityCoords(AirdropObject, airdropCoords.x, airdropCoords.y, zCoord, false, false, false, false)
        end
    end
    StopSound(sound)
    ReleaseSoundId(sound)
    for v = 1, #models do
        SetModelAsNoLongerNeeded(GetHashKey(models[v]))
    end
    DeleteEntity(AirdropObject)
    AirdropObject = nil
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
end

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x,coords.y,coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end