fx_version 'cerulean'
game 'gta5'

description 'Bus Transportation Script'
author 'Im2Slothy#0'
version '2.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

lua54 'yes'

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target'
}
