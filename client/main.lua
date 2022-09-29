local QBCore = exports['qb-core']:GetCoreObject()
local onField = false
local vegetablesT = {}
local animalsT = {}

local ferma_field=PolyZone:Create({
    vector2(2046.2365722656, 4967.6821289063),
    vector2(2016.9166259766, 4941.625),
    vector2(2040.3531494141, 4915.27734375),
    vector2(2068.8298339844, 4944.3022460938)
  }, {
    name="ferma_field",
    --minZ = 40.96305847168,
    --maxZ = 41.068328857422
  })
  
  ferma_field:onPlayerInOut(function(isPointInside)
      --print(Config.Locations['vanilla'].job)
      --print(PlayerData.job.name)
      if LocalPlayer.state['isLoggedIn']  then
          PlayerData = QBCore.Functions.GetPlayerData()
          --print(PlayerData.job.name)
          if isPointInside then
              currentZone = ferma_field
              onField =  true
              print('in' )
              
          else
              print('out')
              currentZone = nil
              onField = false
          end
      end
  end)
  
--function--

local isNotif = false
local function showNotif(text, coords, dist)
    --print('showNotif', isNotif,inUse)
    if not isNotif  then 
        exports['qb-core']:DrawText(text, 'left')
        isNotif = true
        Citizen.CreateThread(function()
            while isNotif do
                local pos = GetEntityCoords(PlayerPedId())
                local distToPed = #(pos-vector3(coords.x, coords.y, coords.z))
                    --print(distToPed, dist)
                    if distToPed > dist then
                        isNotif = false
                        exports['qb-core']:HideText()
                    end
                Citizen.Wait(100)
            end
        end)
    
    end
end

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function addTarget(netid, obj, grp)
    print('61', netid, obj, grp)
    local _id = netid
    print('78', _id)
    exports['qb-target']:AddEntityZone(tostring(_id), obj, {
        name=tostring(_id),
        debugPoly=false,
        useZ = true
            }, {
            options = {
                {
                
                action = function() -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                        TriggerEvent('ferma:watering', _id) -- Triggers a client event called testing:event and sends the argument 'test' with it
                end,
                icon = "fa-solid fa-faucet-drip",
                label = "Полить растение",
                job = "farmer",
                },  
                {
                    action = function() -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                            TriggerEvent('ferma:harvest', _id) -- Triggers a client event called testing:event and sends the argument 'test' with it
                    end,
                    icon = "fas fa-apple-alt",
                    label = "Собрать урожай",
                    job = "farmer",
                },                
                {
                    action = function() -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                            TriggerEvent('ferma:remove', _id) -- Triggers a client event called testing:event and sends the argument 'test' with it
                    end,
                    icon = "fa-solid fa-trash",
                    label = "Убрать",
                    job = "farmer",
                },                
               
               
            },
                
                distance = 1.5
            }) 
end

local function addTargets()
    for i,v in pairs(vegetablesT) do
        exports['qb-target']:RemoveZone(tostring(v.id))
    end
    for i,v in pairs(vegetablesT) do
        addTarget(v.id, NetToObj(v.id), v.grp)
    end
end

