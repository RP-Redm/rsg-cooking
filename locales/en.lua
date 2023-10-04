local Translations = {
    error = {
      you_dont_have_the_required_items = "You don\'t have the required items!",
    },
    success = {
      cooking_finished = 'cooking finished',
      cooking_successful = 'cooking finished',
    },
    primary = {
      campfire_put_out = 'campfire put out',
      campfire_deployed = 'campfire deployed'
    },
    menu = {
      fish_steak = 'Fish Steak',
      baked_bread = 'Fresh Bread',
      apple_pie = 'Apple Pie',
      fish_stew = 'Fish Stew',
      meat_steak = 'Meat Steak',
      bacon_food = 'Wild Boar Bacon',
      commanche_stew = 'Commanche Stew',
      baked_goods = 'Pie Crust',
      animal_food = 'Pet Food',
      cooking_menu = '🥩 | Cooking Menu',
      close_menu = '❌ | Close Menu',
    },
    commands = {
      deploy_campfire = 'deploy a campfire',
    },
    progressbar = {
      cooking_a = 'Cooking',
    },
    label = {
      open_cooking_menu = 'Open Cooking Menu'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
