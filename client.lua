local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local activePassengers = {}
local currentStopData = nil
local busZones = {}

-- Initialize the script
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('[slothy-busStops] Resource started')
    Wait(1000) -- Wait for resources to fully load
    InitializeBusStops()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    print('[slothy-busStops] Player loaded, initializing bus stops')
    PlayerData = QBCore.Functions.GetPlayerData()
    InitializeBusStops()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Add debug function
function DebugPrint(message)
    if Config.Debug then
        print('[slothy-busStops] ' .. message)
    end
end

-- Initialize all bus stop targets
function InitializeBusStops()
    -- Clear any existing zones
    for _, zone in pairs(busZones) do
        exports.ox_target:removeZone(zone)
    end
    busZones = {}
    
    DebugPrint('Initializing all bus stops')
    
    for locationId, locationData in pairs(Config.Locations) do
        if locationData.type == "city" then
            for districtId, districtData in pairs(locationData.subDistricts) do
                for i, stop in ipairs(districtData.stops) do
                    DebugPrint('Creating city stop: ' .. locationId .. ' - ' .. districtId .. ' - ' .. stop.label)
                    CreateBusStopTarget(locationId, districtId, stop, i)
                end
            end
        else
            for i, stop in ipairs(locationData.stops) do
                DebugPrint('Creating town stop: ' .. locationId .. ' - ' .. stop.label)
                CreateBusStopTarget(locationId, nil, stop, i)
            end
        end
    end
    
    DebugPrint('Total bus stops created: ' .. #busZones)
end

-- Create individual bus stop target points
function CreateBusStopTarget(locationId, districtId, stop, index)
    local zoneName = 'bus_stop_' .. locationId .. '_' .. (districtId or 'main') .. '_' .. index
    DebugPrint('Adding target: ' .. zoneName .. ' at ' .. json.encode(stop.coords))
    
    local zoneId = exports.ox_target:addBoxZone({
        name = zoneName,
        coords = stop.coords,
        size = vector3(2.0, 2.0, 3.0),
        rotation = stop.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'interact_bus_stop',
                icon = 'fas fa-bus',
                label = 'Interact with Bus Stop',
                onSelect = function()
                    DebugPrint('Interacting with bus stop: ' .. stop.label)
                    HandleBusStopInteraction(locationId, districtId, stop)
                end
            }
        }
    })
    
    table.insert(busZones, zoneName)
end

function HandleBusStopInteraction(locationId, districtId, stop)
    local playerData = QBCore.Functions.GetPlayerData()
    local isLEO = Config.LEOTracking.Enabled and playerData.job and IsPlayerLEO(playerData.job.name)
    
    local menuOptions = {
        {
            title = 'Use Bus Stop',
            description = 'Plan your bus trip',
            icon = 'fas fa-bus',
            onSelect = function()
                DebugPrint('Selected bus stop: ' .. stop.label)
                OpenBusStopMenu(locationId, districtId, stop)
            end
        }
    }
    
    -- Add LEO option if the player is currently LEO
    if isLEO then
        table.insert(menuOptions, {
            title = 'Check Passenger List',
            description = 'View current bus passengers',
            icon = 'fas fa-clipboard-list',
            onSelect = function()
                DebugPrint('LEO checking passenger list')
                OpenPassengerListMenu(locationId, districtId, stop)
            end
        })
    end
    
    lib.registerContext({
        id = 'bus_stop_interaction_menu',
        title = 'Bus Stop - ' .. stop.label,
        options = menuOptions
    })
    
    lib.showContext('bus_stop_interaction_menu')
end

-- Helper function to check if player is LEO
function IsPlayerLEO(jobName)
    for _, leoJob in pairs(Config.LEOTracking.Departments) do
        if jobName == leoJob then
            return true
        end
    end
    return false
end

-- Add a command to reinitialize bus stops for debugging
RegisterCommand('refreshbusstops', function()
    DebugPrint('Manually refreshing bus stops')
    InitializeBusStops()
end, false)