local function addObject(model, amount)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(100)
    end
    local pos = GetEntityCoords(PlayerPedId())
    if amount == 1 then
        QBCore.Functions.Progressbar('Seedling', 'Высаживаем...', 5000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'random@burial',
            anim = 'a_burial',
            flags = 15,
        }, {  --  	["shovel"] = { category = 'prop', title = "Shovel",  animDict = "random@burial", animName = "a_burial", animFlag = 15, bone = 28422 , prop = "prop_ld_shovel", propPos = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}},

            model = 'prop_ld_shovel',
            bone = 28422,
            coords = { x = 0.0, y = 0.0, z = 0.0 },
            rotation = { x = 0.0, y = 0.0, z = 0.0 },
        }, {}, function() -- Play When Done
            --Stuff goes here
            ClearPedTasksImmediately(PlayerPedId())
            local newpos = pos + (GetEntityForwardVector(PlayerPedId())*0.5) 
            local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
            local obj = CreateObject(GetHashKey(model), newpos.x, newpos.y, newpos.z-1.0, 1, 1, 1)
            Wait(1000)
            local netid = ObjToNet(obj)


            
            --print('110', value.netid, ped)
            --print('110', json.encode(value))
            addTarget(netid, obj, false)


            vegetablesT[#vegetablesT+1] = {
                id = netid,
                prop = model,
                coords = GetEntityCoords(obj),
                level = 0,
                water = 100,
                health = 100,
                grp = false,
                spawn = false,
                live = true,
            }
            TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
            QBCore.Functions.Notify('Ой растет')
            
        end, function() -- Play When Cancel
            --Stuff goes here
            QBCore.Functions.Notify('Процесс отменен', 'error', 7500)
        end)
       
    else
      
        QBCore.Functions.Progressbar('Seedling', 'Высаживаем...', 5000*amount, false, true, { -- Name | Label | Time | useWhileDead | canCancel
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'random@burial',
            anim = 'a_burial',
            flags = 15,
        }, {  --  	["shovel"] = { category = 'prop', title = "Shovel",  animDict = "random@burial", animName = "a_burial", animFlag = 15, bone = 28422 , prop = "prop_ld_shovel", propPos = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}},

            model = 'prop_ld_shovel',
            bone = 28422,
            coords = { x = 0.0, y = 0.0, z = 0.0 },
            rotation = { x = 0.0, y = 0.0, z = 0.0 },
        }, {}, function() -- Play When Done
            FreezeEntityPosition(PlayerPedId(), true)
            ClearPedTasksImmediately(PlayerPedId())
            local temp = {}
            local netid = 0
            local obj = nil
            for i = 1, amount do  
                local newpos = pos + (GetEntityForwardVector(PlayerPedId())*1.0*i) 
                local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
                obj = CreateObject(GetHashKey(model), newpos.x, newpos.y, newpos.z-1.0, 1, 1, 1)
                Wait(1000)
                netid = ObjToNet(obj)
                temp[#temp+1] = {
                    id = netid,
                    prop = model,
                    coords = GetEntityCoords(obj),
                    level = 0,
                  
                   
                }
            end 
           
            vegetablesT[#vegetablesT+1] = {
                id = netid,
                prop = model,
                coords = GetEntityCoords(obj),
                level = 0,
                grp = true,
                grpT = temp,
                spawn = false,
                live = true,
                water = 100,
                health = 100,
            }
            addTarget(netid, obj, true)
            TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
            QBCore.Functions.Notify('Ой растет')
            FreezeEntityPosition(PlayerPedId(), false)
        end, function() -- Play When Cancel
            --Stuff goes here
            QBCore.Functions.Notify('Процесс отменен', 'error', 7500)
        end)


        
        
    end
    
end
--events--


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('ferma:server:GetTables', function(tablV, tableA)
        vegetablesT = tablV
        animalsT = tableA
        addTargets()
    end)
end)

RegisterNetEvent('ferma:client:UpdateTables')
AddEventHandler('ferma:client:UpdateTables', function(tablV, tableA)
    vegetablesT = tablV
    animalsT = tableA
    addTargets()
    --print('185', json.encode(vegetablesT))
end)

RegisterNetEvent('ferma:client:addT')
AddEventHandler('ferma:client:addT', function(netid, obj, grp)
    print('230 ferma:client:addT', netid, obj, grp)
    addTarget(netid, NetToObj(netid), grp)
end)

RegisterNetEvent('ferma:watering')
AddEventHandler('ferma:watering', function(_netid)
    local count = 0
    print('262', _netid)
    QBCore.Functions.TriggerCallback('ferma:server:CheckItem', function(result)
        if result[1] then
             print('266', result[1].amount, _netid)
             for i, v in pairs(vegetablesT) do
                if v.id == _netid then
                    if v.grp then
                        count = #v.grpT 
                        print('271', count, #v.grpT)
                        if result[1].amount >= count then
                            QBCore.Functions.Progressbar('waterling', 'Поливаем...', 5000*count, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = 'missfbi4prepp1',
                                anim = '_bag_throw_garbage_man',
                                flags = 48,
                            }, { 
                                model = 'prop_bucket_02a',
                                bone = 57005,
                                coords = { x = 0.5, y = -0.1, z = 0.0 }, 
                                rotation = { x = -18.08, y = -89.3, z = -10.8 },
                            },
                             {}, function() -- Play When Done
                                ClearPedTasksImmediately(PlayerPedId())
                                TriggerServerEvent("QBCore:Server:RemoveItem", "bucketWater", count)
                                TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['bucketWater'], "remove")
                                vegetablesT[i].water = 100
                                TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
                                --Stuff goes here
                            end, function() -- Play When Cancel
                                --Stuff goes here
                                QBCore.Functions.Notify('Процесс отменен', 'error', 7500)
                            end)
                        else
                            QBCore.Functions.Notify('Нужно ' ..count..' ведер воды', 'error', 7500)
                        end
                    else
                        print('297', count)
                        count = 1
                        QBCore.Functions.Progressbar('waterling', 'Поливаем...', 5000*count, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = 'missfbi4prepp1',
                                anim = '_bag_throw_garbage_man',
                                flags = 48,
                            }, { 
                            model = 'prop_bucket_02a',
                            bone = 57005,
                            coords = { x = 0.5, y = -0.1, z = 0.0 }, 
                            rotation = { x = -18.08, y = -89.3, z = -10.8 },
                            }, {}, function() -- Play When Done
                                ClearPedTasksImmediately(PlayerPedId())
                                TriggerServerEvent("QBCore:Server:RemoveItem", "bucketWater", count)
                                TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['bucketWater'], "remove")
                                vegetablesT[i].water = 100
                                TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
                                --Stuff goes here
                            end, function() -- Play When Cancel
                                --Stuff goes here
                                QBCore.Functions.Notify('Процесс отменен', 'error', 7500)
                        end)
                    end
                    break
                end
            end
        end
     end, 'bucketWater')
     
     if QBCore.Functions.HasItem('bucketWater') then
     else
         QBCore.Functions.Notify('У вас нет воды для полива', 'error', 7500)
     end


