script_name("SARemix_Real_Sun_v0.11a")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")

require "lib.moonloader"
local mad = require 'MoonAdditions'
local math = require('math')
function main()
    while true do
        wait(10)
        
        sun = loadobject(sun, 3896)
        moon = loadobject(moon, 3908)
        local hour, minute =  getTimeOfDay()
        
        local vi, sx, sy, sz = mad.get_sun_world_position()
        
        local mx, my, mz = sx * -1, sy * -1, sz * -1
        
        local px, py, pz = getCharCoordinates(PLAYER_PED)

        --printStringNow("sx: "..formatNum(sx).. ", sy: ".. formatNum(sy)..", sz: ".. formatNum(sz).. ", mx: "..formatNum(mx).. ", my: ".. formatNum(my)..", mz: ".. formatNum(mz), 10)
        
        --local ax, ay, az = calc_orien(px, py, pz, sx, sy, sz)
        --setObjectRotation(sun, ax, ay, az)
        
        --ax, ay, az = calc_orien(px, py, pz, mx, my, mz)
        --setObjectRotation(moon, ax, ay, az)
        
        local sun_threshold = 0.025
        local moon_threshold = 0.025
        sx = (sx * sun_threshold) + px
        sy = (sy * sun_threshold) + py
        sz = (sz * sun_threshold) + pz
        
        mx = (mx * moon_threshold) + px
        my = (my * moon_threshold) + py
        mz = (mz * moon_threshold) + pz
        
        -- printStringNow("sx: "..formatNum(ax).. ", sy: ".. formatNum(ay)..", sz: " .. az, 10)
        
        -- if (hour < 19) and (hour > 4) then
        --    setObjectCoordinates(sun, sx, sy, sz)
        --else
        --    setObjectCoordinates(sun, 0, 0, -100000)
        --end
        setObjectCoordinates(sun, sx, sy, sz)
        setObjectCoordinates(moon, mx, my, mz)
    
    end
end

function atan2(y, x)
    local angle = 0
    if x > 0 then
        angle = math.atan(y/x)
    elseif x < 0 then
        angle = math.atan(y/x) + math.pi
    elseif y > 0 then  
        angle = math.pi/2
    elseif y < 0 then
        angle = -math.pi/2
    end
    return angle
end

function calc_orien(ax, ay, az, bx, by, bz)
    -- printStringNow("px: "..formatNum(ax).. ", py: ".. formatNum(ay)..", pz: ".. formatNum(az).. ", ox: "..formatNum(bx).. ", oy: ".. formatNum(by)..", oz: ".. formatNum(bz), 10)
    local angleZ = 0
    local angleXY = atan2(ay - by, ax - bx)
    local diff = az - bz
    
    if diff == 0 then
        angleZ = 0
    else
        angleZ = math.floor(math.asin(diff) * 10000 + 0.5) / 10000
    end
    
    --printStringNow("0 ,".. angleXY..", ".. angleZ, 10)
    return 0, angleXY, angleZ
end

function loadobject(obj, id)
    if not hasModelLoaded(id) then
        requestModel(id)
        loadAllModelsNow()
        obj = createObject(id, 0, 0, 0)
        setObjectCollision(obj, false)
        setObjectDynamic(obj, true)
        return obj
    else
        return obj
    end
end
function formatNum(num)
    return string.format("%.2f", num)
end