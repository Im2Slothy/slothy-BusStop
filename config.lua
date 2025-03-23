Config = {}

-- General Settings
Config.Debug = false -- Enable/disable debug mode
Config.UseOxInventory = true -- Set to true if using ox_inventory

-- Bus Settings
Config.BusFare = {
    BasePrice = 50, -- Base price for short trips
    PricePerKM = 5, -- Additional price per kilometer
}

-- Law Enforcement Settings
Config.LEOTracking = {
    Enabled = true, -- Allow LEOs to see bus passengers
    Departments = {'police', 'sheriff', 'highway'}, -- Jobs that can access passenger information
}

-- Locations Configuration
Config.Locations = {
    -- Los Santos Stops
    ["los_santos"] = {
        label = "Los Santos",
        type = "city",
        subDistricts = {
            ["strawberry"] = {
                label = "Strawberry",
                stops = {
                    {
                        label = "Strawberry Avenue",
                        coords = vector3(279.4, -1204.04, 29.29),
                        heading = 269.62
                    },
                    {
                        label = "Capital Boulevard",
                        coords = vector3(247.21, -1204.25, 29.29),
                        heading = 269.62
                    }
                }
            },
            ["mirror_park"] = {
                label = "Mirror Park",
                stops = {
                    {
                        label = "Mirror Park Boulevard",
                        coords = vector3(1142.45, -645.44, 56.74),
                        heading = 12.51
                    }
                }
            },
            ["rockford_hills"] = {
                label = "Rockford Hills",
                stops = {
                    {
                        label = "Portola Drive",
                        coords = vector3(-728.29, -76.19, 37.55),
                        heading = 200.43
                    }
                }
            },
            ["vinewood"] = {
                label = "Vinewood",
                stops = {
                    {
                        label = "Vinewood Boulevard",
                        coords = vector3(377.98, 323.33, 103.57),
                        heading = 167.64
                    }
                }
            }
        }
    },
    
    -- Sandy Shores Stops
    ["sandy_shores"] = {
        label = "Sandy Shores",
        type = "town",
        stops = {
            {
                label = "Marina Drive",
                coords = vector3(1965.45, 3741.08, 32.34),
                heading = 299.1
            },
            {
                label = "Algonquin Boulevard",
                coords = vector3(1888.81, 3697.03, 32.34),
                heading = 119.49
            }
        }
    },
    
    -- Paleto Bay Stops
    ["paleto_bay"] = {
        label = "Paleto Bay",
        type = "town",
        stops = {
            {
                label = "Paleto Boulevard",
                coords = vector3(-403.62, 6166.9, 31.5),
                heading = 48.29
            },
            {
                label = "Procopio Drive",
                coords = vector3(-75.95, 6466.49, 31.49),
                heading = 42.94
            }
        }
    }
}

-- Distance calculations for fare
Config.Distances = {
    ["los_santos"] = {
        ["sandy_shores"] = 15.4, -- Distance in km
        ["paleto_bay"] = 20.6,
    },
    ["sandy_shores"] = {
        ["los_santos"] = 15.4,
        ["paleto_bay"] = 8.2,
    },
    ["paleto_bay"] = {
        ["los_santos"] = 20.6,
        ["sandy_shores"] = 8.2,
    }
}
