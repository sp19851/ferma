local QBCore = exports['qb-core']:GetCoreObject()
local vegetablesTS = {}
local animalsTS = {}


local function spawnStart()
    local tV = LoadResourceFile(GetCurrentResourceName(), "./vegetables.json") 
    local tA = LoadResourceFile(GetCurrentResourceName(), "./animals.json") 
    vegetablesTS = json.decode(tV) or {}
    animalsTS = json.decode(tA) or {}
    --[[--Delete if exist--
    for i, v in pairs(vegetablesTS) do
        if v.grp then
            for index, object_ in pairs(v.grpT) do
                local obj = NetworkGetEntityFromNetworkId(object_.id)
                if DoesEntityExist(obj) then DeleteEntity(obj) end
            end
        else
            local obj = NetworkGetEntityFromNetworkId(v.id)
            if DoesEntityExist(obj) then DeleteEntity(obj) end
        end
    end]]
    --spawn--
    for i, v in pairs(vegetablesTS) do
        --print('25', i, v.grp, json.encode(v))
        if v.grp then
            for index, object_ in pairs(v.grpT) do
                --print('28', index, json.encode(object_))
                local obj = CreateObjectNoOffset(GetHashKey(object_.prop), object_.coords.x, object_.coords.y, object_.coords.z, object_.coords.w, true, false, false)
                --print('30 obj', obj )
                local netid = NetworkGetNetworkIdFromEntity(obj)
                --TriggerClientEvent('ferma:client:addT', -1, netid, obj, true)
                --print('31 obj', obj,  'netid', netid)
                vegetablesTS[i].grpT[index].id = netid
                if index == 1 then 
                    vegetablesTS[i].id = netid
                end
            end
        else
            local obj = CreateObjectNoOffset(GetHashKey(v.prop), v.coords.x, v.coords.y, v.coords.z, v.coords.w, true, false, false)            
            local netid = NetworkGetNetworkIdFromEntity(obj)
            vegetablesTS[i].id = netid
            --print('43 before target trigger', netid, obj)
            --TriggerClientEvent('ferma:client:addT', -1, netid, obj, false)
            
        end
    end

    

    --print('45 ferma:client:startSpawn', json.encode(vegetablesTS))
    --TriggerClientEvent('ferma:client:startSpawn', -1, vegetablesTS, animalsTS)
    TriggerClientEvent('ferma:client:Updateables', -1, vegetablesTS, animalsTS)
end

QBCore.Functions.CreateCallback('ferma:server:GetTables', function(source, cb)
	local src = source
    cb(vegetablesTS, animalsTS)
end)

QBCore.Functions.CreateCallback('ferma:server:CheckItem', function(source, cb, itemName)
	local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local items = Player.Functions.GetItemsByName(itemName)
    print('65', json.encode(items))
    cb(items)
end)



QBCore.Commands.Add('set_seedling', 'Посадить рассаду', {{name = "amount", help = 'Количество'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if args ~= nil then
        local amount = tonumber(args[1])
        if amount then
            TriggerClientEvent('ferma:client:newSeedling', src, amount)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Не верный тип данных','error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Не хватает аргументов','error')
    end
    
end, 'admin')


AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName()  then
        spawnStart()
	end
end)


RegisterServerEvent('ferma:server:Updateables')
AddEventHandler('ferma:server:Updateables', function(tablV, tableA)
    --print('29 ferma:server:UpdateTables', #tablV, #tableA)
    if tablV and #tablV > 0 then 
        vegetablesTS = tablV
    end
    if tableA and #tableA > 0 then 
        animalsTS = tableA
    end
    --print('35', json.encode(vegetablesTS))
    TriggerClientEvent('ferma:client:UpdateTables', -1, vegetablesTS, vegetablesAS)
    SaveResourceFile(GetCurrentResourceName(), "./vegetables.json", json.encode(vegetablesTS), -1)
    SaveResourceFile(GetCurrentResourceName(), "./animals.json", json.encode(animalsTS), -1)
end)


RegisterNetEvent('ferma:server:addT')
AddEventHandler('ferma:server:addT', function(netid, ent)
    TriggerClientEvent('ferma:clietn:addT', -1, netid, ent)
end)


Citizen.CreateThread(function()
    while true do
        Wait(Config.Tick)
        for i, v in pairs(vegetablesTS) do
            vegetablesTS[i].water = vegetablesTS[i].water - 5
            if vegetablesTS[i].water < 0 then vegetablesTS[i].water = 0 end
            if vegetablesTS[i].water < 30 then
                vegetablesTS[i].health = vegetablesTS[i].health - 3
                if vegetablesTS[i].health < 0 then vegetablesTS[i].health = 0 end
            else
                if vegetablesTS[i].health > 50 then
                    vegetablesTS[i].level = vegetablesTS[i].level + 5
                    if vegetablesTS[i].level > 100 then vegetablesTS[i].level = 100 end
                end
            end
        end
        TriggerClientEvent('ferma:client:UpdateTables', -1, vegetablesTS, vegetablesAS)
        SaveResourceFile(GetCurrentResourceName(), "./vegetables.json", json.encode(vegetablesTS), -1)
        SaveResourceFile(GetCurrentResourceName(), "./animals.json", json.encode(animalsTS), -1)
    end
end)