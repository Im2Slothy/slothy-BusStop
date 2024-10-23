qbcore = exports['qb-core']:GetCoreObject()
local currentBusStop = nil
local isNearBusStop = false

-- Add bus stop blips to the map
Citizen.CreateThread(function()
    for _, busStop in pairs(Config.BusStops) do
        local blip = AddBlipForCoord(busStop.coords.x, busStop.coords.y, busStop.coords.z)
        SetBlipSprite(blip, 513)  -- Bus icon
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(busStop.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Get the player's proximity to bus stops
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        isNearBusStop = false
        currentBusStop = nil

        -- Loop through all bus stops
        for _, busStop in pairs(Config.BusStops) do
            local distance = #(playerCoords - busStop.coords)

            -- Check if player is near the bus stop
            if distance < 3.0 then -- Adjust this radius to reduce flickering
                isNearBusStop = true
                currentBusStop = busStop

                -- Display help prompt (Press E)
                DrawText3D(busStop.coords.x, busStop.coords.y, busStop.coords.z, "[E] Take the bus")

                -- Detect interaction key press
                if IsControlJustReleased(0, Config.InteractKey) then
                    OpenBusMenu()  -- Open the bus menu for the player to select a destination
                end
                break  -- Exit the loop since the player is near a bus stop
            end
        end

        if isNearBusStop then
            Citizen.Wait(0)  -- Run without delay if player is near a bus stop
        else
            Citizen.Wait(1000)  -- Run every second when player is far from bus stops to save resources
        end
    end
end)

-- Start travel after payment is successful
RegisterNetEvent('bus:startTravel')
AddEventHandler('bus:startTravel', function(destinationCoords, travelTime)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local offset = vector3(15.0, 0.0, 0.0) -- Move the player so they don't see the [E] to take the bus
    SetEntityCoords(playerPed, playerCoords.x + offset.x, playerCoords.y + offset.y, playerCoords.z, false, false, false, true)
    SetEntityVisible(playerPed, false)  -- Hide the player during travel
    -- Play a sound to simulate travel start
    PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "HUD_AWARDS", 1)    
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    Wait(1000)
    -- Check if travelTime is valid, if nil set a default time to prevent errors. It breaks sometimes and I'm not 100% sure why.
    if not travelTime or travelTime <= 0 then
        travelTime = 10  -- Default travel time if not calculated correctly
    end

    -- Start countdown for travel time
    local remainingTime = travelTime
    while remainingTime > 0 do
        -- Display countdown in chat
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Bus", "Arriving in " .. remainingTime .. " seconds..."}
        })

        -- Wait 1 second before decrementing the countdown
        Citizen.Wait(1000)
        remainingTime = remainingTime - 1
    end

    Wait(2500)
    SetEntityCoords(playerPed, destinationCoords.x, destinationCoords.y, destinationCoords.z, false, false, false, true)
    SetEntityVisible(playerPed, true)  -- Hide the player during travel
    SwitchInPlayer(PlayerPedId())  -- Switch back to the player
    TriggerEvent('QBCore:Notify', 'You have arrived at your destination!', 'success')
end)

-- Listen for the destination selection
RegisterNetEvent('bus:selectDestination')
AddEventHandler('bus:selectDestination', function(data)
    local busStop = data.busStop
    local price = data.price
    local travelTime = data.time
    TriggerServerEvent('bus:payForTrip', busStop.coords, price, travelTime)
end)

function OpenBusMenu()
    local menu = {
        {
            header = "Select Bus Destination",
            isMenuHeader = true
        }
    }

    for _, busStop in pairs(Config.BusStops) do
        if busStop ~= currentBusStop then
            -- Calculate the distance to each destination
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - busStop.coords)

            -- Calculate price and time based on distance
            local price = math.floor(busStop.basePrice + (Config.DistancePriceMultiplier * distance))
            local time = busStop.baseTime

            -- Ensure travel time isn't nil or 0
            if not time or time <= 0 then time = 10 end  -- Default time in case of any issue

            table.insert(menu, {
                header = busStop.name,
                txt = "Price: $" .. price .. " - Time: " .. time .. " Seconds",
                params = {
                    event = "bus:selectDestination",
                    args = {
                        busStop = busStop,
                        price = price,
                        time = time
                    }
                }
            })
        end
    end

    table.insert(menu, {
        header = "Cancel",
        txt = "Cancel destination selection",
        params = {
            event = "bus:cancelDestinationSelection"
        }
    })

    exports['qb-menu']:openMenu(menu)
end    

-- Helper function to display 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end