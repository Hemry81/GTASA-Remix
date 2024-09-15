script_name("SARemix_Light_Manager")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.2.0")

local mad = require 'MoonAdditions'
local settingsManager = require("SARemix_SettingsManager")
local vkey = require 'vkeys'

local dataFile = getWorkingDirectory().."/SARemix_Light_Manager.dat"

local SLM_firstStart = true
local SLM_showtext = true
local SLM_timer = 0

local flickering_started = false
local flickering_initiated_today = false
local last_hour, last_minute = getTimeOfDay()
local zoffset = 0.0

local light_list = {lights = {}, count = 0}

local light_type = {
                    {id = 15892}, -- 01
                    {id = 15893}, -- 02
                    {id = 15894}, -- 03
                    {id = 15895}, -- 04
                    {id = 15896}, -- 05
                    {id = 15897}, -- 06
                    {id = 15898}, -- 07
                    {id = 15899}, -- 08
                    {id = 15900}, -- 09
                    {id = 15901}, -- 10
                    {id = 15902}, -- 11
                    {id = 15903}  -- 12
}

local pendingDelete = {}

local light_def = {
    "Big Spot Light - Cold Color",      -- 01 15892
    "Big Spot Light - Warm Color",      -- 02 15893
    "Middle Spot Light -Cold Color",    -- 03 15894
    "Middle Spot Light - Warm Color",   -- 04 15895
    "Small Spot Light - Cold Color",    -- 05 15896
    "Small Spot Light - Warm Color",    -- 06 15897
    "Big Sphere Light - Cold Color",    -- 07 15898
    "Big Sphere Light - Warm Color",    -- 08 15899
    "Middle Sphere Light - Cold Color", -- 09 15900
    "Middle Sphere Light - Warm Color", -- 10 15901
    "Small Sphere Light - Cold Color",  -- 11 15902
    "Small Sphere Light - Warm Color"   -- 12 15903
}

local LightManager = {}
LightManager.__index = LightManager

function LightManager:new()
    local instance = {
        lights = {}
    }
    setmetatable(instance, LightManager)
    return instance
end

function LightManager:isLightID(lightID)
    return self.lights[lightID] ~= nil
end

function LightManager:addLight(lightID, lightType, pos)
    if not self.lights[lightID] then
        self.lights[lightID] = {pos = {}, type = lightType}
    end
    table.insert(self.lights[lightID].pos, pos)
    self.lights[lightID].type = lightType
end

function LightManager:deleteLight(lightID)
    self.lights[lightID] = nil
end

function LightManager:setLightType(lightID, lightType)
    self.lights[lightID].type = lightType
end

function LightManager:getLightType(lightID)
    return self.lights[lightID].type
end

function LightManager:getLightDef(lightID)
    return light_def[self.lights[lightID].type]
end

function LightManager:setModelID(lightID, modelID)
    light_type[self.lights[lightID].type].id = modelID
end

function LightManager:getModelID(lightID)
    return light_type[self.lights[lightID].type].id
end

function LightManager:setLightPosition(lightID, index, position)
    self.lights[lightID].pos[index] = position
end

function LightManager:getLightPosition(lightID, index)
    return self.lights[lightID].pos[index]
end

function LightManager:getLightCount(lightID)
    return #self.lights[lightID].pos
end

function LightManager:setOffset(lightID, index, offset)
    if index == nil then
        index = 1
    end
    self.lights[lightID].pos[index] = offset
end

function LightManager:setoffSetXYZ(lightID, index, x, y, z)
    if index == nil then
        index = 1
    end
    self.lights[lightID].pos[index] = {x = x, y = y, z = z}
end

function LightManager:getOffset(lightID, index)
    if index == nil then
        index = 1
    end
    if self.lights[lightID].pos[index] == nil then
        return {x = 0, y = 0, z = 0}
    else
        return self.lights[lightID].pos[index]
    end
end

function LightManager:getOffsetTable(lightID, index)
    if index == nil then
        index = 1
    end
    
    local light = self.lights[lightID]
    if not light then
        return 0, 0, 0
    else
        return light.pos[index].x, light.pos[index].y, light.pos[index].z
    end
end

local lightMan = LightManager:new()

local Cstreet_light = {}

