Config = {}
Config.CoreName = "qb-core"
Config.TargetName = "qb-target"
Config.FuelResource = 'cdn-fuel'
Config.PureBrickItem = 'pure_cocaine_brick'
Config.PureCocaineItem = 'pure_cocaine'
Config.ProcessedCocaineItem = 'processed_cocaine'
Config.CocaineBaggyItem = 'cocaine_baggy'
Config.PureCocainePerBrick = 10
Config.ProcessedCocainePerBaggy = 4
Config.MissionCooldown = 1800 -- Seconds
Config.Plane = {
    Deposit = 5000,
    MissionTime = 600, -- In Seconds
    Model = 'dodo',
    Reward = {
        ItemName = 'pure_cocaine_brick',
        AmountMin = 3,
        AmountMax = 6
    },
    Ped = {
        Coords = vector4(2120.62, 4784.76, 39.97, 295.42),
        Model = 'a_m_m_golfer_01'
    },
    Target = {
        Coords = vector3(2120.62, 4784.76, 40.97),
        Heading = 115,
    },
    Spawn = {
        Coords = vector4(2134.07, 4783.2, 39.97, 25.0),
    }
}
Config.Lab = {
    Enter = {
        Target = {
            Coords = vector3(-775.34, -891.2, 21.6),
            Heading = 180,
        },
        Teleport = {
            Coords = vector4(1088.76, -3187.76, -38.99, 178.36)
        }
    },
    Exit = {
        Target = {
            Coords = vector3(1088.71, -3187.49, -38.99),
            Heading = 4
        },
        Teleport = {
            Coords = vector4(-775.35, -891.31, 21.6, 350.08)
        }
    },
    BreakDown = {
        Target = {
            Coords = vector3(1090.32, -3195.72, -39.73),
            Heading = 180,
        }
    },
    Purify = {
        Target = {
            Coords = vector3(1092.95, -3195.64, -39.31),
            Heading = 180
        }
    },
    Package = {
        Target = {
            Coords = vector3(1095.44, -3195.77, -39.71) ,
            Heading = 180
        }
    }
}
Config.CrateLocation = vector3(-3920.54, 2331.11, -0.82)