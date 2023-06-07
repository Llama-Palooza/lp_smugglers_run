local QBCore

if Config.settings.newQB then QBCore = exports['qb-core']:GetCoreObject() else QBCore = nil TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end) end

local startPeds, enemy, npc = {}, {}, {}
local cargoVeh = {}
local getIn, done = false, false
local route, blip = nil, nil
local missionVehicle
local npcPed
local chaseVeh
local missionVeh
local plate
local total
local package

local function _U(entry) return locales[Config.locale][entry] end

local function firstToUpper(str) return (str:gsub("^%l", string.upper)) end

local function finishPed(run, pos)
    RequestModel('s_m_y_doorman_01') while not HasModelLoaded('s_m_y_doorman_01') do Wait(1) end
    local finGuy = CreatePed(0, GetHashKey('s_m_y_doorman_01'), pos.x, pos.y, pos.z, pos.w, true, true)
    Wait(50)
    local networkID = NetworkGetNetworkIdFromEntity(finGuy)
    SetNetworkIdCanMigrate(networkID, true)
    SetNetworkIdExistsOnAllMachines(networkID, true)  
    SetBlockingOfNonTemporaryEvents(finGuy, true)
    SetPedFleeAttributes(finGuy, 0, false)
    SetPedCanRagdollFromPlayerImpact(finGuy, false)
    SetEntityAsMissionEntity(finGuy)
    SetEntityInvincible(finGuy, true)
    TaskStartScenarioInPlace(finGuy, 'WORLD_HUMAN_CLIPBOARD', -1, false)
    SetPedCanBeTargetted(finGuy, false)
    SetEntityVisible(finGuy, true)
    FreezeEntityPosition(finGuy, true)
    exports['qb-target']:AddTargetEntity(finGuy, {
        options = {
            {
                icon = "fa-solid fa-landmark-flag",
                label = 'End Run',
                type = 'client',
                action = function(entity)
                    TriggerEvent('lp_smugglers_run:client:finishRun', run, finGuy)           
                end
                -- canInteract = function()
                --     for k, v in pairs(enemy) do
                --         if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(v.ped)) > 200 then                    
                -- end	             	
            }
        },
        distance = 2.5             
    })
    npc[#npc+1] = {ped = finGuy}
end

-- Create Mission Route
local function createRoute(run, coords)
	if route then  RemoveBlip(route) end
    route = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(route, 271)
    SetBlipDisplay(route, 2)
    SetBlipScale(route, 0.9)
    SetBlipAsShortRange(route, false)
    SetBlipColour(route, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(firstToUpper(run.type).." delivery")
    EndTextCommandSetBlipName(route)
    SetBlipRoute(route, true)
    Wait(1000)
    finishPed(run, coords)
end

local function doFade(entity)
    SetEntityAlpha(entity, 204, false)
    Wait(250)
    SetEntityAlpha(entity, 153, false)
    Wait(250)
    SetEntityAlpha(entity, 102, false)
    Wait(250)
    SetEntityAlpha(entity, 51, false)
    Wait(250)
    SetEntityAlpha(entity, 0, false)
end

-- Spawn Mission Enemies
local function badGuys(run)
    local enemyCars = {'vamos', 'gauntlet4', 'sultanrs'}
    Wait(math.random(30000, 45000))  
    local chosenCar = enemyCars[math.random(1, #enemyCars)]  
	local vehhash = GetHashKey(chosenCar)                                                  
	-- local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do Wait(1) end
	RequestModel('g_m_m_chicold_01')
	while not HasModelLoaded('g_m_m_chicold_01') do Wait(1) end
    CreateThread(function()
        while true do
            Wait(1000)
            for k, v in pairs(enemy) do        
                TaskVehicleChase(v.ped, PlayerPedId())
                SetTaskVehicleChaseBehaviorFlag(v.ped, 2, true)
                TaskShootAtEntity(v.ped, ped, -1, GetHashKey("FIRING_PATTERN_BURST_FIRE_DRIVEBY"))      
                if IsEntityUpsidedown(v.veh) then doFade(v.ped) Wait(1200) QBCore.Functions.DeleteVehicle(v.veh) end
                if IsEntityDead(v.ped) then doFade(v.ped) Wait(1200) DeletePed(v.ped) QBCore.Functions.DeleteVehicle(v.veh) end   
            end
        end
    end)
	if not DoesEntityExist(vehhash) then
        local spawning = true
        local ped = PlayerPedId()
        local count = 0
        SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))
        AddRelationshipGroup("MERCS")
        while spawning do
            Wait(math.random(15000,25000))
            if count < run.level then loc = GetEntityCoords(PlayerPedId())                                
                if not Config.settings.useRoads then    
                    local spawnRadius = Config.settings.spawnRadius                                             
                    chaseVeh = CreateVehicle(vehhash, loc.x, loc.y - 15.0, loc.z, GetEntityHeading(ped), true, false)        
                else
                    local spawnRadius = math.random(10,15)
                    found, spawnPos, spawnHeading = GetClosestRoad(loc.x, loc.y, loc.z, 0, 3, 0) 
                    if found then
                        chaseVeh = CreateVehicle(vehhash, spawnPos.x, spawnPos.y - spawnRadius, spawnPos.z, spawnHeading, true, false) 
                    else
                        chaseVeh = CreateVehicle(vehhash, loc.x, loc.y - 15.0, loc.z, GetEntityHeading(ped), true, false)     
                    end
                end                      
                ClearAreaOfVehicles(GetEntityCoords(chaseVeh), 1, false, false, false, false, false)
                SetVehicleOnGroundProperly(chaseVeh)
                SetVehicleNumberPlateText(chaseVeh, "DEEZNUTZ")
                SetEntityAsMissionEntity(chaseVeh, true, true)
                SetVehicleEngineOn(chaseVeh, true, true, false)     
                ModifyVehicleTopSpeed(chaseVeh, 35.0)
                -- SetVehicleMaxSpeed(chaseVeh, 300.0)  
                npcPed = CreatePedInsideVehicle(chaseVeh, 26, GetHashKey('g_m_m_chicold_01'), -1, true, true) 
                npcBlip = AddBlipForEntity(chaseVeh)   
                SetBlipSprite(npcBlip, 630)    
                SetBlipAsFriendly(npcBlip, false)                                          	
                SetBlipFlashes(npcBlip, true)  
                SetBlipColour(npcBlip, 2)
                SetEntityMaxHealth(npcBlip, 1000)
                SetEntityHealth(npcBlip, 1000)
                SetPedFleeAttributes(npcPed, 0, false)   
                GiveWeaponToPed(npcPed, GetHashKey(run.weapon), 255, false, true) 
                SetPedCanSwitchWeapon(npcPed, true)  
                SetDriverAbility(npcPed, 1.0)
                SetDriveTaskDrivingStyle(npcPed, 786468 )
                SetBlockingOfNonTemporaryEvents(npcPed, true)
                SetPedRelationshipGroupHash(npcPed, GetHashKey("MERCS"))
                enemy[#enemy+1] = {ped = npcPed, veh = chaseVeh}
                count = count + 1                
            end
            if count == 3 then break end
        end
    end
    local mission = true
    SetRelationshipBetweenGroups(0, GetHashKey("MERCS"), GetHashKey("MERCS"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("MERCS"))  
    -- CreateThread(function()
    --     while true do
    --         Wait(100)
    --         for k, v in pairs(enemy) do        
    --             if DoesEntityExist(v.ped) then
    --                 local dist = #(GetEntityCoords(v.ped) - GetEntityCoords(ped))
    --                 if dist > 1000 then
    --                     DeletePed(v.ped)
    --                     QBCore.Functions.DeleteVehicle(v.veh)                        
    --                 end
    --             end
    --         end
    --     end
    -- end)
    
    -- TaskGoToEntity(npcPed, ped, -1, 1, 200.0, 1073741824, 0)
end

-- Mission Start / Vehicle Check
local function missionStarted(run, plate, coords)
    local ped = PlayerPedId()
    local subject = "Nice work..."
    local msg = "I see you found the vehicle. Bring it to the location marked on your GPS. Be careful, someone may come looking for it..."
    getIn = true
    CreateThread(function()
        while getIn do            
            if IsPedGettingIntoAVehicle(ped) then  
                local currentVeh = GetVehiclePedIsEntering(ped) 
                local currentPlate = QBCore.Functions.GetPlate(currentVeh) 
                if string.upper(currentPlate) == string.upper(plate) then getIn = false missionVeh = currentVeh
                    if Config.settings.useEmail then TriggerEvent('lp_smugglers_run:client:sendEmail', run, subject, msg) end
                    if blip then RemoveBlip(blip) end
                    createRoute(run, coords)  
                    badGuys(run) 
                end
            end
            Wait(100)
        end
    end)
end

-- Mission Vehicle Blip
local function createVehBlip(run, veh, spawn, coords, plate)
	if blip then RemoveBlip(blip) end blip = AddBlipForRadius(spawn.x - math.random(50,300), spawn.y + math.random(50,300), spawn.z, 500.0) 
    SetBlipRotation(blip, 0) SetBlipAlpha(blip, 64) SetBlipColour(blip, 47)
    Wait(50) 
    missionStarted(run, plate, coords)
end

-- Finish Mission/Run
local function endRun(run, npc)
    RemoveBlip(route)
    Wait(250)    
    if #enemy >= 1 then for k, v in pairs(enemy) do doFade(v.ped) doFade(v.veh) Wait(1200) DeletePed(v.ped) QBCore.Functions.DeleteVehicle(v.veh) end end
    if #cargoVeh > 0 then for k, v in pairs(cargoVeh) do doFade(v.veh) Wait(1200) QBCore.Functions.DeleteVehicle(v.veh) end end
    if run.type ~= 'items' then doFade(missionVeh) Wait(1200) QBCore.Functions.DeleteVehicle(missionVeh) end    
    doFade(npc)
    Wait(1200)
    DeletePed(npc)   
    busy = false
    -- QBCore.Functions.DeleteVehicle(missionVeh)  
    -- if #enemy >= 1 then for k, v in pairs(enemy) do DeletePed(v.ped) QBCore.Functions.DeleteVehicle(v.veh) end end
    -- TriggerServerEvent('lp_smugglers_run:server:pabloSanchez', run.reward)
end

-- Attach Vehicle to Tow Truck
RegisterNetEvent('lp_smugglers_run:client:attachVehicle', function(coords)
-- local function attachVehicle(coords)
    local model = 'cheetah2'
    local newPos = vector4(coords.x, coords.y + 2.8, coords.z + 3.5, coords.w)
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        missionVehicle = NetToVeh(netId)
        SetEntityAsMissionEntity(missionVehicle, true, true)
        local carPlate = QBCore.Shared.RandomStr(8)
        SetEntityHeading(missionVehicle, newPos.w)
        SetVehicleFixed(missionVehicle) 
        cargoVeh[#cargoVeh+1] = { veh = missionVehicle}
    end, model, newPos, false)  
    Wait(math.random(750,1000))
    -- FreezeEntityPosition(missionVehicle, true)
    for k, v in pairs(cargoVeh) do AttachEntityToEntity(v.veh, missionVeh, GetEntityBoneIndexByName(vehicle, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 0.94, 0, 0, 0, 1, 1, 0, 1, 0, 1) FreezeEntityPosition(v.veh, true) end 
end)

-- Spawn Mission Vehicle
RegisterNetEvent('lp_smugglers_run:client:paloozaCar', function(run)
    -- local vehicle = run.veh
    local vehicle = run.veh[math.random(1, #run.veh )]
    local endPos = Config.locations["Finish"][math.random(1, #Config.locations["Finish"])]
    local vehSpawn = Config.locations["VehSpawn"][math.random(1, #Config.locations["VehSpawn"])]
    plate = "RUN"..QBCore.Shared.RandomStr(5)
    local subject = firstToUpper(run.type).." Mission"
    local msg = 'I see you\'re wanting to make some extra cash.. We\'ve located a vehicle with some product stashed inside of it. Go find it, further instructions will be sent. The plate # is: '..plate    
    if #(endPos - run.start) < 1000.0 then endPos = Config.locations["Finish"][math.random(1, #Config.locations["Finish"])] end
    Wait(100) 
    if #(endPos - run.start) < 1000.0 then endPos = Config.locations["Finish"][math.random(1, #Config.locations["Finish"])] end  
    Wait(100) 
    if #(endPos - run.start) < 1000.0 then endPos = Config.locations["Finish"][math.random(1, #Config.locations["Finish"])] end   
    ClearAreaOfVehicles(vehSpawn, 5.0, false, false, false, false, false)
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        missionVeh = NetToVeh(netId)
        SetEntityAsMissionEntity(missionVeh, true, true)
        SetVehicleEngineOn(missionVeh, false, true)
        SetVehicleNumberPlateText(missionVeh, plate)
        SetEntityHeading(missionVeh, vehSpawn.w)
        exports['LegacyFuel']:SetFuel(missionVeh, 100.0)
        SetVehicleFixed(missionVeh)        
        SetVehicleDoorsLocked(missionVeh, 2)
        SetVehicleMaxSpeed(missionVeh, 36.0)
        createVehBlip(run, missionVeh, vehSpawn, endPos, plate)        
    end, vehicle, vehSpawn, false)          
    Wait(math.random(100,500))
    -- if run.type == 'vehicle' then TriggerEvent('lp_smugglers_run:client:attachVehicle', vehSpawn) end  
    if Config.settings.useEmail then TriggerEvent('lp_smugglers_run:client:sendEmail', run, subject, msg) end
end)

-- Start Item Run
RegisterNetEvent('lp_smugglers_run:client:startItemRun', function(run)
    if run.veh then return end
    QBCore.Functions.TriggerCallback('lp_smugglers_run:server:giveNote', function(given, item, amount)
        if given then 
            package = item
            total = amount
            local endPos = Config.locations["Finish"][math.random(1, #Config.locations["Finish"])]   
            if Config.settings.useEmail then
                local subject = "Special Items"
                local msg = 'Bring the items on the sticky note to the drop off and we\'ll take care of you.'
                TriggerEvent('lp_smugglers_run:client:sendEmail', run, subject, msg)
            end
            createRoute(run, endPos)
        end
    end)
end)

-- Email Notification
RegisterNetEvent('lp_smugglers_run:client:sendEmail', function(run, sub, msg)
    SetTimeout(math.random(1500, 3000), function()
        if Config.settings.phone == 'qb' then
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender = 'Anonymous',
                subject = sub,
                message = msg,
                button = {}
            })
        elseif Config.settings.phone == 'gks' then
            local MailData = {
                sender = 'Anonymous',
                image = '/html/static/img/icons/mail.png',
                subject = sub,
                message = msg
            }
            exports["gksphone"]:SendNewMail(MailData)
        end 
    end)
end)

-- Finish Mission
RegisterNetEvent('lp_smugglers_run:client:finishRun', function(run, npc)
    if run.type ~= 'items' then
        CreateThread(function()
            local ped = PlayerPedId()
            local vehCoords = GetEntityCoords(missionVeh)
            local pCoords = GetEntityCoords(ped)
            if #(pCoords - vehCoords) <= 25.0 then
                for k, v in pairs(enemy) do
                    if done then return end Wait(100)
                    if DoesEntityExist(v.ped) then
                        if #(pCoords - GetEntityCoords(v.ped)) < 50.0 then return end Wait(100)
                        if #(pCoords - GetEntityCoords(v.ped)) < 50.0 then return end Wait(100)
                        if #(pCoords - GetEntityCoords(v.ped)) < 50.0 then return end Wait(100)                                  
                        QBCore.Functions.TriggerCallback('lp_smugglers_run:server:givePayment', function(cb)
                            if cb then done = true endRun(run, npc) end
                        end, run.reward, nil, nil, false)
                    else
                        QBCore.Functions.TriggerCallback('lp_smugglers_run:server:givePayment', function(cb)
                            if cb then done = true endRun(run, npc) end
                        end, run.reward, nil, nil, false)
                    end
                end
            else print('mission vehicle too far away') end
        end) 
    else
        QBCore.Functions.TriggerCallback('lp_smugglers_run:server:givePayment', function(cb)
            if cb then done = true endRun(run, npc) end
        end, run.reward, package, total, true)
    end
end)

-- Create Start Peds
local function createPeds()
    for k, v in pairs (Config.locations["Start"]) do        
        -- local startNPC = Config.locations["Start"][i]
        RequestModel(GetHashKey(v.ped))
        while not HasModelLoaded(GetHashKey(v.ped)) do Wait(1) end
        startPeds[k] = CreatePed(4, GetHashKey(v.ped), v.start.x, v.start.y, v.start.z, v.start.w, false, true)
        Wait(math.random(200,500))
        -- local networkID = NetworkGetNetworkIdFromEntity(startPeds[k])
        -- SetNetworkIdCanMigrate(networkID, true)
        -- SetNetworkIdExistsOnAllMachines(networkID, true)  
        -- SetBlockingOfNonTemporaryEvents(startPeds[k], true)
        SetPedFleeAttributes(startPeds[k], 0, false)
        SetPedCanRagdollFromPlayerImpact(startPeds[k], false)
        SetEntityAsMissionEntity(startPeds[k])
        SetEntityInvincible(startPeds[k], true)
        TaskStartScenarioInPlace(startPeds[k], 'WORLD_HUMAN_CLIPBOARD', -1, false)
        SetPedCanBeTargetted(startPeds[k], false)
        SetEntityVisible(startPeds[k], true)
        FreezeEntityPosition(startPeds[k], true)
        exports['qb-target']:AddTargetEntity(startPeds[k], {
            options = {
                {
                    icon = "fa-solid fa-landmark-flag",
                    label = 'Start Mission | $'..v.cost,
                    type = 'client',
                    action = function(entity)
                        QBCore.Functions.TriggerCallback('lp_smugglers_run:server:getCops', function(cops, payment)
                            if cops >= Config.settings.police.copsNeeded then
                                if payment then
                                    if v.veh ~= nil then
                                        TriggerEvent('lp_smugglers_run:client:paloozaCar', v)     
                                        busy = true
                                    else
                                        TriggerEvent('lp_smugglers_run:client:startItemRun', v)
                                        busy = true
                                    end
                                else
                                    TriggerEvent('QBCore:Notify', 'Not enough money | (cost: '..v.cost..')', 'error', 5000)
                                end
                            else
                                TriggerEvent('QBCore:Notify', 'Not enough police', 'error', 5000)
                            end
                        end, v.cost)
                    end,
                    canInteract = function()               
                        if busy then return false end
                        return true
                    end                  	
                }
            },
            distance = 2.5             
        })
    end
end

-- Starting Thread
CreateThread(function() createPeds() end)

-- Misc Events
AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        for _, v in pairs(startPeds) do DeleteEntity(v) end
        if #enemy > 0 then for k, v in pairs(enemy) do DeletePed(v.ped) QBCore.Functions.DeleteVehicle(v.veh) end end         
        if #cargoVeh > 0 then print('meme') for k, v in pairs(cargoVeh) do QBCore.Functions.DeleteVehicle(v.veh) end end
        QBCore.Functions.DeleteVehicle(missionVeh)
    end    
end)

-- AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
-- 	createPeds()
-- end)