function Cstreet_light:new(object, hash, modelID, matrix, pos, hour, min)
    local newObj = {
        object = object,  -- The object pointer
        hash = hash, -- The hash of the object base on its matrix
        modelID = lightMan:getModelID(modelID),  -- The model ID for the light Replacement
        lightID = modelID, -- The light original model ID
        obj = {},  -- This will hold the actual object once created
        subObj = {}, -- This will hold the actual object once created
        matrix = matrix, -- This will hold the matrix of the object
        pos = pos,  -- Position where the light will be placed
        visible = false,  -- Initially visible
        update_time = os.clock(),  -- Last update time
        flicker_count = 0,  -- Current count of flickers
        max_flickers = math.random(3, 7),  -- Max number of flickers in one flickering session
        max_damaged_flickers = math.random(3, 5), -- Max number of flickers for damaged light
        flicker_duration = math.random(0.1, 0.3),  -- Duration of each flicker
        pause_duration = math.random(4, 16),  -- Long pause between flickering sessions
        in_pause = not (hour == 19 and min == 0),  -- Is the light currently in a pause phase
        damaged = false,  -- Indicate if the light is damaged
        autoOff = false, -- Indicate if the light is auto off during the daylight
        firstTrigger = true, -- Indicate if the light is damaged for the first time
        noDamageTrigger = true, -- Indicate if the light is damaged for the first timeupdate
    }
    setmetatable(newObj, self)
    self.__index = self
    return newObj
end

