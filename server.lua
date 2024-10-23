QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('bus:checkMoney', function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player.Functions.GetMoney('cash') >= price then
        cb(true)
    else
        cb(false)
    end
end)

-- Deduct the fare when the player takes the bus
RegisterNetEvent('bus:payFare', function(price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Deduct the fare from the player's money
    Player.Functions.RemoveMoney('cash', price, "bus-fare")
end)

-- Bus travel attempt
RegisterNetEvent('bus:attemptTravel')
AddEventHandler('bus:attemptTravel', function(price, busStop)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    local cashBalance = Player.PlayerData.money.cash
    local bankBalance = Player.PlayerData.money.bank
    local totalBalance = cashBalance + bankBalance

    -- Check if the player has enough money in total (cash + bank)
    if totalBalance >= price then
        -- Deduct money from cash first, then from bank if needed
        if cashBalance >= price then
            Player.Functions.RemoveMoney('cash', price)
        else
            local remainingPrice = price - cashBalance
            Player.Functions.RemoveMoney('cash', cashBalance)  -- Remove all cash
            Player.Functions.RemoveMoney('bank', remainingPrice)  -- Remove the rest from the bank
        end

        -- Notify successful payment
        TriggerClientEvent('QBCore:Notify', src, 'You paid $'..price..' for the bus ride.', 'success')

        -- Bus travel
        TriggerClientEvent('bus:startTravel', src, busStop.coords)
    else
        -- Calculate how much more money the player needs
        local missingAmount = price - totalBalance
        TriggerClientEvent('QBCore:Notify', src, 'You need $'..missingAmount..' more to pay for the bus fare.', 'error')
    end
end)

-- Event to handle payment and travel initiation
RegisterNetEvent('bus:payForTrip')
AddEventHandler('bus:payForTrip', function(destinationCoords, price, travelTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Check if player has enough money in bank or cash
    if Player.Functions.GetMoney('bank') >= price then
        Player.Functions.RemoveMoney('bank', price)

        -- Start travel
        TriggerClientEvent('bus:startTravel', src, destinationCoords, travelTime)
    elseif Player.Functions.GetMoney('cash') >= price then
        Player.Functions.RemoveMoney('cash', price)

        -- Start travel
        TriggerClientEvent('bus:startTravel', src, destinationCoords, travelTime)
    else
        -- Doesn't have enough money
        local missingAmount = price - Player.Functions.GetMoney('bank') - Player.Functions.GetMoney('cash')
        TriggerClientEvent('QBCore:Notify', src, "Not enough money. You need $" .. missingAmount .. " more.", 'error')
    end
end)
