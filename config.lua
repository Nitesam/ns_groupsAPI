Config = {}

Config.Debug = true 

Config.MaxGroup = 4
Config.TempoMassimo = 60 -- Da specificare in secondi!
Config.BonusExp = true -- Bonus Exp per attività di base quali correre (in vicinanza di x Componenti del gruppo) -- NECESSITA DI NS_Abilità

Debug = function(...)
    if Config.Debug then
        print(...)
    end
end











































function Debug(...)
    if Config.Debug then
        print(...)
    end
end