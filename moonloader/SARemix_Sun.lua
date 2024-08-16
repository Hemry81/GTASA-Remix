script_name("SARemix_Real_Sun")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.1.3")
require "lib.moonloader"

local mad = require 'MoonAdditions'
local settingsManager = require("SARemix_SettingsManager")
local moveitTimer = 0
local moveitDuration = 0.005
local transiting = false
local debugmode = true
local key = require 'vkeys'
local imgui = require 'imgui'
local dataFile = getWorkingDirectory().."/SARemix_Real_Sun.dat"

Window = {
	x = 10,
	y = 10,
	w = 200,
	h = 100
}
local scr_w, scr_h = getScreenResolution()

local settings = {
    daycycle = {
        id = 3890,
        obj = nil,
        pos = {
        x = 0,
        y = 0,
        z = 0
        },
        rot = {
            x = 0,
            y = 0,
            z = 0
            },
        basePosition = 0
    },
    nightcycle = {
        id = 3891,
        obj = nil,
        pos = {
        x = 0,
        y = 0,
        z = 0
        },
        rot = {
            x = 0,
            y = 0,
            z = 0
            },
        basePosition = 0
    },
    clouddome = {
        id = 0,
        obj = nil,
        pos = {
        x = 0,
        y = 0,
        z = 0
        },
        rot = {
            x = 0,
            y = 0,
            z = 0
        },
        basePosition = 0
    },
    stardome = {
        id = 0,
        obj = nil,
        pos = {
        x = 0,
        y = 0,
        z = 0
        },
        rot = {
            x = 0,
            y = 0,
            z = 0
        },
        basePosition = 0
    }
}

local RSL_firstStart = true
local RSL_showtext = true
local RSL_timer = 0

local currentRotation = 0
local lastUpdateTime = os.clock()

local RSL_Rot = {
    x = imgui.ImInt(settings.daycycle.rot.x),
    y = imgui.ImInt(settings.daycycle.rot.y),
    z = imgui.ImInt(settings.daycycle.rot.z),
    basePosition = imgui.ImInt(settings.daycycle.basePosition),
}

local Im = {
	main_window_state = imgui.ImBool(false)
}

function main()
    wait(3000)
    loadsettings()
    loadobject(settings.daycycle)
    loadobject(settings.nightcycle)
    while true do
        imgui.Process = Im.main_window_state.v
        wait(10)
        showInfo()
        if os.clock() - moveitTimer > moveitDuration then
            if wasKeyPressed(key.VK_F3) then
                Im.main_window_state.v = not Im.main_window_state.v
            end
			moveIt()
			moveitTimer = os.clock()
		end
    end
end

function imgui.OnDrawFrame()
    if Im.main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(10, 10),imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(Window.w * (scr_w/648) , Window.h * (scr_h/448)), imgui.Cond.FirstUseEver)
        imgui.Begin("SASRemix Sun Position Editor", Im.main_window_state, nil)
        --lockPlayerControl(true)
        if imgui.SliderInt("Sun X Rotaion", RSL_Rot.x, -180, 180, "%.0f") then
            settings.daycycle.rot.x = RSL_Rot.x.v
            settings.nightcycle.rot.x = RSL_Rot.x.v
        end
        if imgui.SliderInt("Sun Y Rotaion", RSL_Rot.y, -180, 180, "%.0f") then
            settings.daycycle.rot.y = RSL_Rot.y.v
            settings.nightcycle.rot.y = RSL_Rot.y.v
        end
        if imgui.SliderInt("Sun Z Rotaion", RSL_Rot.z, -180, 180, "%.0f") then
            settings.daycycle.rot.z = RSL_Rot.z.v
            settings.nightcycle.rot.z = RSL_Rot.z.v
        end
        if imgui.SliderInt("Base position", RSL_Rot.basePosition, -180, 180, "%.0f") then
            settings.daycycle.basePosition = RSL_Rot.basePosition.v
        end
        if imgui.Button("Save") then
			saveSettings()
			printStringNow("Sun Setting Saved", 3000)
		end
		imgui.SameLine()
		if imgui.Button("Reset") then
			loadsettings()
			printStringNow("Sun Setting Reset", 3000)
		end
        imgui.End()
    else
        --lockPlayerControl(false)
    end
end

function clearObjectList()
    for k, v in pairs(settings) do
        if v.obj then
            v.obj = nil
        end
    end
end

function loadsettings()
    print("Loading settings from:", dataFile)
    newSettings = settingsManager.loadSettings(dataFile, settings)
    if newSettings then
        settings = newSettings
        print("Settings loaded successfully:", settings)
        RSL_Rot.x = imgui.ImInt(settings.daycycle.rot.x)
        RSL_Rot.y = imgui.ImInt(settings.daycycle.rot.y)
        RSL_Rot.z = imgui.ImInt(settings.daycycle.rot.z)
        RSL_Rot.basePosition = imgui.ImInt(settings.daycycle.basePosition)
        clearObjectList()
    else
        print("Failed to load settings.")
    end
end

function saveSettings()
    settingsManager.saveSettings(dataFile, settings)
end