-- Open bus stop menu for regular citizens
function OpenBusStopMenu(currentLocationId, currentDistrictId, stop)
    currentStopData = {
        locationId = currentLocationId,
        districtId = currentDistrictId,
        stop = stop
    }
    
    local menuOptions = {}
    
    -- Add menu header
    table.insert(menuOptions, {
        title = 'Bus Transportation',
        description = 'Select your destination',
        icon = 'fas fa-bus'
    })
    
    -- Add location options (exclude current location)
    for locationId, locationData in pairs(Config.Locations) do
        if locationId ~= currentLocationId then
            table.insert(menuOptions, {
                title = 'Travel to ' .. locationData.label,
                description = CalculateTripInfo(currentLocationId, locationId),
                icon = 'fas fa-map-marker-alt',
                onSelect = function()
                    if locationData.type == "city" then
                        -- If it's a city, we need to show districts
                        OpenDistrictSelectionMenu(locationId, locationData)
                    else
                        -- If it's a town, show stops directly
                        OpenStopSelectionMenu(locationId, nil, locationData)
                    end
                end
            })
        end
    end
    
    lib.registerContext({
        id = 'bus_stop_menu',
        title = 'Bus Stop - ' .. stop.label,
        options = menuOptions
    })
    
    lib.showContext('bus_stop_menu')
end

-- Open district selection menu for cities
function OpenDistrictSelectionMenu(locationId, locationData)
    local menuOptions = {}
    
    -- Add menu header
    table.insert(menuOptions, {
        title = locationData.label .. ' Districts',
        description = 'Select a district',
        icon = 'fas fa-city'
    })
    
    -- Add district options
    for districtId, districtData in pairs(locationData.subDistricts) do
        table.insert(menuOptions, {
            title = districtData.label,
            description = 'View bus stops in ' .. districtData.label,
            icon = 'fas fa-map-signs',
            onSelect = function()
                OpenStopSelectionMenu(locationId, districtId, districtData)
            end
        })
    end
    
    lib.registerContext({
        id = 'district_selection_menu',
        title = 'Select District in ' .. locationData.label,
        options = menuOptions
    })
    
    lib.showContext('district_selection_menu')
end

-- Open stop selection menu
function OpenStopSelectionMenu(locationId, districtId, data)
    local menuOptions = {}
    local stops = data.stops
    
    -- Add menu header
    table.insert(menuOptions, {
        title = 'Bus Stops',
        description = 'Select your destination stop',
        icon = 'fas fa-bus'
    })
    
    -- Add stop options
    for _, stop in ipairs(stops) do
        table.insert(menuOptions, {
            title = stop.label,
            description = 'Travel to this bus stop',
            icon = 'fas fa-map-pin',
            onSelect = function()
                StartBusJourney(locationId, districtId, stop)
            end
        })
    end
    
    lib.registerContext({
        id = 'stop_selection_menu',
        title = 'Select Bus Stop',
        options = menuOptions
    })
    
    lib.showContext('stop_selection_menu')
end

-- Calculate fare and trip duration
function CalculateTripInfo(fromLocation, toLocation)
    local distance = Config.Distances[fromLocation][toLocation]
    local fare = Config.BusFare.BasePrice + (distance * Config.BusFare.PricePerKM)
    local duration = distance * 0.5 -- 0.5 minutes per km
    
    return string.format('Fare: $%d | Duration: %.1f minutes', math.floor(fare), duration)
end

-- Start the bus journey
function StartBusJourney(toLocationId, toDistrictId, toStop)
    local fromLocationId = currentStopData.locationId
    local distance = Config.Distances[fromLocationId][toLocationId]
    local fare = Config.BusFare.BasePrice + (distance * Config.BusFare.PricePerKM)
    local duration = distance * 30000 -- 30 seconds per km (in ms)
    
    local tripInfo = CalculateTripInfo(fromLocationId, toLocationId)
    local confirm = lib.alertDialog({
        header = 'Confirm Trip',
        content = 'From: ' .. Config.Locations[fromLocationId].label .. '\nTo: ' .. Config.Locations[toLocationId].label .. 
                 (toDistrictId and (' - ' .. Config.Locations[toLocationId].subDistricts[toDistrictId].label) or '') ..
                 '\n' .. tripInfo,
        centered = true,
        cancel = true
    })
    
    if confirm ~= 'confirm' then return end
    
    QBCore.Functions.TriggerCallback('slothy-busStops:server:checkMoney', function(hasMoney)
        if not hasMoney then
            lib.notify({
                title = 'Insufficient Funds',
                description = 'You don\'t have enough money for this trip',
                type = 'error'
            })
            return
        end
        
        local departureTime = math.floor(GetGameTimer() / 1000) -- Convert to seconds
        
        TriggerServerEvent('slothy-busStops:server:registerPassenger', {
            fromLocation = Config.Locations[fromLocationId].label,
            fromStop = currentStopData.stop.label,
            toLocation = Config.Locations[toLocationId].label,
            toDistrict = toDistrictId and Config.Locations[toLocationId].subDistricts[toDistrictId].label or nil,
            toStop = toStop.label,
            departureTime = departureTime
        })
        
        -- Pass the destination stop label to BusTripSequence
        BusTripSequence(duration, toStop.coords, toStop.heading, fare, toStop.label)
    end, fare)
