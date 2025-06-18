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

local keybinds = {}

local IsPauseMenuActive = IsPauseMenuActive
local Await = Citizen.Await
local ExecuteCommand = ExecuteCommand
local IsControlJustPressed, IsDisabledControlJustPressed, IsControlJustReleased, IsDisabledControlJustReleased, IsControlPressed, IsDisabledControlPressed = IsControlJustPressed, IsDisabledControlJustPressed, IsControlJustReleased, IsDisabledControlJustReleased, IsControlPressed, IsDisabledControlPressed
local keybind_mt = {
    disabled = false,
    isPressed = false,
    defaultKey = '',
    defaultMapper = 'keyboard',
}

function keybind_mt:__index(index)
    return index == 'currentKey' and self:getCurrentKey() or keybind_mt[index]
end

if cache.game == 'redm' then
    function keybind_mt:getCurrentKey()
        return GetControlInstructionalButton(0, self.hash, true):sub(3)
    end
end

function keybind_mt:isControlPressed()
    return self.isPressed
end

function keybind_mt:disable(toggle)
    self.disabled = toggle
end

if cache.game == 'redm' then
    local KeyMapper = {
        keys = {
            ["A"] = { hash = 0x7065027D },
            ["B"] = { hash = 0x4CC0E2FE },
            ["C"] = { hash = 0x9959A6F0 },
            ["D"] = { hash = 0xB4E465B4 },
            ["E"] = { hash = 0xCEFD9220 },
            ["F"] = { hash = 0xB2F377E8 },
            ["G"] = { hash = 0x760A9C6F },
            ["H"] = { hash = 0x24978A28 },
            ["I"] = { hash = 0xC1989F95 },
            ["J"] = { hash = 0xF3830D8E },
            -- ["K"] = {hash = Missing},
            ["L"] = { hash = 0x80F28E95 },
            ["M"] = { hash = 0xE31C6A41 },
            ["N"] = { hash = 0x4BC9DABB },
            ["O"] = { hash = 0xF1301666 },
            ["P"] = { hash = 0xD82E0BD2 },
            ["Q"] = { hash = 0xDE794E3E },
            ["R"] = { hash = 0xE30CD707 },
            ["S"] = { hash = 0xD27782E3 },
            -- ["T"] = {hash = Missing},
            ["U"] = { hash = 0xD8F73058 },
            ["V"] = { hash = 0x7F8D09B8 },
            ["W"] = { hash = 0x8FD015D8 },
            ["X"] = { hash = 0x8CC9CD42 },
            -- ["Y"] = {hash = Missing},
            ["Z"] = { hash = 0x26E9DC00 },
            ["RIGHTBRACKET"] = { hash = 0xA5BDCD3C },
            ["LEFTBRACKET"] = { hash = 0x430593AA },
            ["MOUSE1"] = { hash = 0x07CE1E61 },
            ["MOUSE2"] = { hash = 0xF84FA74F },
            ["MOUSE3"] = { hash = 0xCEE12B50 },
            ["MWUP"] = { hash = 0x3076E97C },
            ["CTRL"] = { hash = 0xDB096B85 },
            ["TAB"] = { hash = 0xB238FE0B },
            ["SHIFT"] = { hash = 0x8FFC75D6 },
            ["SPACEBAR"] = { hash = 0xD9D0E1C0 },
            ["ENTER"] = { hash = 0xC7B5340A },
            ["BACKSPACE"] = { hash = 0x156F7119 },
            ["LALT"] = { hash = 0x8AAA0AD4 },
            ["DEL"] = { hash = 0x4AF4D473 },
            ["PGUP"] = { hash = 0x446258B6 },
            ["PGDN"] = { hash = 0x3C3DD371 },
            ["F1"] = { hash = 0xA8E3F467 },
            ["F4"] = { hash = 0x1F6D95E5 },
            ["F6"] = { hash = 0x3C0A40F2 },
            ["1"] = { hash = 0xE6F612E4 },
            ["2"] = { hash = 0x1CE6D9EB },
            ["3"] = { hash = 0x4F49CC4C },
            ["4"] = { hash = 0x8F9F9E58 },
            ["5"] = { hash = 0xAB62E997 },
            ["6"] = { hash = 0xA1FDE2A6 },
            ["7"] = { hash = 0xB03A913B },
            ["8"] = { hash = 0x42385422 },
            ["DOWN"] = { hash = 0x05CA7C52 },
            ["UP"] = { hash = 0x6319DB71 },
            ["LEFT"] = { hash = 0xA65EBAB4 },
            ["RIGHT"] = { hash = 0xDEB34313 },
        },

        keybinds = {}
    }

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

        if not KeyMapper.keys[inputKey] then
            return false, print(("Registering keymapping for command ' %s ' on key ' %s ' failed: the key is missing in the key table"):format(commandString, inputKey))
        end

        if modifier then
            modifier = modifier:upper()

            if not KeyMapper.keys[modifier] then
                return false, print(("Registering keymapping for command ' %s ' on key ' %s ' failed: the key is missing in the key table"):format(commandString, modifier))
            end
        end

        if not KeyMapper.keybinds[inputKey] then
            KeyMapper.keybinds[inputKey] = { hash = KeyMapper.keys[inputKey].hash, commandsList = {} }
        end

        KeyMapper.keybinds[inputKey].commandsList[commandString] = { 
            description = data.description,
            inputKey = inputKey,
            modifier = modifier,
            onPressed = data.onPressed or nil,
            onReleased = data.onReleased or nil,
        }
        KeyMapper.keybinds[inputKey].commandsList[commandString].modifier = modifier and {hash = self.keys[modifier].hash, key = modifier} or nil
    
        return KeyMapper.keybinds[inputKey].commandsList[commandString]
    end

    function KeyMapper:Thread()
        CreateThread(function()
            local Promise = promise.new()

            CreateThread(function(threadId)
                Promise:resolve(threadId)

                while true do
                    for k, v in pairs(self.keybinds) do
                        if IsControlJustPressed(0, v.hash) or IsDisabledControlJustPressed(0, v.hash) then
                            for commandString, commandData in pairs(v.commandsList) do
                                if commandData.modifier and (IsControlPressed(0, commandData.modifier.hash) or IsDisabledControlPressed(0, commandData.modifier.hash)) then
                                    
                                elseif not commandData.modifier then
                                    if commandData.onPressed then                                        
                                        commandData.onPressed()
                                    end
                                end
                            end
                        elseif IsControlJustReleased(0, v.hash) or IsDisabledControlJustReleased(0, v.hash) then
                            for commandString, commandData in pairs(v.commandsList) do
                                if commandData.modifier and (IsControlPressed(0, commandData.modifier.hash) or IsDisabledControlPressed(0, commandData.modifier.hash)) then
                                    if commandData.onReleased then
                                        commandData.onReleased()
                                    end
                                elseif not commandData.modifier then
                                    if commandData.onReleased then
                                        commandData.onReleased()
                                    end
                                end
                            end
                        end
                    end

                    -- I didnt had the option the have a slower thread has if you're using the script its most likely going to use keybinds.
                    Wait(0)
                end
            end)

            return Await(Promise)
        end)
    end

    KeyMapper:Thread()
end

if cache.game == 'fivem' then
    ---@param data KeybindProps
    ---@return CKeybind
    function lib.addKeybind(data)
        ---@cast data CKeybind
        data.hash = joaat('+' .. data.name) | 0x80000000
        keybinds[data.name] = setmetatable(data, keybind_mt)

        RegisterCommand('+' .. data.name, function()
            if data.disabled or IsPauseMenuActive() then return end
            data.isPressed = true
            if data.onPressed then data:onPressed() end
        end)

        RegisterCommand('-' .. data.name, function()
            if data.disabled or IsPauseMenuActive() then return end
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
end

return lib.addKeybind
