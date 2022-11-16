fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'RexShack#3041'
description 'rsg-cooking'

client_script {
	'client/client.lua'
}

server_script {
	'server/server.lua'
}

shared_script {
	'config.lua'
}

dependency 'qr-core'
dependency 'qr-menu'

lua54 'yes'