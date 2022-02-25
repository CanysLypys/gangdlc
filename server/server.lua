ESX = nil

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for i = 1, #Config.DrogenVerkaufOrte, 1 do
            local npcID = Config.DrogenVerkaufOrte[i]["ID"]
            TriggerEvent("gangdlc:resetDealer", npcID)
        end
    end
end)

RegisterNetEvent("gangdlc:verkaufeDrogen")
AddEventHandler("gangdlc:verkaufeDrogen", function(ped, npcID)
    local xPlayer = ESX.GetPlayerFromId(source)

    local droge = xPlayer.getInventoryItem("weed")
    local preis = math.random(250, 5000)
    if droge.count >= tonumber(25) then
        xPlayer.removeInventoryItem(droge.name, 25)
        xPlayer.addMoney(preis)
        TriggerClientEvent("gangdlc:WeedDabei", xPlayer.source)
        TriggerEvent("gangdlc:updateDealer", npcID)
        TriggerClientEvent("notifications", xPlayer.source, "#7a000d", "DROGENDEAL", "Du verkaufst 25x Weed für "..preis.."$")
    else
        TriggerClientEvent("notifications", xPlayer.source, "#7a000d", "DROGENDEAL", "Du brauchst mindestens 25x Weed zum verkaufen.")
    end
end)

ESX.RegisterServerCallback("gangdlc:checkDealer", function(source, cb, npcID)

    MySQL.Async.fetchAll("SELECT * FROM dealers WHERE ID = @ID", {
        ["@ID"] = npcID
    }, function(result)
        if result[1] ~= nil then
            local dealer_benutzt = result[1].benutzt
            cb(dealer_benutzt)
        end
    end)
end)

AddEventHandler("gangdlc:updateDealer", function(npcID)
    MySQL.Async.execute("UPDATE dealers SET benutzt = @benutzt WHERE ID = @ID", {
        ["@benutzt"] = "1",
        ["@ID"] = npcID
    }, function(rowsChanged)
    end)
end)

AddEventHandler("gangdlc:resetDealer", function(npcID)
    MySQL.Async.execute("UPDATE dealers SET benutzt = @benutzt WHERE ID = @ID", {
        ["@benutzt"] = "0",
        ["@ID"] = npcID
    }, function(rowsChanged)
        print("^5[Gangdlc]^2 DealerID: "..npcID.." resettet.")
    end)
end)

local code = [[

    ESX = nil
    local PlayerData = {}
    
    CreateThread(function()
        while ESX == nil do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Wait(0)
        end
    
        while ESX.GetPlayerData().job == nil do
            Wait(0)
        end
    
        PlayerData = ESX.GetPlayerData()
    end)
    
    
    
    CreateThread(function()
        InitialisiereNPC()
    end)
    
    InitialisiereNPC = function()
        for i = 1, #Config.DrogenVerkaufOrte, 1 do
            local npcX = Config.DrogenVerkaufOrte[i]["x"]
            local npcY = Config.DrogenVerkaufOrte[i]["y"]
            local npcZ = Config.DrogenVerkaufOrte[i]["z"]
            local npcHeading = Config.DrogenVerkaufOrte[i]["h"]
            local npcHash = Config.DrogenVerkaufOrte[i]["Hash"]
            local npcModel = Config.DrogenVerkaufOrte[i]["Model"]
            local npcAnimation = Config.DrogenVerkaufOrte[i]["Animation"]
            local npcType = Config.DrogenVerkaufOrte[i]["Drogentyp"]
            local preisMin = Config.DrogenVerkaufOrte[i]["PreisMin"]
            local preisMax = Config.DrogenVerkaufOrte[i]["PreisMax"]
    
            RequestModel(GetHashKey(npcModel))
            while not HasModelLoaded(GetHashKey(npcModel)) do
                Wait(15)
            end
        
            ped = CreatePed(4, npcHash, npcX, npcY, npcZ - 1, 3374176, false, true)
            SetEntityHeading(ped, npcHeading)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, npcAnimation, 0, true)
        end
    end
    
    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
    
            for i = 1, #Config.DrogenVerkaufOrte, 1 do
                local npcX = Config.DrogenVerkaufOrte[i]["x"]
                local npcY = Config.DrogenVerkaufOrte[i]["y"]
                local npcZ = Config.DrogenVerkaufOrte[i]["z"]
                local npcHeading = Config.DrogenVerkaufOrte[i]["h"]
                local npcHash = Config.DrogenVerkaufOrte[i]["Hash"]
                local npcModel = Config.DrogenVerkaufOrte[i]["Model"]
                local npcAnimation = Config.DrogenVerkaufOrte[i]["Animation"]
                local npcType = Config.DrogenVerkaufOrte[i]["Drogentyp"]
                local preisMin = Config.DrogenVerkaufOrte[i]["PreisMin"]
                local preisMax = Config.DrogenVerkaufOrte[i]["PreisMax"]
                local npcID = Config.DrogenVerkaufOrte[i]["ID"]
                local distance = #(playerCoords - vector3(npcX, npcY, npcZ))
    
                if distance <= 1.0 then
                    if PlayerData.job.name == "sheriff" or PlayerData.job.name == "police" or PlayerData.job.name == "fib" then
                        ESX.ShowHelpNotification("Du bist Mitglied einer Staatsfraktion.")
                    else
                        ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um 5x ~g~Weed~s~ zu verkaufen.")
                        if IsControlJustPressed(0, 38) then
                            if not cooldown then
                                cooldown = true
                                OpenDealerShopMenu(ped, npcID)
                                cooldowntimer()
                            else
                                TriggerEvent("notifications", "#7a000d", "DROGENDEAL", "Bitte hab Geduld, du bist zu schnell.")
                            end
                        end
                    end
                end
            end
        end
    end)
    
    OpenDealerShopMenu = function(ped, npcID)
        ESX.TriggerServerCallback("gangdlc:checkDealer", function(dealerStatus)
            if dealerStatus == "0" then
                TriggerServerEvent("gangdlc:verkaufeDrogen", ped, npcID)
            else
                TriggerEvent("notifications", "#7a000d", "DROGENDEAL", "Hab schon mein Weed von jemand anderes bekommen, trotzdem Danke.")
            end
        end, npcID)
    end
    
    RegisterNetEvent("gangdlc:WeedDabei")
    AddEventHandler("gangdlc:WeedDabei", function()
        ESX.Streaming.RequestAnimDict("mp_common", function()
            TaskPlayAnim(PlayerPedId(), "mp_common", "givetake1_a", 8.0, 8.0, -1, 0, 0, false, false, false)
        end)
    end)
    
    
    
    cooldowntimer = function()
        cooldown = true
        SetTimeout(5 * 1000, function()
            cooldown = false
        end)
    end
]]

RegisterNetEvent("gangdlc:skid")
AddEventHandler("gangdlc:skid", function()
    local _source = source
    TriggerClientEvent("gangdlc:skid", _source, code)
end)