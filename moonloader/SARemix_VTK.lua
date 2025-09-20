script_name("SARemix_Vehicle_Toolkit")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.1.3a")

local mad = require 'MoonAdditions'
local imgui = require 'imgui'
local key = require 'vkeys'
local ffi = require "ffi"
local memory = require "memory"
local settingsManager = require("SARemix_SettingsManager")
local debugPrinter = require "SARemix_DebugPrinter"

local workDir = getWorkingDirectory()

local debugprint = nil

local VTK_firstStart = true
local VTK_showtext = true
local VTK_timer = 0

local updateTimer = os.clock()
local lastupdatetime = 0
local longest_updateTime = 0
local shortest_updateTime = 999999
local average_updateTime = 0

local hour, minute = 0, 0

local playerVeh = nil
local last_Interior = nil

local changecolorTimer = 0
local changecolorDuration = 0.2
local clean_list_time = 0.5
local reset = true
local forceReset = false
local mod_list = {"Vanilla"}
local cur_mod_name = mod_list[1]

local scr_w, scr_h = getScreenResolution()
local scr_w_half, scr_h_half = scr_w / 2, scr_h / 2
local InvertCamYAxis = true
local InvertCamXAxis = false


ffi.cdef([[
	struct CMouseControllerState {
		unsigned char lmb;
		unsigned char rmb;
		unsigned char mmb;
		unsigned char wheelUp;
		unsigned char wheelDown;
		unsigned char bmx1;
		unsigned char bmx2;
		char __align;
		float Z;
		float X;
		float Y;
	};
]])

local mouseState 		= ffi.cast("struct CMouseControllerState*", 0xB73418)

local material_config = {
	excludeMaterial = {
		vehicleNames = {"quad", "streak", "firela", "freight", "hotdog", "hotrin", "monsta", "monstb", "rhino", "maveric", "polmav", "policar", "utility"},
		CustomPaintTexturesName = {"#emap"},
		ComponentNames = {"number", "plate"},
		GlasstextureNames = {"txt", "tx", "gril", "badge", "decal", "scratch", "dash", "logo", "steer", "rotor"},
		GlassComponentNames = {"gril", "badge", "decal", "scratch", "dash", "logo", "steer", "rotor"},
		ChrometextureNames = {"leath", "plastic"},
		MirrorComponentNames = {""},
		MirrortextureNames = {""},
		ColorTextureNames = {"txt", "tx", "decal", "plate"},
		ColorPartNames = {},
		LeatherComponentNames = {""},
		LeatherTextureNames = {""},
		roughPaintVehicleNames = {""},
		roughPaintTextureNames = {""},
		roughPaintPartNames = {""}
	},
						
	includeMaterial = {
		vehicleNames = {""},
		CustomPaintTexturesName = {"#emap"},
		ComponentNames = {"glass", "wind", "windscreen", "wing", "chassis", "roof", "door", "boot", "front", "back", "rf"},
		GlasstextureNames = {"generic", "glass", "hite", "chrome", "wind", "light", "no texture"},
		GlassComponentNames = {"glass"},
		ChrometextureNames = {"hite", "chrome"},
		MirrorComponentNames = {"mirror"},
		MirrortextureNames = {"mirror", "vehiclelights128"},
		ColorTextureNames = {"grunge","body"},
		ColorPartNames = {"bully"},
		LeatherComponentNames = {"int", "seat"},
		LeatherTextureNames = {"int", "leath"},
		roughPaintVehicleNames = {"flatbed", "huntley", "journey"},
		roughPaintTextureNames = {"mix"},
		roughPaintPartNames = {"mixer", "misc"}
	}
}
	
local lightType = {
					headlight = 15923,
					taillight = 15924,
					red_light = 15925,
					blue_light = 15926
}

local str_find = string.find
local str_lower = string.lower

local tempClosed = nil

local vehiclelight = {}


vehicle_class = {
    AUTOMOBILE = 0,
    MTRUCK = 1,
    QUAD = 2,
    HELI = 3,
    PLANE = 4,
    BOAT = 5,
    TRAIN = 6,
    FHELI = 7,
    FPLANE = 8,
    BIKE = 9,
    BMX = 10,
    TRAILER = 11
}

local vehicle_class_def = {
    [0] = "AUTOMOBILE",
    [1] = "MTRUCK",
    [2] = "QUAD",
    [3] = "HELI",
    [4] = "PLANE",
    [5] = "BOAT",
    [6] = "TRAIN",
    [7] = "FHELI",
    [8] = "FPLANE",
    [9] = "BIKE",
    [10] = "BMX",
    [11] = "TRAILER"
}


local vehicle_subclass = {
    AUTOMOBILE = 0,
    BIKE = 1,
    HELI = 2,
    BOAT = 3,
    PLANE = 4
}

local vehicle_subclass_def = {
    [0] = "AUTOMOBILE",
    [1] = "BIKE",
    [2] = "HELI",
    [3] = "BOAT",
    [4] = "PLANE"
}

local car_light = {
    FRONT_LEFT = 0,
    FRONT_RIGHT = 1,
    REAR_RIGHT = 2,
    REAR_LEFT = 3
}

local car_light_def = {
    [1] = "Front Left",
    [2] = "Front Right",
    [3] = "Rear Left",
    [4] = "Rear Right"
}


local vehicle_dummy = {
    HEADLIGHTS = 0,
    TAIL_LIGHTS = 1,
    HEADLIGHTS_2 = 2,
    TAIL_LIGHTS_2 = 3,
    PED_FRONT_SEAT = 4,
    PED_BACK_SEAT = 5,
    EXHAUST = 6,
    ENGINE = 7,
    PETROLCAP = 8,
    HOOKUP = 9,
    PED_ARM = 10
}

local vehicle_dummy_def = {
    [0] = "HEADLIGHTS",
    [1] = "TAIL_LIGHTS",
    [2] = "HEADLIGHTS_2",
    [3] = "TAIL_LIGHTS_2",
    [4] = "PED_FRONT_SEAT",
    [5] = "PED_BACK_SEAT",
    [6] = "EXHAUST",
    [7] = "ENGINE",
    [8] = "PETROLCAP",
    [9] = "HOOKUP",
    [10] = "PED_ARM"
}

local materialsName = {
	"Original",                     
	"Debug",                        
	"Mirror",                       
	"Glass",                        
	"Fog Glass",                    
	"Broken Glass",                 
	"Chrome 1",                     
	"Chrome 2",                     
	"Chrome 3",                     
	"Black Plastic Glossy",         
	"Black Plastic Rough",          
	"Primary Color Carpaint",       
	"Secondary Color Carpaint",     
	"Extra Color 1 Carpaint",       
	"Extra Color 2 Carpaint",       
	"Primary Color Matte",          
	"Secondary Color Matte",        
	"Extra Color 1 Matte",          
	"Extra Color 2 Matte",          
	"Primary Color Leather",        
	"Secondary Color Leather",      
	"Extra Color 1 Leather",        
	"Extra Color 2 Leather",        
	"Primary Color Metallic",       
	"Secondary Color Metallic",     
	"Extra Color 1 Metallic",       
    "Extra Color 2 Metallic",       
}

local mat_Original = 1
local mat_Debug = 2
local mat_Mirror = 3
local mat_Glass = 4
local mat_FogGlass = 5
local mat_BrokenGlass = 6
local mat_Chrome1 = 7
local mat_Chrome2 = 8
local mat_Chrome3 = 9
local mat_BlackPlasticGlossy = 10
local mat_BlackPlasticRough = 11
local mat_PrimaryColor_Glossy = 12
local mat_SecondaryColor_Glossy = 13
local mat_ExtraColor1_Glossy = 14
local mat_ExtraColor2_Glossy = 15
local mat_PrimaryColor_Matte = 16
local mat_SecondaryColor_Matte = 17
local mat_ExtraColor1_Matte = 18
local mat_ExtraColor2_Matte = 19
local mat_PrimaryColor_Leather = 20
local mat_SecondaryColor_Leather = 21
local mat_ExtraColor1_Leather = 22
local mat_ExtraColor2_Leather = 23
local mat_PrimaryColor_Metallic = 24
local mat_SecondaryColor_Metallic = 25
local mat_ExtraColor1_Metallic = 26
local mat_ExtraColor2_Metallic = 27


local materialsTex = {
	0,                                                                                      
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/debug.png')),                  
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/mirror.png')),                 
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/glass.png')),                  
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/glass_fog.png')),              
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/glass_broken.png')),           
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/chrome_1.png')),               
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/chrome_2.png')),               
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/chrome_3.png')),               
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/black_plastic_g.png')),        
	assert(mad.load_png_texture(workDir .. '/SARemix/texture/black_plastic_r.png')),        
	{r = 0x3C, g = 0xFF, b = 0x00},                                                         
	{r = 0xFF, g = 0x00, b = 0xAF},                                                         
	{r = 0x00, g = 0xFF, b = 0xFF},                                                         
	{r = 0x00, g = 0xFF, b = 0x00},                                                         
	{r = 0x3C, g = 0xFF, b = 0x00},                                                         
	{r = 0xFF, g = 0x00, b = 0xAF},                                                         
	{r = 0x00, g = 0xFF, b = 0xFF},                                                         
	{r = 0x00, g = 0xFF, b = 0x00},                                                         
	{r = 0x3C, g = 0xFF, b = 0x00},                                                         
	{r = 0xFF, g = 0x00, b = 0xAF},                                                         
	{r = 0x00, g = 0xFF, b = 0xFF},                                                         
	{r = 0x00, g = 0xFF, b = 0x00},                                                         
	{r = 0x3C, g = 0xFF, b = 0x00},                                                         
	{r = 0xFF, g = 0x00, b = 0xAF},                                                         
	{r = 0x00, g = 0xFF, b = 0xFF},                                                         
	{r = 0x00, g = 0xFF, b = 0x00},                                                         
}

local debug_texture = materialsTex[2]
local mirror_texture = materialsTex[3]
local glass_texture = materialsTex[4]
local glass_fog_texture = materialsTex[5]
local glass_broken_texture = materialsTex[6]
local chrome_1_texture = materialsTex[7]
local chrome_2_texture = materialsTex[8]
local chrome_3_texture = materialsTex[9]
local blackPlasticGlossy_texture = materialsTex[10]
local blackPlasticRough_texture = materialsTex[11]

local car_primaryColor = {r = 60, g = 255, b = 0, a = 255}
local car_secondaryColor = {r = 255, g = 0, b = 175, a = 255}
local car_extraColor1 = {r = 0, g = 255, b = 255, a = 255}
local car_extraColor2 = {r = 255, g = 0, b = 255, a = 255}

local car_primaryColorSimple = {60, 255, 0, 255}
local car_secondaryColorSimple = {255, 0, 175,255}
local car_extraColor1Simple = {0, 255, 255, 255}
local car_extraColor2Simple = {255, 0, 255, 255}

local car_primaryColorHex = {r = 0x3C, g = 0xFF, b = 0x00, a = 0xFF}
local car_secondaryColorHex = {r = 0xFF, g = 0x00, b = 0xAF, a = 0xFF}
local car_extraColor1Hex = {r = 0x00, g = 0xFF, b = 0xFF, a = 0xFF}
local car_extraColor2Hex = {r = 0xFF, g = 0x00, b = 0xFF, a = 0xFF}

