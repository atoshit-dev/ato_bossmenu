function sendLogs(webhook, title, message)
    local embed = {
        {
            ["color"] = 16448250,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Ato Logs",
            },
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Society Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end