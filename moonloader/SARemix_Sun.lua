script_name("SARemix_Real_Sun")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.1.2")
require "lib.moonloader"

local mad = require 'MoonAdditions'
local moveitTimer = 0
local moveitDuration = 0.005
local debugmode = true
local key = require 'vkeys'
local imgui = require 'imgui'

Window = {
	x = 10,
	y = 10,
	w = 200,
	h = 100
}
local scr_w, scr_h = getScreenResolution()

local daycycle = {
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
    }
}
local clouddome = {
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
        }
}
local stardome = {
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
        }
}

local RSL_firstStart = true
local RSL_showtext = true
local RSL_timer = 0

local RSL_Rot = {
    x = imgui.ImInt(daycycle.rot.x),
    y = imgui.ImInt(daycycle.rot.y),
    z = imgui.ImInt(daycycle.rot.z)
}

local Im = {
	main_window_state = imgui.ImBool(false)
}

function main()
    wait(3000)
    loadobject(daycycle)
    loadSetting()
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
            daycycle.rot.x = RSL_Rot.x.v
        end
        if imgui.SliderInt("Sun Y Rotaion", RSL_Rot.y, -180, 180, "%.0f") then
            daycycle.rot.y = RSL_Rot.y.v
        end
        if imgui.SliderInt("Sun Z Rotaion", RSL_Rot.z, -180, 180, "%.0f") then
            daycycle.rot.z = RSL_Rot.z.v
        end
        if imgui.Button("Save") then
			saveSetting()
			printStringNow("Sun Setting Saved", 3000)
		end
		imgui.SameLine()
		if imgui.Button("Reset") then
			loadSetting()
			printStringNow("Sun Setting Reset", 3000)
		end
        imgui.End()
    else
        --lockPlayerControl(false)
    end
end

function loadSetting()
	local setting = io.open(getWorkingDirectory().."/SARemix_Real_Sun.dat", "r")
	local lines = setting:lines()
    for line in lines do
        if line:find("X Rotaion") then
            daycycle.rot.x = tonumber(line:match("= (.+)"))
            RSL_Rot.x = imgui.ImInt(daycycle.rot.x)
        elseif line:find("Y Rotaion") then
            daycycle.rot.y = tonumber(line:match("= (.+)"))
            RSL_Rot.y = imgui.ImInt(daycycle.rot.y)
        elseif line:find("Z Rotaion") then
            daycycle.rot.z = tonumber(line:match("= (.+)"))
            RSL_Rot.z = imgui.ImInt(daycycle.rot.z)
        end
    end
    io.close(setting)
end

function saveSetting()
	local setting = io.open(getWorkingDirectory().."/SARemix_Real_Sun.dat", "w")
	setting:write("[SARemix_Real_Sun Setting]\n")
	setting:write("X Rotaion = "..formatNum(daycycle.rot.x).."\n")
    setting:write("Y Rotaion = "..formatNum(daycycle.rot.y).."\n")
    setting:write("Z Rotaion = "..formatNum(daycycle.rot.z))
	io.close(setting)
end

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

function moveIt()
    local hour, minute =  getTimeOfDay()
    local p = {
        x = 0,
        y = 0,
        z = 0
        }
        
    --p.x, p.y, p.z = getCharCoordinates(PLAYER_PED)
    p.x, p.y, p.z = getActiveCameraCoordinates()

    daycycle.pos.x = p.x
    daycycle.pos.y = p.y
    daycycle.pos.z = p.z
    
    if daycycle.obj ~= nil then
        local rot_y = daycycle.rot.y + 360 - (hour * 15 + minute * 0.25)
        setObjectCoordinates(daycycle.obj, daycycle.pos.x, daycycle.pos.y, daycycle.pos.z)
        setObjectRotation(daycycle.obj, daycycle.rot.x, rot_y, daycycle.rot.z)
    end
end

function loadobject(obj)
    if obj.obj == nil then
        requestModel(obj.id)
        loadAllModelsNow()
        obj.obj = createObject(obj.id, 0, 0, 0)
        setObjectCollision(obj.obj, false)
        setObjectDynamic(obj.obj, true)
    end
end

function formatNum(num)
    return string.format("%.5f", num)
end