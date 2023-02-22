listaGruppo, nomeGruppo, Capo = {}, "", false

opzioniAb, busy, kill = {["invita"] = false, ["promuovi"] = false, ["kicka"] = false}, false, false


RegisterNetEvent("ns_giocatore:invitoGruppo")
AddEventHandler("ns_giocatore:invitoGruppo", function(n)
    if gTabella(listaGruppo) == 0 and not busy then
        busy = true
        ESX.HideUI()
        ESX.TextUI("Hai ricevuto un Invito al Gruppo [" .. n .. "]<br><br>[G] per Accettare<br>[X] per Rifiutare")

        Citizen.CreateThread(function()
            local i = false
            Citizen.CreateThread(function()
                Citizen.Wait(10000)
                i = true
            end)

            while true do
                DisableControlAction(0, 113, true)
                DisableControlAction(0, 105, true)

                if IsDisabledControlJustPressed(0, 113) then
                    TriggerServerEvent("ns_giocatore:accettaInvito", n)
                    break
                end

                if IsDisabledControlJustPressed(0, 105) then
                    break
                end

                if i or kill then ESX.ShowNotification("Tempo Scaduto per Accettare l'Invito", "error", "Elite"); break; end

                Wait(1)
            end

            busy = false
            ESX.HideUI()
        end)
    end
end)

RegisterNetEvent("ns_giocatore:aggiornaGruppo")
AddEventHandler("ns_giocatore:aggiornaGruppo", function(n, t)
    if t and t[tostring(GetPlayerServerId(PlayerId()))] then 
        listaGruppo = t
        nomeGruppo = n
        
        Capo = listaGruppo[tostring(GetPlayerServerId(PlayerId()))].Capo

        if Capo and (not opzioniAb["invita"] or not opzioniAb["promuovi"]) then 
            opzioniAb["invita"] = true; opzioniAb["promuovi"] = true;

            exports.ox_target:addGlobalPlayer({
                {
                    name = 'aggiungi_gruppo',
                    icon = 'fa-solid fa-user-check',
                    label = 'Invita al Gruppo',
                    distance = 3.0,
                    canInteract = function(entity)
                        return not listaGruppo[tostring(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))] and not (gTabella(listaGruppo) > Config.MaxGroup)
                    end,
                    onSelect = function(data)
                        TriggerServerEvent("ns_giocatore:invitaMembro", nomeGruppo, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
                    end
                },
                {
                    name = 'promuovi_gruppo',
                    icon = 'fa-solid fa-user-check',
                    label = 'Promuovi',
                    distance = 3.0,
                    canInteract = function(entity)
                        return listaGruppo[tostring(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))]
                    end,
                    onSelect = function(data)
                        TriggerServerEvent("ns_giocatore:promuoviMembro", GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), nomeGruppo)
                    end
                }
            })
        elseif not Capo and (opzioniAb["invita"] or opzioniAb["promuovi"]) then
            opzioniAb["invita"] = false; opzioniAb["promuovi"] = false;
            exports.ox_target:removeGlobalPlayer({"aggiungi_gruppo", "promuovi_gruppo"})
        end

        Debug("Capo: " .. tostring(Capo) .. "\nGruppo: " .. json.encode(listaGruppo))
    else
        listaGruppo = {}
        nomeGruppo = ""

        opzioniAb["invita"] = false; opzioniAb["promuovi"] = false;
        exports.ox_target:removeGlobalPlayer({"aggiungi_gruppo", "promuovi_gruppo"})
    end
end)

function creaGruppo()
    if gTabella(listaGruppo) == 0 then 
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'nome_gruppo_giocatore_1', {
            title = 'Inserisci il Nome del Gruppo'
        }, function(data, menu)
            local d = tostring(data.value)
            if d == "nil" or string.len(d) < 3 or string.len(d) > 16 then Nty("Il Nome deve essere Lungo MIN 3 e MAX 16 Caratteri", "warning", "Elite"); menu.close(); return; end
            ESX.TriggerServerCallback("ns_giocatore:esGruppo", function(r) 
                if r then
                    Nty("Gruppo Creato!<br><br>Potrai invitare persone al tuo gruppo semplicemente puntandole con la Funzione ALT!", "success", "Elite")
                else
                    Nty("Gruppo Esistente", "error", "Elite")
                end

                menu.close()
            end, d)

        end, function(data, menu)
            menu.close()
        end)
    else
        Nty("Fai già parte di un Gruppo!", "error", "Elite")
    end
end

function Nty(a, b, c, d)
    ESX.ShowNotification(a, b, c, d)
end

function gTabella(tabella)
    local n = 0
    for k, v in pairs(tabella) do
        n = n + 1
    end
    return n
end

-- EXPORTS TIME!

exports("Gruppo", function()
    return listaGruppo, nomeGruppo, gTabella(listaGruppo)
end)

exports("nomeGruppo", function()
    return nomeGruppo
end)

exports("membriGruppo", function()
    return gTabella(listaGruppo)
end)

exports("sonoCapo", function()
    return Capo
end)