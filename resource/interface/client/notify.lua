--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left'
---@alias NotificationType 'info' | 'warning' | 'success' | 'error'
---@alias IconAnimationType 'spin' | 'spinPulse' | 'spinReverse' | 'pulse' | 'beat' | 'fade' | 'beatFade' | 'bounce' | 'shake'

---@class NotifyProps
---@field id? string
---@field title? string
---@field description? string
---@field duration? number
---@field showDuration? boolean
---@field position? NotificationPosition
---@field type? NotificationType
---@field style? { [string]: any }
---@field icon? string | { [1]: IconProp, [2]: string }
---@field iconAnimation? IconAnimationType
---@field iconColor? string
---@field alignIcon? 'top' | 'center'
---@field sound? { bank?: string, set: string, name: string }

local settings = require 'resource.settings'

---client
---@param data NotifyProps
---@diagnostic disable-next-line: duplicate-set-field
function lib.notify(data)
    local sound = settings.notification_audio and data.sound
    data.sound = nil

    local positionMap = {
        ["top"] = "top-center",
        ["bottom"] = "bottom-right",
        ["top-left"] = "top-left",
        ["top-right"] = "top-right",
        ["bottom-left"] = "bottom-left",
        ["bottom-right"] = "bottom-right",
        ["center-left"] = "middle-left",   
        ["center-right"] = "middle-right", 
        ["middle"] = "middle-center",      
        ["center"] = "middle-center",      
    }

    local placement = positionMap[data.position] or "middle-left"

    local templateMap = {
        error = "ERROR",
        success = "SUCCESS",
        info = "INFO",
        warning = "INFO",
        tip = "TIP"
    }

    local iconTypeMap = {
        success = "tick",
        error = "cross",
        info = "warning",
        warning = "warning"
    }

    local template = data.type and templateMap[string.lower(data.type)]

    local icon = nil
    if not template then
        if data.icon then
            if type(data.icon) == "string" then
                icon = iconTypeMap[data.icon:lower()] or data.icon
            elseif type(data.icon) == "table" and type(data.icon[2]) == "string" then
                icon = iconTypeMap[data.icon[2]:lower()] or data.icon[2]
            end
        elseif data.type then
            icon = iconTypeMap[data.type:lower()] or "warning"
        else
            icon = "warning"
        end
    else
        if data.icon then
            local imageCdn = 'https://cdn.downtownrp.com.br/images/resources/inventory/%s.png'
            icon = (imageCdn):format(data.icon)
        end
    end

    local notifyOptions = {
        title = data.title or "Aviso!",
        description = data.description or "",
        duration = data.duration or 5000,
        placement = placement,
        progress = {
            enabled = true,
            type = "bar",
            color = (data.type == "error" and "#ff4444")
                 or (data.type == "success" and "#44ff44")
                 or "#aaaaaa"
        }
    }

    if icon then
        notifyOptions.icon = icon
    end

    TriggerEvent("bln_notify:send", notifyOptions, template)

    -- Sound handling
    if not sound then return end
    if sound.bank then lib.requestAudioBank(sound.bank) end

    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, sound.name, sound.set, true)
    ReleaseSoundId(soundId)

    if sound.bank then ReleaseNamedScriptAudioBank(sound.bank) end
end

---@class DefaultNotifyProps
---@field title? string
---@field description? string
---@field duration? number
---@field position? NotificationPosition
---@field status? 'info' | 'warning' | 'success' | 'error'
---@field id? number

---@param data DefaultNotifyProps
function lib.defaultNotify(data)
    -- Backwards compat for v3
    data.type = data.status
    if data.type == 'inform' then data.type = 'info' end
    return lib.notify(data --[[@as NotifyProps]])
end

RegisterNetEvent('ox_lib:notify', lib.notify)
RegisterNetEvent('ox_lib:defaultNotify', lib.defaultNotify)