local colorID_List = {
	{1,1,1},                
	{245,245,245},			
	{42,119,161},			
	{132,4,16},			    
	{38,55,57},             
	{134,68,110},			
	{215,142,16},			
	{76,117,183},			
	{189,190,198},			
	{94,112,114},			
	{70,89,122},			
	{101,106,121},			
	{93,126,141},			
	{88,89,90},             
	{214,218,214},			
	{156,161,163},			
	{51,95,63},             
	{115,14,26},			
	{123,10,42},			
	{159,157,148},			
	{59,78,120},			
	{115,46,62},			
	{105,30,59},			
	{150,145,140},			
	{81,84,89},				
	{63,62,69},				
	{165,169,167},			
	{99,92,90},				
	{61,74,104},			
	{151,149,146},			
	{66,31,33},				
	{95,39,43},				
	{132,148,171},			
	{118,123,124},			
	{100,100,100},			
	{90,87,82},				
	{37,37,39},				
	{45,58,53},				
	{147,163,150},			
	{109,122,136},			
	{34,25,24},				
	{111,103,95},			
	{124,28,42},			
	{95,10,21},				
	{25,56,38},				
	{93,27,32},				
	{157,152,114},			
	{122,117,96},			
	{152,149,134},			
	{173,176,176},			
	{132,137,136},			
	{48,79,69},				
	{77,98,104},			
	{22,34,72},				
	{39,47,75},				
	{125,98,86},			
	{158,164,171},			
	{156,141,113},			
	{109,24,34},			
	{78,104,129},			
	{156,156,152},			
	{145,115,71},			
	{102,28,38},			
	{148,157,159},			
	{164,167,165},			
	{142,140,70},			
	{52,26,30},				
	{106,122,140},			
	{170,173,142},			
	{171,152,143},			
	{133,31,46},			
	{111,130,151},			
	{88,88,83},				
	{154,167,144},			
	{96,26,35},				
	{32,32,44},				
	{164,160,150},			
	{170,157,132},			
	{120,34,43},			
	{14,49,109},			
	{114,42,63},			
	{123,113,94},			
	{116,29,40},			
	{30,46,50},				
	{77,50,47},				
	{124,27,68},			
	{46,91,32},				
	{57,90,131},			
	{109,40,55},			
	{167,162,143},			
	{175,177,177},			
	{54,65,85},				
	{109,108,110},			
	{15,106,137},			
	{32,75,107},			
	{43,62,87},				
	{155,159,157},			
	{108,132,149},			
	{77,93,96},				
	{174,155,127},			
	{64,108,143},			
	{31,37,59},				
	{171,146,118},			
	{19,69,115},			
	{150,129,108},			
	{100,104,106},			
	{16,80,130},			
	{161,153,131},			
	{56,86,148},			
	{82,86,97},				
	{127,105,86},			
	{140,146,154},			
	{89,110,135},			
	{71,53,50},				
	{68,98,79},				
	{115,10,39},			
	{34,52,87},				
	{100,13,27},			
	{163,173,198},			
	{105,88,83},			
	{155,139,128},			
	{98,11,28},				
	{91,93,94},				
	{98,68,40},				
	{115,24,39},			
	{27,55,109},			
	{236,106,174},			
	{255,255,255},			
}


local color_textures = {}

local componentNameFilter = ""
local textureNameFilter = ""
local materialFilter = ""
local selectedItem = 1

local im = {}

function im:init()
	self:reset()
end

function im:reset()
	self.components_List = {
		filter = "#All",
		items = {"#All"},
		index = imgui.ImInt(0)
	}
	self.texture_List = {
		filter = "#All",
		items = {"#All"},
		index = imgui.ImInt(0)
	}
	self.materials_List = {
		filter = "#All",
		items = {"#All"},
		index = imgui.ImInt(0)
	}
	self.bulkedit = {
		index = imgui.ImInt(0),
		name = "",
		enable = false
	}
	self.selectedVehicle = {
		items = {},
		lights = {}
	}
	self.currentName = ""
	self.prevName = ""
	self.firstLoad = true
	self.lastitem = 0
	self.showoPopup = false
	self.primaryColor = imgui.ImInt(0)
	self.secondaryColor = imgui.ImInt(0)
	self.thirdColor = imgui.ImInt(0)
	self.quadColor = imgui.ImInt(0)
	self.current_mod = imgui.ImInt(0)
	self.mod_name = imgui.ImBuffer(cur_mod_name, 16)
	self.main_window_state = imgui.ImBool(false)
	self.selectedItem = imgui.ImInt(1)
	for i, mat in ipairs(materialsName) do
		table.insert(im.materials_List.items, mat)
	end
end

function safegetCharInCarPassengerSeat(Veh,seat)
	return getCharInCarPassengerSeat(Veh, seat) or nil
end

CVehicle_list = {}
CVehicle_list.__index = CVehicle_list

function CVehicle_list:new()
    local instance = setmetatable({}, CVehicle_list)
    instance.vehicles = {}
    instance.count = 0
    return instance
end

function CVehicle_list:createNewCar(vehPtr, name, color1, color2, color3, color4)
    local newCar = {
        id = vehPtr,
        name = name,
        disabled = false,
        color1 = color1,
        color2 = color2,
        color3 = color3,
        color4 = color4,
        prev_color1 = color1,
        prev_color2 = color2,
        prev_color3 = color3,
        prev_color4 = color4,
        timeupdate = os.clock(),
        lights = {},
        lightsOn = false,
        lightToggled = false,
        static = true,
        isFirstAssignment = true
    }
    self.vehicles[vehPtr] = newCar
    self.count = self.count + 1
    local class, subClass = mad.get_vehicle_class(vehPtr)
    if class ~= nil then
        local passenger = pcall(safegetCharInCarPassengerSeat, vehPtr, 0) or pcall(safegetCharInCarPassengerSeat, vehPtr, 1)
		if passenger ~= nil then
			if class == vehicle_class.AUTOMOBILE or class == vehicle_class.MTRUCK or class == vehicle_class.QUAD then
				for i = 1, 4 do
					self.vehicles[vehPtr].lights[i] = {
						index = i,
						id = i <= 2 and lightType.headlight or lightType.taillight,
						obj = nil,
						pos = {x = 0, y = 0, z = 0},
						rot = {x = 0, y = 0, z = 0}
					}
					if self:isLightOn(vehPtr, i) then
						self:addLight(vehPtr, class, i)
					end
				end
			elseif class == vehicle_class.BIKE and name ~= "BIKE" and name ~= "BMX" and name ~= "MTBIKE" then
				for i = 1, 4 do
					if i == 1 or i == 4 then
						self.vehicles[vehPtr].lights[i] = {
							index = i,
							id = i == 1 and lightType.headlight or lightType.taillight,
							obj = nil,
							pos = {x = 0, y = 0, z = 0},
							rot = {x = 0, y = 0, z = 0}
						}
						if self:isLightOn(vehPtr, i) then
							self:addLight(vehPtr, class, i)
						end
					end
				end
			end
		end
	end
    return self.vehicles[vehPtr]
end

function CVehicle_list:removeDisabledCars()
    
    for i, veh in pairs(self.vehicles) do
        if veh.disabled or os.clock() - veh.timeupdate >= clean_list_time then
            
            if veh.lights then
                for l, light in ipairs(veh.lights) do
                    if light and light.obj then
                        detachObject(light.obj, 0, 0, 0, false)
                        deleteObject(light.obj)
                        light.obj = nil
                    end
                end
                veh.lights = {}
            end
            
            
            self.vehicles[veh.id] = nil
            self.count = self.count - 1
        end
    end
end

function CVehicle_list:findcar(vehPtr)
	return self.vehicles[vehPtr]
end

function CVehicle_list:isLightOn(vehPtr, light_index)
	local veh = self:findcar(vehPtr)
	if veh.static then
		return false
	elseif self:getLightDamage(vehPtr, light_index) then
		if veh.lightToggled then
			return veh.lightsOn
		elseif hour >= 19 or hour < 6 then
			veh.lightsOn = true
			return true
		else
            veh.lightsOn = false
            return false
        end
	end
	return false
end

function CVehicle_list:getLightDamage(vehPtr, light_index)
	if light_index >= 1 and light_index <= 4 then
		
		return mad.get_car_light_damage_status(vehPtr, light_index - 1) ~= 1
	else
		return false
	end
end

function CVehicle_list:addLight(vehPtr, class, light_index)
	
    local veh = self:findcar(vehPtr)
    
    if veh and light_index >= 1 and light_index <= 4 then
		veh.lights[light_index].pos, veh.lights[light_index].rot = vehs_settings:getLightPosition(veh.name, vehPtr, class, light_index)
		loadlightobject(veh.lights[light_index])
		local light = veh.lights[light_index]
		placeObjectRelativeToCar(light.obj, vehPtr, light.pos.x, light.pos.y, light.pos.z)
		attachObjectToCar(light.obj, vehPtr, light.pos.x, light.pos.y, light.pos.z, light.rot.x, light.rot.y, light.rot.z)
		
	else
		
	end
end

function CVehicle_list:removelight(vehPtr, light_index)
	local veh = self:findcar(vehPtr)
	
	if veh and light_index >= 1 and light_index <= 4 then
		if veh.lights[light_index] and veh.lights[light_index].obj ~= nil then
			detachObject(veh.lights[light_index].obj, 0, 0, 0, false)
			deleteObject(veh.lights[light_index].obj)
			veh.lights[light_index].obj = nil
		end
	end
end

function CVehicle_list:toggleLight(vehPtr)
	local veh = self:findcar(vehPtr)
	if veh then
        veh.lightsOn = not veh.lightsOn
        veh.lightToggled = true
    end
    return veh.lightsOn
end

function CVehicle_list:setStatic(vehPtr, static)
	local veh = self:findcar(vehPtr)
	if veh then
        veh.static = static
    end
end

function CVehicle_list:checkLights(vehPtr)
	local veh = self:findcar(vehPtr)
	if veh then
		if pcall(getCharInCarPassengerSeat, vehPtr, 0) ~= nil or pcall(getCharInCarPassengerSeat, vehPtr, 1) ~= nil then
			
			local class, subClass = mad.get_vehicle_class(vehPtr)
			if class ~= nil then
				for i = 1, 4 do
					if self:isLightOn(vehPtr, i) then
						if veh.lights[i] and veh.lights[i].obj == nil then
							self:addLight(vehPtr, class, i)
						end
					else
						if veh.lights[i] and veh.lights[i].obj ~= nil then
							self:removelight(vehPtr, i)
						end
					end
				end
			end
		else
			for i, light in ipairs(veh.lights) do
				self:removelight(vehPtr, i)
			end
		end
	end
end

function CVehicle_list:checkcar(vehPtr, name, color1, color2, color3, color4)
    local veh = self:findcar(vehPtr)
    
    if veh == nil then
        
        veh = self:createNewCar(vehPtr, name, color1, color2, color3, color4)
        veh.isFirstAssignment = true  
        
        local colorChanged = {primary = true,secondary = true, extra1 = true, extra2 = true }
        check_parts(vehPtr, veh, name, true, colorChanged, color1, color2, color3, color4)
    else
        
        local colorChanged = { 
            primary = veh.color1 ~= color1,
            secondary = veh.color2 ~= color2,
            extra1 = veh.color3 ~= color3,
            extra2 = veh.color4 ~= color4 
        }
        local anyColorChanged = colorChanged.primary or colorChanged.secondary or colorChanged.extra1 or colorChanged.extra2

        if anyColorChanged then
            
            
            check_parts(vehPtr, veh, name, veh.isFirstAssignment, colorChanged, color1, color2, color3, color4)
            veh.isFirstAssignment = false  
        end
        if veh.static then
			if getCarCurrentGear(vehPtr) > 1  then
				veh.static = false
			end
		end
        
        
        if vehPtr == playerVeh then
            self:checkLights(vehPtr)
        end
		
        veh.name, veh.color1, veh.color2, veh.color3, veh.color4 = name, color1, color2, color3, color4
        veh.timeupdate = os.clock()
    end
end

function CVehicle_list:reset()
    for i, veh in pairs(self.vehicles) do
        for l, light in ipairs(veh.lights) do
            if light.obj ~= nil then
                detachObject(light.obj, 0, 0, 0, true)
                deleteObject(light.obj)
                light.obj = nil
            end
        end
        veh.lights = nil
    end
    self.vehicles = {}
    self.count = 0
end

function CVehicle_list:resetMaterials(vehPtr)
	local vehicle = self.vehicles[vehPtr]
	if vehicle then
        for_each_vehicle_material(vehPtr, function(mats, component, obj)
			for mat_index, mat in ipairs(mats) do
				if mat then
					mat:reset_texture()
					mat:reset_color()
				end
			end
		end)
	end
end

vehicleList = CVehicle_list:new()

Cvehicles_Settings = {}
Cvehicles_Settings.__index = Cvehicles_Settings

function Cvehicles_Settings:new(data)
	local instance = setmetatable({}, Cvehicles_Settings)
    instance.vehicles = data or {}
    return instance
end


function Cvehicles_Settings:addCar(vehicle, vehicleName, componentName, mat_index, material, textureName, manualAdded)
    
    
    if vehicle == nil or vehicleName == nil or componentName == nil or mat_index == nil then
		print("Invalid parameters for addCar function")
		return
	end
    
    if not self.vehicles[vehicleName] then
		self.vehicles[vehicleName] = {name = vehicleName, components = {}, dummies = {}, lights = {}}
	end
    self.vehicles[vehicleName] = self.vehicles[vehicleName] or {name = vehicleName, components = {}, dummies = {}, lights = {}}

    
    if vehicle and componentName ~= "Dummy" then
        self:collectLightPositions(vehicle, vehicleName)
    end

    
    if componentName == "Dummy" then
        self:addDummyComponent(vehicleName, mat_index, material)  
    else
        self:addRegularComponent(vehicleName, componentName, mat_index, material, textureName, manualAdded)
    end
