local risorseImpiegate = {}

-- SISTEMA TASK

RegisterServerEvent("ns_giocatore:RichiestaTaskServer")
AddEventHandler("ns_giocatore:RichiestaTaskServer", function(n, risorsa, messaggio, data, _source)
    local source = _source or source

    if Gruppi[n] then
        local Giocatore = ESX.GetPlayerFromId(source)
        if not Giocatore then return end
        
        if TaskGruppi[n] and not TaskGruppi[n][risorsa] then
            if not risorseImpiegate[risorsa] then risorseImpiegate[risorsa] = true end
            TaskGruppi[n][risorsa] = 
            {
                Membri = {}, 
                Funzioni = 
                {
                    Inizio = {Evento = data.eventoI or {}, Attributi = data.attributiI or {}}, 
                    Fine = {Evento = data.eventoF or {}, Attributi = data.attributiF or {}},
                    App = {Evento = data.eventoA or {}, Attributi = data.attributiA or {}},
                    Globali = {Evento = data.eventoG or {}, Attributi = data.Globali or {}}
                }
            }

            TaskGruppi[n][risorsa]["Membri"][tostring(source)] = true

            for k,v in pairs(Gruppi[n]) do 
                if k ~= tostring(source) then
                    TaskGruppi[n][risorsa]["Membri"][k] = false
                    TriggerClientEvent("ns_giocatore:RichiestaTaskClient", k, n, risorsa, messaggio)
                end
            end
        else
            Debug("Gruppo non esistente oppure missione già in corso!", json.encode(TaskGruppi[n][risorsa] or "NULL"))
        end
    end
end)

RegisterServerEvent("ns_giocatore:RispostaTaskServer")
AddEventHandler("ns_giocatore:RispostaTaskServer", function(n, risorsa, valore, _source)
    local source = _source or source

    if TaskGruppi[n] and TaskGruppi[n][risorsa] then
        if not valore then 
            annullaTask(n, risorsa, " non ha accettato l'invito", source)
        else
            TaskGruppi[n][risorsa]["Membri"][tostring(source)] = true
            
            local m, pronti = 0, 0
            for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                if v then
                    pronti = pronti + 1
                end
                m = m + 1
            end

            if pronti == m then
                for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                    TriggerClientEvent(TaskGruppi[n][risorsa]["Funzioni"]["Inizio"]["Evento"], k, TaskGruppi[n][risorsa]["Funzioni"]["Inizio"]["Attributi"])
                    TaskGruppi[n][risorsa]["Membri"][k] = false
                end
            end
        end
    end
end)

RegisterServerEvent("ns_giocatore:AnnullaTaskServer")
AddEventHandler("ns_giocatore:AnnullaTaskServer", function(n, risorsa, messaggio, _source)
    local source = _source or source
    if not annullaTask(n, risorsa, messaggio, source) then
        print("[ns_giocatore] - ERRORE GRAVE \"AnnullaTaskServer\"")
    end
end)

