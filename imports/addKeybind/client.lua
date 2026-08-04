---@class KeybindProps
---@field name string
---@field description? string
---@field defaultMapper? string
---@field defaultKey? string
---@field secondaryKey? string
---@field secondaryMapper? string
---@field modifier? string        -- só usado no fallback manual
---@field disabled? boolean
---@field allowInPauseMenu? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field [string] any

---@class CKeybind : KeybindProps
---@field currentKey string
---@field disabled boolean
---@field isPressed boolean
---@field hash number
---@field getCurrentKey fun(self: CKeybind): string
---@field isControlPressed fun(self: CKeybind): boolean

local keybinds = {}

-- Feature detection: usa a native se ela existir no ambiente atual,
-- independente do jogo. Isso cobre FiveM hoje e RedM no dia que a
-- PR #4075 (ou equivalente) for mergeada.
local hasNativeKeyMapping = type(RegisterKeyMapping) == 'function'
    and type(RegisterCommand) == 'function'

if hasNativeKeyMapping then
    ------------------------------------------------------------------
    -- Caminho nativo: RegisterKeyMapping existe no ambiente
    ------------------------------------------------------------------
    local IsPauseMenuActive = IsPauseMenuActive
    local GetControlInstructionalButton = GetControlInstructionalButton
    local hasInstructionalButton = type(GetControlInstructionalButton) == 'function'

    local keybind_mt = {
        disabled = false,
        isPressed = false,
        defaultKey = '',
        defaultMapper = 'keyboard',
    }

    function keybind_mt:__index(index)
        return index == 'currentKey' and self:getCurrentKey() or keybind_mt[index]
    end

    function keybind_mt:getCurrentKey()
        if hasInstructionalButton then
            return GetControlInstructionalButton(0, self.hash, true):sub(3)
        end

        -- native de mapping existe, mas não a de label (ex: RedM
        -- pode portar RegisterKeyMapping sem portar essa outra)
        return self.defaultKey
    end

    function keybind_mt:isControlPressed()
        return self.isPressed
    end

    function keybind_mt:disable(toggle)
        self.disabled = toggle
        self.isPressed = false
    end

    ---@param data KeybindProps
    ---@return CKeybind
    function lib.addKeybind(data)
        ---@cast data CKeybind
        data.hash = joaat('+' .. data.name) | 0x80000000
        keybinds[data.name] = setmetatable(data, keybind_mt)

        RegisterCommand('+' .. data.name, function()
            if data.disabled or (IsPauseMenuActive and IsPauseMenuActive() and not data.allowInPauseMenu) then return end
            data.isPressed = true
            if data.onPressed then data:onPressed() end
        end)

        RegisterCommand('-' .. data.name, function()
            if data.disabled or (IsPauseMenuActive and IsPauseMenuActive() and not data.allowInPauseMenu) then return end
            data.isPressed = false
            if data.onReleased then data:onReleased() end
        end)

        RegisterKeyMapping('+' .. data.name, data.description, data.defaultMapper, data.defaultKey)

        if data.secondaryKey then
            RegisterKeyMapping('~!+' .. data.name, data.description, data.secondaryMapper or data.defaultMapper, data.secondaryKey)
        end

        SetTimeout(500, function()
            TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
            TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
        end)

        return data
    end

    function lib.removeKeybind(name)
        local data = keybinds[name]
        if not data then return false end
        data:disable(true)
        return true
    end
else
    ------------------------------------------------------------------
    -- Fallback: RegisterKeyMapping não existe -> polling manual
    ------------------------------------------------------------------
    local IsRawKeyPressed = IsRawKeyPressed
    local rawKeys = raw_keys -- table<string, number>

    local keyNodes = {}   -- [inputKey] = { key = rawKeyId, commandsList = { [name] = CKeybind } }
    local keyStates = {}  -- [inputKey] = { wasPressed = bool }

    local keybind_mt = {}
    keybind_mt.__index = keybind_mt

    function keybind_mt:getCurrentKey()
        return self.defaultKey
    end

    function keybind_mt:isControlPressed()
        return self.isPressed
    end

    function keybind_mt:disable(toggle)
        self.disabled = toggle
        self.isPressed = false
    end

    ---@param data KeybindProps
    ---@return CKeybind | false
    ---@return string? errorMessage
    function lib.addKeybind(data)
        if not data.name or data.name == '' then
            return false, 'lib.addKeybind: missing keybind name'
        end

        local name = data.name:gsub('^[+-]', '')
        local inputKey = data.defaultKey and data.defaultKey:upper()

        if not inputKey or inputKey == '' then
            return false, ('lib.addKeybind: missing defaultKey for "%s"'):format(name)
        end

        if not rawKeys[inputKey] then
            return false, ('lib.addKeybind: key "%s" not found in raw key table'):format(inputKey)
        end

        local modifier = data.modifier and data.modifier:upper() or nil
        if modifier and not rawKeys[modifier] then
            return false, ('lib.addKeybind: modifier "%s" not found in raw key table'):format(modifier)
        end

        keyNodes[inputKey] = keyNodes[inputKey] or { key = rawKeys[inputKey], commandsList = {} }
        keyStates[inputKey] = keyStates[inputKey] or { wasPressed = false }

        ---@cast data CKeybind
        data.name = name
        data.defaultKey = inputKey
        data.modifier = modifier
        data.disabled = data.disabled == true
        data.isPressed = false

        setmetatable(data, keybind_mt)

        keyNodes[inputKey].commandsList[name] = data
        keybinds[name] = data

        return data
    end

    ---@param name string
    ---@return boolean success
    ---@return string? errorMessage
    function lib.removeKeybind(name)
        local data = keybinds[name]
        if not data then
            return false, ('lib.removeKeybind: "%s" does not exist'):format(name)
        end

        local node = keyNodes[data.defaultKey]
        if node then
            node.commandsList[name] = nil
            if next(node.commandsList) == nil then
                keyNodes[data.defaultKey] = nil
                keyStates[data.defaultKey] = nil
            end
        end

        keybinds[name] = nil
        return true
    end

    CreateThread(function()
        while true do
            for keyName, node in pairs(keyNodes) do
                local state = keyStates[keyName]
                local isDown = IsRawKeyPressed(node.key)
                local justPressed = isDown and not state.wasPressed
                local justReleased = not isDown and state.wasPressed

                for _, data in pairs(node.commandsList) do
                    if not data.disabled then
                        local modifierOk = not data.modifier or IsRawKeyPressed(rawKeys[data.modifier])

                        if justPressed and modifierOk and not data.isPressed then
                            data.isPressed = true
                            if data.onPressed then
                                local ok, err = pcall(data.onPressed, data)
                                if not ok then warn(('keybind "%s" onPressed error: %s'):format(data.name, err)) end
                            end
                        elseif (justReleased or not modifierOk) and data.isPressed then
                            data.isPressed = false
                            if data.onReleased then
                                local ok, err = pcall(data.onReleased, data)
                                if not ok then warn(('keybind "%s" onReleased error: %s'):format(data.name, err)) end
                            end
                        end
                    end
                end

                state.wasPressed = isDown
            end

            Wait(0)
        end
    end)
end

return lib.addKeybind