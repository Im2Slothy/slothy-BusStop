local QBCore = exports['qb-core']:GetCoreObject()
local activePassengers = {}

-- Check if player has enough money for the fare
QBCore.Functions.CreateCallback('slothy-busStops:server:checkMoney', function(source, cb, fare)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return cb(false) end
    
    if Player.PlayerData.money['cash'] >= fare then
        cb(true)
    elseif Player.PlayerData.money['bank'] >= fare then
        cb(true)
    else
        cb(false)
    end
end)

-- Pay the bus fare
RegisterNetEvent('slothy-busStops:server:payFare', function(fare)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if Player.PlayerData.money['cash'] >= fare then
        Player.Functions.RemoveMoney('cash', fare, "bus-fare")
    else
        Player.Functions.RemoveMoney('bank', fare, "bus-fare")
    end
end)

-- Register a passenger on a bus
RegisterNetEvent('slothy-busStops:server:registerPassenger', function(tripInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    activePassengers[src] = {
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        fromLocation = tripInfo.fromLocation,
        fromStop = tripInfo.fromStop,
        toLocation = tripInfo.toLocation,
        toDistrict = tripInfo.toDistrict,
        toStop = tripInfo.toStop,
        departureTime = tripInfo.departureTime
    }
    
    print('[slothy-busStops] Registered passenger ' .. src)
end)

-- Unregister a passenger when they arrive
RegisterNetEvent('slothy-busStops:server:unregisterPassenger', function()
    local src = source
    activePassengers[src] = nil
    print('[slothy-busStops] Unregistered passenger ' .. src)
end)

-- Get list of active passengers
QBCore.Functions.CreateCallback('slothy-busStops:server:getPassengers', function(source, cb)
    local passengers = {}
    
    for _, passengerInfo in pairs(activePassengers) do
        table.insert(passengers, passengerInfo)
    end
    
    print('[slothy-busStops] Returning ' .. #passengers .. ' passengers')
    cb(passengers)
end)

-- Clean up when a player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    activePassengers[src] = nil
end)
