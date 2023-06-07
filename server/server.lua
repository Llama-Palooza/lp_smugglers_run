if Config.settings.newQB then QBCore = exports['qb-core']:GetCoreObject() else QBCore = nil	TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj	end) end

local copAmount = {}

-- Functions
local function _U(entry) return locales[Config.locale][entry] end

local function firstToUpper(str) return (str:gsub("^%l", string.upper)) end

-- Callbacks
QBCore.Functions.CreateCallback('lp_smugglers_run:server:giveNote', function(source, cb)
    local item = Config.itemRun.item[math.random(1, #Config.itemRun.item)]
    local amount = math.random(Config.itemRun.amount.min, Config.itemRun.amount.max)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src) 
    if not Player then return end
    info = {label = 'Item: '..item..' | Amount: '..amount}
    Wait(50)
    if Player.Functions.AddItem('stickynote', 1, false, info) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['stickynote'], "add", 1) 
        cb(true, item, amount)         
    else
        cb(false)
        TriggerClientEvent('QBCore:Notify', src,  'You arr carrying too much', 'error') 
    end    
end)

QBCore.Functions.CreateCallback('lp_smugglers_run:server:givePayment', function(source, cb, pay, item, amount, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local paid = false 
    if not Player then return end  
    if type then
        if pay ~= 0 and not paid then  
            if Player.Functions.RemoveItem(item, amount) then
                Player.Functions.AddMoney('cash', pay)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", amount) 
                TriggerClientEvent('QBCore:Notify', src, "You received $"..pay, 'success')
                paid = true
            end
        end
    else
        Player.Functions.AddMoney('cash', pay)
        TriggerClientEvent('QBCore:Notify', src, "You received $"..pay, 'success')
    end
    if paid then cb(true) else cb(false) end
end)

QBCore.Functions.CreateCallback('lp_smugglers_run:server:getCops', function(source, cb, cost)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)    
    if not Player then return end  
    local cashBalance = Player.PlayerData.money["cash"]
    local feePaid = false
	local amount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    if cashBalance >= cost then feePaid = true Player.Functions.RemoveMoney('cash', cost) end
    copAmount[source] = amount
    cb(amount, feePaid)
end)

QBCore.Functions.CreateCallback('lp_smugglers_run:server:spawnVehicle', function(source, cb, veh, coords)
    local pos = coords
    local CreateAutomobile = GetHashKey("CREATE_AUTOMOBILE")
    local vehicle = Citizen.InvokeNative(CreateAutomobile, GetHashKey(veh), coords, coords.w, true, false)
    while not DoesEntityExist(vehicle) do
        Wait(25)
    end
    if DoesEntityExist(vehicle) then
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        cb(netId)
    else
        cb(0)
    end
end)    

-- Events
RegisterNetEvent('lp_smugglers_run:server:pabloSanchez', function(poop)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end  
    Player.Functions.AddMoney('cash', poop)
    TriggerClientEvent('QBCore:Notify', src, "You received $"..poop, 'success')
end)



