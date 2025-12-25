--[[
    Sistema de Points adaptado para Server-Side
    Gerencia pontos de interesse para múltiplos jogadores
]]

---@class ServerPointProperties
---@field coords vector3
---@field distance number
---@field onEnter? fun(self: ServerPoint, source: number)
---@field onExit? fun(self: ServerPoint, source: number)
---@field nearby? fun(self: ServerPoint, source: number)
---@field [string] any

---@class ServerPoint : ServerPointProperties
---@field id number
---@field playersInside table<number, boolean>
---@field remove fun()

---@type table<number, ServerPoint>
local points = {}
---@type table<number, table<number, ServerPoint>> -- [source][pointId]
local playerNearbyPoints = {}

local function removePoint(self)
    -- Remove todos os jogadores deste ponto
    for source in pairs(self.playersInside or {}) do
        if self.onExit then
            self:onExit(source)
        end
        
        if playerNearbyPoints[source] then
            playerNearbyPoints[source][self.id] = nil
        end
    end
    
    points[self.id] = nil
end

local function toVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

-- Thread principal que verifica a posição de cada jogador
CreateThread(function()
    while true do
        local players = GetPlayers()
        
        for _, playerId in ipairs(players) do
            local source = tonumber(playerId)
            local ped = GetPlayerPed(source)
            
            if ped and DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                
                if not playerNearbyPoints[source] then
                    playerNearbyPoints[source] = {}
                end
                
                -- Verifica cada ponto registrado
                for pointId, point in pairs(points) do
                    local distance = #(coords - point.coords)
                    local isInside = distance <= point.distance
                    local wasInside = playerNearbyPoints[source][pointId] ~= nil
                    
                    if isInside and not wasInside then
                        -- Jogador entrou no ponto
                        if not point.playersInside then
                            point.playersInside = {}
                        end
                        
                        point.playersInside[source] = true
                        playerNearbyPoints[source][pointId] = point
                        
                        if point.onEnter then
                            point:onEnter(source)
                        end
                        
                    elseif not isInside and wasInside then
                        -- Jogador saiu do ponto
                        if point.playersInside then
                            point.playersInside[source] = nil
                        end
                        
                        playerNearbyPoints[source][pointId] = nil
                        
                        if point.onExit then
                            point:onExit(source)
                        end
                        
                    elseif isInside and wasInside then
                        -- Jogador está dentro, executa nearby
                        if point.nearby then
                            point:nearby(source)
                        end
                    end
                end
            end
        end
        
        Wait(500) -- Ajuste conforme necessário
    end
end)

-- Limpa os dados quando um jogador desconecta
AddEventHandler('playerDropped', function()
    local source = source
    
    if playerNearbyPoints[source] then
        -- Executa onExit para todos os pontos que o jogador estava dentro
        for pointId, point in pairs(playerNearbyPoints[source]) do
            if point.onExit then
                point:onExit(source)
            end
            
            if point.playersInside then
                point.playersInside[source] = nil
            end
        end
        
        playerNearbyPoints[source] = nil
    end
end)

-- API Pública
lib = lib or {}
lib.points = {}

---Cria um novo ponto de interesse no servidor
---@param data ServerPointProperties
---@return ServerPoint
function lib.points.new(data)
    local id = #points + 1
    
    local self = {
        id = id,
        coords = toVector(data.coords),
        distance = data.distance,
        onEnter = data.onEnter,
        onExit = data.onExit,
        nearby = data.nearby,
        playersInside = {},
        remove = removePoint,
    }
    
    -- Adiciona propriedades extras
    for k, v in pairs(data) do
        if not self[k] then
            self[k] = v
        end
    end
    
    points[id] = self
    
    return self
end

---Retorna todos os pontos registrados
---@return table<number, ServerPoint>
function lib.points.getAllPoints()
    return points
end

---Retorna os pontos próximos de um jogador específico
---@param source number
---@return table<number, ServerPoint>
function lib.points.getNearbyPoints(source)
    return playerNearbyPoints[source] or {}
end

---Retorna todos os jogadores dentro de um ponto específico
---@param pointId number
---@return table<number, boolean>
function lib.points.getPlayersInPoint(pointId)
    local point = points[pointId]
    return point and point.playersInside or {}
end

---Verifica se um jogador está dentro de um ponto
---@param source number
---@param pointId number
---@return boolean
function lib.points.isPlayerInPoint(source, pointId)
    return playerNearbyPoints[source] and playerNearbyPoints[source][pointId] ~= nil
end

return lib.points

--[[
    EXEMPLO DE USO:

    -- Criar um ponto de venda de drogas
    local drugPoint = lib.points.new({
        coords = vec3(123.45, -456.78, 28.5),
        distance = 5.0,
        
        onEnter = function(self, source)
            print(('Jogador %s entrou na área de drogas'):format(source))
            TriggerClientEvent('showNotification', source, 'Você entrou na zona de drogas')
        end,
        
        onExit = function(self, source)
            print(('Jogador %s saiu da área de drogas'):format(source))
            TriggerClientEvent('hideNotification', source)
        end,
        
        nearby = function(self, source)
            -- Executado constantemente enquanto o jogador está próximo
            -- Útil para verificações periódicas
        end
    })

    -- Remover o ponto depois
    -- drugPoint:remove()
]]