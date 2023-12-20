-- Project: ato_societyboss
-- ProjetDesc: Resource which allows you to have a management menu for your company at one point or with a direct key.
-- File: events.lua
-- Author: discord.gg/fivedev
-- Date: 18/12/2023 04:07:00

lib.locale()

RegisterNetEvent('ato:societyboss:svopenBossMenu', function (job)
    local source = source

    TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..job, function(account)

        TriggerClientEvent('ato:societyboss:openBossMenu', source, account.money)

    end)

end)

RegisterNetEvent('ato:societyboss:recruit', function(playerId, job, jobGrade)
    local source = source

    if playerId == nil then
        return
    end

    local player = ESX.GetPlayerFromId(playerId)
    local playerLicense = player.identifier
    local sourceIde = ESX.GetPlayerFromId(source).identifier

    if ESX.DoesJobExist(job, jobGrade) then

        if Shared.debug then
            print(playerId, job, jobGrade)
        end

        player.setJob(job, jobGrade)

        MySQL.update('UPDATE users SET job = ? WHERE identifier = ?', {job, player.identifier}, function(rowsChanged) end)

        sendServerNotify(source, 'Information', "Vous avez bien recruté: " .. player.getName(), 'inform')
        sendServerNotify(playerId, 'Information', "Vous avez été recruté dans un métier", 'inform')
        sendLogs(Shared.logs.recruit, 'Recrutement', "Patron (" .. job .. "): " .. sourceIde .. "\n Joueur: " .. playerLicense .. "\n Message: Le joueur à été recruté par le patron.")
    end
end)

RegisterNetEvent('ato:societyboss:announceEmployee', function(job, title, desc)
    local source = source
    local sourceIde = ESX.GetPlayerFromId(source).identifier

    local Employees = ESX.GetExtendedPlayers('job', job)

    for i = 1, #Employees do
        sendServerNotify(Employees[i].source, title, desc, 'inform')
        sendLogs(Shared.logs.announce, 'Annonce Employé', "Player: " .. sourceIde .. "\n Titre: " .. title .. "\n Message: " .. desc)
    end
end)

RegisterNetEvent('ato:societyboss:players', function(title, desc)
    local source = source
    local sourceIde = ESX.GetPlayerFromId(source).identifier

    sendServerNotify(-1, title, desc, 'inform')
    sendLogs(Shared.logs.announce, 'Annonce Personnalisé', "Player: " .. sourceIde .. "\n Titre: " .. title .. "\n Message: " .. desc)
end)

RegisterNetEvent('ato:societyboss:washMoney', function(ammount)
    local source = source
    local player = ESX.GetPlayerFromId(source)
    local sourceIde = player.identifier
    local playerMoney = player.getAccount('black_money').money

    if playerMoney >= ammount then
        own_money = ammount * Shared.whiteningPercentage
        player.removeAccountMoney('black_money', ammount)
        player.addMoney(own_money)

        sendLogs(Shared.logs.washMoney, 'Blanchiment d\'argent', "Player: " .. sourceIde .. "\n Montant en sale: " .. ammount .. "\n Montant reçu: " .. own_money)

    else
        sendServerNotify(source, locale("error"), locale("not_enough_money"), 'error')
    end

end)

RegisterNetEvent('ato:societyboss:gradeOptions', function(job)
    local source = source

    MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = ?', {job}, function(result)
        if result then

            local optionsGrade = {}

            for _, row in ipairs(result) do
                local grade = row.grade
                local gradeName = row.name
                local gradeLabel = row.label
                local gradeSalary = row.salary

                if Shared.debug then
                    print("Grade: " .. grade .. ", Grade Name: " .. gradeName .. ", Grade Label: " .. gradeLabel .. ", Grade Salary: " .. gradeSalary)
                end

                optionsGrade[#optionsGrade + 1] = {
                    grade = grade,
                    gradeName = gradeName,
                    gradeLabel = gradeLabel,
                    gradeSalary = gradeSalary
                }
            end

            TriggerClientEvent('ato:societyboss:gradeList', source, optionsGrade)
        else
            print("Aucun résultat trouvé pour le job: " .. job)
        end
    end)
end)

RegisterNetEvent('ato:societyboss:updateGrade', function(job, grade, newSalary, newGradeLabel)
    local source = source
    local player = ESX.GetPlayerFromId(source)


    if player.job.name ~= job or player.getJob().grade == grade then
        return
    end


    MySQL.update('UPDATE job_grades SET salary = ?, label = ? WHERE job_name = ? AND grade = ?', {newSalary, newGradeLabel, job, grade}, function(rowsChanged)

        ESX.RefreshJobs()

        local xPlayers = ESX.GetExtendedPlayers('job', job)

        for _, xTarget in pairs(xPlayers) do
            if xTarget.job.grade == grade then
                xTarget.setJob(job, grade)
            end
        end      

        sendLogs(Shared.logs.reworkGrade, 'Modification de grade', "Player: " .. player.identifier .. "\n Grade après modification: " .. newGradeLabel .. "\n Salaire après modification: " .. newSalary)
    end)

end)

