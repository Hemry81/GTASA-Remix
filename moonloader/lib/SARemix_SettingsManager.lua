local function serializeToJSON(tbl)
    local function serialize(tbl, level)
        level = level or 0
        local indent = string.rep("  ", level)  -- Create indentation based on the current level
        local result = {}

        if level > 0 then result[#result + 1] = "{\n" else result[#result + 1] = "{" end
        for k, v in pairs(tbl) do
            local formattedKey = type(k) == "string" and '"' .. k .. '":' or '[' .. k .. ']:'
            if type(v) == "table" then
                result[#result + 1] = indent .. formattedKey .. serialize(v, level + 1)
            else
                local formattedValue = type(v) == "string" and '"' .. v .. '"' or tostring(v)
                result[#result + 1] = indent .. "  " .. formattedKey .. formattedValue
            end
            result[#result + 1] = ",\n"
        end
        if #result > 0 then result[#result] = "\n" .. indent .. "}" else result[#result + 1] = "}" end
        return table.concat(result)
    end
    return serialize(tbl)
end

local function saveSettings(filePath, settings)
    local file = io.open(filePath, "w")
    if not file then
        print("Failed to open file for writing.")
        return false
    end
    
    local jsonString = serializeToJSON(settings)
    file:write(jsonString)
    file:close()
    print("Settings saved successfully.")
    return true
end

local function mergeTables(defaults, loaded)
    if type(loaded) ~= 'table' then return defaults end
    local result = {}
    for k, v in pairs(defaults) do
        if type(v) == 'table' and type(loaded[k]) == 'table' then
            -- Recursively merge tables
            result[k] = mergeTables(v, loaded[k])
        else
            -- If loaded has a value for k, use it, otherwise use the value from defaults
            result[k] = loaded[k] ~= nil and loaded[k] or v
        end
    end
    for k, v in pairs(loaded) do
        if result[k] == nil then
            -- If the key doesn't exist in the result yet, add it from loaded
            result[k] = v
        end
    end
    return result
end

local function loadSettings(filePath, defaultSettings)
    local file = io.open(filePath, "r")
    if not file then
        print("Failed to open file for reading.")
        return defaultSettings
    end

    local content = file:read("*a")
    file:close()

    -- Replace ':' with '=' for Lua table syntax, and ensure all keys are correctly formatted
    content = content:gsub('"(.-)":', '%1 =')  -- Adjust string keys in objects
    content = content:gsub('%[(%d+)%]:', '[%1] =')  -- Adjust numeric indices

    -- Attempt to convert the modified string back to a Lua table
    local settingsTable, err = load("return " .. content, nil, "t", {})
    if not settingsTable then
        print("Failed to parse settings: " .. err)
        return defaultSettings
    end

    local ok, settings = pcall(settingsTable)
    if not ok then
        print("Failed to execute parsed settings: " .. settings)
        return defaultSettings
    end

    return settings
end

return {
    saveSettings = saveSettings,
    loadSettings = loadSettings,
    serializeToJSON = serializeToJSON
}