end

function Cvehicles_Settings:collectLightPositions(vehPtr, vehicleName)
    self.vehicles[vehicleName].lights = self.vehicles[vehicleName].lights or {}
    local class, subclass = mad.get_vehicle_class(vehPtr)
    for i = 1, 4 do
        if not self.vehicles[vehicleName].lights[i] then
            local pos, rot = lightPosition(vehPtr, class, i)
            if pos and rot then
                self.vehicles[vehicleName].lights[i] = {pos = pos, rot = rot}
            else
                
            end
        end
    end
end

function Cvehicles_Settings:addDummyComponent(vehicleName, mat_index, position)
    
    local dummy = self.vehicles[vehicleName].dummies[mat_index] or {}
    dummy.position = position
    dummy.active = false
    self.vehicles[vehicleName].dummies[mat_index] = dummy
end

function Cvehicles_Settings:addRegularComponent(vehicleName, componentName, mat_index, material, textureName, manualAdded)
    local componentPath = ensureTableStructure(self.vehicles, vehicleName, componentName, textureName, mat_index)
    componentPath.material = material
    componentPath.edited = manualAdded
    componentPath.textures = componentPath.textures or {}
    componentPath.textures.currentTexture = textureName
    componentPath.textures.prevTexture = textureName
end

function Cvehicles_Settings:findCar(vehicleName)
    return self.vehicles[vehicleName]
end

function Cvehicles_Settings:removeCar(vehicleName)
    self.vehicles[vehicleName] = nil
end

function Cvehicles_Settings:addDummy(vehicleName, dummyName, pos)
	if vehicleName == nil or dummyName == nil or pos == nil then
		print("Invalid parameters for addDummy function")
		return
	end
    
    if self.vehicles[vehicleName] == nil then
        
        
        self:addCar(nil, vehicleName, "Dummy", dummyName, pos, nil, false)
    else
        
        self.vehicles[vehicleName].dummies = self.vehicles[vehicleName].dummies or {}
        self.vehicles[vehicleName].dummies[dummyName] = self.vehicles[vehicleName].dummies[dummyName] or {}
        self.vehicles[vehicleName].dummies[dummyName].name = dummyName
        self.vehicles[vehicleName].dummies[dummyName].position = pos
        self.vehicles[vehicleName].dummies[dummyName].active = false
        
    end
end

function Cvehicles_Settings:getDummyPosition(vehicleName, dummyName)
	local veh = self.vehicles[vehicleName]
	if veh then
		if veh.dummies[dummyName] then
			if veh.dummies[dummyName].position then
				return veh.dummies[dummyName].position
			end
		end
	end
	return nil
end

function Cvehicles_Settings:getLightPosition(vehicleName, vehPtr, class, light_index)
    local veh = self.vehicles[vehicleName]
    if veh ~= nil then
        
        veh.lights = {}
        
        
        if veh.lights[light_index] == nil then
            local pos, rot = lightPosition(vehPtr, class, light_index)
            veh.lights[light_index] = {pos = pos, rot = rot}
            return veh.lights[light_index].pos, veh.lights[light_index].rot
        end

        
        if veh.lights[light_index].pos and veh.lights[light_index].rot then
            return veh.lights[light_index].pos, veh.lights[light_index].rot
        else
            
            veh.lights[light_index].pos, veh.lights[light_index].rot = lightPosition(vehPtr, class, light_index)
            return veh.lights[light_index].pos, veh.lights[light_index].rot
        end
    else
        
        return lightPosition(vehPtr, class, light_index)
    end
end

function Cvehicles_Settings:setLightPosition(vehicleName, light_index, pos, rot)
    local veh = self.vehicles[vehicleName]
    if veh then
        veh.lights[light_index] = {pos = pos, rot = rot}
    end
end

function Cvehicles_Settings:setMaterial(vehicle, vehicleName, componentName, mat_index, material, textureName, manualAdded)
	local uid = string.format("%s%s%s", componentName, textureName, mat_index)
    if not self.vehicles[vehicleName] then
        self:addCar(vehicle, vehicleName, componentName, mat_index, material, textureName, manualAdded)
        
        
        return
    end

    local componentPath = ensureTableStructure(self.vehicles, vehicleName, componentName, textureName, mat_index)
    componentPath.textures = componentPath.textures or {currentTexture = "", prevTexture = ""}
    local isNewTexture = componentPath.textures.currentTexture ~= textureName

    if manualAdded or isNewTexture then
        componentPath.textures.prevTexture = componentPath.textures.currentTexture
        componentPath.textures.currentTexture = textureName
        
        
    end

    componentPath.material = material
    componentPath.edited = manualAdded
end

function Cvehicles_Settings:getMaterial(vehicleName, componentName, textureName, mat_index)
	local uid = string.format("%s%s%s", componentName, textureName, mat_index)
    local veh = self.vehicles[vehicleName]
    if veh and veh.components[componentName] and veh.components[componentName][textureName] and veh.components[componentName][textureName][mat_index] then
        return veh.components[componentName][textureName][mat_index].material, veh.components[componentName][textureName][mat_index].edited
    else
        return nil, false
    end
end

function Cvehicles_Settings:isEdited(vehicleName, componentName, textureName, mat_index)
	local uid = string.format("%s%s%s", componentName, textureName, mat_index)
    local veh = self.vehicles[vehicleName]
    if veh and veh.components[componentName] and veh.components[componentName][textureName] and veh.components[componentName][textureName][mat_index] then
        return veh.components[componentName][textureName][mat_index].edited
    else
        return false
    end
end

function Cvehicles_Settings:saveSettings(mod_name)
    if mod_name == nil then
        mod_name = "Vanilla"
    end
    local fileName = string.format('%s/SARemix_VTK_%s.dat', workDir, mod_name)
    settingsManager.saveSettings(fileName, self.vehicles)
end

function Cvehicles_Settings:loadSettings(mod_name, printStatus)
	printStatus = printStatus or true
    if mod_name == nil then
        mod_name = "Vanilla"
    end
    local filename = string.format('%s/SARemix_VTK_%s.dat', workDir, mod_name)
	local newSettings, status = settingsManager.loadSettings(filename, self.vehicles)
	if newSettings then
		self.vehicles = newSettings
		if printStatus then
			if settings and status then
				printString(string.format("Vehicle Settings loaded from : 'SARemix_VTK_%s.dat'", mod_name), 3000)
			else
				printString("Failed to load Vehicle settings", 3000)
			end
		end
	end
end

settings = {
	vehicles = Cvehicles_Settings.new({})
}

vehs_settings = settings.vehicles