-- function loadSetting()
-- 	local setting = io.open(getWorkingDirectory().."/SARemix_Real_Sun.dat", "r")
-- 	local lines = setting:lines()
--     for line in lines do
--         if line:find("X Rotaion") then
--             settings.daycycle.rot.x = tonumber(line:match("= (.+)"))
--             settings.nightcycle.rot.x = tonumber(line:match("= (.+)"))
--             RSL_Rot.x = imgui.ImInt(settings.daycycle.rot.x)
--         elseif line:find("Y Rotaion") then
--             settings.daycycle.rot.y = tonumber(line:match("= (.+)"))
--             settings.nightcycle.rot.y = tonumber(line:match("= (.+)"))
--             RSL_Rot.y = imgui.ImInt(settings.daycycle.rot.y)
--         elseif line:find("Z Rotaion") then
--             settings.daycycle.rot.z = tonumber(line:match("= (.+)"))
--             settings.nightcycle.rot.z = tonumber(line:match("= (.+)"))
--             RSL_Rot.z = imgui.ImInt(settings.daycycle.rot.z)
--         end
--     end
--     io.close(setting)
-- end

-- function saveSetting()
-- 	local setting = io.open(getWorkingDirectory().."/SARemix_Real_Sun.dat", "w")
-- 	setting:write("[SARemix_Real_Sun Setting]\n")
-- 	setting:write("X Rotaion = "..formatNum(settings.daycycle.rot.x).."\n")
--     setting:write("Y Rotaion = "..formatNum(settings.daycycle.rot.y).."\n")
--     setting:write("Z Rotaion = "..formatNum(settings.daycycle.rot.z))
-- 	io.close(setting)
-- end

function showInfo()
    if RSL_firstStart then
        RSL_timer = os.clock()
        RSL_firstStart = false
    else
        if os.clock() - RSL_timer > 15 then
            RSL_showtext = false
        end
    end
    if RSL_showtext then
        mad.draw_text('SA REMIX SUN MOD STARTED, press F3 for editing the sun position', 300, 20, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 1000, true, false, 255, 255, 255, 255, 0, 1)
    end
end

function getTargetRotationFromGameTime(hours, minutes)
    local totalMinutes = hours * 60 + minutes
    return totalMinutes * (360 / (24 * 60))  -- Full circle in 24 hours
end

function smmoothTransition(hours, minutes)
    local targetRotation = getTargetRotationFromGameTime(hours, minutes)
    local currentTime = os.clock()
    local dt = currentTime - lastUpdateTime
    lastUpdateTime = currentTime

    local rotationDifference = targetRotation - currentRotation
    -- Normalize the difference to handle the wrapping around 360 degrees
    rotationDifference = (rotationDifference + 180) % 360 - 180

    local rotationSpeed = rotationDifference - rotationDifference * 0.5  -- Base speed degrees per second
    if math.abs(rotationDifference) < 0.1 then
        rotationSpeed = 0
    end
    
    transiting = math.abs(rotationDifference) > 20

    -- Update rotation in the direction of the target
    currentRotation = currentRotation + rotationSpeed * dt

    -- Ensure rotation stays within 0-360 degrees
    currentRotation = currentRotation % 360
    return currentRotation
end

function moveIt()
    local hour, minute =  getTimeOfDay()
    local p = {
        x = 0,
        y = 0,
        z = 0
        }
        
    -- p.x, p.y, p.z = getCharCoordinates(PLAYER_PED)
    p.x, p.y, p.z = getActiveCameraCoordinates()

    settings.daycycle.pos.x = p.x
    settings.daycycle.pos.y = p.y
    settings.daycycle.pos.z = p.z
    settings.nightcycle.pos.x = p.x
    settings.nightcycle.pos.y = p.y
    settings.nightcycle.pos.z = p.z
    local rot_y = settings.daycycle.basePosition - smmoothTransition(hour, minute)
    
    if settings.daycycle.obj ~= nil then
        if hour >= 5 and hour < 19 then
            setObjectRotation(settings.daycycle.obj, settings.daycycle.rot.x, rot_y, settings.daycycle.rot.z)
            setObjectCoordinates(settings.daycycle.obj, settings.daycycle.pos.x, settings.daycycle.pos.y, settings.daycycle.pos.z)
        else
            setObjectRotation(settings.daycycle.obj, settings.daycycle.rot.x, rot_y, settings.daycycle.rot.z)
            if transiting == false then setObjectCoordinates(settings.daycycle.obj, -10000, -10000, -10000) end
        end
    end
    if settings.nightcycle.obj ~= nil then
        if hour >= 17 or hour < 7 then
            setObjectRotation(settings.nightcycle.obj, settings.nightcycle.rot.x, rot_y, settings.nightcycle.rot.z)
            setObjectCoordinates(settings.nightcycle.obj, settings.nightcycle.pos.x, settings.nightcycle.pos.y, settings.nightcycle.pos.z)
        else
            setObjectRotation(settings.nightcycle.obj, settings.nightcycle.rot.x, rot_y, settings.nightcycle.rot.z)
            if transiting == false then setObjectCoordinates(settings.nightcycle.obj, -10000, -10000, -10000) end
        end
    end
end

function loadobject(obj)
    if obj.obj == nil then
        requestModel(obj.id)
        -- loadAllModelsNow()
        obj.obj = createObject(obj.id, 0, 0, 0)
        setObjectCollision(obj.obj, false)
        setObjectDynamic(obj.obj, true)
    end
end

function formatNum(num)
    return string.format("%.5f", num)
end