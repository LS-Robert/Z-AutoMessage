local commandsFile = "commands.json"
local commands = {}
local historyFile = "command_history.json"
local history = {}

Citizen.CreateThread(function()
    EnsureCommandsFileExists()
    EnsureHistoryFileExists()

    if LoadResourceFile(GetCurrentResourceName(), commandsFile) then
        commands = json.decode(LoadResourceFile(GetCurrentResourceName(), commandsFile))
    end

    if LoadResourceFile(GetCurrentResourceName(), historyFile) then
        history = json.decode(LoadResourceFile(GetCurrentResourceName(), historyFile))
    end
end)

function EnsureCommandsFileExists()
    if not LoadResourceFile(GetCurrentResourceName(), commandsFile) then
        SaveCommandsToFile({})
    end
end

function EnsureHistoryFileExists()
    if not LoadResourceFile(GetCurrentResourceName(), historyFile) then
        SaveHistoryToFile({})
    end
end

function SaveCommandsToFile()
    SaveResourceFile(GetCurrentResourceName(), commandsFile, json.encode(commands, { indent = true }), -1)
end

function SaveHistoryToFile()
    SaveResourceFile(GetCurrentResourceName(), historyFile, json.encode(history, { indent = true }), -1)
end

function LogHistory(action, playerName, commandId, oldData, newData)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    table.insert(history, { action = action, player = playerName, timestamp = timestamp, commandId = commandId, oldData = oldData, newData = newData })
    SaveHistoryToFile()
end

RegisterCommand('addcommand', function(source, args)
    local playerName = GetPlayerName(source)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1You do not have permission to use this command." } })
        return
    end

    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1Usage: /addcommand \"phrase\" time_in_minutes" } })
        return
    end

    local commandText = table.concat(args, " ", 1, #args - 1)
    local timeInterval = tonumber(args[#args])

    if commandText and timeInterval then
        local newCommand = {
            text = commandText,
            interval = timeInterval * 60000,
            lastSent = 0
        }

        table.insert(commands, newCommand)
        SaveCommandsToFile()
        SendServerMessage("^2New command added: " .. commandText)
        LogHistory("Add Command", playerName, #commands, nil, newCommand)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { "^1Usage: /addcommand \"phrase\" time_in_minutes" } })
    end
end, false)

RegisterCommand('editcommand', function(source, args)
    local playerName = GetPlayerName(source)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local commandId = tonumber(args[1])
    local newText = table.concat(args, " ", 2, #args)

    if commandId and commands[commandId] and newText then
        local oldCommand = commands[commandId]
        oldCommand.text = newText
        commands[commandId] = oldCommand
        SaveCommandsToFile()
        SendServerMessage("^2Command edited: ID " .. commandId)
        LogHistory("Edit Command", playerName, commandId, oldCommand, commands[commandId])
    else
        TriggerClientEvent('chat:addMessage', source, { args = { "^1Usage: /editcommand command_id \"new_text\"" } })
    end
end, false)

RegisterCommand('deletecommand', function(source, args)
    local playerName = GetPlayerName(source)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local commandId = tonumber(args[1])
    
    if commandId and commands[commandId] then
        local deletedCommand = table.remove(commands, commandId)
        SaveCommandsToFile()
        SendServerMessage("^1Command deleted: ID " .. commandId)
        LogHistory("Delete Command", playerName, commandId, deletedCommand, nil)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { "^1Usage: /deletecommand command_id" } })
    end
end, false)

RegisterCommand('seecommands', function(source, args)
    local playerName = GetPlayerName(source)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1You do not have permission to use this command." } })
        return
    end

    for id, cmd in ipairs(commands) do
        SendServerMessage("^3ID: " .. id .. " - Command: " .. cmd.text .. " - Interval: " .. (cmd.interval / 60000) .. " minutes")
    end

    LogHistory("View Commands", playerName, nil, nil, nil)
end, false)

RegisterCommand('reloadcommands', function(source, args)
    local playerName = GetPlayerName(source)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1You do not have permission to use this command." } })
        return
    end

    ReloadCommands()
    SendServerMessage("^2Commands reloaded by " .. playerName)
    LogHistory("Reload Commands", playerName, nil, nil, nil)
end, false)

function ReloadCommands()
    if LoadResourceFile(GetCurrentResourceName(), commandsFile) then
        commands = json.decode(LoadResourceFile(GetCurrentResourceName(), commandsFile))
    end
end

function SendServerMessage(message, color)
    TriggerClientEvent('chat:addMessage', -1, { args = { "^8[Server]^7 " .. message } })
end

function IsPlayerAdmin(playerSource)
    return IsPlayerAceAllowed(playerSource, "command")
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        for _, cmd in ipairs(commands) do
            if os.time() * 1000 - cmd.lastSent >= cmd.interval then
                SendServerMessage(cmd.text)
                cmd.lastSent = os.time() * 1000
                SaveCommandsToFile()
            end
        end
    end
end)
