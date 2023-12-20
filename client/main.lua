-- Project: ato_societyboss
-- ProjetDesc: Resource which allows you to have a management menu for your company at one point or with a direct key.
-- File: main.lua
-- Author: discord.gg/fivedev
-- Date: 18/12/2023 04:06:23

lib.locale()

RegisterNetEvent('ato:societyboss:svopenBossMenu', function ()
    TriggerServerEvent('ato:societyboss:svopenBossMenu', ESX.PlayerData.job.name)
end)

Citizen.CreateThread(function()

    if Shared.resourceName ~= 'ato_bossmenu' then
        while true do
            print('[^3ato_bossmenu^7] [^1Error^7] ' .. locale('dont_change_name'))
            StopResource(Shared.resourceName)
            Wait(100)
        end
    elseif Shared.resourceName == 'ato_bossmenu' then
        print('[^3ato_bossmenu^7] [^2Success^7] ' .. locale('rsrc_started'))
    end

    while PlayerPedId() == nil do
        print(PlayerPedId())
        Wait(100)
    end

    Wait(3000)

    if Shared.menuSystem ~= 'touch' then

        while true do

            for i = 1, #Shared.society do
        
                if ESX.PlayerData.job.grade_name == Shared.society[i].bossName and ESX.PlayerData.job.name == Shared.society[i].name then
    

                    local society_target = exports["ox_target"]:addBoxZone({
                        coords = Shared.society[i].coords,
                        size = vec3(3, 3, 3),
                        rotation = 45,
                        drawSprite = true,
                        options = {
                            {
                                event = 'ato:societyboss:svopenBossMenu',
                                icon = 'fa-solid fa-building', 
                                label = locale("management") .. Shared.society[i].label,
                                distance = 3
                            }
                        }
                    })

                    Wait(5000)

                    exports.ox_target:removeZone(society_target)

                elseif ESX.PlayerData.job.grade_name ~= Shared.society[i].bossName then

                    Wait(5000)

                end
                
            end

        end
        
    elseif Shared.menuSystem == 'touch' then

        for i = 1, #Shared.society do
        
            if ESX.PlayerData.job.grade_name == Shared.society[i].bossName and ESX.PlayerData.job.name == Shared.society[i].name then

                RegisterCommand("open_boss_menu", function()

                    TriggerServerEvent('ato:societyboss:svopenBossMenu', ESX.PlayerData.job.name)

                end, false)

                RegisterKeyMapping('open_boss_menu', 'Ouvrir le menu patron', 'keyboard', Shared.keyOpenBossMenu)

            end
            
        end

    end

end)
