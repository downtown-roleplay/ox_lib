---@class KeybindProps
---@field name string
---@field description? string
---@field defaultMapper? string
---@field defaultKey? string
---@field modifier? string
---@field disabled? boolean
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)

---@class KeyState
---@field wasPressed boolean
---@field currentlyPressed boolean
---@field lastCheck number

---@class ModifierData
---@field hash number
---@field key string

---@class CKeybind
---@field name string
---@field description string
---@field inputKey string
---@field modifier? string
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field disabled boolean
---@field _wasPressed boolean
---@field _currentlyPressed boolean
---@field modifierData? ModifierData
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field isEnabled? fun(self: CKeybind): boolean
---@field getCurrentKey? fun(self: CKeybind): string
---@field isControlPressed? fun(self: CKeybind): boolean

---@class KeybindData
---@field key number
---@field commandsList table<string, CKeybind>

---@class KeyMapperClass
---@field keys table<string, number>
---@field keybinds table<string, KeybindData>
---@field keyStates table<string, KeyState>
---@field Thread? fun(self: KeyMapperClass): number
---@field GetDebugInfo? fun(self: KeyMapperClass): table
---@field ClearAll? fun(self: KeyMapperClass)

local Await = Citizen.Await

if cache.game == 'redm' then
    ---@type KeyMapperClass
    local KeyMapper = {
        keys = raw_keys,
        keybinds = {},
        keyStates = {} -- Adiciona rastreamento de estados das teclas
    }

    ---@param name string
    ---@param inputKey? string
    ---@return boolean success
    ---@return string? errorMessage
    function lib.removeKeybind(name, inputKey)
        if not inputKey or not KeyMapper.keybinds[inputKey] then
            return false, warn(("Cannot remove keybind '%s' because key '%s' is not mapped"):format(name, inputKey or "nil"))
        end

        if KeyMapper.keybinds[inputKey].commandsList[name] then
            KeyMapper.keybinds[inputKey].commandsList[name] = nil
        else
            return false, warn(("Cannot remove keybind '%s' because it does not exist"):format(name))
        end

        -- Se não sobrar mais comandos nesse inputKey, limpa o nó inteiro
        if next(KeyMapper.keybinds[inputKey].commandsList) == nil then
            KeyMapper.keybinds[inputKey] = nil
            -- Remove também do rastreamento de estados
            KeyMapper.keyStates[inputKey] = nil
        end

        return true
    end

    ---@param data KeybindProps
    ---@return CKeybind | false
    ---@return string? errorMessage
    function lib.addKeybind(data)
        -- Validações iniciais
        if not data or type(data) ~= "table" then
            return false, warn("Invalid keybind data provided")
        end

        if not data.name or type(data.name) ~= "string" or data.name == "" then
            return false, warn("Invalid or missing keybind name")
        end

        local commandString = data.name
        local inputKey = data.defaultKey
        local modifier = data.modifier

        -- Limpa prefixos + ou - do comando
        if commandString:sub(1, 1) == "+" or commandString:sub(1, 1) == "-" then
            commandString = commandString:sub(2, commandString:len())
        end

        if not inputKey or type(inputKey) ~= "string" or inputKey == "" then
            return false, warn("Missing or invalid input key for keybind: " .. commandString)
        end

        -- Normaliza a tecla para maiúscula
        if inputKey:lower() == inputKey then
            inputKey = inputKey:upper()
        end

        -- Verifica se a tecla existe
        if not KeyMapper.keys[inputKey] then
            return false, warn(("Registering keymapping for command '%s' on key '%s' failed: the key is missing in the key table"):format(commandString, inputKey))
        end

        -- Valida modifier se fornecido
        if modifier then
            if type(modifier) ~= "string" or modifier == "" then
                return false, warn(("Invalid modifier for keybind '%s'"):format(commandString))
            end
            
            modifier = modifier:upper()

            if not KeyMapper.keys[modifier] then
                return false, warn(("Registering keymapping for command '%s' on modifier '%s' failed: the modifier key is missing in the key table"):format(commandString, modifier))
            end
        end

        -- Inicializa estruturas se necessário
        if not KeyMapper.keybinds[inputKey] then
            ---@type KeybindData
            KeyMapper.keybinds[inputKey] = { key = KeyMapper.keys[inputKey], commandsList = {} }
        end

        -- Inicializa estado da tecla
        if not KeyMapper.keyStates[inputKey] then
            ---@type KeyState
            KeyMapper.keyStates[inputKey] = {
                wasPressed = false,
                currentlyPressed = false,
                lastCheck = 0
            }
        end

        -- Verifica se o comando já existe
        if KeyMapper.keybinds[inputKey].commandsList[commandString] then
            warn(("Keybind '%s' on key '%s' already exists, overriding"):format(commandString, inputKey))
        end

        ---@type CKeybind
        local keybind = {
            name = commandString,
            description = data.description or "No description",
            inputKey = inputKey,
            modifier = modifier,
            onPressed = type(data.onPressed) == "function" and data.onPressed or nil,
            onReleased = type(data.onReleased) == "function" and data.onReleased or nil,
            disabled = data.disabled == true,
            _wasPressed = false,
            _currentlyPressed = false
        }

        -- Adiciona os métodos no próprio objeto
        function keybind:disable(toggle)
            if type(toggle) ~= "boolean" then
                warn(("Invalid toggle value for keybind '%s', expected boolean"):format(self.name))
                return
            end
            self.disabled = toggle
        end

        function keybind:isEnabled()
            return not self.disabled
        end

        function keybind:getCurrentKey()
            return self.inputKey
        end

        function keybind:isControlPressed()
            return self._currentlyPressed
        end

        -- Armazena referência do modifier corretamente
        if modifier then
            ---@type ModifierData
            keybind.modifierData = { hash = KeyMapper.keys[modifier], key = modifier }
        end

        KeyMapper.keybinds[inputKey].commandsList[commandString] = keybind

        return keybind
    end

    ---@return number threadId
    function KeyMapper:Thread()
        local Promise = promise.new()

        CreateThread(function(threadId)
            Promise:resolve(threadId)
            
            local lastFrameTime = GetGameTimer()

            while true do
                local currentTime = GetGameTimer()
                local deltaTime = currentTime - lastFrameTime
                lastFrameTime = currentTime

                -- Itera sobre todas as teclas com keybinds
                for keyName, keyData in pairs(self.keybinds) do
                    local rawKey = self.keys[keyName]

                    if rawKey then
                        local isCurrentlyPressed = IsRawKeyPressed(rawKey)
                        local keyState = self.keyStates[keyName]

                        -- Atualiza estado da tecla
                        local wasPressed = keyState.wasPressed
                        keyState.currentlyPressed = isCurrentlyPressed
                        keyState.lastCheck = currentTime

                        -- Detecta mudanças de estado
                        local justPressed = isCurrentlyPressed and not wasPressed
                        local justReleased = not isCurrentlyPressed and wasPressed

                        -- Processa comandos para esta tecla
                        for commandString, commandData in pairs(keyData.commandsList) do
                            -- Só executa se não estiver desativado
                            if commandData and not commandData.disabled then
                                local modifierPressed = true
                                
                                -- Verifica modifier se existir
                                if commandData.modifier then
                                    local modifierKey = self.keys[commandData.modifier]
                                    if modifierKey then
                                        modifierPressed = IsRawKeyPressed(modifierKey)
                                    else
                                        warn(("Modifier key '%s' not found for command '%s'"):format(commandData.modifier, commandString))
                                        modifierPressed = false
                                    end
                                end

                                -- Atualiza estado do comando
                                commandData._currentlyPressed = isCurrentlyPressed and modifierPressed

                                -- Executa onPressed quando a tecla é pressionada pela primeira vez
                                if justPressed and modifierPressed then
                                    if not commandData._wasPressed then
                                        commandData._wasPressed = true
                                        
                                        -- Executa callback com tratamento de erro
                                        if commandData.onPressed then
                                            local success, err = pcall(commandData.onPressed, commandData)
                                            if not success then
                                                warn(("Error in onPressed callback for '%s': %s"):format(commandString, tostring(err)))
                                            end
                                        end
                                    end
                                end

                                -- Executa onReleased quando a tecla é solta
                                if justReleased or (not modifierPressed and commandData._wasPressed) then
                                    if commandData._wasPressed then
                                        commandData._wasPressed = false
                                        
                                        -- Executa callback com tratamento de erro
                                        if commandData.onReleased then
                                            local success, err = pcall(commandData.onReleased, commandData)
                                            if not success then
                                                warn(("Error in onReleased callback for '%s': %s"):format(commandString, tostring(err)))
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        -- Atualiza estado anterior da tecla
                        keyState.wasPressed = isCurrentlyPressed
                    else
                        warn(("Raw key not found for keyName: %s"):format(keyName))
                    end
                end

                -- Controle de frame rate (evita 100% CPU)
                if deltaTime < 16 then -- ~60 FPS
                    Wait(0)
                else
                    Wait(1) -- Pequeno delay se o frame está muito lento
                end
            end
        end)

        return Await(Promise)
    end

    -- Função para debug/diagnóstico
    ---@return table debugInfo
    function KeyMapper:GetDebugInfo()
        local info = {
            totalKeybinds = 0,
            keyStates = {},
            commands = {}
        }
        
        for keyName, keyData in pairs(self.keybinds) do
            info.keyStates[keyName] = self.keyStates[keyName]
            for commandName, commandData in pairs(keyData.commandsList) do
                info.totalKeybinds = info.totalKeybinds + 1
                info.commands[commandName] = {
                    key = keyName,
                    disabled = commandData.disabled,
                    hasOnPressed = commandData.onPressed ~= nil,
                    hasOnReleased = commandData.onReleased ~= nil,
                    wasPressed = commandData._wasPressed,
                    currentlyPressed = commandData._currentlyPressed
                }
            end
        end
        
        return info
    end

    -- Função para limpar todos os keybinds (útil para debugging)
    function KeyMapper:ClearAll()
        self.keybinds = {}
        self.keyStates = {}
    end

    KeyMapper:Thread()
end

---@return fun(data: KeybindProps): CKeybind | false, string?
return lib.addKeybind