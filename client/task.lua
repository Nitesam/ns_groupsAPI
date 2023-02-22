RegisterNetEvent("ns_giocatore:RichiestaTaskClient")
AddEventHandler("ns_giocatore:RichiestaTaskClient", function(nome, risorsa, messaggio)
    while busy do Wait(10) end
    ESX.HideUI()
    ESX.TextUI(messaggio .. "<br>Desideri Accettare?<br><br>[G] Sì<br>[X] No")
    busy = true
    Citizen.CreateThread(function()
        local i = false
        Citizen.CreateThread(function()
            Citizen.Wait(Config.TempoMassimo * 1000)
            i = true
        end)

        while true do
            DisableControlAction(0, 113, true)
            DisableControlAction(0, 105, true)

            if IsDisabledControlJustPressed(0, 113) then
                TriggerServerEvent("ns_giocatore:RispostaTaskServer", nome, risorsa, true)
                break
            end

            if IsDisabledControlJustPressed(0, 105) then
                TriggerServerEvent("ns_giocatore:RispostaTaskServer", nome, risorsa, false)
                break
            end

            if i or kill then ESX.ShowNotification("Tempo Scaduto", "error", "Elite"); TriggerServerEvent("ns_giocatore:RispostaTaskServer", nome, risorsa, false); break; end

            Wait(1)
        end

        busy = false
        ESX.HideUI()
    end)
end)