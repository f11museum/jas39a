--gripen_map module

-- karta3 = loadImage("images/karta3.png", 0, 0, 4096, 4096)
-- mask = loadImage("images/screenmask.png", 0, 0, 4096, 4096)
-- rendertarget2 = createRenderTarget ( 1024 , 1024 )

dr_true_heading = globalPropertyf("sim/flightmodel/position/true_psi")
dr_alpha = globalPropertyf("sim/flightmodel2/misc/AoA_angle_degrees")
dr_beta = globalPropertyf("sim/flightmodel/position/beta")
dr_acf_roll = globalPropertyf("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
dr_mach = globalPropertyf("sim/flightmodel/misc/machno")
dr_gnrml = globalPropertyf("sim/flightmodel/forces/g_nrml")
dr_airspeed = globalPropertyf("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
dr_alt = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
dr_qnh = globalPropertyf("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot")
dr_droptank_mass = globalPropertyfa("sim/weapons/fuel_warhead_mass_max")
dr_fuel_mass = globalPropertyf("sim/flightmodel/weight/m_fuel_total")
dr_thro = globalPropertyfa("sim/flightmodel/engine/ENGN_thro")
dr_burner_ratio = globalPropertyfa("sim/flightmodel2/engines/afterburner_ratio")

local sim_alpha = 0
local sim_beta = 0
local sim_mach = 0
local sim_gnrml = 0
local sim_airspeed_kmh = 0
local sim_alt_m = 0
local sim_roll = 0
local sim_qnh_hpa = 0
local sim_fuel_mass = 0
local sim_droptank_mass = 0
local sim_thro = 0
local sim_burner_ratio = 0

local green = {0.0, 1.0, 0.0, 1.0}
local black = {0, 0, 0, 1.0}
local grey = {0, 0.3, 0, 1.0}
local white = {1, 1, 1, 1.0}
local g01 = {0.0, 0.2, 0.0, 1.0}
local g02 = {0.0, 0.4, 0.0, 1.0}
local g03 = {0.2, 0.6, 0.0, 1.0}
local g04 = {0.3, 0.8, 0.0, 1.0}
local g05 = {0.7, 1.0, 0.0, 1.0}

local speed_ang = 0
local m1_ang = 0

speed_pie = {}

function interpolate(ipol_inval, x, y, length)          
	ipol_outval = 0.0
	
	for i = 1, length do    
		if (ipol_inval <= x[1]) then
			ipol_outval = y[1]                         
			break         
		elseif (ipol_inval >= x[i] and ipol_inval < x[i+1]) then
			ipol_div_temp = x[i+1]-x[i]                            
			if (ipol_div_temp == 0) then
				ipol_div_temp = 1.0
				end	
			ipol_ratio = (ipol_inval-x[i])/(ipol_div_temp)
			ipol_outval = (y[i] * (1-ipol_ratio)) + (y[i+1] * ipol_ratio)                                  
			break 
		elseif (ipol_inval >= x[length]) then
			ipol_outval = y[length]                                
			break 
		end
	end
	
	return ipol_outval
	
end

function build_pie(radius, start_angle, end_angle)
	
	local ang = start_angle
	speed_pie[0] = {}
		speed_pie[0].x = radius * math.sin(math.rad(ang)) --x
		speed_pie[0].y = radius * math.cos(math.rad(ang)) --y
	for i = 1, 36 do
		ang = start_angle + i / 36 * (end_angle - start_angle) 
		speed_pie[i] = {}
		speed_pie[i].x = radius * math.sin(math.rad(ang)) --x
		speed_pie[i].y = radius * math.cos(math.rad(ang)) --y
		end

end


function clamp(inval, minv, maxv)

	if inval > maxv then return maxv
	elseif inval < minv then return minv
	else return inval
		end

end

function render()
	
end

function update()

	speed_ang = interpolate(sim_airspeed_kmh, {50, 180, 200, 300, 400, 1400}, {-170, -155, -140, -85, -63, 150}, 6)
	build_pie(130, -180, speed_ang)
	if sim_mach < 0.5 then 
		m1_ang = interpolate(1240, {50, 180, 200, 300, 400, 1400}, {-170, -155, -140, -85, -63, 150}, 6)
	else
		m1_ang = interpolate(sim_airspeed_kmh / sim_mach, {50, 180, 200, 300, 400, 1400}, {-170, -155, -140, -85, -63, 150}, 6)
		end
	
	sim_mach = get(dr_mach)
	if sim_mach > 0.1 then
		sim_alpha = get(dr_alpha)
		sim_beta = get(dr_beta)
		sim_gnrml = get(dr_gnrml)
		sim_airspeed_kmh = get(dr_airspeed) * 1.852
		sim_alt_m = get(dr_alt) * 0.3048
	else
		sim_alpha = 0
		sim_beta = 0
		sim_gnrml = 0
		sim_airspeed_kmh = 0
		sim_alt_m = 0
		end
	sim_roll = get(dr_acf_roll)
	sim_qnh_hpa = get(dr_qnh) * 33.86
	sim_fuel_mass = get(dr_fuel_mass)
	sim_droptank_mass = 0--get(dr_droptank_mass, 1)
	sim_thro = get(dr_thro, 1)
	sim_burner_ratio = get(dr_burner_ratio, 1)

end

function draw()
	
	
	-- ADI ball
	drawTexture(newtex, 3, -4, 1024, 1024, g04)

	-- velocity vector
	setClipArea(0, 0, 1024, 768)
	saveGraphicsContext()
		setTranslateTransform(-sim_beta * 5 + 512, -sim_alpha * 5 + 293)
		drawWideLine(-40, 0, -14, 0, 4, g05)
		drawWideLine(40, 0, 14, 0, 4, g05)
		drawWideLine(0, 40, 0, 14, 4, g05)
		drawTexturePart(mask, -25, -25, 50, 50, 895, 4, 40, 40, g05) 
		restoreGraphicsContext()	
		
	-- speed needle
	-- if sim_airspeed_kmh > 50 then 
	saveGraphicsContext()
		setTranslateTransform(216, 588)
		-- drawTriangle(0, 0, 100, 100, 200, 0, g01)
		for i = 1, #speed_pie do
			drawTriangle(0, 0, speed_pie[i-1].x, speed_pie[i-1].y, speed_pie[i].x, speed_pie[i].y, g01 )
			end
		
		setRotateTransform(speed_ang)
		drawTexturePart(mask, -13, 0, 25, 130, 895, 857, 28, 140, g04) 
		restoreGraphicsContext()
		-- end
		
	-- general mask
	drawTexturePart(mask, 0, 0, 1024, 768, 934, 77, 1024, 768, g03) 
	
	-- alt needles
	saveGraphicsContext()
		setTranslateTransform(790, 588)
		-- setRotateTransform(sim_alt_m * 0.036 - 180)
		drawTexturePart(mask, 0, -131, 83, 37, 1057, 871, 83, 37, g03) 
		restoreGraphicsContext()
	saveGraphicsContext()
		setTranslateTransform(790, 588)
		setRotateTransform(sim_alt_m * 0.36 - 180)
		drawTexturePart(mask, -13, 0, 25, 130, 895, 857, 28, 140, g04) 
		restoreGraphicsContext()
	saveGraphicsContext()
		setTranslateTransform(790, 588)
		drawTexturePart(mask, -15, -15, 30, 30, 932, 859, 28, 28, g04) 
		setRotateTransform(sim_alt_m * 0.036 - 180)
		drawTexturePart(mask, -16, 0, 32, 100, 893, 998, 32, 123, g04) 
		restoreGraphicsContext()


	--Mach no
	if sim_mach >= 1 then 
		drawText( regfont, 252, 570, string.format("%3.2f", sim_mach), 30, true, false, TEXT_ALIGN_RIGHT, g03 )
	else
		drawText( regfont, 252, 570, string.format(".%.2d", sim_mach*100), 30, true, false, TEXT_ALIGN_RIGHT, g03 )
		end
		
	-- speed refs
	saveGraphicsContext()
		setTranslateTransform(216, 588)
		setRotateTransform(-42)
		drawWideLine(0, 131, -5, 150, 4,  g04)
		drawWideLine(0, 131, 5, 150, 4, g04)
		setRotateTransform(42)
		setRotateTransform(m1_ang)
		drawWideLine(0, 131, -5, 150, 4,  g04)
		drawWideLine(0, 131, 5, 150, 4, g04)
		restoreGraphicsContext()	
		
	-- roll index
	saveGraphicsContext()
	setTranslateTransform(508, 292)
	setRotateTransform(-sim_roll)
	drawTexturePart(mask, -268, 0, 536, 274, 1171, 853, 536, 274, g04) 
		restoreGraphicsContext()
		
	-- bar indicators
	drawRectangle(140, 101, 15, 0 + clamp(sim_alpha, 0, 30) / 30 * 265, g04)
	drawRectangle(212, 101, 15, 0 + clamp(sim_gnrml, 0, 9) / 9 * 265, g04)
	drawRectangle(833, 101, 15, sim_thro * 225 + sim_burner_ratio * 90, g04)
	-- drawRectangle(908, 101, 15, interpolate((sim_fuel_mass + sim_droptank_mass), {2400, 5100}, {225, 315}, 2), g04)
	drawRectangle(908, 101, 15, sim_fuel_mass/2400 * 225, g04)
	
	-- HPA
	drawText( regfont, 525, 696, math.floor(sim_qnh_hpa*10 + 0.5) / 10, 38, true, false, TEXT_ALIGN_RIGHT, g03 )
	
	resetClipArea()
end



-- BLEND_SOURCE_COLOR
-- BLEND_ONE_MINUS_SOURCE_COLOR
-- BLEND_SOURCE_ALPHA
-- BLEND_ONE_MINUS_SOURCE_ALPHA
-- BLEND_DESTINATION_ALPHA
-- BLEND_ONE_MINUS_DESTINATION_ALPHA
-- BLEND_DESTINATION_COLOR
-- BLEND_ONE_MINUS_DESTINATION_COLOR
-- BLEND_SOURCE_ALPHA_SATURATE
-- BLEND_CONSTANT_COLOR
-- BLEND_ONE_MINUS_CONSTANT_COLOR
-- BLEND_CONSTANT_ALPHA
-- BLEND_ONE_MINUS_CONSTANT_ALPHA
--