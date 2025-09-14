---@class KeybindProps
---@field name string
---@field description string
---@field defaultMapper? string
---@field defaultKey? string
---@field modifier? string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field [string] any

---@class CKeybind : KeybindProps
---@field currentKey string
---@field disabled boolean
---@field isPressed boolean
---@field hash number
---@field getCurrentKey fun(): string
---@field isControlPressed fun(): boolean

local Await = Citizen.Await

if cache.game == 'redm' then
    local KeyMapper = {
        keys = raw_keys,
        keybinds = {}
    }

    ---@param name string
    ---@param inputKey string
    function lib.removeKeybind(name, inputKey)
        if not inputKey or not KeyMapper.keybinds[inputKey] then
            return false, warn(("Cannot remove keybind '%s' because key '%s' is not mapped"):format(name, inputKey or "nil"))
        end

        if KeyMapper.keybinds[inputKey].commandsList[name] then
            KeyMapper.keybinds[inputKey].commandsList[name] = nil
        else
            return false, warn(("Cannot remove keybind '%s' because it does not exist"):format(name))
        end

        -- se não sobrar mais comandos nesse inputKey, limpa o nó inteiro
        if next(KeyMapper.keybinds[inputKey].commandsList) == nil then
            KeyMapper.keybinds[inputKey] = nil
        end

        return true
    end

    --- Desativa um keybind
    ---@param name string
    ---@param inputKey string
    function lib.disableKeybind(name, inputKey)
        local keyData = KeyMapper.keybinds[inputKey]
        if keyData and keyData.commandsList[name] then
            keyData.commandsList[name].disabled = true
            return true
        end
        return false
    end

    --- Ativa um keybind
    ---@param name string
    ---@param inputKey string
    function lib.enableKeybind(name, inputKey)
        local keyData = KeyMapper.keybinds[inputKey]
        if keyData and keyData.commandsList[name] then
            keyData.commandsList[name].disabled = false
            return true
        end
        return false
    end

    ---@param data KeybindProps
    ---@return CKeybind | boolean
    function lib.addKeybind(data)
        local commandString = data.name
        local inputKey = data.defaultKey
        local modifier = data.modifier
        if commandString:sub(1, 1) == "+" or commandString:sub(1, 1) == "-" then
            commandString = commandString:sub(2, commandString:len())
        end

        if not inputKey then
            return false, warn("Missing input key for keybind: " .. commandString)
        end

        if inputKey:lower() == inputKey then
            inputKey = inputKey:upper()
        end

        if not KeyMapper.keys[inputKey] then
            return false,
                print(("Registering keymapping for command ' %s ' on key ' %s ' failed: the key is missing in the key table"):format(commandString, inputKey))
        end

        if modifier then
            modifier = modifier:upper()

            if not KeyMapper.keys[modifier] then
                return false,
                    print(("Registering keymapping for command ' %s ' on key ' %s ' failed: the key is missing in the key table"):format(commandString, modifier))
            end
        end

        if not KeyMapper.keybinds[inputKey] then
            KeyMapper.keybinds[inputKey] = { key = KeyMapper.keys[inputKey], commandsList = {} }
        end

        KeyMapper.keybinds[inputKey].commandsList[commandString] = {
            description = data.description,
            inputKey = inputKey,
            modifier = modifier,
            onPressed = data.onPressed or nil,
            onReleased = data.onReleased or nil,
        }
        KeyMapper.keybinds[inputKey].commandsList[commandString].modifier = modifier and { hash = self.keys, key = modifier } or nil

        return KeyMapper.keybinds[inputKey].commandsList[commandString]
    end

    function KeyMapper:Thread()
        CreateThread(function()
            local Promise = promise.new()

            CreateThread(function(threadId)
                Promise:resolve(threadId)

                while true do
                    for keyName, keyData in pairs(self.keybinds) do
                        local rawKey = raw_keys[keyName]

                        if rawKey then
                            local isPressed = IsRawKeyPressed(rawKey)
                            local isReleased = IsRawKeyReleased(rawKey)

                            for commandString, commandData in pairs(keyData.commandsList) do
                                -- só executa se não estiver desativado
                                if not commandData.disabled then
                                    local modifier = commandData.modifier and raw_keys[commandData.modifier.key]
                                    local modifierDown = not modifier or IsRawKeyPressed(modifier)

                                    if isPressed and modifierDown then
                                        if not commandData._wasPressed then
                                            commandData._wasPressed = true
                                            if commandData.onPressed then
                                                commandData.onPressed()
                                            end
                                        end
                                    end

                                    if isReleased then
                                        if commandData._wasPressed then
                                            commandData._wasPressed = false
                                            if commandData.onReleased then
                                                commandData.onReleased()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    Wait(0)
                end
            end)

            return Await(Promise)
        end)
    end

    KeyMapper:Thread()
end


return lib.addKeybind
