fx_version "adamant"
game "gta5"

author "Canis lupus"
description "Gang DLC"

client_script {
    "client/client.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/server.lua"
}

shared_scripts {
    "config.lua"
}