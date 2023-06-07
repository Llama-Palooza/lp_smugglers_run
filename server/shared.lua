-- Discord: https://discord.gg/gqxxwt49SX

Config = {}

Config.settings = {
    newQB = true, -- check `fxmanifest` if `false`
    debug = false, -- `true` to see prints (info) in F8 console
    useRoads = true, -- `false` fixes enemy vehicles not spawning close enough due to being off-road/in mountain areas, I don't recommend changing this to `false, just don't have ["VehSpawn"] locations in the middle of Egypt
    spawnRadius = 10.0,
    useEmail = true, -- set to true to have email sent to phone with mission info, else notification sent instead
    phone = 'qb', -- 'qb' or 'gks' / `useEmail` MUST be `true`
    coolDown = 20, -- in minutes
    police = {
        copsNeeded = 0, -- min cops needed to start a run
        dispatch = 'ps-dispatch', -- `ps-dispatch`, `qb-dispatch`, `normal`, `custom` <-- check `client/editable.lua` for more info
        alertChance = 40 -- chance to alert police, from 1-100 with 100 being 100% chance
    }
}

Config.locations = {
    ["Start"] = { -- type `items` uses no vehicle, so `veh` is set to `nil` / levels go from 0-3 & control how many enemies spawn / cost is the fee to start the mission / the vehicle (veh) configured MUST have a visible plate
                  -- missions `types` are: `items` (find/get the required item(s) & deliver them), `electronics`, `drugs`, `vehicle`, & `weapons` / add more of each type as you wish
        [1] = {active = false, start = vector4(92.03, -1739.79, 28.315, 232.92), ped = 'g_m_m_armboss_01', veh = nil, weapon = nil, type = 'items', level = 0, cost = 0, reward = math.random(750,1500)},
        [2] = {active = false, start = vector4(89.41, -1745.51, 29.09, 323.16), ped = 'g_m_m_armboss_01', veh = {'mule', 'boxville', 'benson'}, weapon = 'weapon_pistol', type = 'electronics', level = 1, cost = 500, reward = math.random(1500,3000)},
        [3] = {active = false, start = vector4(2430.87, 4962.68, 42.35, 308.825), ped = 'csb_prologuedriver', veh = {'rumpo3', 'youga', 'journey'}, weapon = 'weapon_appistol', type = 'drugs', level = 2, cost = 750, reward = math.random(2500,5000)},
        [4] = {active = false, start = vector4(858.59, -3202.67, 5.10, 180.185), ped = 's_m_y_dealer_01', veh = {'everon2', '300r', 'torero2', 'cheetah', 'eudora', 'ignus', 'zeno', 's80rr'}, weapon = 'weapon_microsmg', type = 'vehicle', level = 2, cost = 750, reward = math.random(2500,5000)},
        [5] = {active = false, start = vector4(-1146.46, 4940.96, 222.32, 165.115), ped = 'csb_mweather', veh = {'pounder2', 'barracks', 'boxville'}, weapon = 'weapon_microsmg', type = 'weapons', level = 3, cost = 1000, reward = math.random(3500,6000)}
    },
    ["VehSpawn"] = { -- Don't put inside of building, garages, or under low clearence overhangs. Depending on the vehicles configured above, the larger, commercial type vehicles, may collide with the roof/overhang
        vector4(2439.76, -410.1, 93.0, 2.68),
        vector4(2554.77, 295.89, 108.46, 185.3),
        vector4(2742.1, 1431.95, 24.49, 164.38),
        vector4(3564.38, 3656.02, 33.89, 77.56),
        vector4(3808.72, 4471.29, 4.17, 113.6),
        vector4(-269.84, 6334.49, 32.43, 314.36),
        vector4(-2350.3, 267.74, 165.31, 26.78),
        vector4(217.95, 2789.71, 45.66, 98.38),
        vector4(388.32, 3592.52, 33.29, 262.25),
        vector4(1572.04, 3625.03, 35.17, 301.37),
        vector4(2956.51, 2737.14, 44.06, 304.48),
        vector4(1408.25, 1118.68, 114.84, 90.29),
        vector4(1133.85, 81.51, 80.76, 208.94) -- casino track
        -- vector4(856.15, -3213.01, 5.9, 176.27)
    },
    ["Finish"] = { -- random finish locations, make sure they are accessible with a vehicle or you won't be able to finish certain missions that use a vehicle
        vector4(-196.75, -1712.35, 32.00, 135.29), 
        vector4(-340.96, -1568.48, 24.33, 54.54),
        vector4(-540.34, -1719.28, 18.43, 304.51),
        vector4(-236.85, -2442.34, 5.1, 241.39),
        vector4(-349.42, -2650.75, 5.1, 317.86),
        vector4(-169.89, -2704.18, 5.1, 272.2),
        vector4(140.67, -3004.98, 6.13, 357.61),
        vector4(611.32, -3100.18, 5.07, 192.45),
        vector4(3332.47, 5163.63, 17.48, 162.8),
        vector4(1728.98, 6425.89, 33.46, 334.29),
        vector4(-279.29, 6167.17, 30.6, 316.25),
        vector4(2700.4, 3458.73, 54.65, 158.05),
        vector4(974.86, -111.13, 73.55, 156.2), -- lost mc, next to casino
        vector4(1104.96, -778.82, 57.36, 274.73)
    }
}

Config.itemRun = {item = {'weed_amnesia', 'weed_skunk', 'weed_nutrition', 'weed_skunk_seed', 'weed_og-kush'}, amount = {min = math.random(5, 10), max = math.random(10, 25)}} -- items and rewards used for type `items` missions

