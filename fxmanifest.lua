fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'seigneuratoshit' -- discord.gg/fivedev
description 'Resource which allows you to have a management menu for your company at one point or with a direct key'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib',
    'esx_addonaccount'
}