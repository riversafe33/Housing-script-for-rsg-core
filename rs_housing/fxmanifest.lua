fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
}

shared_scripts {
    'config.lua', 
    'locales.lua'
}
client_scripts { 
    '@ox_lib/init.lua',
    'doorhashes.lua', 
    'client/*.lua' 
}
server_scripts { 
    'server/*.lua' 
}

lua54 'yes'