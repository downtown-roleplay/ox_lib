-- Add additional functions to the standard table library

---@class oxtable : tablelib
lib.table = table
local pairs = pairs

---@param tbl table
---@param value any
---@return boolean
---Checks if tbl contains the given values. Only intended for simple values and unnested tables.
local function contains(tbl, value)
    if type(value) ~= 'table' then
        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end

        return false
    else
        local set = {}

        for _, v in pairs(tbl) do
            set[v] = true
        end

        for _, v in pairs(value) do
            if not set[v] then
                return false
            end
        end

        return true
    end
end

---@param t1 any
---@param t2 any
---@return boolean
---Compares if two values are equal, iterating over tables and matching both keys and values.
local function table_matches(t1, t2)
    local tabletype1 = table.type(t1)

    if not tabletype1 then return t1 == t2 end

    if tabletype1 ~= table.type(t2) or (tabletype1 == 'array' and #t1 ~= #t2) then
        return false
    end

    for k, v1 in pairs(t1) do
        local v2 = t2[k]
        if v2 == nil or not table_matches(v1, v2) then
            return false
        end
    end

    for k in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end

    return true
end

---@generic T
---@param tbl T
---@return T
---Recursively clones a table to ensure no table references.
local function table_deepclone(tbl)
    tbl = table.clone(tbl)

    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            tbl[k] = table_deepclone(v)
        end
    end

    return tbl
end

local function table_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
        copy[table.copy(orig_key)] = table.copy(orig_value)
      end
      setmetatable(copy, table.copy(getmetatable(orig)))
    else -- number, string, boolean, etc
      copy = orig
    end
    return copy
  end
  

---comment
---@param t table
---@param f function
---@param options { as_list: boolean, copy: boolean }
---@return table
local function table_map(t, f, options)
    assert(type(t) == "table", "First argument must be a table")
    assert(type(f) == "function", "Second argument must be a function")

    options = options or {}
    local use_list = options.as_list or false
    local make_copy = options.copy or false

    local new_table = {}
    for k, v in pairs(t) do
        local result = f(v, k, t)
        if use_list then
            table.insert(new_table, result)
        else
            new_table[k] = result
        end
    end

    return make_copy and table_copy(new_table) or new_table
end

local function table_filter(t, filterIter, keepKeyAssociation)
    local out = {}
    if keepKeyAssociation == nil then keepKeyAssociation = false end
    for k, v in pairs(t) do
      if filterIter(v, k, t) then
        if keepKeyAssociation or type(k) ~= "number" then
          out[k] = v
        else
          out[#out + 1] = v
        end
      end
    end
    return out
end

local function table_find(t, cb)
    assert(type(t) == "table", "First argument must be a table")
    assert(type(cb) == "function", "Second argument must be a function")

    for k, v in pairs(t) do
        if cb(v, k, t) then
            return v, k
        end
    end
    
    return nil
end


local function table_extend(target, extension)
	local tbl = table.clone(target)
	for _, v in ipairs(extension) do
		table.insert(tbl, v)
	end
	return tbl
end

---@param t1 table
---@param t2 table
---@param addDuplicateNumbers boolean? add duplicate number keys together if true, replace if false. Defaults to true.
---@return table
---Merges two tables together. Defaults to adding duplicate keys together if they are numbers, otherwise they are overriden.
local function table_merge(t1, t2, addDuplicateNumbers)
    addDuplicateNumbers = addDuplicateNumbers == nil or addDuplicateNumbers
    for k, v2 in pairs(t2) do
        local v1 = t1[k]
        local type1 = type(v1)
        local type2 = type(v2)

        if type1 == 'table' and type2 == 'table' then
            table_merge(v1, v2, addDuplicateNumbers)
        elseif addDuplicateNumbers and (type1 == 'number' and type2 == 'number') then
            t1[k] = v1 + v2
        else
            t1[k] = v2
        end
    end

    return t1
end

table.contains = contains
table.matches = table_matches
table.deepclone = table_deepclone
table.merge = table_merge
table.map = table_map
table.extend = table_extend
table.filter = table_filter
table.find = table_find

local frozenNewIndex = function(self) error(('cannot set values on a frozen table (%s)'):format(self), 2) end
local _rawset = rawset

---@param tbl table
---@param index any
---@param value any
---@return table
function rawset(tbl, index, value)
    if table.isfrozen(tbl) then
        frozenNewIndex(tbl)
    end

    return _rawset(tbl, index, value)
end

---Makes a table read-only, preventing further modification. Unfrozen tables stored within `tbl` are still mutable.
---@generic T : table
---@param tbl T
---@return T
function table.freeze(tbl)
    local copy = table.clone(tbl)
    local metatbl = getmetatable(tbl)

    table.wipe(tbl)
    setmetatable(tbl, {
        __index = metatbl and setmetatable(copy, metatbl) or copy,
        __metatable = 'readonly',
        __newindex = frozenNewIndex,
        __len = function() return #copy end,
        ---@diagnostic disable-next-line: redundant-return-value
        __pairs = function() return next, copy end,
    })

    return tbl
end

---Return true if `tbl` is set as read-only.
---@param tbl table
---@return boolean
function table.isfrozen(tbl)
    return getmetatable(tbl) == 'readonly'
end

return lib.table
