Config = {}

--Bus Stops
Config.BusStops = {
    {name = "Paleto Bus Stop", coords = vector3(-330.87, 6189.47, 31.37), basePrice = 50, baseTime = 5},
    {name = "Sandy Shores Bus Stop", coords = vector3(2002.37, 3740.31, 32.32), basePrice = 100, baseTime = 10},
    {name = "North Los Santos", coords = vector3(-525.43, -264.35, 35.45), basePrice = 150, baseTime = 15},
    {name = "South Los Santos", coords = vector3(-110.23, -1685.67, 29.31), basePrice = 150, baseTime = 15},
}

-- Distance modifier (Price change based on distance)
Config.DistancePriceMultiplier = 1.2 -- Price increases by 20% per km

-- Key for interaction
Config.InteractKey = 38 -- E key