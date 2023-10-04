Config = {}

Config.Debug = false

Config.CampfireProps = {
    55104655, -- s_campfire01x
    -1892618927, -- s_campfire02x
    -1179266405, -- s_campfire05x
    -732527717, -- p_cs_campfirecmbnd01x
    -1112289552, -- p_campfirecombined01x_off
    -96662597, -- p_campfirecombined02x
    174418135, -- p_campfirecombined03x
    1582699527, -- p_campfirecombined04x
    -808559472, -- p_kettle03x
    -1126885751, -- p_campfire05x_script
    -450300420, -- p_cookgrate01x
    1948816661, -- p_cookgrate02x
    -689630872, -- s_cookfire01x
    2145954873, -- p_stove01x
    -677652422, -- p_stove04x
    -2008369031, -- p_stove05x
    -1438090360, -- p_stove06x
    -1740286366, -- p_stove07x
    -2054771143, -- p_stove09x
    1636905044, -- p_baseburner01x
    445844223, -- p_furnace01x
    305182125, -- p_boiler01x
}

Config.Recipes = {

    {
        title =  Lang:t('menu.fish_steak'),
        category = "fish",
        cooktime = 5000,
        ingredients = { 
            [1] = { item = "raw_fish", amount = 1 },
        },
        receive = "cooked_fish",
        giveamount = 1
    },
    {
        title = Lang:t('menu.meat_steak'),
        category = "meat",
        cooktime = 5000,
        ingredients = { 
            [1] = { item = "raw_meat", amount = 1 },
        },
        receive = "cooked_meat",
        giveamount = 1
    },
    
 
    
}


