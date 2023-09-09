local Translations = {
error = {
    you_dont_have_the_required_items = "Você não tem os itens necessários!",
},
success = {
    cooking_finished = 'cozimento concluído',
},
primary = {
    campfire_put_out = 'fogueira apagada',
    campfire_deployed = 'fogueira montada'
},
menu = {
    fish_steak = 'Bife de Peixe',
    meat_steak = 'Bife de Carne',
    cooking_menu = '🥩 | Menu de Cozimento',
    close_menu = '❌ | Fechar Menu',
},
commands = {
    deploy_campfire = 'montar uma fogueira',
},
progressbar = {
    cooking_a = 'Cozinhando um(a) ',
},
label = {
    open_cooking_menu = 'Abrir Menu de Cozimento'
}
}

if GetConvar('rsg_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
