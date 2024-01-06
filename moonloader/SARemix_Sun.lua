script_name("SARemix_Real_Sun")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.1.1")
require "lib.moonloader"

local mad = require 'MoonAdditions'
local math = require('math')
local moveitTimer = 0
local moveitDuration = 0.005
local debugmode = false

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
    z = -22
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

local roty = -4

function main()
    wait(3000)
    while true do
        loadobject(daycycle)
        wait(10)
        showInfo()
        if os.clock() - moveitTimer > moveitDuration then
			moveIt()
			moveitTimer = os.clock()
		end
    end
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
        mad.draw_text('SA REMIX SUN MOD STARTED', 300, 20, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 1000, true, false, 255, 255, 255, 255, 0, 1)
    end
end

function moveIt()
    if debugmode then
        if isKeyDown(VK_NUMPAD2) then
            daycycle.rot.z = daycycle.rot.z + 0.1
        elseif isKeyDown(VK_NUMPAD3) then
            daycycle.rot.z = daycycle.rot.z - 0.1
        elseif isKeyDown(VK_NUMPAD5) then
            roty = roty + 0.1
        elseif isKeyDown(VK_NUMPAD6) then
            roty = roty - 0.1
        elseif isKeyDown(VK_NUMPAD8) then
            daycycle.rot.x = daycycle.rot.x + 0.1
        elseif isKeyDown(VK_NUMPAD9) then
            daycycle.rot.x = daycycle.rot.x - 0.1
        end
        mad.draw_text(string.format("Rotation : x: %.2f, y : %.2f, z: %.2f %d:%d", daycycle.rot.x, roty, daycycle.rot.z, hour, minute), 100, 10)
    end
    
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
    
    if daycycle.obj ~= nil then
        daycycle.rot.y = roty + 360 - (hour * 15 + minute * 0.25)
        setObjectCoordinates(daycycle.obj, daycycle.pos.x, daycycle.pos.y, daycycle.pos.z)
        setObjectRotation(daycycle.obj, daycycle.rot.x, daycycle.rot.y, daycycle.rot.z)
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