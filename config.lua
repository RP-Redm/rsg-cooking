Config = {}

Config.Debug = false

Config.CampfireProps = {
	'p_campfire05x',
	'p_campfirecombined01x',
	'p_campfirecombined02x',
	'p_campfirecombined03x',
	'p_campfirecombined04x',
	's_cookfire01x',
	'p_stove06x',
	'p_stove07x',
}

Config.Recipes = {

    ["Fish Steak"] = {
		name = "Fish Steak",
        cooktime = 5000,
        ingredients = {
            [1] = { item = "raw_fish", amount = 1 },
        },
        receive = "cooked_fish"
    },

    ["Meat Steak"] = {
		name = "Meat Steak",
        cooktime = 5000,
        ingredients = {
            [1] = { item = "raw_meat", amount = 1 },
        },
        receive = "cooked_meat"
    },
	
}