end)


RegisterNetEvent('ferma:harvest')
AddEventHandler('ferma:harvest', function(_netid)
    local count = 0
    for i, v in pairs(vegetablesT) do
        if v.id == _netid then
            if v.grp then
                count = #v.grpT 
            else
                count = 1
            end
            QBCore.Functions.Progressbar('harvest', 'Собираем...', 5000*count, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
                }, {
                        animDict = 'amb@world_human_gardener_plant@male@base',
                        anim = 'base',
                        flags = 16,
                }, { 
                        --model = 'prop_bucket_02a',
                        --bone = 57005,
                        --coords = { x = 0.5, y = -0.1, z = 0.0 }, 
                        --rotation = { x = -18.08, y = -89.3, z = -10.8 },
                },
                {}, function() -- Play When Done
                ClearPedTasksImmediately(PlayerPedId())
                if v.health > 50 then 
                    if v.level > 95 then
                        TriggerServerEvent("QBCore:Server:RemoveItem", "vegetables", count*Config.bush_multiplier)
                        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['vegetables'], "add") 
                        table.remove (vegetablesT, i)
                    else
                        TriggerServerEvent("QBCore:Server:RemoveItem", "vegetables", math.random(1, count))
                        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['vegetables'], "add") 
                        table.remove (vegetablesT, i)
                    end
                
                else
                    TriggerServerEvent("QBCore:Server:RemoveItem", "dry_root", count)
                    TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['dry_root'], "add") 
                    table.remove (vegetablesT, i)
                end
                if v.grp then
                    for index, object in pairs(v.grpT) do
                        local obj = GetClosestObjectOfType(object.coords.x, object.coords.y, object.coords.z, 2.0, GetHashKey(v.prop), true, 0, 0)
                        if DoesEntityExist(obj) then
                            SetObjectAsNoLongerNeeded(obj)
                            DeleteObject(obj)
                        end
                    end
                else
                    local obj = GetClosestObjectOfType(v.coords.x, v.coords.y, v.coords.z, 2.0, GetHashKey(v.prop), true, 0, 0)
                    if DoesEntityExist(obj) then
                        SetObjectAsNoLongerNeeded(obj)
                        DeleteObject(obj)
                    end
                end
                TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
                QBCore.Functions.Notify('Урожай собран', 'success')
                --Stuff goes here
                end, function() -- Play When Cancel
                --Stuff goes here
                QBCore.Functions.Notify('Процесс отменен', 'error', 7500)
            end)
            break
        end
    end
end)