function vehiclelight:new(index)
	local obj_id = 15923
	if index >= 3 and index <= 4 then
		obj_id = 15924
    end
	local light =
	{
		id = obj_id,
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
	return light
end

debugMaterial = {
	debugmode = false,
	switch = false,
	switch_timer = os.clock(),
	components = {}
}

function debugMaterial:update()
	if self.debugmode then
		if os.clock() - self.switch_timer > 0.2 then
			self.switch_timer = os.clock()
			self.switch = not self.switch
			if self.switch then
				for i, comp in pairs(self.components) do
					if comp.material:get_texture() == nil then
						local r, g, b, a = comp.material:get_color()
						local tex = color_textures:getTexture(r, g, b, a)
						comp.material:set_texture(tex)
					else
						comp.material:reset_texture()
					end
				end
			else
				for i, comp in pairs(self.components) do
					if comp.originalMaterial == mat_Original then
						comp.material:reset_texture()
					elseif comp.originalMaterial >= mat_Mirror and comp.originalMaterial <= mat_BlackPlasticRough then
						comp.material:set_texture(materialsTex[comp.originalMaterial])
					elseif comp.originalMaterial >= mat_PrimaryColor_Glossy and comp.originalMaterial <= mat_ExtraColor2_Glossy then
						local tex = color_textures:getTexture(comp.color.r, comp.color.g, comp.color.b, comp.color.a)
						if tex then
							comp.material:set_texture(tex)
						end
					elseif comp.originalMaterial >= mat_PrimaryColor_Matte and comp.originalMaterial <= mat_ExtraColor2_Matte then
						local tex = color_textures:getTexture(comp.color.r, comp.color.g, comp.color.b, 1)
						if tex then
							comp.material:set_texture(tex)
						end
					elseif comp.originalMaterial >= mat_PrimaryColor_Leather and comp.originalMaterial <= mat_ExtraColor2_Leather then
						local tex = color_textures:getTexture(comp.color.r, comp.color.g, comp.color.b, 2)
						if tex then
							comp.material:set_texture(tex)
						end
					elseif comp.originalMaterial >= mat_PrimaryColor_Metallic and comp.originalMaterial <= mat_ExtraColor2_Metallic then
						local tex = color_textures:getTexture(comp.color.r, comp.color.g, comp.color.b, 3)
						if tex then
							comp.material:set_texture(tex)
						end
					end
					if comp.isHover then
						comp.countdown = comp.countdown - 1
						if comp.countdown <= 0 then
							self.components[i] = nil
						end
					end
				end
			end
		end
	end
end

function debugMaterial:removeMaterial(index)
	for v, k in pairs(self.components) do
		if k.index == index then
			self.components[v] = nil
		end
	end
	
	self.debugmode = #self.components > 0
	
end

function debugMaterial:reset()
	self.debugmode = false
	self.switch = false
	self.switch_timer = os.clock()
	for i, comp in pairs(self.components) do
		if comp.material:get_texture() == nil then
			local r, g, b, a = comp.material:get_color()
			local tex = color_textures:getTexture(r, g, b, a)
			comp.material:set_texture(tex)
		else
			comp.material:reset_texture()
		end
	end
	self.components = {}
end

function color_textures:addTexture(name, tex)
	color_textures[name] = tex
	return tex
end

function color_textures:getTexture(r, g, b, a)
	local name = colorTotextureName(r,g,b,a)
	local tex = color_textures:findTexture(name)
	if tex then
		return tex
	else
		self:generateTexture(r,g,b,a,"c")
		color_textures:addTexture(colorTotextureName(r,g,b,a), assert(mad.load_bmp_texture_with_mask(workDir .. string.format('/SARemix/texture/sub/c_%s.bmp', name), (workDir .. '/SARemix/texture/mask.bmp'))))
		tex = color_textures:findTexture(name)
		return tex
	end
end

function color_textures:findTexture(name)
	return color_textures[name] or false
end

function color_textures:generateTexture(r,g,b,a,prefix)
	local name = colorTotextureName(r,g,b,a)
	local filename = workDir .. string.format('/SARemix/texture/sub/%s_%s.bmp', prefix, name)
	local file = io.open(filename, "wb")
	if file ~= nil then
		file:write(self:createBMPHeader(16, 16))
		file:write(self:createBMPImageData(16, 16, r, g, b, a))
		file:close()
	else
		printStringNow(string.format("Error creating texture file Hex Code : %s", name), 1000)
	end
end


function color_textures:createBMPHeader(width, height)
    local rowSize = math.floor((3 * width + 3) / 4) * 4
    local pixelDataSize = rowSize * height
    local fileSize = 54 + pixelDataSize

    local header = {
        'B', 'M',                     
        intToChar(fileSize),          
        intToChar(0),                 
        intToChar(54),                
        intToChar(40),                
        intToChar(width),             
        intToChar(height),            
        string.char(1, 0),            
        string.char(24, 0),           
        intToChar(0),                 
        intToChar(pixelDataSize),     
        intToChar(0),                 
        intToChar(0),                 
        intToChar(0),                 
        intToChar(0)                  
    }

    return table.concat(header)
end


function color_textures:createBMPImageData(width, height, r, g, b, a)
    local normalRow = {}
    local bottomRow = {}
    if a == nil then
		a = 255
	end
    for i = 1, width do
        if a == 255 then
            table.insert(normalRow, string.char(b, g, r))
            table.insert(bottomRow, string.char(b, g, r))
		else
			if r + a >= 255 then
				r = 255 - a
			elseif g + a >= 255 then
                g = 255 - a
			elseif b + a >= 255 then
                b = 255 - a
            elseif r == 0 then
				r = r + a
			elseif g == 0 then
				g = g + a
			elseif b == 0 then
				b = b + a
			else
				r = r + a
				g = g + a
				b = b + a
			end
			table.insert(normalRow, string.char(b, g, r))
			table.insert(bottomRow, string.char(b, g, r))
        end
    end
    normalRow = table.concat(normalRow)
    bottomRow = table.concat(bottomRow)
    local rowPadding = string.rep(string.char(0), (4 - (width * 3 % 4)) % 4)
    local imageData = {}
    for i = 1, height do
        if height - i < 16 then
            table.insert(imageData, bottomRow .. rowPadding)
        else
            table.insert(imageData, normalRow .. rowPadding)
        end
    end
    return table.concat(imageData)
end

function colorTotextureName(r, g, b, a)
    
    return string.format("%02X%02X%02X%02X", tonumber(r), tonumber(g), tonumber(b), tonumber(a))
end

function band(x, y)
    local result = 0
    local bit = 1
    while x > 0 and y > 0 do
        if x % 2 == 1 and y % 2 == 1 then
            result = result + bit
        end
        x = math.floor(x / 2)
        y = math.floor(y / 2)
        bit = bit * 2
    end
    return result
end
function rshift(x, n)
    return math.floor(x / 2^n)
end

function intToChar(int)
    return string.char(
        band(int, 0xFF),
        band(rshift(int, 8), 0xFF),
        band(rshift(int, 16), 0xFF),
        band(rshift(int, 24), 0xFF)
    )
end

function ensureTableStructure(vehicles, vehicleName, componentName, textureName, mat_index)
    vehicles[vehicleName].components = vehicles[vehicleName].components or {}
    vehicles[vehicleName].components[componentName] = vehicles[vehicleName].components[componentName] or {}
    vehicles[vehicleName].components[componentName][textureName] = vehicles[vehicleName].components[componentName][textureName] or {}
    vehicles[vehicleName].components[componentName][textureName][mat_index] = vehicles[vehicleName].components[componentName][textureName][mat_index] or {}
    return vehicles[vehicleName].components[componentName][textureName][mat_index]
end

function file_Lines(file)
	local lines = {}
	local file = io.open(file, 'r')
	if file then
		for line in file:lines() do
			lines[#lines+1] = line
		end
		file:close()
		return lines
	end
	return false
end

local function splitstring(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

local function colorIDtoRGBA(id)
	id = id + 1
	if id < 0 then
		id = id * -1
	end
	if id > 128 then
		id = 1
	end
	local r, g, b = colorID_List[id][1], colorID_List[id][2], colorID_List[id][3]
	local a = 255
	
	return r, g, b, a
end

function lightPosition(vehPtr, class, index)
	local lightConfig = {
        [1] = {dummy = 0, rot = {x = 0, y = 0, z = 0}},
        [2] = {dummy = 4 and class == vehicle_class.BIKE or 0, rot = {x = 0, y = 0, z = 0}},
        [3] = {dummy = 1, rot = {x = 0, y = 0, z = 180}},
        [4] = {dummy = 1, rot = {x = 0, y = 0, z = 180}}
    }

    local config = lightConfig[index]
    if not config then
        printString(string.format("Invalid light index %d", index))
        return {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0}
    end

    local pos = {}
    pos.x, pos.y, pos.z = mad.get_vehicle_dummy_element_position(vehPtr, config.dummy, {true, false})
    if index % 2 == 1 then
		pos.x = -pos.x
	end
    local rot = config.rot
    
    return pos, rot
end

local function isPrimaryColor(r, g, b)
	
	
	return (r == car_primaryColor.r and g == car_primaryColor.g and b == car_primaryColor.b) or (r == 133 and g == 255 and b == 0)
end

local function isSecondaryColor(r, g, b)
	
	return r == car_secondaryColor.r and g == car_secondaryColor.g and b == car_secondaryColor.b
end

local function isExtraColor1(r, g, b)
	
	return r == car_extraColor1.r and g == car_extraColor1.g and b == car_extraColor1.b
end

local function isExtraColor2(r, g, b)
	
	return r == car_extraColor2.r and g == car_extraColor2.g and b == car_extraColor2.b
end

local function islightcolor(r, g, b)
	r = tonumber(r)
	g = tonumber(g)
	b = tonumber(b)
	return (r == 255 and g == 175 and b == 0) or (r == 185 and g == 255 and b == 0) or (r == 0 and g == 255 and b == 200) or (r == 255 and g == 60 and b == 0)
end

local function hextoColor(numbers)
	local v = {}
	for i, num in ipairs(numbers) do
		table.insert(v, tonumber(num))
	end
	return v[1], v[2], v[3], v[4]
end

local function getAllMaterials(component)
	local objs = component:get_objects()
	for i, obj in ipairs(objs) do
		return obj:get_materials()
	end
end

local function containsString(main, sub, exclude)
	if main == nil or sub == nil then
		return false
	end
	if sub and #sub > 0 then
		main = str_lower(main)
		if exclude and #exclude > 0 and exclude[1] ~= "" then
			for _, s in pairs(exclude) do
				if str_find(main, str_lower(s), 1, true) then
					return false
				end
			end
		end
		for _, s in pairs(sub) do
			if str_find(main, str_lower(s), 1, true) then
				return true
			end
		end
	end
    return false
end

local function getVehicleName(veh)
	return getNameOfVehicleModel(getCarModel(veh))
end

function for_each_vehicle_material(car, func)
	for _, comp in ipairs(mad.get_all_vehicle_components(car)) do
		for _, obj in ipairs(comp:get_objects()) do
			func(obj:get_materials(), comp, obj)
		end
	end
end

local function addNewDummy(vehicleName, component)
	if vehicleName == nil or component == nil then
		print("Invalid parameters for addNewDummy function")
		return
	end
    local pos = {x = 0, y = 0, z = 0}
    pos.x, pos.y, pos.z = component.modeling_matrix.pos:get()
    vehs_settings:addDummy(vehicleName, component.name, pos)
end
						
local function handleSpecificComponents(veh, vehicleName, component, mat_index, mat, tex, textureName, r, g, b, a, colorisPrimary, colorisSecondary, colorisExtraColor1, colorisExtraColor2)
	if containsString(vehicleName, material_config.excludeMaterial.vehicleNames) then
		if check_glass(veh, vehicleName, component, mat_index, mat, a) then
			return true
		else
			if textureName == "no texture" then
				r, g, b, a = mat:get_color()
				tex = color_textures:getTexture(r, g, b, a)
				mat:set_texture(tex)
			end
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_Original, textureName, false)
			return true
		end
	elseif containsString(component.name, material_config.includeMaterial.ComponentNames) or containsString(textureName, material_config.includeMaterial.GlasstextureNames, material_config.excludeMaterial.GlasstextureNames) then
		if check_glass(veh, vehicleName, component, mat_index, mat, a) then
			return true
		end
	end
	
	if check_mirror(veh, vehicleName, component, mat_index, mat, textureName) then
        return true
	elseif check_glass(veh, vehicleName, component, mat_index, mat, a) then
		return true
	elseif containsString(textureName, material_config.includeMaterial.ChrometextureNames, material_config.excludeMaterial.ChrometextureNames) then
        mat:set_texture(chrome_1_texture)
        vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_Chrome1, textureName, false)
        return true
	elseif textureName == "no texture" then
		r, g, b, a = mat:get_color()
		tex = color_textures:getTexture(r, g, b, a)
		mat:set_texture(tex)
	end
	
end

local function autoAssignMaterial(veh, vehicleName, component, mat, mat_index, materialType)
	local tex = mat:get_texture() or nil
    local textureName = mat:get_texture() and mat:get_texture().name or "no texture"
    local color1, color2 = getCarColours(veh)
    local color3, color4 = getExtraCarColours(veh)
    local r, g, b, a = hextoColor({mat:get_color()})
    local isVehicleColor = {false, false, false, false}
    local result = false

    if materialType == nil then
        local colorChecks = {
            {isPrimaryColor, color1, mat_PrimaryColor_Glossy, 1},
            {isSecondaryColor, color2, mat_SecondaryColor_Glossy, 2},
            {isExtraColor1, color3, mat_ExtraColor1_Glossy, 3},
            {isExtraColor2, color4, mat_ExtraColor2_Glossy, 4}
        }

        local shouldExclude = containsString(vehicleName, material_config.excludeMaterial.vehicleNames) or
                            (not (containsString(textureName, material_config.includeMaterial.ColorTextureNames, material_config.excludeMaterial.ColorTextureNames)) and containsString(component.name, material_config.includeMaterial.ColorPartNames)) or
                            (isPrimaryColor and color1 == 1 and getCurrentVehiclePaintjob(veh) >= 0)
        
        for _, check in ipairs(colorChecks) do
            local colorFunc, colorID, materialKey, index = table.unpack(check)
            if colorFunc(r, g, b) then
                isVehicleColor[index] = true
                if not shouldExclude and not result then
                    r, g, b, a = colorIDtoRGBA(colorID)
                    result = true
                end
            end
        end
    else
        local materialMappings = {
            [mat_PrimaryColor_Glossy] = {1, color1, 255},
            [mat_PrimaryColor_Matte] = {1, color1, 1},
            [mat_PrimaryColor_Leather] = {1, color1, 2},
            [mat_PrimaryColor_Metallic] = {1, color1, 3},
            [mat_SecondaryColor_Glossy] = {2, color2, 255},
            [mat_SecondaryColor_Matte] = {2, color2, 1},
            [mat_SecondaryColor_Leather] = {2, color2, 2},
            [mat_SecondaryColor_Metallic] = {2, color2, 3},
            [mat_ExtraColor1_Glossy] = {3, color3, 255},
            [mat_ExtraColor1_Matte] = {3, color3, 1},
            [mat_ExtraColor1_Leather] = {3, color3, 2},
            [mat_ExtraColor1_Metallic] = {3, color3, 3},
            [mat_ExtraColor2_Glossy] = {4, color4, 255},
            [mat_ExtraColor2_Matte] = {4, color4, 1},
            [mat_ExtraColor2_Leather] = {4, color4, 2},
            [mat_ExtraColor2_Metallic] = {4, color4, 3}
        }

        local mapping = materialMappings[materialType]
        if mapping then
            local colorIndex, colorID, alphaValue = table.unpack(mapping)
            isVehicleColor[colorIndex] = true
            r, g, b, a = colorIDtoRGBA(colorID)
            a = alphaValue
            result = true
        end
    end

    if result or containsString(component.name, material_config.includeMaterial.ColorPartNames) then
		check_color(veh, vehicleName, component, mat_index, mat, r, g, b, a, 
			isVehicleColor[1], isVehicleColor[2], isVehicleColor[3], isVehicleColor[4])
    else
        handleSpecificComponents(veh, vehicleName, component, mat_index, mat, tex, textureName, 
            r, g, b, a, isVehicleColor[1], isVehicleColor[2], isVehicleColor[3], isVehicleColor[4])
    end
end

function check_parts(vehPtr, vehicle, vehicleName, isFirstAssignment, colorChanges, color1, color2, color3, color4)
    if not isFirstAssignment then
        vehicle.color1, vehicle.color2, vehicle.color3, vehicle.color4 = color1, color2, color3, color4
    end

    for_each_vehicle_material(vehPtr, function(mats, component, obj)
        for mat_index, mat in ipairs(mats) do
            local textureName = mat:get_texture() and mat:get_texture().name or "no texture"
            local r, g, b, a = mat:get_color()
            local tex = mat:get_texture()
            local comp_mat_Index, isEdited = vehs_settings:getMaterial(vehicleName, component.name, textureName, mat_index)

            local needsUpdate = isFirstAssignment or
                                (colorChanges.primary and isPrimaryColor(r, g, b) or isPrimaryMaterial(comp_mat_Index)) or
                                (colorChanges.secondary and isSecondaryColor(r, g, b) or isSecondaryColor(comp_mat_Index)) or
                                (colorChanges.extra1 and isExtraColor1(r, g, b) or isExtraColor1Material(comp_mat_Index)) or
                                (colorChanges.extra2 and isExtraColor2(r, g, b) or isExtraColor2Material(comp_mat_Index) and
                                comp_mat_Index ~= mat_Original)
                                
            if comp_mat_Index ~= nil and comp_mat_Index > mat_Debug and comp_mat_Index <= mat_BlackPlasticRough and isEdited then
                mat:set_texture(materialsTex[comp_mat_Index])
                needsUpdate = false
            elseif comp_mat_Index == mat_Original and textureName == "no texture" then
                r, g, b, a = mat:get_color()
                tex = color_textures:getTexture(r, g, b, a)
                mat:set_texture(tex)
            elseif mat:get_texture() == nil and containsString(component.name, {"dummy"}) and a == 255 then
                addNewDummy(vehicleName, component)
                vehs_settings:setMaterial(vehPtr, vehicleName, component.name, mat_index, mat_Original, "no texture", false)
            end

            if needsUpdate then
                if (isPrimaryColor(r, g, b) and color1 == 1 and getCurrentVehiclePaintjob(vehPtr) >= 0) then
					mat:reset_texture()
                else
                    autoAssignMaterial(vehPtr, vehicleName, component, mat, mat_index, comp_mat_Index)
				end
            elseif textureName == "no texture" then
                r, g, b, a = mat:get_color()
                if a > 250 and (comp_mat_Index == nil or comp_mat_Index == mat_Original) then
                    tex = color_textures:getTexture(r, g, b, a)
                    mat:set_texture(tex)
                    vehs_settings:setMaterial(vehPtr, vehicleName, component.name, mat_index, mat_Original, "no texture", false)
                end
            end
        end
    end)
end

function check_glass(veh, vehicleName, component, mat_index, mat, a)
	local textureName = mat:get_texture() and mat:get_texture().name or "no texture"
	
	if (a < 250) and (containsString(component.name, material_config.includeMaterial.ComponentNames, material_config.excludeMaterial.ComponentNames) or containsString(textureName, material_config.includeMaterial.GlasstextureNames)) then
		if not containsString(textureName, material_config.excludeMaterial.GlasstextureNames) then
			if containsString(textureName, {"shatter"}) then
				mat:set_texture(glass_broken_texture)
				vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_BrokenGlass, textureName, false)
				return true
			elseif (a > 180) then
				mat:set_texture(glass_fog_texture)
				vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_FogGlass, textureName, false)
				return true
			else
				mat:set_texture(glass_texture)
				vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_Glass, textureName, false)
				return true
			end
		end
	end
	return false
