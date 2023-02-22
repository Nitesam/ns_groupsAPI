Gruppi, TaskGruppi = {}, {}

ESX.RegisterServerCallback("ns_giocatore:esGruppo", function(source, cb, nome)
    if source then 
        if not Gruppi[nome] then 
            local Giocatore = ESX.GetPlayerFromId(source)
            if Giocatore then 
                Gruppi[nome] = {}
                TaskGruppi[nome] = {}
                Gruppi[nome][tostring(source)] = {Nome = Giocatore.get("firstName"), Cognome = Giocatore.get("lastName"), Capo = true, Bonus = {}, Var = {x = 0.0, y = 0.0}}
                printc("Team " .. nome .. " Creato")
                TriggerClientEvent("ns_giocatore:aggiornaGruppo", source, nome, Gruppi[nome])

                cb(true)
                return
            end
        end
    end

    cb(false)
end)

RegisterServerEvent("ns_giocatore:invitaMembro")
AddEventHandler("ns_giocatore:invitaMembro", function(n, idG)
    if Gruppi[n] then
        if not Gruppi[n][idG] then
            local canDo = true 
            for k,v in pairs(Gruppi) do 
                if v[tostring(idG)] then 
                    canDo = false 
                    break
                end
            end

            if canDo then 
                TriggerClientEvent("ns_giocatore:invitoGruppo", idG, n)
                TriggerClientEvent("esx:showNotification", source, "Hai Invitato un Giocatore al Team!", "warning")
            else
                TriggerClientEvent("esx:showNotification", source, "Questo Giocatore si trova già in un Team!", "error")
            end
        end
    end
end)


RegisterServerEvent("ns_giocatore:accettaInvito")
AddEventHandler("ns_giocatore:accettaInvito", function(n)
    if Gruppi[n] and not Gruppi[n][source] then
        local Giocatore = ESX.GetPlayerFromId(source)
        if Giocatore then 
            Gruppi[n][tostring(source)] = {Nome = Giocatore.get("firstName"), Cognome = Giocatore.get("lastName"), Capo = false, Bonus = {}, Var = {x = 0.0, y = 0.0}}

            for k,v in pairs(Gruppi[n]) do 
                TriggerClientEvent("ns_giocatore:aggiornaGruppo", tonumber(k), n, Gruppi[n])
                if k ~= tostring(source) then 
                    TriggerClientEvent("esx:showNotification", tonumber(k), Giocatore.get("firstName") .. " - Entra a far parte del TEAM!", "success")
                else
                    Wait(250)
                    TriggerClientEvent("esx:showNotification", tonumber(k), Giocatore.get("firstName") .. " - Benvenuto in Squadra!", "success", n)
                end
            end
        end
    end
end)

RegisterServerEvent("ns_giocatore:promuoviMembro")
AddEventHandler("ns_giocatore:promuoviMembro", function(idG, n)
    if Gruppi[n] and Gruppi[n][tostring(source)].Capo then
        Gruppi[n][tostring(idG)].Capo     = true
        Gruppi[n][tostring(source)].Capo  = false

        for k,v in pairs(Gruppi[n]) do
            TriggerClientEvent("ns_giocatore:aggiornaGruppo", k, n, Gruppi[n])
        end

        TriggerClientEvent("esx:showNotification", idG, "Sei diventato il Capo Gruppo di " .. n, "success")
        TriggerClientEvent("esx:showNotification", source, "Hai Ceduto il Grado di Capo del Team " .. n, "success")
    end
end)

RegisterServerEvent("ns_giocatore:lasciaGruppo")
AddEventHandler("ns_giocatore:lasciaGruppo", function(n, _source)
    local source = _source or source

    rimuoviGiocatore(n, source)
end)

