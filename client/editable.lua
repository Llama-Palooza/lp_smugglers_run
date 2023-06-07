
if Config.settings.newQB then QBCore = exports['qb-core']:GetCoreObject() else QBCore = nil	TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj	end) end

local function getLocation(coords)
	local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
	local currentStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
	currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
	playerStreetsLocation = currentStreetName .. ", " .. zone
	return playerStreetsLocation
end

function CustomAlert(vehicle)
    -- Input Your Own!
    if Config.settings.debug then print('customAlert') end
    local src = source
    local Player = QBCore.Functions.GetPlayerData()
    local ped = PlayerPedId()
    local currentPos = GetEntityCoords(ped)
    local locationInfo = getLocation(currentPos)  
    local veh = vehicle
    if Player.job.name == 'police' and Player.job.onduty then
    -- if Player.job.type == 'leo' and Player.job.onduty then
        TriggerEvent('QBCore:Notify', _U('theft')..locationInfo, 'police', 10000)
    end    
end