end

function isPrimaryMaterial(materialtype)
	return materialtype == mat_PrimaryColor_Glossy or materialtype == mat_PrimaryColor_Matte or materialtype == mat_PrimaryColor_Leather or materialtype == mat_PrimaryColor_Metallic
end

function isSecondaryMaterial(materialtype)
	return materialtype == mat_SecondaryColor_Glossy or materialtype == mat_SecondaryColor_Matte or materialtype == mat_SecondaryColor_Leather or materialtype == mat_SecondaryColor_Metallic
end

function isExtraColor1Material(materialtype)
	return materialtype == mat_ExtraColor1_Glossy or materialtype == mat_ExtraColor1_Matte or materialtype == mat_ExtraColor1_Leather or materialtype == mat_ExtraColor1_Metallic
end

function isExtraColor2Material(materialtype)
	return materialtype == mat_ExtraColor2_Glossy or materialtype == mat_ExtraColor2_Matte or materialtype == mat_ExtraColor2_Leather or materialtype == mat_ExtraColor2_Metallic
end

function check_color(veh, vehicleName, component, mat_index, mat, r, g, b, a, colorisPrimary, colorisSecondary, colorisExtraColor1, colorisExtraColor2)
	local textureName = mat:get_texture() and mat:get_texture().name or "no texture"
	local tex = nil
	
	if (a > 250) and (containsString(textureName, material_config.includeMaterial.ColorTextureNames) or containsString(vehicleName, material_config.includeMaterial.roughPaintVehicleNames) or containsString(vehicleName, material_config.includeMaterial.roughPaintVehicleNames) or containsString(component.name, material_config.includeMaterial.ColorPartNames) or (not containsString(textureName, material_config.excludeMaterial.ColorTextureNames))) then
		local materialtype = vehs_settings:getMaterial(vehicleName, component.name, textureName, mat_index)
		if colorisPrimary or isPrimaryMaterial(materialtype) or containsString(component.name, material_config.includeMaterial.ColorPartNames) then
			if materialtype == mat_PrimaryColor_Metallic then
				tex = color_textures:getTexture(r,g,b,3)
			elseif containsString(vehicleName, material_config.includeMaterial.roughPaintVehicleNames) or (containsString(component.name, material_config.includeMaterial.roughPaintPartNames) and containsString(textureName, material_config.includeMaterial.roughPaintTextureNames)) then
				tex = color_textures:getTexture(r,g,b,1)
				materialtype = mat_PrimaryColor_Matte
			elseif containsString(component.name, material_config.includeMaterial.LeatherComponentNames) or 
				containsString(textureName, material_config.includeMaterial.LeatherTextureNames)  or
				materialtype == mat_PrimaryColor_Leather then
				tex = color_textures:getTexture(r,g,b,2)
				materialtype = mat_PrimaryColor_Leather
			elseif materialtype == mat_PrimaryColor_Matte then
				tex = color_textures:getTexture(r,g,b,1)
			else
				tex = color_textures:getTexture(r,g,b,a)
				materialtype = mat_PrimaryColor_Glossy
			end
			mat:set_color(car_primaryColorSimple)
			mat:set_texture(tex)
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, materialtype, textureName, false)
			return true
		elseif colorisSecondary or isSecondaryMaterial(materialtype) then
			if materialtype == mat_SecondaryColor_Metallic then
				tex = color_textures:getTexture(r,g,b,3)
			elseif containsString(vehicleName, material_config.includeMaterial.roughPaintVehicleNames) or (containsString(component.name, material_config.includeMaterial.roughPaintPartNames) and containsString(textureName, material_config.includeMaterial.roughPaintTextureNames)) then
				tex = color_textures:getTexture(r,g,b,1)
				materialtype = mat_SecondaryColor_Matte
			elseif containsString(component.name, material_config.includeMaterial.LeatherComponentNames) or
				containsString(textureName, material_config.includeMaterial.LeatherTextureNames) or
				materialtype == mat_SecondaryColor_Leather then
				tex = color_textures:getTexture(r,g,b,2)
				materialtype = mat_SecondaryColor_Leather
			elseif materialtype == mat_SecondaryColor_Matte then
				tex = color_textures:getTexture(r,g,b,1)
			else
				tex = color_textures:getTexture(r,g,b,a)
				materialtype = mat_SecondaryColor_Glossy
			end
			mat:set_color(car_secondaryColorSimple)
			mat:set_texture(tex)
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, materialtype, textureName, false)
			return true
		elseif colorisExtraColor1 or isExtraColor1Material(materialtype) then
			if materialtype == mat_ExtraColor1_Metallic then
				tex = color_textures:getTexture(r,g,b,3)
			elseif containsString(vehicleName, material_config.includeMaterial.roughPaintVehicleNames) or (containsString(component.name, material_config.includeMaterial.roughPaintPartNames) and containsString(textureName, material_config.includeMaterial.roughPaintTextureNames)) then
				tex = color_textures:getTexture(r,g,b,1)
				materialtype = mat_ExtraColor1_Matte
			elseif containsString(component.name, material_config.includeMaterial.LeatherComponentNames) or
				containsString(textureName, material_config.includeMaterial.LeatherTextureNames) or
				materialtype == mat_ExtraColor1_Leather then
				tex = color_textures:getTexture(r,g,b,2)
				materialtype = mat_ExtraColor1_Leather
			elseif materialtype == mat_ExtraColor1_Matte then
				tex = color_textures:getTexture(r,g,b,1)
			else
				tex = color_textures:getTexture(r,g,b,a)
				materialtype = mat_ExtraColor1_Glossy
			end
			mat:set_color(car_extraColor1Simple)
			mat:set_texture(tex)
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, materialtype, textureName, false)
			return true
		elseif colorisExtraColor2 or isExtraColor2Material(materialtype) then
			if materialtype == mat_ExtraColor2_Metallic then
				tex = color_textures:getTexture(r,g,b,3)
			elseif containsString(vehicleName, material_config.includeMaterial.roughPaintVehicleNames) or (containsString(component.name, material_config.includeMaterial.roughPaintPartNames) and containsString(textureName, material_config.includeMaterial.roughPaintTextureNames)) then
				tex = color_textures:getTexture(r,g,b,1)
				materialtype = mat_ExtraColor2_Matte
			elseif containsString(component.name, material_config.includeMaterial.LeatherComponentNames) or
				containsString(textureName, material_config.includeMaterial.LeatherTextureNames) or
				materialtype == mat_ExtraColor2_Leather then
				tex = color_textures:getTexture(r,g,b,2)
			elseif materialtype == mat_ExtraColor2_Matte then
				tex = color_textures:getTexture(r,g,b,1)
			else
				tex = color_textures:getTexture(r,g,b,a)
				materialtype = mat_ExtraColor2_Glossy
			end
			mat:set_color(car_extraColor2Simple)
			mat:set_texture(tex)
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, materialtype, textureName, false)
			return true
		elseif containsString(component.name, material_config.includeMaterial.LeatherComponentNames, material_config.excludeMaterial.LeatherComponentNames) or containsString(textureName, material_config.includeMaterial.ColorTextureNames, material_config.excludeMaterial.ColorTextureNames) then
			local color1, color2 = getCarColours(veh)
			r, g, b, a = colorIDtoRGBA(color1)
			if containsString(component.name, material_config.includeMaterial.LeatherComponentNames) or containsString(textureName, material_config.includeMaterial.LeatherTextureNames) then
				tex = color_textures:getTexture(r,g,b,2)
			else
				tex = color_textures:getTexture(r,g,b,a)
			end
			mat:set_color(car_primaryColorSimple)
			mat:set_texture(tex)
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_PrimaryColor_Leather, textureName, false)
			return true
		end
	end
	return false
end

function check_mirror(veh, vehicleName, component, mat_index, mat, textureName)
	if containsString(component.name, material_config.includeMaterial.MirrorComponentNames, material_config.excludeMaterial.MirrorComponentNames) or 
	(containsString(component.name, {"door"}) and containsString(textureName, material_config.includeMaterial.MirrortextureNames, material_config.excludeMaterial.MirrortextureNames)) then
		local r,g,b,a = mat:get_color()
		if not islightcolor(r,g,b) then
			mat:set_texture(mirror_texture)
			vehs_settings:setMaterial(veh, vehicleName, component.name, mat_index, mat_Mirror, textureName, false)
			return mirror_texture
		end
	end
    return false
end

local function preloadtexture()
	for i, col in ipairs(colorID_List) do
		local r, g, b, a = col[1], col[2], col[3], 255
		color_textures:getTexture(r,g,b,a)
	end
end

local function changePartColor(vehPtr, r, g, b, a, colorType, colorID)
	local vehicleName = getVehicleName(vehPtr)
	local components = mad.get_all_vehicle_components(vehPtr)
	local vehicle = vehs_settings.vehicles[vehicleName]

	
	for_each_vehicle_material(vehPtr, function(mats, component, obj)
		for mat_index, mat in ipairs(mats) do
			if mat then
				local textureName = mat:get_texture() and mat:get_texture().name or "no texture"
				local materialType = vehs_settings:getMaterial(vehicleName, component.name, textureName, mat_index)
				local tex = nil
				if materialType then
					if colorType == mat_PrimaryColor_Glossy and isPrimaryMaterial(materialType) then
						if materialType == mat_PrimaryColor_Metallic then
							tex = color_textures:getTexture(r, g, b, 3)
							mat:set_texture(tex)
						elseif materialType == mat_PrimaryColor_Leather then
							tex = color_textures:getTexture(r, g, b, 2)
							mat:set_texture(tex)
						elseif materialType == mat_PrimaryColor_Matte then
							tex = color_textures:getTexture(r, g, b, 1)
							mat:set_texture(tex)
						else
							tex = color_textures:getTexture(r, g, b, a)
							mat:set_texture(tex)
						end
						printString(string.format("Part name : %s change color to color ID %d ", component.name, colorID), 1000)
					elseif colorType == mat_SecondaryColor_Glossy and isSecondaryMaterial(materialType) then
						if materialType == mat_SecondaryColor_Metallic then
							tex = color_textures:getTexture(r, g, b, 3)
							mat:set_texture(tex)
						elseif materialType == mat_SecondaryColor_Leather then
							tex = color_textures:getTexture(r, g, b, 2)
							mat:set_texture(tex)
						elseif materialType == mat_SecondaryColor_Matte then
							tex = color_textures:getTexture(r, g, b, 1)
							mat:set_texture(tex)
						else
							tex = color_textures:getTexture(r, g, b, a)
							mat:set_texture(tex)
						end
						printString(string.format("Part name : %s change color to color ID %d ", component.name, colorID), 1000)
					elseif colorType == mat_ExtraColor1_Glossy and isExtraColor1Material(materialType) then
						if materialType == mat_ExtraColor1_Metallic then
							tex = color_textures:getTexture(r, g, b, 3)
							mat:set_texture(tex)
						elseif materialType == mat_ExtraColor1_Leather then
							tex = color_textures:getTexture(r, g, b, 2)
							mat:set_texture(tex)
						elseif materialType == mat_ExtraColor1_Matte then
							tex = color_textures:getTexture(r, g, b, 1)
							mat:set_texture(tex)
						else
							tex = color_textures:getTexture(r, g, b, a)
							mat:set_texture(tex)
						end
						printString(string.format("Part name : %s change color to color ID %d ", component.name, colorID), 1000)
					elseif colorType == mat_ExtraColor2_Glossy and isExtraColor2Material(materialType) then
						if materialType == mat_ExtraColor2_Metallic then
							tex = color_textures:getTexture(r, g, b, 3)
							mat:set_texture(tex)
						elseif materialType == mat_ExtraColor2_Leather then
							tex = color_textures:getTexture(r, g, b, 2)
							mat:set_texture(tex)
						elseif materialType == mat_ExtraColor2_Matte then
							tex = color_textures:getTexture(r, g, b, 1)
							mat:set_texture(tex)
						else
							tex = color_textures:getTexture(r, g, b, a)
							mat:set_texture(tex)
						end
						printString(string.format("Part name : %s change color to color ID %d ", component.name, colorID), 1000)
					end
				else
					printString("Component or material ID not found for: " .. component.name, 1000)
				end
			end
		end
	end)