RegisterServerEvent("ns_giocatore:sciogliGruppo")
AddEventHandler("ns_giocatore:sciogliGruppo", function(n, _source)
    local source = _source or source

    if Gruppi[n] then
        local Giocatore = ESX.GetPlayerFromId(source)
        if not Giocatore then return end
        if (Gruppi[n][tostring(source)] and Gruppi[n][tostring(source)].Capo) or Giocatore.controllaGrado("mod") then 
            for k,v in pairs(Gruppi[n]) do 
                TriggerClientEvent("ns_giocatore:aggiornaGruppo", k, "", {})
                TriggerClientEvent("ns_giocatore:TaskUpdateClient", k, false)
                TriggerClientEvent("esx:showNotification", k, "Il Team " .. n .. " si è sciolto", "warning")
            end

            Gruppi[n] = nil
            TaskGruppi[n] = nil
        end
    end
end)

RegisterServerEvent("esx:playerLogout")
AddEventHandler("esx:playerLogout", function(idGiocatore)
    for k,v in pairs(Gruppi) do 
        for a,b in pairs(v) do 
            if a == tostring(idGiocatore) then 
                rimuoviGiocatore(k, idGiocatore)
                break
            end
        end
    end
end)

function rimuoviGiocatore(n, source)
    if Gruppi[n] then
        if Gruppi[n][tostring(source)] then 
            local nome = Gruppi[n][tostring(source)].Nome .. " " .. Gruppi[n][tostring(source)].Cognome

            if Gruppi[n][tostring(source)].Capo then 

                local change = false 
                
                for k,v in pairs(Gruppi[n]) do
                    if k ~= tostring(source) then 
                        Gruppi[n][k].Capo = true
                        TriggerClientEvent("esx:showNotification", k, "Sei diventato il Nuovo Capo di questo Team!", "success", n)
                        change = true 
                        break
                    end
                end

                if not change then
                    Gruppi[n] = nil
                    TaskGruppi[n] = nil
                    TriggerClientEvent("esx:showNotification", source, "Il Team " .. n .. " è stato Sciolto", "warning", "Elite")
                    printc("Team " .. n .. " Eliminato")
                else
                    Gruppi[n][tostring(source)] = nil
                    TriggerClientEvent("esx:showNotification", source, "Hai Lasciato " .. n .. " Cedendo la Leadership", "warning", "Elite")
                end

                TriggerClientEvent("ns_giocatore:aggiornaGruppo", source, "", false)
            else
                Gruppi[n][tostring(source)] = nil
                TriggerClientEvent("ns_giocatore:aggiornaGruppo", source, "", false)
                TriggerClientEvent("esx:showNotification", source, "Hai Lasciato " .. n, "warning", "Elite")
            end

            if Gruppi[n] then 
                for k,v in pairs(Gruppi[n]) do
                    TriggerClientEvent("ns_giocatore:aggiornaGruppo", k, n, Gruppi[n] or false)
                    TriggerClientEvent("ns_giocatore:GlobalLascia", k, tostring(source))
                    TriggerClientEvent("esx:showNotification", k, nome .. " ha lasciato il gruppo", "error", n)
                end
            end
        end
    else
        Debug("Team " .. n .. " non Trovato.")
    end
end

if Config.Debug then 
    RegisterCommand("listaGruppi", function(a, b, c)
        if a > 0 then
            local Giocatore = ESX.GetPlayerFromId(a)
            if not Giocatore.controllaGrado("admin") then 
                return 
            end
        end

        print(ESX.DumpTable(Gruppi))
    end)
end

function printc(...) 
    local connect = {
        {
            ["color"] = 12745742,
            ["title"] = "**NS Gruppo**",
            ["description"] = ...,
            ["footer"] = {
                ["text"] = "Elite Log | " .. os.date("%d/%m/%Y - %X"),
            },
        }
    }
    PerformHttpRequest(ESX.Config["webhook"]["console-log"], function(err, text, headers) end, 'POST', json.encode({username = "Elite Log", embeds = connect, avatar_url = 'https://media.discordapp.net/attachments/1026900945356988488/1029852182138335332/exlogo256.png'}), { ['Content-Type'] = 'application/json' })
end

-- EXPORTS TIME!!

exports("Gruppo", function(source, nome)
    if source then 
        if nome and Gruppi[nome] then 
            if Gruppi[nome]["membri"][tostring(source)] then 
                return Gruppi[nome]
            end
        else
            for k,v in pairs(Gruppi) do 
                if v["membri"][tostring(source)] then 
                    return v, k
                end
            end
        end
    end    

    return false
end)