RegisterNetEvent('ferma:remove')
AddEventHandler('ferma:remove', function(_netid)
    local count = 0
    for i, v in pairs(vegetablesT) do
        if v.id == _netid then
            if v.grp then
                count = #v.grpT 
            else
                count = 1
            end
            QBCore.Functions.Progressbar('remove', 'Убираем...', 5000*count, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
                }, {
                        animDict = 'amb@world_human_gardener_plant@male@base',
                        anim = 'base',
                        flags = 16,
                }, { 
                        --model = 'prop_bucket_02a',
                        --bone = 57005,
                        --coords = { x = 0.5, y = -0.1, z = 0.0 }, 
                        --rotation = { x = -18.08, y = -89.3, z = -10.8 },
                },
                {}, function() -- Play When Done
                ClearPedTasksImmediately(PlayerPedId())
                table.remove (vegetablesT, i)
                if v.grp then
                    for index, object in pairs(v.grpT) do
                        local obj = GetClosestObjectOfType(object.coords.x, object.coords.y, object.coords.z, 2.0, GetHashKey(v.prop), true, 0, 0)
                        if DoesEntityExist(obj) then
                            SetObjectAsNoLongerNeeded(obj)
                            DeleteObject(obj)
                        end
                    end
                else
                    local obj = GetClosestObjectOfType(v.coords.x, v.coords.y, v.coords.z, 2.0, GetHashKey(v.prop), true, 0, 0)
                    if DoesEntityExist(obj) then
                        SetObjectAsNoLongerNeeded(obj)
                        DeleteObject(obj)
                    end
                end
                TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
                QBCore.Functions.Notify('Куст убран', 'success')
                --Stuff goes here
                end, function() -- Play When Cancel
                --Stuff goes here
                QBCore.Functions.Notify('Процесс отменен', 'error', 7500)
            end)
            break
        end
    end
end)

RegisterNetEvent('ferma:client:startSpawn')
AddEventHandler('ferma:client:startSpawn', function(tablV, tableA)
    print('+')
    vegetablesT = tablV
    animalsT = tableA

    --[[--Delete if exist--
    for i, v in pairs(vegetablesT) do

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
    print('184', json.encode(vegetablesT))
    for i, v in pairs(vegetablesT) do
        print('185', i, v.grp, json.encode(v))
        if not v.spawn  then 
            if v.grp then
                for index, object_ in pairs(v.grpT) do
                    print('28', index, json.encode(object_))
                    local obj = CreateObject(GetHashKey(object_.prop), object_.coords.x, object_.coords.y, object_.coords.z, object_.coords.w, true, false, false)
                    print('30 obj', obj )
                    local netid = NetworkGetNetworkIdFromEntity(obj)
                    print('31 obj', obj,  'netid', netid)
                    vegetablesT[i].grpT[index].id = netid
                    if index == 1 then 
                        vegetablesT[i].id = netid
                        vegetablesT[i].spawn = true
                    end
                end
            else
                local obj = CreateObject(GetHashKey(object_.prop), object_.coords.x, object_.coords.y, object_.coords.z, object_.coords.w, true, false, false)            
                local netid = NetworkGetNetworkIdFromEntity(obj)
                vegetablesT[i].id = netid
                vegetablesT[i].spawn = true
            end
        end
    end
    TriggerServerEvent('ferma:server:Updateables', vegetablesT, animalsT)
end)


RegisterNetEvent("ferma:client:newSeedling")
AddEventHandler("ferma:client:newSeedling", function(amount)
    if onField then
        addObject('prop_veg_crop_03_cab', amount)
       
    else
        QBCore.Functions.Notify('Здесь нельзя высаживать, пройдите на поле', 'error', 7500)
    end
end)

--Threads--

Citizen.CreateThread(function()
    while not LocalPlayer.state['isLoggedIn'] do
        Wait(5000)
    end
    while true do
        local sleep = 1000
        local posPl = GetEntityCoords(PlayerPedId())
        --print('257 vegetablesT', json.encode(vegetablesT))
        local t = vegetablesT
        print('527 tick', json.encode(t))
        for index, value in pairs(t) do
            --print('value', json.encode(value), value.health)
            if value.coords then
                local coordsV = vec3(value.coords.x,value.coords.y,value.coords.z)
                local distToV = #(coordsV - posPl)
                --print(coordsV, distToV)
                if distToV < 2.0 then
                    sleep = 0
                    
                    --if not isNotif then
                        local manure = 'нет'
                        if value.manure then
                            manure = 'да'
                        end
                        local milk = value.milk_yield
                        local eggs = value.eggs
                        local text = ''
                        --print('503 a_c_hen eggs', index, eggs, value.eggs)
                        if value.grp then
                            text = 'Группа | Рост: '..value.level..' | здоровье: '..value.health.. ' | вода: '..value.water
                        else
                            text = 'Рост: '..value.level..' | здоровье: '..value.health.. ' | вода: '..value.water
                        end
                        
                        DrawText3D(coordsV.x, coordsV.y, coordsV.z, text)
                        --showNotif(text, coordsV, 1.3)
                    --end
                  break  
                end
            end
        end
        Wait(sleep)
    end
end)


