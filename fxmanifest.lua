fx_version 'cerulean'
game 'gta5'
author 'LlamaPalooza | Dream Scripts'
description 'QBCore Smugglers Run'
version 'A-1.0.0'

shared_script {  -- COMMENT IF YOU'RE USING OLD QB-CORE EXPORT                  
    'server/shared.lua',
}

-- shared_script {  -- UNCOMMENT IF YOU'RE USING OLD QB-CORE EXPORT
--     '@qb-core/import.lua',            
--     'server/shared.lua'
-- }

client_script {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

escrow_ignore {    
    'server/shared.lua',
    'client/editable.lua'
}

dependency '/assetpacks'

lua54 'yes'