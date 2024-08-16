function serializeToJSON(val, seen)
    seen = seen or {}
    local valType = type(val)

    if valType == "string" then
        return string.format("\"%s\"", val)
    elseif valType == "number" or valType == "boolean" then
        return tostring(val)
    elseif valType ~= "table" then
        error("JSON can only serialize numbers, booleans, strings, and tables")
    end

    if seen[val] then
        return "\"[Circular]\""
    end
    seen[val] = true

    local s = "{"
    for k, v in pairs(val) do
        if type(k) ~= "string" and type(k) ~= "number" then
            error("JSON can only serialize string or number keys")
        end
        k = type(k) == "string" and string.format("\"%s\"", k) or k
        s = s .. string.format("%s:%s,", k, serializeToJSON(v, seen))
    end
    if #s > 1 then
        s = s:sub(1, -2)  -- Remove the last comma
    end
    s = s .. "}"
    seen[val] = nil
    return s
end

function saveSettings(filePath, settings)
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

function mergeTables(defaults, loaded)
    if type(loaded) ~= 'table' then return defaults end
    local result = {}
    for k, v in pairs(defaults) do
        if type(v) == 'table' then
            result[k] = mergeTables(v, loaded[k])
        else
            result[k] = loaded[k] ~= nil and loaded[k] or v
        end
    end
    for k, v in pairs(loaded) do
        if result[k] == nil then
            result[k] = v
        end
    end
    return result
end

function loadSettings(filePath, defaultSettings)
    local file = io.open(filePath, "r")
    if not file then
        print("Failed to open file for reading.")
        return defaultSettings
    end
    
    local content = file:read("*a")
    file:close()

    -- Convert from JSON string to Lua table manually
    local func, err = load("return " .. content:gsub('%s*([%[%]{}:,])%s*', '%1')
                                        :gsub('":', '"=')
                                        :gsub('([{,]%s*)"(.-)"%s*=', '%1%2='), nil, "t", {})
    if not func then
        print("Failed to parse settings:", err)
        return defaultSettings
    end

    local status, result = pcall(func)
    if status then
        return mergeTables(defaultSettings, result)
    else
        print("Failed to execute parsed settings:", result)
        return defaultSettings
    end
end

return {
    saveSettings = saveSettings,
    loadSettings = loadSettings,
    serializeToJSON = serializeToJSON
}