local function loadLightObject(obj, count, modelID, isSubObject)
    if isSubObject then
        if #obj.subObj < count then
            requestModel(modelID)
            for i = 1, count do
                obj.subObj[#obj.subObj + 1] = createObject(modelID, 0, 0, 0)
            end
        end
        return true
    elseif #obj.obj < count then
        requestModel(modelID)
        for i = 1, count do
            obj.obj[#obj.obj + 1] = createObject(modelID, 0, 0, 0)
        end
        return true
    end
    return false
end

local function loadsettings()
    print("Loading settings from:", dataFile)
    local newSettings = settingsManager.loadSettings(dataFile, lightMan.lights)
    if newSettings then
        lightMan.lights = newSettings
        print("Settings loaded successfully:", lightMan.lights)
        for k, light in pairs(lightMan.lights) do
            print(string.format("Light ID : %s", k))
            for i, pos in ipairs(light.pos) do
                print(string.format("    [pos %d] : x : %.03f, y : %.03f, z : %.03f", i, pos.x, pos.y, pos.z))
            end
        end
    else
        print("Failed to load settings.")
    end
end

local function removebulb(obj)
    deleteObject(obj)
    obj = nil
end

local function handleFlickering(light, current_time, max_flickers, min_duration, max_duration, hasSubObject, removeObject)
    if light.flicker_count < max_flickers then
        if current_time - light.update_time > light.flicker_duration then
            light.visible = not light.visible
            light.update_time = current_time
            light.flicker_count = light.flicker_count + 1
            light.flicker_duration = math.random(min_duration * 1000, max_duration * 1000) / 1000  -- Convert to seconds

            if light.visible then
                loadLightObject(light, #light.pos, light.modelID, false)
                for i, pos in ipairs(light.pos) do
                    local obj = light.obj[i]
                    if obj and doesObjectExist(obj) then
                        setObjectCoordinates(obj, pos.x, pos.y, pos.z)
                        setObjectCollision(obj, false)
                        setObjectDynamic(obj, true)
                    end
                end
                if hasSubObject then
                    loadLightObject(light, #light.pos * 5, light.modelID, true)
                    for i, pos in ipairs(light.pos) do
                        local obj = light.subObj[i]
                        if obj and doesObjectExist(obj) then
                            setObjectCoordinates(obj, pos.x, pos.y, pos.z)
                            setObjectCollision(obj, false)
                            setObjectDynamic(obj, true)
                        end
                    end
                end
            else
                for _, objList in ipairs({light.obj, light.subObj}) do
                    for _, obj in ipairs(objList) do
                        if obj and doesObjectExist(obj) then
                            removebulb(obj)
                        end
                    end
                end
                light.obj = {}
                light.subObj = {}
            end
        end
    elseif removeObject then
        return true
    else
        light.flicker_count = 0
        light.pause_duration = math.random(0.8, 3.2)
        light.in_pause = true
        light.update_time = current_time
        loadLightObject(light, #light.pos, light.modelID, false)
        for i, pos in ipairs(light.pos) do
            local obj = light.obj[i]
            if obj and doesObjectExist(obj) then
                setObjectCoordinates(obj, pos.x, pos.y, pos.z)
                setObjectCollision(obj, false)
                setObjectDynamic(obj, true)
            end
        end
    end
    return false
end

local function update_light()
    local current_time = os.clock()
    local hour, minute = getTimeOfDay()  -- Get the current time of day
    
    local playerPos = {x = 0, y = 0, z = 0}
    playerPos.x, playerPos.y, playerPos.z = getCharCoordinates(PLAYER_PED)

    -- Check if a new day has started or game just loaded
    if (last_hour == 23 and hour == 0) or (last_hour ~= nil and last_hour > hour) then
        flickering_started = false
        flickering_initiated_today = false
    end
    last_hour = hour

    -- Initiate flickering if it's past 18:00 and hasn't been started yet
    if not flickering_initiated_today and hour >= 18 or hour >= 0 and hour < 6 then
        flickering_initiated_today = true
        flickering_started = true
    end

    -- Proceed with flickering if it has started
    if flickering_started then
        for _, light in pairs(light_list.lights) do
            local hash = light.hash
            local matrix = mad.get_object_matrix(light.object)
            if matrix then
                light.matrix = matrix.pos
                for i, obj in ipairs(light.pos) do
                    local offset = lightMan:getOffset(light.lightID, i)
                    light.pos[i].x, light.pos[i].y, light.pos[i].z = matrix:get_coords_with_offset(offset.x, offset.y, offset.z + zoffset)
                end
            end
            local distance = getDistanceBetweenCoords3d(playerPos.x, playerPos.y, playerPos.z, light.matrix.x, light.matrix.y, light.matrix.z)
            if distance > 1600 then
                if #light.obj > 0 then
                    for i, obj in ipairs(light.obj) do
                        deleteObject(obj)  -- Remove the actual object
                        obj = nil
                    end
                    light.obj = {}
                end
                if #light.subObj > 0 then
                    for i, obj in ipairs(light.subObj) do
                        deleteObject(obj)  -- Remove the actual object
                        obj = nil
                    end
                    light.subObj = {}
                end
                light_list.lights[hash] = nil
                light_list.count = light_list.count - 1
            elseif light.damaged then
                if light.firstTrigger then
                    light.firstTrigger = false
                    light.noDamageTrigger = false
                    light.update_time = current_time
                    light.visible = true
                    light.flicker_count = 0
                    light.in_pause = false
                    light.flicker_duration = 0  -- Start flashing immediately
                    for i, pos in ipairs(light.pos) do
                        loadLightObject(light, i * 5, light.modelID, true)
                        local obj = light.subObj[i]
                        setObjectCoordinates(obj, pos.x, pos.y, pos.z)
                        setObjectCollision(obj, false)
                        setObjectDynamic(obj, true)
                    end
                end
                
                -- Handle damaged light fast flashing
                local shouldRemove = handleFlickering(light, current_time, light.max_damaged_flickers, 0.02, 0.1, true, true)
                
                if shouldRemove or light.flicker_count >= light.max_damaged_flickers then
                    -- Remove all objects and clean up immediately
                    for _, objList in ipairs({light.obj, light.subObj}) do
                        for _, obj in ipairs(objList) do
                            if doesObjectExist(obj) then
                                removebulb(obj)  -- Remove the actual object
                            end
                        end
                    end
                    light.obj = {}
                    light.subObj = {}
                    light_list.lights[hash] = nil
                    light_list.count = light_list.count - 1
                end
            elseif light.autoOff then
                if light.firstTrigger then
                    light.firstTrigger = false
                    light.update_time = current_time
                    light.visible = false
                    light.flicker_count = 0
                    light.in_pause = false
                    if #light.subObj > 0 then
                        for i, obj in ipairs(light.subObj) do
                            removebulb(obj)  -- Remove the actual object
                        end
                        light.subObj = {}
                    end
                end
				if handleFlickering(light, current_time, light.max_damaged_flickers, 0.1, 0.5, false, true) then
                    if #light.obj > 0 then
                        for i, obj in ipairs(light.obj) do
                            removebulb(obj)  -- Remove the actual object
                        end
                        light.obj = {}
                    end
                    if #light.subObj > 0 then
                        for i, obj in ipairs(light.subObj) do
                            removebulb(obj)  -- Remove the actual object
                        end
                        light.subObj = {}
                    end
                    light_list.lights[hash] = nil
                    light_list.count = light_list.count - 1
                end
			else
				if light.in_pause then
					if current_time - light.update_time > light.pause_duration then
						light.in_pause = false
						light.flicker_count = 0
                        light.update_time = current_time
                    end
                    loadLightObject(light, #lightMan.lights[light.lightID].pos, light.modelID, false)
                    for i, pos in ipairs(light.pos) do
                        local obj = light.obj[i]
                        setObjectCoordinates(obj, pos.x, pos.y, pos.z)
                        setObjectCollision(obj, false)
                        setObjectDynamic(obj, true)
                    end
                else
                    if handleFlickering(light, current_time, light.max_flickers, 0.1, 0.3, false, false) then
                        if #light.obj > 0 then
                            for i, obj in ipairs(light.obj) do
                                removebulb(obj)  -- Remove the actual object
                            end
                            light.obj = {}
                        end
                        if #light.subObj > 0 then
                            for i, obj in ipairs(light.subObj) do
                                removebulb(obj)
                            end
                            light.subObj = {}
                        end
                        light_list.lights[hash] = nil
                        light_list.count = light_list.count - 1
                    end
                end
			end
        end
    end
end

local function handle_delete()
    if #pendingDelete > 0 then
        for _, key in ipairs(pendingDelete) do
            lightMan:deleteLight(key)
        end
        pendingDelete = {}
    end
end

local function remove_lights(hour, min, forceReset)
    if (hour >= 6 and min > 20) or forceReset then
        if type(light_list.lights) == "table" then
            for key, light in pairs(light_list.lights) do
                for i, obj in ipairs(light.obj) do
                    deleteObject(obj)
                    obj = nil
                end
                for i, obj in ipairs(light.subObj) do
                    deleteObject(obj)
                    obj = nil
                end
                light_list.lights[key] = nil
                light_list.count = light_list.count - 1
            end
        end
    else
        for _, light in pairs(light_list.lights) do
            if light.autoOff == false then
                light.autoOff = true
                light.firstTrigger = true
                light.flicker_count = 0
                light.in_pause = true
                light.update_time = os.clock()
                light.pause_duration = math.random(1, 8)
            end
        end
    end
end

local function matrix_to_hash(matrix)
    -- Format the matrix position components into hexadecimal
    local formatted_string = string.format("%a%a%a", matrix.pos.x, matrix.pos.y, matrix.pos.z)
    -- Replace any periods or dashes in the string with underscores
    local hash = string.upper(string.gsub(formatted_string, "[%.%-%+%0x]", ""))
    return hash
end

local function matrix_equals(matrix1, matrix2)
    -- Implement a robust matrix comparison function
    return matrix1.x == matrix2.x and matrix1.y == matrix2.y and matrix1.z == matrix2.z
end

local function safeGetObjectModel(object)
    return getObjectModel(object)
end

local function showInfo()
    if SLM_firstStart then
        SLM_timer = os.clock()
        SLM_firstStart = false
    else
        if os.clock() - SLM_timer > 15 then
            SLM_showtext = false
        end
    end
    if SLM_showtext then
        mad.draw_text('SA REMIX STREET LIGHT MOD STARTED', 300, 100, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 1000, true, false, 255, 255, 255, 255, 0, 1)
    end
end

addEventHandler('onScriptTerminate', function()
	remove_lights(7, 0, true)
	light_list.lights = {}
	light_list.count = 0
end)

function main()
    loadsettings()
    while true do
        wait(10)
        showInfo()
        if isPlayerPlaying(PLAYER_HANDLE) then
            local hour, minute = getTimeOfDay()
            local daytime = (hour >= 6 and hour < 19)
            if daytime then
                remove_lights(hour, minute, (hour >= 7))
            else
                local x, y, z = getCharCoordinates(PLAYER_PED)
                for _, object in ipairs(mad.get_all_objects(x, y, z, 400)) do
                    local status, modelID = pcall(safeGetObjectModel, object)
                    if status then
                        if modelID ~= nil then
                            
                            local matrix = mad.get_object_matrix(object)
                            if lightMan:isLightID(modelID) then
                                local health = getObjectHealth(object)
                                local hash = matrix_to_hash(matrix)
                                local light = light_list.lights[hash]
                                local position = {}
                                if matrix and health > 0 then
                                    if light == nil then
                                        for i = 1, lightMan:getLightCount(modelID) do
                                            local offset = lightMan:getOffset(modelID, i)
                                            position[i] = {}
                                            position[i].x, position[i].y, position[i].z = matrix:get_coords_with_offset(offset.x, offset.y, offset.z + zoffset)
                                        end
                                        light = Cstreet_light:new(object, hash, modelID, matrix.pos, position, hour, minute)
                                        light_list.lights[hash] = light
                                        light_list.count = light_list.count + 1
                                    elseif not matrix_equals(light.matrix, matrix.pos) then
                                        for i, obj in ipairs(light.obj) do
                                            deleteObject(obj)
                                            obj = nil
                                        end
                                        for i, obj in ipairs(light.subObj) do
                                            deleteObject(obj)
                                            obj = nil
                                        end
                                        for i = 1, lightMan:getLightCount(modelID) do
                                            local offset = lightMan:getOffset(modelID, i)
                                            position[i] = {}
                                            position[i].x, position[i].y, position[i].z = matrix:get_coords_with_offset(offset.x, offset.y, offset.z + zoffset)
                                        end
                                        light = Cstreet_light:new(object, hash, modelID, matrix.pos, position, hour, minute)
                                        light_list.lights[hash] = light
                                    end
                                elseif light then
                                    light.damaged = true
                                    if light.noDamageTrigger then
                                        light.firstTrigger = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
            update_light()
            handle_delete()
        end
    end
end