end

-- Bus trip animation sequence
function BusTripSequence(duration, destCoords, destHeading, fare)
    local player = PlayerPedId()
    
    -- Pay for the trip
    TriggerServerEvent('slothy-busStops:server:payFare', fare)
    
    -- Get destination name for notifications (passed from StartBusJourney via a new parameter)
    local destination = currentStopData.stop.label -- We'll modify StartBusJourney to pass this
    
    -- Switch out the player (start the journey)
    SwitchOutPlayer(player, 0, 1) -- 0 = no flags, 1 = switch state
    
    -- Use the full duration as calculated
    local actualDuration = duration -- duration is already in milliseconds from StartBusJourney
    local totalSeconds = math.floor(actualDuration / 1000) -- Convert to seconds for countdown
    local startTime = GetGameTimer()
    local endTime = startTime + actualDuration
    
    -- Countdown timer in seconds (console and player notifications)
    Citizen.CreateThread(function()
        local notifyInterval = 30 -- Notify every 30 seconds
        for secondsLeft = totalSeconds, 0, -1 do
            -- Log to console
            print('[slothy-busStops] Bus trip countdown: ' .. secondsLeft .. ' seconds remaining')
            
            -- Show notification every 30 seconds (including at start and end)
            if secondsLeft % notifyInterval == 0 or secondsLeft == totalSeconds or secondsLeft == 0 then
                lib.notify({
                    title = 'Bus Trip Update',
                    description = secondsLeft .. ' seconds until you arrive at ' .. destination,
                    type = 'inform',
                    duration = 5000 -- Show for 5 seconds
                })
            end
            
            Wait(1000) -- Wait 1 second per iteration
        end
    end)
    
    -- Wait for the trip duration
    while GetGameTimer() < endTime do
        Wait(0) -- Keep the script responsive
    end
    
    -- Teleport player to destination
    SetEntityCoords(player, destCoords.x, destCoords.y, destCoords.z)
    SetEntityHeading(player, destHeading)
    
    -- Switch back in the player (end the journey)
    SwitchInPlayer(player)
    
    -- Notify arrival
    lib.notify({
        title = 'You Have Arrived',
        description = 'Welcome to ' .. destination,
        type = 'success',
        duration = 5000
    })
    
    -- Unregister as passenger
    TriggerServerEvent('slothy-busStops:server:unregisterPassenger')
end

-- Math helper for camera lerp
function Lerp(a, b, t)
    return a + (b - a) * t
end

-- Open passenger list menu for LEOs
function OpenPassengerListMenu(locationId, districtId, stop)
    QBCore.Functions.TriggerCallback('slothy-busStops:server:getPassengers', function(passengers)
        local menuOptions = {}
        
        table.insert(menuOptions, {
            title = 'Active Bus Passengers',
            description = 'Current passenger information',
            icon = 'fas fa-users'
        })
        
        if #passengers == 0 then
            table.insert(menuOptions, {
                title = 'No Active Passengers',
                description = 'There are no passengers currently using the bus system',
                icon = 'fas fa-ban'
            })
        else
            for _, passenger in ipairs(passengers) do
                -- Convert timestamp to readable format (assuming departureTime is in seconds)
                local timeString = os.date('%H:%M:%S', passenger.departureTime) or 'Unknown Time'
                if not os.date then
                    -- Fallback if os.date isn't available
                    timeString = string.format('Approx %d seconds ago', math.floor(GetGameTimer() / 1000) - passenger.departureTime)
                end
                
                local tripDetails = string.format(
                    'From: %s (%s)\nTo: %s%s (%s)\nDeparture: %s',
                    passenger.fromLocation,
                    passenger.fromStop,
                    passenger.toLocation,
                    passenger.toDistrict and (' - ' .. passenger.toDistrict) or '',
                    passenger.toStop,
                    timeString
                )
                
                table.insert(menuOptions, {
                    title = passenger.name,
                    description = tripDetails,
                    icon = 'fas fa-user'
                })
            end
        end
        
        lib.registerContext({
            id = 'passenger_list_menu',
            title = 'Bus Passenger List',
            options = menuOptions
        })
        
        lib.showContext('passenger_list_menu')
    end)
end
