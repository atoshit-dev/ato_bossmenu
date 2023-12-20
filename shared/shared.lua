-- Project: ato_societyboss
-- ProjetDesc: Resource which allows you to have a management menu for your company at one point or with a direct key.
-- File: shared.lua
-- Author: discord.gg/fivedev
-- Date: 18/12/2023 04:01:55

local Shared <const> = {

    debug = false, -- activates debug messages on the server and client sides
    menuSystem = 'target', -- 'target' = boss menu has precise target | 'touch' = boss menu via a key (anywhere on the map)
    keyOpenBossMenu = 'F7',
    resourceName = GetCurrentResourceName(),
    whiteningPercentage = 0.80, -- Percentage received from the initial price after laundering, 0.80 corresponds to 80%
    maxSalary = 5000,
    unemployedJob = 'unemployed',
    unemployedGrade = 0,

    logs = { 
        recruit = 'https://ptb.discord.com/api/webhooks/1186200282447757464/gBdmCYgkSnH-wU7sR09E1Pu62faj1ga8_uZqsJT_sNj56cUQxuUQXLsi-Ilxv5GKxgyw',
        announce = 'https://ptb.discord.com/api/webhooks/1186200282447757464/gBdmCYgkSnH-wU7sR09E1Pu62faj1ga8_uZqsJT_sNj56cUQxuUQXLsi-Ilxv5GKxgyw',
        washMoney = 'https://ptb.discord.com/api/webhooks/1186200282447757464/gBdmCYgkSnH-wU7sR09E1Pu62faj1ga8_uZqsJT_sNj56cUQxuUQXLsi-Ilxv5GKxgyw',
        reworkGrade = 'https://ptb.discord.com/api/webhooks/1186200282447757464/gBdmCYgkSnH-wU7sR09E1Pu62faj1ga8_uZqsJT_sNj56cUQxuUQXLsi-Ilxv5GKxgyw',
        moneyInteraction = 'https://ptb.discord.com/api/webhooks/1186200282447757464/gBdmCYgkSnH-wU7sR09E1Pu62faj1ga8_uZqsJT_sNj56cUQxuUQXLsi-Ilxv5GKxgyw'
    },

    society = {
        {name = 'police', label = 'LSPD', coords = vec3(-22.450283050537, -1097.5412597656, 26.19454574585), bossGrade = 4, washMoney = true},
        {name = 'cardealer', label = 'Concessionaire', coords = vec3(-23.630056381226, -1101.4237060547, 26.19454574585), bossGrade = 4, washMoney = true},
        {name = 'ambulance', label = 'Ambulance', coords = vec3(-30.604228973389, -1100.12109375, 26.19454574585), bossGrade = 3, washMoney = true}

    }

}

_ENV.Shared = Shared

function sendNotify(title, description, icon, iconColor, type)

    if title == nil then
        title = ESX.PlayerData.job.label
    end

    if description == nil then
        description = 'Merci de bien définir la déscription dans la notification'
    end

    if icon == nil then
        icon = 'envelope'
    end

    if iconColor == nil then
        iconColor = '#FFFBFB'
    end

    if type == nil then
        type = 'inform'
    end

    lib.notify({
        title = title,
        description = description,
        position = 'top',
        icon = icon,
        iconColor = iconColor,
        duration = 4000,
        type = type
    })

end

function sendServerNotify(player, title, message, type)
    TriggerClientEvent('ox_lib:notify', player, {
        title = title,
        description = message,
        position = 'top',
        duration = 5000,
        type =  type,
    })
end
