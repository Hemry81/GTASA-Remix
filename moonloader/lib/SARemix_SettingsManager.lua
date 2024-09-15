local function saveSettings(filePath, tbl)
    local file, err = io.open(filePath, "w")
    if not file then
        error("Failed to open file for writing: " .. filePath .. ". Error: " .. tostring(err))
    end

    local function serialize(val, indent)
        indent = indent or ""
        local t = type(val)
        if t == "table" then
            local result = "{\n"
            for k, v in pairs(val) do
                local key = type(k) == "number" and "[" .. k .. "]" or "[" .. string.format("%q", k) .. "]"
                result = result .. indent .. "  " .. key .. " = " .. serialize(v, indent .. "  ") .. ",\n"
            end
            return result .. indent .. "}"
        elseif t == "string" then
            return string.format("%q", val)
        else
            return tostring(val)
        end
    end

    file:write("return " .. serialize(tbl))
    file:close()
end

local function mergeTable(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            mergeTable(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

local function loadSettings(filePath, existingTable)
    existingTable = existingTable or {}
    local chunk, err = loadfile(filePath)
    if not chunk then
        print("Failed to load file: " .. filePath .. ". Error: " .. tostring(err))
        return existingTable, false
    end
    local success, loadedTable = pcall(chunk)
    if not success then
        print("Error executing loaded chunk: " .. tostring(loadedTable))
        return existingTable, false
    end
    return mergeTable(existingTable, loadedTable), true
end
    
return {
    saveSettings = saveSettings,
    loadSettings = loadSettings,
}