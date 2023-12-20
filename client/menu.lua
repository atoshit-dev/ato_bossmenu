-- Project: ato_societyboss
-- ProjetDesc: Resource which allows you to have a management menu for your company at one point or with a direct key.
-- File: menu.lua
-- Author: discord.gg/fivedev
-- Date: 18/12/2023 04:06:39

RegisterNetEvent('ato:societyboss:openBossMenu', function(societyMoney)

    for i = 1, #Shared.society do
        if Shared.society[i].name == ESX.PlayerData.job.name then
            wash = Shared.society[i].washMoney
        end
    end

    if wash == false then
        disabledWash = true
    elseif wash == true then
        disabledWash = false
    end

    lib.registerContext({
        id = 'bossmenu_main',
        title = locale("title_boss_menu"),
        options = {

            {
                title = locale("your_society") .. ESX.PlayerData.job.label,
                icon = 'building',
                readOnly = true
            },

            {
                title = ('Fonds de la societé: %s$'):format(societyMoney),
                icon = 'money-check-dollar',
                readOnly = true
            },
    

            { title = ' ' },

            { 
                title = locale("recruit"), 
                description = locale("desc_recruit"), 
                icon = 'plus', 
                onSelect = function()
                    local coords = GetEntityCoords(PlayerPedId())
                    local closestPlayer, closestPlayerPed, closestPlayerCoords = lib.getClosestPlayer(coords, 5.0, false)  

                    if closestPlayerCoords == nil then

                        sendNotify(locale("error"), locale("no_one_nearby"), 'xmark', 'red', 'error')

                    else

                        local input = lib.inputDialog('Confirmation', {
                            {type = 'checkbox', label = locale("confirm")}
                        })

                        if not input then 
                            sendNotify(locale("error"), locale("cancel_change"), 'ban', 'red', 'error')
                            return 
                        end

                        if input[1] then
                            TriggerServerEvent('ato:societyboss:recruit', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
                        else
                            sendNotify(locale("error"), locale("not_confirmed"), 'ban', 'red', 'error')
                        end

                    end
                end
            },

            { 
                title = locale("announce_"), 
                description = locale("desc_announce"), 
                icon = 'message', 
                onSelect = function()
                    local input = lib.inputDialog(locale("announce"), {
                        {type = 'select', label = locale("announce_type"), required = true, options = {
                            {value = 'employeeAd', label = locale("employee_ad")}, 
                            {value = 'playersAd', label = locale("players_ad")}
                        }},
                        {type = 'input', label = locale("announce_title"), description = locale("message_title"), required = true},
                        {type = 'input', label = locale("announce_desc"), description = locale("message_desc"), required = true}
                    })

                    if not input then return end

                    if input[1] == 'employeeAd' then
                        TriggerServerEvent('ato:societyboss:announceEmployee', ESX.PlayerData.job.name, input[2], input[3])
                    elseif input[1] == 'playersAd' then
                        TriggerServerEvent('ato:societyboss:players', input[2], input[3])
                    end
                end
            },


            { 
                title = locale("grade_options"), 
                description = locale("grade_options_desc"), 
                icon = 'bars', 
                onSelect = function()
                    TriggerServerEvent('ato:societyboss:gradeOptions', ESX.PlayerData.job.name)
                end
            },

            { 
                title = locale("employee_options"), 
                description = locale("employee_options_desc"), 
                icon = 'user', 
                onSelect = function()
                    TriggerServerEvent('ato:societyboss:employeeOptions', ESX.PlayerData.job.name)
                end
            },

            { 
                title = locale("money_options"), 
                description = locale("money_options_desc"), 
                icon = 'wallet', 
                onSelect = function ()
                    lib.showContext('money_gestion')
                end
            },
        },

        {
            id = 'money_gestion',
            title = locale("money_options"),
            menu = 'bossmenu_main',
            options = {
                {
                    title = locale("deposit_money"),
                    description = locale("deposit_money_desc"),
                    icon = 'money-bill-transfer',
                    onSelect = function()
                        local input = lib.inputDialog(locale("ammount"), {
                            {type = 'number', label = locale("ammount"), required = true}
                        })

                        if not input then return end

                        TriggerServerEvent('ato:societyboss:moneyGestion', 'deposit', input[1], ESX.PlayerData.job.name)
                    end,
                },

                {
                    title = locale("withtdraw_money"),
                    description = locale("withtdraw_money_desc"),
                    icon = 'money-bill-transfer',
                    onSelect = function()
                        local input = lib.inputDialog(locale("ammount"), {
                            {type = 'number', label = locale("ammount"), required = true}
                        })

                        if not input then return end

                        TriggerServerEvent('ato:societyboss:moneyGestion', 'whitdraw', input[1], ESX.PlayerData.job.name)
                    end,
                },

                {
                    title = locale("wash_money"),
                    icon = 'money-bill-transfer',
                    description = locale("desc_wash_money"),
                    iconColor = 'red',
                    disabled = disabledWash,
                    onSelect = function()
                        local input = lib.inputDialog(locale("ammount"), {
                            {type = 'number', label = locale("ammount"), required = true}
                        })
    
                        if not input then return end
    
                        TriggerServerEvent('ato:societyboss:washMoney', input[1])
                    end,
                }
            }
        }

    })

    lib.showContext('bossmenu_main')

end)

RegisterNetEvent('ato:societyboss:gradeList', function(optionsGrade)

    local options = {}

    for i = 1, #optionsGrade do

        if optionsGrade[i].grade == ESX.PlayerData.job.grade then

            options[#options + 1] = {
                title = optionsGrade[i].gradeLabel .. locale("salary") .. optionsGrade[i].gradeSalary .. ")",
                description = locale("rework_disabled"),
                icon = 'circle-user',
                disabled = true,
                onSelect = function()
                    local input = lib.inputDialog(locale("rework"), {
                        {type = 'input', label = locale("rework_name"), description = locale("actually_label") .. optionsGrade[i].gradeLabel, required = true},
                        {type = 'number', label = locale("rework_salary"), description = locale("actually_salary") .. optionsGrade[i].gradeSalary, required = true, min = 100, max = 5000}
                    })

                    if not input then return end

                    TriggerServerEvent('ato:societyboss:updateGrade', ESX.PlayerData.job.name, optionsGrade[i].grade, input[2], input[1])
                
                end
            }

        else

            options[#options + 1] = {
                title = optionsGrade[i].gradeLabel .. locale("salary") .. optionsGrade[i].gradeSalary .. ")",
                description = locale("rework_enabled"),
                icon = 'circle-user',
                onSelect = function()
                    local input = lib.inputDialog(locale("rework"), {
                        {type = 'input', label = locale("rework_name"), description = locale("actually_label") .. optionsGrade[i].gradeLabel, required = true},
                        {type = 'number', label = locale("rework_salary"), description = locale("actually_salary") .. optionsGrade[i].gradeSalary, required = true, min = 100, max = 5000}
                    })

                    if not input then return end

                    TriggerServerEvent('ato:societyboss:updateGrade', ESX.PlayerData.job.name, optionsGrade[i].grade, input[2], input[1])
                    
                end
            }

        end

    end

    lib.registerContext({
        id = 'societyboss_grademenu',
        title = locale("grade_options"),
        menu = 'bossmenu_main',
        options = options
    })

    lib.showContext('societyboss_grademenu')
end)

RegisterNetEvent('ato:societyboss:employeeList', function(optionsEmployee, numberEmployee)

    local options = {
        {
            title = ('Nombre d\'emplopyé(s): %s'):format(numberEmployee),
            icon = 'users-line',
            readOnly = true
        },

        {
            title = ' ',
            readOnly = true
        },
    }

    for i = 1, #optionsEmployee do
        options[#options+1] = {
            title = optionsEmployee[i].firstname .. " " .. optionsEmployee[i].lastname,
            description = locale("rework_employee"),
            icon = 'fa-regular fa-user',
            onSelect = function ()
                
                lib.registerContext({
                    id = "_" .. optionsEmployee[i].identifier,
                    menu = 'societyboss_employeemenu',
                    title = optionsEmployee[i].firstname .. " " .. optionsEmployee[i].lastname,
                    options = {

                        {
                            title = 'Promouvoir',
                            description = 'Augmenter le grade de votre emplyé',
                            icon = 'up-long',
                            iconColor = '#57A955',
                            onSelect = function()
                                TriggerServerEvent('ato:societyboss:promote', optionsEmployee[i].job, optionsEmployee[i].grade, optionsEmployee[i].identifier)
                            end
                        },

                        {
                            title = 'Retrograder',
                            description = 'Descendre le grade de votre emplyé',
                            icon = 'down-long',
                            iconColor = '#772F2F',
                            onSelect = function()
                                TriggerServerEvent('ato:societyboss:downgrade', optionsEmployee[i].job, optionsEmployee[i].grade, optionsEmployee[i].identifier)
                            end
                        },

                        {
                            title = 'Virer',
                            description = 'Expulser l\'employé',
                            icon = 'ban',
                            onSelect = function()
                                TriggerServerEvent('ato:societyboss:expulse', optionsEmployee[i].identifier)
                            end
                        }

                    }
                })

                lib.showContext("_" .. optionsEmployee[i].identifier)
            end,
            metadata = {
                {label = locale("dob"), value = optionsEmployee[i].dob},
                {label = locale("sex"), value = optionsEmployee[i].sex},
                {label = locale("height"), value = optionsEmployee[i].height},
                {label = locale("grade"), value = optionsEmployee[i].grade}
            }
        }
    end

    lib.registerContext({
        id = 'societyboss_employeemenu',
        title = locale("employee_options"),
        menu = 'bossmenu_main',
        options = options
    })

    lib.showContext('societyboss_employeemenu')
end)