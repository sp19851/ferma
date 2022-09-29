fx_version 'cerulean'
game 'gta5'

description 'ferma for QBCore by @Cruso#5044'
version '0.0.1'

shared_scripts {
    'config.lua',
	
}

dependencies {
	'qb-core',
    'qb-target',
	'PolyZone',
}

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua',
}
server_script {'server/*.lua'}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/js/*.js',
	'html/img/*.png',
	'html/css/*.css',
	'html/fonts/*.ttf'
}


lua54 'yes'