function annullaTask(n, risorsa, messaggio, _source)
    if _source then 
        local source = _source

        if TaskGruppi[n][risorsa] then
            if TaskGruppi[n][risorsa]["Membri"][tostring(source)] ~= nil then
                for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                    TriggerClientEvent(TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Evento"], k, TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Attributi"])
                    
                    if k ~= tostring(source) then 
                        TriggerClientEvent("esx:showNotification", k, Gruppi[n][tostring(source)].Nome .. (messaggio or " Messaggio Non Trovato - Errore Riga 87"), "error", n or "Non Trovato - 88")
                    end
                end

                Debug("Per il Gruppo " .. n .. " eseguo " .. TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Evento"] .. " con Attributi " .. json.encode(TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Attributi"]))

                TaskGruppi[n][risorsa] = nil

                return true
            end
        end
    else
        if TaskGruppi[n][risorsa] then
            for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                TriggerClientEvent(TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Evento"], k, TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Attributi"])
                if messaggio then
                    TriggerClientEvent("esx:showNotification", k, messaggio, "error", n or "Non Trovato - 103")
                end
            end

            Debug("Per il Gruppo " .. n .. " eseguo " .. TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Evento"] .. " con Attributi " .. json.encode(TaskGruppi[n][risorsa]["Funzioni"]["Fine"]["Attributi"]))


            TaskGruppi[n][risorsa] = nil

            return true
        end
    end

    return false
end

exports("annullaTask", annullaTask)

RegisterServerEvent("ns_giocatore:TaskUpdateServer")
AddEventHandler("ns_giocatore:TaskUpdateServer", function(n, risorsa, ev, data, execute, _source)
    local source = _source or source

    if TaskGruppi[n] and TaskGruppi[n][risorsa] then
        local Giocatore = ESX.GetPlayerFromId(source)
        if not Giocatore then return end
        
        Debug(n, risorsa, ev, json.encode(data), execute)
        if TaskGruppi[n][risorsa]["Funzioni"][ev] then 
            TaskGruppi[n][risorsa]["Funzioni"][ev]["Evento"] = data[1]
            TaskGruppi[n][risorsa]["Funzioni"][ev]["Attributi"] = data[2]

            if execute then 
                for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                    TriggerClientEvent(TaskGruppi[n][risorsa]["Funzioni"][ev]["Evento"], k, TaskGruppi[n][risorsa]["Funzioni"][ev]["Attributi"])
                end

                Debug("Per il Gruppo " .. n .. " eseguo " .. TaskGruppi[n][risorsa]["Funzioni"][ev]["Evento"] .. " con Attributi " .. json.encode(TaskGruppi[n][risorsa]["Funzioni"][ev]["Attributi"]))
            end
        end
    end
end)

RegisterServerEvent("ns_giocatore:EseguiTask")
AddEventHandler("ns_giocatore:EseguiTask", function(n, risorsa, data, _source)
    local source = _source or source

    if TaskGruppi[n] and TaskGruppi[n][risorsa] and TaskGruppi[n][risorsa]["Funzioni"][data] then
        if type(source) ~= "string" and source > 0 then
            local Giocatore = ESX.GetPlayerFromId(source)
            if not Giocatore then return end
        end
        
        for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
            TriggerClientEvent(TaskGruppi[n][risorsa]["Funzioni"][data]["Evento"], k, TaskGruppi[n][risorsa]["Funzioni"][data]["Attributi"])
        end

        Debug("Per il Gruppo " .. n .. " eseguo " .. TaskGruppi[n][risorsa]["Funzioni"][data]["Evento"] .. " con Attributi " .. json.encode(TaskGruppi[n][risorsa]["Funzioni"][data]["Attributi"]))
    end
end)

-- FINE SISTEMA TASK

AddEventHandler("onResourceStop", function(nome)
	if risorseImpiegate[nome] then 
        for k,v in pairs(TaskGruppi) do 
            if v[nome] then 
                TaskGruppi[k][nome] = nil 
            end
        end

        risorseImpiegate[nome] = nil 

        print("[ns_giocatore] - Rimosse tutte le Task della risorsa " .. nome .. " poichè quest'ultima è stata STOPPATA.")
	end
end)

if Config.Debug then 
    RegisterCommand("printTask", function(a, b, c)
        if a > 0 then 
            local Giocatore = ESX.GetPlayerFromId(a) 
            if not Giocatore or not Giocatore.controllaGrado("admin") then return end
        end 

        print(ESX.DumpTable(TaskGruppi))
    end)
end


--[[function threadAttesa(n, risorsa)
    Citizen.CreateThread(function()
        local i = 0
        while TaskGruppi[n][risorsa] do
            local m, pronti = 0, 0
            for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                if v.Attivo then
                    pronti = pronti + 1
                end
                m = m + 1
            end

            if pronti == m then 
                for k,v in pairs(TaskGruppi[n][risorsa]["Membri"]) do 
                    TriggerClientEvent(TaskGruppi[n][risorsa]["Funzioni"]["Inizio"]["Evento"], k, TaskGruppi[n][risorsa]["Funzioni"]["Inizio"]["Attributi"])
                end
                break
            end

            i = i + 1
            if i == Config.TempoMassimo then 
                break
            end

            Wait(1000)
        end
    end)
end]]