end

local function tempClose()
	im.main_window_state.v = false
	tempClosed = os.clock()
end


local function mirrorTransform(i)
	if i == 1 then
		return 2
	elseif i == 2 then
        return 1
    elseif i == 3 then
		return 4
	elseif i == 4 then
        return 3
    end
end

function trimString(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function serializeToJSON(tbl)
    local function serialize(tbl, level)
        level = level or 0
        local indent = string.rep(" ", level * 2)  
        local result = {}

        result[#result + 1] = "{\n"

        local entries = {}
        for k, v in pairs(tbl) do
            
            local formattedKey = string.format('%q', k) .. ":"

            
            local formattedValue
            if type(v) == "table" then
                formattedValue = serialize(v, level + 1)
            elseif type(v) == "string" then
                formattedValue = string.format('%q', v)
            elseif type(v) == "boolean" then
                formattedValue = tostring(v)
            elseif type(v) == "number" then
                formattedValue = tostring(v)
            else
                formattedValue = 'null'  
            end

            entries[#entries + 1] = indent .. "  " .. formattedKey .. "  " .. formattedValue
        end

        
        result[#result + 1] = table.concat(entries, ",\n")

        if level > 0 then
            result[#result + 1] = "\n" .. indent .. "}"
        else
            result[#result + 1] = "\n}"
        end
        return table.concat(result)
    end
    local firstline = true
    return serialize(tbl)
end

function loadlightobject(obj)
    if obj.obj == nil then
        requestModel(obj.id)
        obj.obj = createObject(obj.id, 0, 0, 0)
        setObjectCollision(obj.obj, false)
        setObjectDynamic(obj.obj, false)
    end
end

function DragCameraAround()
	local dragDelta = imgui.GetMouseDragDelta(1) 
	if InvertCamYAxis then
		mouseState.Y = -dragDelta.y / 5
	else
		mouseState.Y = dragDelta.y / 5
	end

	if InvertCamXAxis then
		mouseState.X = -dragDelta.x / 5
	else
		mouseState.X = dragDelta.x / 5
	end
end

function imgui.OnDrawFrame()
	if im.main_window_state.v then
		if isCharInAnyCar(PLAYER_PED) then
			local veh = storeCarCharIsInNoSave(PLAYER_PED)
			local Components = mad.get_all_vehicle_components(veh)
			local color1, color2 = getCarColours(veh)
			local color3, color4 = getExtraCarColours(veh)
			local r, g, b, a = 0, 0, 0, 0
			
			printString(string.format("Availiable Paint Jobs : %d, Current Paint Job %d", getNumAvailablePaintjobs(veh), getCurrentVehiclePaintjob(veh), 1000))
			
			im.primaryColor = imgui.ImInt(color1)
			im.secondaryColor = imgui.ImInt(color2)
			im.thirdColor = imgui.ImInt(color3)
			im.quadColor = imgui.ImInt(color4)
			im.mod_name = imgui.ImBuffer(cur_mod_name ,16)
			im.selectedItem = imgui.ImInt(selectedItem)
			im.currentName = string.format("%s", getVehicleName(veh))
			reset = false
			
			imgui.SetNextWindowPos(imgui.ImVec2(400, 80),imgui.Cond.FirstUseEver)
			imgui.SetNextWindowSize(imgui.ImVec2(640, 1080), imgui.Cond.FirstUseEver)
			
			imgui.Begin(string.format('SA Remix Vehicle Toolkit - Vehicle Name : %s', im.currentName), im.main_window_state)
			
			function resetSetting()
				local vehicle = vehs_settings.vehicles[im.currentName]
				if vehicle then
					im.prevName = im.currentName
					im.components_List.items = {}
					im.texture_List.items = {}
					local componentTracker = {}
					local textureTracker = {}
					table.insert(im.components_List.items, "#All")
					componentTracker["#All"] = true
					
					table.insert(im.texture_List.items, "#All")
					textureTracker["#All"] = true
					
					for c, component in ipairs(Components) do
						local mats = getAllMaterials(component)
						if mats then
							for mat_index, mat in ipairs(mats) do
								if mat then
									
									if not componentTracker[component.name] then
										table.insert(im.components_List.items, component.name)
										componentTracker[component.name] = true
									end
									local texture_name = mat.get_texture and mat:get_texture() and mat:get_texture().name or 'no texture'
									if not textureTracker[texture_name] then
										table.insert(im.texture_List.items, texture_name)
										textureTracker[texture_name] = true
									end
								end
							end
						end
					end
					table.sort(im.components_List.items)
					table.sort(im.texture_List.items)
				end
			end
			
			im.firstLoad = im.prevName ~= im.currentName
			if im.firstLoad then
				resetSetting()
			end
			
			imgui.Text("Vehicles Mods : ")
			
			imgui.SameLine()
			imgui.PushItemWidth(100)
			if imgui.Combo("Mod Name", im.current_mod, mod_list, #mod_list) then
				cur_mod_name = mod_list[im.current_mod.v + 1]
				vehs_settings:loadSettings(cur_mod_name)
				forceReset = true
				resetSetting()
				tempClose()
			end
			imgui.PopItemWidth()
			
			imgui.SameLine()
			imgui.PushItemWidth(100)
			imgui.PushID("Input Mod Name ID")
			if imgui.Button("Add Mod") then
				im.showoPopup = true
			end
			imgui.PopItemWidth()
			imgui.PopID()
			
			if im.showoPopup then
				imgui.OpenPopup("Input Mod Name")
			end
			
			if imgui.BeginPopupModal("Input Mod Name", nil, imgui.WindowFlags.AlwaysAutoResize) then
				imgui.Text("Mod Name : ")
				imgui.SameLine()
				imgui.PushItemWidth(100)
				imgui.InputText("", im.mod_name)
				imgui.PopItemWidth()
				imgui.PushID("Input Mod Name OK")
				if imgui.Button("OK") then
					if im.mod_name.v ~= "" then
						local exists = false
						for _, mod in ipairs(mod_list) do
							if mod == im.mod_name.v then
								exists = true
								break
							end
						end
						
						if not exists then
							table.insert(mod_list, im.mod_name.v)
							cur_mod_name = im.mod_name.v
							im.current_mod.v = #mod_list - 1  
							forceReset = true
							tempClose()
							
							
							imgui.SetNextItemValue(im.current_mod.v)
						end
					end
					im.showoPopup = false
					imgui.CloseCurrentPopup()
				end
				imgui.PopID()
				imgui.PushID("Input Mod Name Cancel")
				imgui.SameLine()
				imgui.PushItemWidth(100)
				if imgui.Button("Cancel") then
					im.showoPopup = false
					imgui.CloseCurrentPopup()
				end
				imgui.PopItemWidth()
				imgui.PopID()
				imgui.EndPopup()
			end
			
			if #mod_list > 1 then
				imgui.SameLine()
				imgui.PushItemWidth(100)
				imgui.PushID("Remove Mod Btn")
				if imgui.Button("Remove Mod") then
					if cur_mod_name ~= "Vanilla" then
						for i, mod in ipairs(mod_list) do
							if mod == cur_mod_name then
								table.remove(mod_list, i)
								break
							end
						end
						cur_mod_name = mod_list[1]
						im.current_mod = imgui.ImInt(0)
					end
				end
				imgui.PopItemWidth()
				imgui.PopID()
			end
			
			imgui.PushID("Save Btn")
			imgui.PushItemWidth(100)
			if imgui.Button("Save") then
				vehs_settings:saveSettings(cur_mod_name)
				forceReset = true
				printString("Vehicle Setting Saved", 3000)
				saveMainSettings()
				tempClose()
			end
			imgui.PopItemWidth()
			imgui.PopID()
			
			imgui.SameLine()
			imgui.PushID("Load Btn")
			imgui.PushItemWidth(100)
			if imgui.Button("Load") then
				vehs_settings:loadSettings(cur_mod_name, false)
				printString("Vehicle Setting Loaded", 3000)
				resetSetting()
				tempClose()
			end
			imgui.PopItemWidth()
			imgui.PopID()
			
			imgui.SameLine()
			imgui.PushItemWidth(100)
			imgui.PushID("Reset Btn")
			if imgui.Button("Reset Materials") then
				forceReset = true
				vehs_settings:removeCar(im.currentName)
				vehs_settings:saveSettings(cur_mod_name)
				resetSetting()
				vehicleList:resetMaterials(veh)
				printString(string.format("Vehicle %s materials reset", im.currentName), 3000)
				tempClose()
			end
			imgui.PopItemWidth()
			imgui.PopID()
			
			if not forceReset then
				if imgui.CollapsingHeader("Color Configuration") then
					imgui.PushID("Color Control 1")
					if imgui.SliderInt("Primary Color", im.primaryColor, 0, 127, "%.0f") then
						changeCarColour(veh, im.primaryColor.v, im.secondaryColor.v)
						r, g, b, a = colorIDtoRGBA(im.primaryColor.v)
						changePartColor(veh, r, g, b, a, mat_PrimaryColor_Glossy, im.primaryColor.v)
					end
					imgui.PopID()
					
					imgui.PushID("Color Control 2")
					if imgui.SliderInt("Secondary Color", im.secondaryColor, 0, 127, "%.0f") then
						changeCarColour(veh, im.primaryColor.v, im.secondaryColor.v)
						r, g, b, a = colorIDtoRGBA(im.secondaryColor.v)
						changePartColor(veh, r, g, b, a, mat_SecondaryColor_Glossy, im.secondaryColor.v)
					end
					imgui.PopID()
					
					imgui.PushID("Color Control 3")
					if imgui.SliderInt("Extra Color 1", im.thirdColor, 0, 127, "%.0f") then
						setExtraCarColours(veh, im.thirdColor.v, im.quadColor.v)
						r, g, b, a = colorIDtoRGBA(im.thirdColor.v)
						changePartColor(veh, r, g, b, a, mat_ExtraColor1_Glossy, im.thirdColor.v)
					end
					imgui.PopID()
					
					imgui.PushID("Color Control 4")
					if imgui.SliderInt("Extra Color 2", im.quadColor, 0, 127, "%.0f") then
						setExtraCarColours(veh, im.thirdColor.v, im.quadColor.v)
						r, g, b, a = colorIDtoRGBA(im.quadColor.v)
						changePartColor(veh, r, g, b, a, mat_ExtraColor2_Glossy, im.quadColor.v)
					end
					imgui.PopID()
				end
				if imgui.CollapsingHeader("Material Configuration") then
					
					imgui.PushID("Part Name")
					imgui.PushItemWidth(150)
					imgui.Text('Part Name')
					imgui.PopItemWidth()
					imgui.PopID()
					
					
					imgui.PushID("Texture Name")
					imgui.SameLine(180)
					imgui.PushItemWidth(150)
					imgui.Text('Texture Name')
					imgui.PopItemWidth()
					imgui.PopID()
					
					
					imgui.PushID("Material Type")
					imgui.SameLine(360)
					imgui.PushItemWidth(200)
					imgui.Text('Material Type')
					imgui.PopItemWidth()
					imgui.PopID()
					
					
					imgui.PushID("components filter")
					imgui.PushItemWidth(150)
					if imgui.Combo(" ", im.components_List.index, im.components_List.items, #im.components_List.items) then
						im.components_List.filter = im.components_List.items[im.components_List.index.v+1]
						printString(string.format("component filter applied to %s", im.components_List.filter), 3000)
					end
					imgui.PopItemWidth()
					imgui.PopID()
					
					
					imgui.PushID("textures filter")
					imgui.SameLine(180)
					imgui.PushItemWidth(150)
					if imgui.Combo(" ", im.texture_List.index, im.texture_List.items, #im.texture_List.items) then
						im.texture_List.filter = im.texture_List.items[im.texture_List.index.v+1]
						printString(string.format("texture filter applied to %s", im.texture_List.filter), 3000)
					end
					imgui.PopItemWidth()
					imgui.PopID()
					
					
					imgui.PushID("materials filter")
					imgui.SameLine(360)
					imgui.PushItemWidth(200)
					if imgui.Combo(" ", im.materials_List.index, im.materials_List.items, #im.materials_List.items) then
						im.materials_List.filter = im.materials_List.items[im.materials_List.index.v+1]
						printString(string.format("material filter applied to %s", im.materials_List.filter), 3000)
					end
					imgui.PopItemWidth()
					imgui.PopID()
					
					
					imgui.Separator()
					
					
					for compIndex, component in ipairs(Components) do
						local mats = getAllMaterials(component)
						if mats ~= nil then
							for mat_index, mat in ipairs(mats) do
								if mat ~= nil then
									local textureName = mat:get_texture() and mat:get_texture().name or "no texture"
									local comp_mat_Index = vehs_settings:getMaterial(im.currentName, component.name, textureName, mat_index)
									if comp_mat_Index == nil then
										vehs_settings:setMaterial(veh, im.currentName, component.name, mat_index, mat_Original, textureName, false)
										comp_mat_Index = mat_Original
									end
									
									if (im.components_List.filter == "#All" or im.components_List.filter == component.name) and
										(im.texture_List.filter == "#All" or im.texture_List.filter == textureName) and
										(im.materials_List.filter == "#All" or im.materials_List.filter == materialsName[comp_mat_Index]) then
										local uid = string.format("%s%s%s", component.name, textureName, mat_index)
										
										if im.selectedVehicle.items[uid] == nil then
											im.selectedVehicle.items[uid] = {
												index = imgui.ImInt(comp_mat_Index),
												name = materialsName[comp_mat_Index]
											}
										end
					
										imgui.PushID(uid .. "_component")
										imgui.PushItemWidth(120)
										imgui.Text(string.format('%s', component.name))
										imgui.PopItemWidth()
										if imgui.IsItemHovered() then
											showComponent(component)
											editMaterial(mat_Debug, component.name, mat, color1, color2, color3, color4, uid, comp_mat_Index, true)
										end
										imgui.PopID()
										
										imgui.PushID(uid .. "_texture")
										imgui.SameLine(140)
										imgui.PushItemWidth(120)
										imgui.Text(string.format('%s', textureName))
										if imgui.IsItemHovered() then
											showComponent(component)
											editMaterial(mat_Debug, component.name, mat, color1, color2, color3, color4, uid, comp_mat_Index, true)
										end
										imgui.PopItemWidth()
										imgui.PopID()
										
										imgui.PushID(uid .. "_color")
										imgui.SameLine(280)
										imgui.PushItemWidth(240)
										local r, g, b, a = mat:get_color()
										local color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
										imgui.ColorButton("##color", color, imgui.ColorEditFlags.NoTooltip, imgui.ImVec2(20, 20))
										imgui.SameLine()
										imgui.Text(string.format("%d, %d, %d, %d", r, g, b, a))
										if imgui.IsItemHovered() then
											showComponent(component)
											editMaterial(mat_Debug, component.name, mat, color1, color2, color3, color4, uid, comp_mat_Index, true)
										end
										imgui.PopItemWidth()
										imgui.PopID()
										
										imgui.PushID(uid .. "_slider")
										imgui.SameLine(460)
										imgui.PushItemWidth(160)
										imgui.SliderInt(" ", im.selectedVehicle.items[uid].index, 1, #materialsName, materialsName[im.selectedVehicle.items[uid].index.v])
										if imgui.IsItemHovered() then
											showComponent(component)
											editMaterial(mat_Debug, component.name, mat, color1, color2, color3, color4, uid, comp_mat_Index, true)
										end
										local newIndex = im.selectedVehicle.items[uid].index.v
										if newIndex ~= comp_mat_Index then
											im.selectedVehicle.items[uid].name = materialsName[newIndex]
											local materialChanged = editMaterial(newIndex, component.name, mat, color1, color2, color3, color4, uid, newIndex, false)
											if debugMaterial.debugmode then
												debugMaterial:removeMaterial(uid)
											elseif materialChanged then
												textureName = mat:get_texture() and mat:get_texture().name or "no texture"
												vehs_settings:setMaterial(veh, im.currentName, component.name, mat_index, newIndex, textureName, true)
											end
										end
										imgui.PopID()
										imgui.PopItemWidth()
									end
								end
							end
						end
					end
				end
				if imgui.CollapsingHeader("Light Configuration") then
					local mirrorCB = imgui.ImBool(true)
					imgui.Checkbox("Mirror Transform", mirrorCB)
					
					local x, y, z, rot_x, rot_y, rot_z = {}, {}, {}, {}, {}, {}
					local class, subclass = mad.get_vehicle_class(veh)
					for i, light in ipairs(im.selectedVehicle.lights) do
						
						local pos, rot = vehs_settings:getLightPosition(im.currentName, class, veh, i)
						x[i], y[i], z[i], rot_x[i], rot_y[i], rot_z[i] = imgui.ImFloat(pos.x), imgui.ImFloat(pos.y), imgui.ImFloat(pos.z), imgui.ImFloat(rot.x), imgui.ImFloat(rot.y), imgui.ImFloat(rot.z)
						
						imgui.PushID(string.format("create light %d",i))
						if light == nil or light.obj == nil then
							vehicleList:removelight(veh, i)
							light = vehiclelight:new(i)
							loadlightobject(light)
							light.pos.x = x[i].v
							light.pos.y = y[i].v
							light.pos.z = z[i].v
							placeObjectRelativeToCar(light.obj, veh, x[i].v, y[i].v, z[i].v)
							attachObjectToCar(light.obj, veh, x[i].v, y[i].v, z[i].v, rot.x, rot.y, rot.z)
						else
							x[i].v = light.pos.x
							y[i].v = light.pos.y
							z[i].v = light.pos.z
							placeObjectRelativeToCar(light.obj, veh, x[i].v, y[i].v, z[i].v)
							attachObjectToCar(light.obj, veh, x[i].v, y[i].v, z[i].v, rot.x, rot.y, rot.z)
						end
						imgui.PopID()
						
						imgui.PushID(string.format("light %d x",i))
						imgui.Text(string.format("name : %s", car_light_def[i]))
						imgui.PushItemWidth(100)
						if imgui.DragFloat("X", x[i], 0.001, 0.0, 0.0,"%.03f") then
							light.pos.x = x[i].v
							pos.x = x[i].v
							vehs_settings:setLightPosition(im.currentName, i, pos, rot)
							
							if not light.obj or not veh then
								
								return
							else
								local status, err = pcall(placeObjectRelativeToCar, light.obj, veh, x[i].v, y[i].v, z[i].v)
								if not status then
									
								end
							end
							attachObjectToCar(light.obj, veh, x[i].v, y[i].v, z[i].v, rot.x, rot.y, rot.z)
							if mirrorCB.v then
								local m = mirrorTransform(i)
								
								vehs_settings:setLightPosition(im.currentName, m, pos, rot)
								if im.selectedVehicle.lights[m] == nil then
									im.selectedVehicle.lights[m] = vehiclelight:new(m)
									loadlightobject(light)
								end
								im.selectedVehicle.lights[m].pos.x = x[i].v * -1
								im.selectedVehicle.lights[m].pos.y = y[i].v
								im.selectedVehicle.lights[m].pos.z = z[i].v
								pos.x = x[i].v * -1
								placeObjectRelativeToCar(im.selectedVehicle.lights[m].obj, veh, pos.x, pos.y, pos.z)
								attachObjectToCar(im.selectedVehicle.lights[m].obj, veh, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)
							end
							
							printString(string.format("%s x %.03f, y %.03f,z %.03f", car_light_def[i], x[i].v, y[i].v, z[i].v), 1000)
						end
						imgui.PopItemWidth()
						imgui.PopID()
						
						imgui.PushID(string.format("light %d y",i))
						imgui.SameLine()
						imgui.PushItemWidth(100)
						if imgui.DragFloat("Y", y[i], 0.001, 0.0, 0.0,"%.03f") then
							light.pos.y = y[i].v
							pos.y = y[i].v
							vehs_settings:setLightPosition(im.currentName, i, pos, rot)
							attachObjectToCar(light.obj, veh, x[i].v, y[i].v, z[i].v, rot_x[i].v, rot_y[i].v, rot_z[i].v)
							if mirrorCB.v then
								local m = mirrorTransform(i)
								vehs_settings:setLightPosition(im.currentName, m, pos, rot)
								if im.selectedVehicle.lights[m] == nil then
									im.selectedVehicle.lights[m] = vehiclelight:new(m)
									loadlightobject(light)
								end
								im.selectedVehicle.lights[m].pos.x = x[i].v * -1
								im.selectedVehicle.lights[m].pos.y = y[i].v
								im.selectedVehicle.lights[m].pos.z = z[i].v
								pos.x = x[i].v * -1
								placeObjectRelativeToCar(im.selectedVehicle.lights[m].obj, veh, pos.x, pos.y, pos.z)
								attachObjectToCar(im.selectedVehicle.lights[m].obj, veh, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)
							end
							printString(string.format("%s x %.03f, y %.03f,z %.03f", car_light_def[i], x[i].v, y[i].v, z[i].v), 1000)
						end
						imgui.PopItemWidth()
						imgui.PopID()
						
						imgui.PushID(string.format("light %d z",i))
						imgui.SameLine()
						imgui.PushItemWidth(100)
						if imgui.DragFloat("Z", z[i], 0.001, 0.0, 0.0,"%.03f") then
							light.pos.z = z[i].v
							pos.z = z[i].v
							vehs_settings:setLightPosition(im.currentName, i, pos, rot)
							attachObjectToCar(light.obj, veh, x[i].v, y[i].v, z[i].v, rot_x[i].v, rot_y[i].v, rot_z[i].v)
							if mirrorCB.v then
								local m = mirrorTransform(i)
								vehs_settings:setLightPosition(im.currentName, m, pos, rot)
								if im.selectedVehicle.lights[m] == nil then
									im.selectedVehicle.lights[m] = vehiclelight:new(m)
									loadlightobject(im.selectedVehicle.lights[i])
								end
								im.selectedVehicle.lights[m].pos.x = x[i].v * -1
								im.selectedVehicle.lights[m].pos.y = y[i].v
								im.selectedVehicle.lights[m].pos.z = z[i].v
								pos.x = x[i].v * -1
								placeObjectRelativeToCar(im.selectedVehicle.lights[m].obj, veh, pos.x, pos.y, pos.z)
								attachObjectToCar(im.selectedVehicle.lights[m].obj, veh, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)
							end
							printString(string.format("%s x %.03f, y %.03f,z %.03f", car_light_def[i], x[i].v, y[i].v, z[i].v), 1000)
						end
						imgui.PopItemWidth()
						imgui.PopID()
						
						imgui.PushID(string.format("light status %d",i))
						imgui.SameLine()
						imgui.PushItemWidth(200)
						imgui.Text(string.format("%s", vehicleList:isLightOn(veh, i) and "ON" or "OFF"))
						imgui.PopID()
					end
					if isEmergencyServicesVehicle(veh) then
						printString("It's Emergency Services Vehicle", 1000)
					end
					
					
					
					
					
					
				end
			end
			imgui.End()
			im.firstLoad = false
		elseif not reset then
			debugMaterial:reset()
			im:init()
			im.main_window_state.v = false
			reset = true
		end
	end
end

function editMaterial(materialType, componentName, mat, color1, color2, color3, color4, uid, original_mat_Index, isHover)
    local changed = true
    
    
    local materialMappings = {
        [mat_PrimaryColor_Glossy] = {color1, 255, car_primaryColorSimple},
        [mat_SecondaryColor_Glossy] = {color2, 255, car_secondaryColorSimple},
        [mat_ExtraColor1_Glossy] = {color3, 255, car_extraColor1Simple},
        [mat_ExtraColor2_Glossy] = {color4, 255, car_extraColor2Simple},
        [mat_PrimaryColor_Matte] = {color1, 1, car_primaryColorSimple},
        [mat_SecondaryColor_Matte] = {color2, 1, car_secondaryColorSimple},
        [mat_ExtraColor1_Matte] = {color3, 1, car_extraColor1Simple},
        [mat_ExtraColor2_Matte] = {color4, 1, car_extraColor2Simple},
        [mat_PrimaryColor_Leather] = {color1, 2, car_primaryColorSimple},
        [mat_SecondaryColor_Leather] = {color2, 2, car_secondaryColorSimple},
        [mat_ExtraColor1_Leather] = {color3, 2, car_extraColor1Simple},
        [mat_ExtraColor2_Leather] = {color4, 2, car_extraColor2Simple},
        [mat_PrimaryColor_Metallic] = {color1, 3, car_primaryColorSimple},
        [mat_SecondaryColor_Metallic] = {color2, 3, car_secondaryColorSimple},
        [mat_ExtraColor1_Metallic] = {color3, 3, car_extraColor1Simple},
        [mat_ExtraColor2_Metallic] = {color4, 3, car_extraColor2Simple}
    }

    
    if materialType == mat_Original then
        if mat:get_texture() == nil then
            local r, g, b, a = mat:get_color()
            local tex = color_textures:getTexture(r, g, b, a)
            mat:set_texture(tex)
            printString(string.format("Vehicle %s Component %s id %s reset to original and assigned a pure color texture", im.currentName, componentName, uid), 1000)
        else
            mat:reset_texture()
            mat:reset_color()
            printString(string.format("%s's material reset to original texture", componentName), 1000)
        end
        
    
    elseif materialType == mat_Debug then
        changed = false
        local r, g, b, a = 0, 0, 0, 0
        
        
        if isPrimaryMaterial(original_mat_Index) then
            r, g, b, a = colorIDtoRGBA(color1)
        elseif isSecondaryMaterial(original_mat_Index) then
            r, g, b, a = colorIDtoRGBA(color2)
        elseif isExtraColor1Material(original_mat_Index) then
            r, g, b, a = colorIDtoRGBA(color3)
        elseif isExtraColor2Material(original_mat_Index) then
            r, g, b, a = colorIDtoRGBA(color4)
        end
        
        debugMaterial.debugmode = true
        if not debugMaterial.components[uid] then
            debugMaterial.components[uid] = {
                isHover = isHover,
                material = mat,
                originalMaterial = original_mat_Index,
                color = {r = r, g = g, b = b, a = a},
                countdown = 2
            }
        end
        mat:set_texture(debug_texture)
        
    
    elseif materialMappings[materialType] then
        local mapping = materialMappings[materialType]
        local colorID, alpha, colorSimple = table.unpack(mapping)
        local r, g, b, a = colorIDtoRGBA(colorID)
        local tex = color_textures:getTexture(r, g, b, alpha)
        
        if tex then
            mat:set_color(colorSimple)
            mat:set_texture(tex)
            printString(string.format("Part name : %s assigned to %s", componentName, materialsName[materialType]), 1000)
        end
        
    
    else
        local tex = materialsTex[materialType]
        if tex then
            mat:set_texture(tex)
            mat:reset_color()
            printString(string.format("Part name : %s assigned to %s material", componentName, materialsName[materialType]), 1000)
        end
    end

    
    if debugMaterial.components[uid] then
        debugMaterial.components[uid].originalMaterial = original_mat_Index
    end

    return changed
end

function updatevehicles()
    local vehs = getAllVehicles()
    
    for i, veh in ipairs(vehs) do
        local vehicleName = getVehicleName(veh)
        if vehicleName ~= nil then
			local color1, color2 = getCarColours(veh)
			local color3, color4 = getExtraCarColours(veh)
			vehicleList:checkcar(veh, vehicleName, color1, color2, color3, color4)
		end
    end
    vehicleList:removeDisabledCars()
end

function showInfo()
    if VTK_firstStart then
        VTK_timer = os.clock()
        VTK_firstStart = false
    else
        if os.clock() - VTK_timer > 15 then
            VTK_showtext = false
        end
    end
    if VTK_showtext then
        mad.draw_text('SA REMIX VEHICLE TOOLKIT START', 300, 140, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 1000, true, false, 255, 255, 255, 255, 0, 1)
    end
end

function showComponent(component)
	local x, y, z = component.matrix.pos:get()
	local sx, sy = convert3DCoordsToScreen(x, y, z)
	local exsx, exsy, tsx, tsy = 0, 0, 0, 0
	if sx > scr_w_half then
		exsx, exsy = convert3DCoordsToScreen(x + 0.5, y, z)
	else
		exsx, exsy = convert3DCoordsToScreen(x - 0.5, y, z)
	end
	renderDrawLine(sx, sy, exsx, exsy, 2.0, 0xFFFFFFFF)
	local extendx = 40
	local textx = 0
	if exsx < sx then
		extendx = -40
		textx = -40
	end
	renderDrawLine(exsx, exsy, exsx + extendx, exsy, 2.0, 0xFFFFFFFF)
	mad.draw_text("here", exsx + textx, exsy - 20, mad.font_style.SUBTITLES, 0.4, 0.8, mad.font_align.LEFT, 2000, true, false, 255, 255, 255, 255, 1, 0, 30, 30, 30, 120)
end

function loadMainSetting()
	local setting = io.open(workDir .. "/SARemix_VTK.conf", "r")
	if setting then
		local lines = setting:lines()
		for line in lines do
			if line:find("Mod List") then
				local mods = line:match("= (.+)")
				mod_list = splitstring(mods, ",")
				for i, mod in ipairs(mod_list) do
					mod_list[i] = trimString(mod)
				end
			elseif line:find("Mod Name") then
				local mod_name = trimString(line:match("= (.+)"))
				cur_mod_name = ""  
				for index, mod in ipairs(mod_list) do
					if mod == mod_name then
						cur_mod_name = mod_list[index]
						im.current_mod = imgui.ImInt(index - 1)
						break
					end
				end
				if cur_mod_name == "" then
					cur_mod_name = mod_list[1]
				end
			end
		end
		io.close(setting)
	end
end

function saveMainSettings()
	local setting = io.open(workDir .. "/SARemix_VTK.conf", "w")
	if setting then
		setting:write("[SARemix_VTK Setting]\n")
		for i, mod in ipairs(mod_list) do
			if i == 1 then
				setting:write("Mod List = ".. mod)
			else
				setting:write(", ".. mod)
			end
		end
		setting:write("\n")
		setting:write("Mod Name = ".. cur_mod_name .."\n")
		io.close(setting)
	end
end

function updateDebugView()
    for vehPtr, veh in pairs(vehicleList.vehicles) do
		local success, x, y, z = pcall(getCarCoordinates, vehPtr)
		if success then
			local sx, sy = convert3DCoordsToScreen(x, y, z)
			if isPointOnScreen(x, y, z, 5) then
				local texttoDraw = string.format("static : %s Light On : %s light Toggled : %s", tostring(veh.static), tostring(veh.lightsOn), tostring(veh.lightToggled))
				mad.draw_text(texttoDraw, sx, sy - 20, mad.font_style.MENU, 0.3, 0.9, mad.font_align.LEFT, 3000, true, true, 255, 255, 255, 255, 0, 1)
				for i, light in ipairs(veh.lights) do
					if light.obj then
						local status = mad.get_car_light_damage_status(vehPtr, i - 1)
						local lx, ly, lz = getOffsetFromCarInWorldCoords(vehPtr, light.pos.x, light.pos.y, light.pos.z)
						local lsx, lsy = convert3DCoordsToScreen(lx, ly, lz)
						mad.draw_text(string.format("%s is %s", car_light_def[i], status), lsx, lsy, mad.font_style.MENU, 0.3, 0.9, mad.font_align.LEFT, 3000, true, true, 255, 255, 255, 255, 0, 1)
					end
				end
			end
		end
	end
end


































local function unloadTextures(Texturelist)
    
    
    
    collectgarbage("collect")
end

function removeNonPlayerVehicleLights()
    for vehPtr, veh in pairs(vehicleList.vehicles) do
        if vehPtr ~= playerVeh then  
            for i, light in ipairs(veh.lights) do
                if light and light.obj then
                    detachObject(light.obj, 0, 0, 0, false)
                    deleteObject(light.obj)
                    light.obj = nil
                end
            end
        end
    end
end

function resetAll()
	
	if playerVeh ~= nil then
		vehicleList:reset()
		debugMaterial:reset()
		im:reset()
		playerVeh = nil
	end
	
end

addEventHandler('onScriptTerminate', function()
	resetAll()
end)

addEventHandler('onSaveGame', function(data)
	resetAll()
end)

addEventHandler('onLoadGame', function(data)
	resetAll()
end)

addEventHandler('onStartNewGame', function(data)
	resetAll()
end)

function main()
	wait(1000)
	debugprint = debugPrinter:new()
	preloadtexture()
	im:init()
	loadMainSetting()
	vehs_settings:loadSettings(cur_mod_name)
	while true do
		wait(0)
		showInfo()
		hour, minute = getTimeOfDay()
		updateTimer = os.clock()
		local activeInterior = getActiveInterior()
		if activeInterior == 0 then
			if isPlayerPlaying(PLAYER_HANDLE) then
				imgui.Process = im.main_window_state.v
				if imgui.Process then
					DragCameraAround()
				end
				if (changecolorTimer == 0) or (os.clock() - changecolorTimer > changecolorDuration) then
					updatevehicles()
					changecolorTimer = os.clock()
					debugMaterial:update()
					if isCharInAnyCar(PLAYER_PED) then
						playerVeh = storeCarCharIsInNoSave(PLAYER_PED)
						vehicleList:setStatic(playerVeh, false)
						if wasKeyPressed(key.VK_M) then
							if im.main_window_state.v then
								im.main_window_state.v = not im.main_window_state.v
								debugMaterial:reset()
							else
								if im.prevName ~= im.currentName then
									im:reset()
								end
								saveMainSettings()
								im.main_window_state.v = not im.main_window_state.v
							end
						end
						if wasKeyPressed(key.VK_L) then
							vehicleList:toggleLight(playerVeh)
						end
						
						
						
						
						
						
						
						
					else
						playerVeh = nil
						im.main_window_state.v = false
					end
					lastupdatetime = os.clock() - updateTimer
					if lastupdatetime < shortest_updateTime then shortest_updateTime = lastupdatetime end
					if lastupdatetime > longest_updateTime then longest_updateTime = lastupdatetime end
					average_updateTime = (average_updateTime + lastupdatetime) / 2
				end
				if tempClosed ~= nil then
					if os.clock() - tempClosed > 0.1 then
						tempClosed = nil
						if forceReset then
							vehs_settings:loadSettings(cur_mod_name, false)
							vehicleList:reset()
							debugMaterial:reset()
							im:reset()
							forceReset = false
						end
						updatevehicles()
						im.main_window_state.v = not im.main_window_state.v
					end
				end
			end
		else
			if last_Interior ~= activeInterior then
				removeNonPlayerVehicleLights()  
				last_Interior = activeInterior
			end
			
			if isPlayerPlaying(PLAYER_HANDLE) then
				if (changecolorTimer == 0) or (os.clock() - changecolorTimer > changecolorDuration) then
					updatevehicles()
					changecolorTimer = os.clock()
					debugMaterial:update()

					if isCharInAnyCar(PLAYER_PED) then
						playerVeh = storeCarCharIsInNoSave(PLAYER_PED)
						vehicleList:setStatic(playerVeh, false)

						if wasKeyPressed(key.VK_L) then
							vehicleList:toggleLight(playerVeh)
						end
					else
						playerVeh = nil
					end

					lastupdatetime = os.clock() - updateTimer
					if lastupdatetime < shortest_updateTime then shortest_updateTime = lastupdatetime end
					if lastupdatetime > longest_updateTime then longest_updateTime = lastupdatetime end
					average_updateTime = (average_updateTime + lastupdatetime) / 2
				end
			end
		end
	end
end