RegisterNetEvent('ato:societyboss:employeeOptions', function(job)
    local source = source
    local player = ESX.GetPlayerFromId(source)
    local playerIde = player.identifier

    MySQL.Async.fetchAll('SELECT * FROM users WHERE job = ?', {job}, function(result)
        if result then

            local optionsEmployee = {}

            for _, row in ipairs(result) do
                local identifier = row.identifier
                local job = row.job
                local grade = row.job_grade
                local firstname = row.firstname
                local lastname = row.lastname
                local dob = row.dateofbirth
                local sex = row.sex
                local height = row.height

                if Shared.debug then
                    print(identifier, job, grade, firstname, lastname, dob, sex, height)
                end

                if playerIde ~= identifier then
                    optionsEmployee[#optionsEmployee + 1] = {
                        identifier = row.identifier,
                        job = row.job,
                        grade = row.job_grade,
                        firstname = row.firstname,
                        lastname = row.lastname,
                        dob = row.dateofbirth,
                        sex = row.sex,
                        height = row.height
                    }
                end
            end

            TriggerClientEvent('ato:societyboss:employeeList', source, optionsEmployee, #optionsEmployee)
        else
            print("Aucun employé trouvé pour le job: " .. job)
        end

    end)

end)

RegisterNetEvent('ato:societyboss:promote', function(job, grade, identifier)
    local source = source
    local player = ESX.GetPlayerFromIdentifier(identifier)
    local srcPlayer = ESX.GetPlayerFromId(source)
    local srcJobGrade = srcPlayer.getJob().grade

    if player then

        if grade + 1 > srcJobGrade then
            sendServerNotify(source, locale("error"), locale("no_grade"), 'error')
            return
        end

        player.setJob(job, grade + 1)
        MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job, grade + 1, player.identifier}, function(rowsChanged) end)

        sendLogs(Shared.logs.reworkGrade, 'Promotion', "Patron: " .. srcPlayer.identifier .. "\n Employé: " .. player.identifier .. "\n Grade après promotion: " .. grade + 1)

    end
end)

RegisterNetEvent('ato:societyboss:downgrade', function(job, grade, identifier)
    local source = source
    local player = ESX.GetPlayerFromIdentifier(identifier)
    local srcPlayer = ESX.GetPlayerFromId(source)

    if player then

        if grade == 0 then
            sendServerNotify(source, locale("error"), locale("no_grade"), 'error')
            return
        end

        player.setJob(job, grade - 1)
        MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job, grade - 1, player.identifier}, function(rowsChanged) end)

        sendLogs(Shared.logs.reworkGrade, 'Retrogradation', "Patron: " .. srcPlayer.identifier .. "\n Employé: " .. player.identifier .. "\n Grade après retrogradation: " .. grade - 1)

    end
end)

RegisterNetEvent('ato:societyboss:expulse', function(identifier)
    local source = source
    local player = ESX.GetPlayerFromIdentifier(identifier)
    local srcPlayer = ESX.GetPlayerFromId(source)

    if player then

        player.setJob(Shared.unemployedJob, Shared.unemployedGrade)
        MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {Shared.unemployedJob, Shared.unemployedGrade, player.identifier}, function(rowsChanged) end)

        sendLogs(Shared.logs.reworkGrade, 'Entreprise', "Patron: " .. srcPlayer.identifier .. "\n Employé: " .. player.identifier .. "\n L'employé à été viré !")

    end
end)

RegisterNetEvent('ato:societyboss:moneyGestion', function (type, ammount, job)
    local source = source
    local player = ESX.GetPlayerFromId(source)

    if type == 'deposit' then
        
        if player.getMoney() < ammount then
            sendServerNotify(source, locale("error"), locale("not_enough_money"), 'error')
            return
        end

        TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..job, function(account)
            
            player.removeMoney(ammount)
            account.addMoney(ammount)
            sendLogs(Shared.logs.moneyInteraction, 'Intéraction d\'argent', "Patron: " .. player.identifier .. "\n Société: " .. job .. "\n" .. ammount .. "$ ont été déposé")

        end)

    elseif type == 'whitdraw' then

        TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..job, function(account)

            if account.money < ammount then
                sendServerNotify(source, locale("error"), locale("society_not_enough_money"), 'error')
                return 
            end

            account.removeMoney(ammount)
            player.addMoney(ammount)
            sendLogs(Shared.logs.moneyInteraction, 'Intéraction d\'argent', "Patron: " .. player.identifier .. "\n Société: " .. job .. "\n" .. ammount .. "$ ont été retiré")


        end)

    end
end)