--gripen_hud module

--*****************************UTILITIES********************************--
function clamp(inval, minv, maxv)

	if inval > maxv then return maxv
	elseif inval < minv then return minv
	else return inval
		end

end

function to_brg(inval)
	if inval > 180 then return inval -360
	elseif inval < -180 then return inval + 360 
	else return inval
	end
end

function anim(inval, target, spd)
	local retval = inval
	
	if inval == target then
		return retval
	else
		if target > inval then
			retval = inval + spd * sim_FRP
			if retval > target then retval = target end
			return retval 
		else
			retval = inval - spd * sim_FRP
			if retval < target then retval = target end
			return retval 
			end
		end
end

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

function inrange(in1, in2, range)
	if math.abs(in1 - in2) < range then return true else return false end
end

function getangles(x1, y1, z1, x2, y2, z2)
	local brg = math.deg(math.atan2((x2-x1),(z2-z1)))
	local hdst =  math.sqrt((x2-x1)^2+(z2-z1)^2)
	local elev = math.deg(math.atan2((hdst),(y2-y1)))
	local dst = math.sqrt(hdst^2+(y2-y1)^2) / 1852
	return -brg, elev, dst
end


--**********************************************************************--
local head_pitch = 0
local head_heading = 0
local head_pitch_rate = 0 
local head_heading_rate = 0
local head_rel_pitch_px
local head_rel_heading_px
local proj_area_pxl = {0, 0, 0, 0}--x, y, width, height
local hfov_tan = 0
local cam_x , cam_y , cam_z , cam_pitch , cam_yaw , cam_roll , cam_zoom = sasl.getCamera()
local vvector = 0 
local hvector = 0 
local hor_vector = 0
local ver_vector = 0
local headpos_x, headpos_y, headpos_z = 0, 0, 0
local sim_view_is_external = 0 
local hud_mode = "to" --  can be "to", "flt", "land" 
local sim_flight_time = 0 
local vector_mix = 0
local blackout_setting = 0
local landing_speed = 0
local min_speed = 0
local rotation_speed = 0

local horizon_yoffset = 0 
local window_w_old = 0
local window_h_old = 0

local sim_running = 0
local dr_multiplayer_x = {}
local dr_multiplayer_y = {}
local dr_multiplayer_z = {}
local dr_multiplayer_heading = {}
-- local target = {}
local meteor_range = 0

local ref_alt = 1000
local alt_pole_t = 0 
local alt_pole_b = 0 
local ref_pole_t = 0 
local ref_pole_b = 0 

local on_HMD = false

local sim_airspeed_kmh = 0
local sim_alt_m = 0

--standard colors
local hudcol = {0, 1, 0, 1}
local black = {0,0, 0, 1}

function init_stuff()

-- defaultFont = loadFont ("fonts/SourceCodePro.ttf")
horiz1 = loadImage("images/horiz1.png", 0, 0, 4096, 4096)
horiz2 = loadImage("images/horiz2.png", 0, 0, 4096, 4096)
symbols = loadImage("images/symbology.png", 0, 0, 1024, 1024)
rendertarget = createRenderTarget ( 1024 , 1024 )
renderblur = createRenderTarget ( 128 , 128 )

dr_acf_pitch = globalPropertyf("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot")
dr_acf_roll = globalPropertyf("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
dr_acf_heading = globalPropertyf("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
dr_airspeed = globalPropertyf("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
dr_vpath = globalPropertyf("sim/flightmodel/position/vpath")
dr_hpath = globalPropertyf("sim/flightmodel/position/hpath")
dr_true_heading = globalPropertyf("sim/flightmodel/position/true_psi")
dr_gnrml = globalPropertyf("sim/flightmodel/forces/g_nrml")
dr_mach = globalPropertyf("sim/flightmodel/misc/machno")
dr_alt = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
dr_gear_handle = globalPropertyf("sim/cockpit2/controls/gear_handle_down")
dr_groundspeed = globalPropertyf("sim/flightmodel/position/groundspeed") 
dr_radalt = globalPropertyf("sim/flightmodel/position/y_agl") 
dr_gear_depress = globalPropertyfa("sim/flightmodel/parts/tire_vrt_def_veh") 

dr_FRP = globalPropertyf("sim/operation/misc/frame_rate_period")
dr_wind_dir = globalPropertyf("sim/weather/wind_direction_degt")
dr_wind_speed = globalPropertyf("sim/weather/wind_speed_kt")
dr_true_airspeed = globalPropertyf("sim/cockpit2/gauges/indicators/true_airspeed_kts_pilot")
dr_acf_rollrate = globalPropertyf("sim/flightmodel/position/P") 
dr_acf_pitchrate = globalPropertyf("sim/flightmodel/position/Q") 
dr_acf_yawrate = globalPropertyf("sim/flightmodel/position/R") 
dr_total_weight_kg = globalPropertyf("sim/flightmodel/weight/m_total") 
dr_fuel_weight_kg = globalPropertyf("sim/flightmodel/weight/m_fuel_total") 
dr_pilot_heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
dr_pilot_pitch = globalPropertyf("sim/graphics/view/pilots_head_the")
dr_view_pitch = globalPropertyf("sim/graphics/view/view_pitch")
dr_view_roll = globalPropertyf("sim/graphics/view/view_roll")
dr_alpha = globalPropertyf("sim/flightmodel2/misc/AoA_angle_degrees")
dr_beta = globalPropertyf("sim/flightmodel/position/beta")
dr_pilots_head_x = globalPropertyf("sim/graphics/view/pilots_head_x")
dr_pilots_head_y = globalPropertyf("sim/graphics/view/pilots_head_y")
dr_pilots_head_z = globalPropertyf("sim/graphics/view/pilots_head_z")
dr_view_is_external = globalPropertyi("sim/graphics/view/view_is_external")
-- dr_relative_bearing_degs = globalPropertyfa("sim/cockpit2/tcas/indicators/relative_bearing_degs")	
-- dr_relative_distance_mtrs = globalPropertyfa("sim/cockpit2/tcas/indicators/relative_distance_mtrs")
-- dr_relative_altitude_mtrs = globalPropertyfa("sim/cockpit2/tcas/indicators/relative_altitude_mtrs")
dr_multiplayer_yoke = globalPropertyfa("sim/multiplayer/controls/engine_throttle_request")
dr_plane_target_index = globalPropertyi("sim/cockpit/weapons/plane_target_index")
dr_team_status = globalPropertyia("sim/multiplayer/combat/team_status")
dr_acf_x = globalPropertyf("sim/flightmodel/position/local_x")
dr_acf_y = globalPropertyf("sim/flightmodel/position/local_y")
dr_acf_z = globalPropertyf("sim/flightmodel/position/local_z")
dr_target_index = globalPropertyi("sim/cockpit/weapons/plane_target_index")
dr_paused = globalPropertyi("sim/time/paused")
dr_mis_arm = globalPropertyi("sim/cockpit/weapons/missiles_armed")


for i = 1, 19 do
	dr_multiplayer_x[i] = globalPropertyd("sim/multiplayer/position/plane" .. i .. "_x")
	dr_multiplayer_y[i] = globalPropertyd("sim/multiplayer/position/plane" .. i .. "_y")
	dr_multiplayer_z[i] = globalPropertyd("sim/multiplayer/position/plane" .. i .. "_z")
	dr_multiplayer_heading[i] = globalPropertyf("sim/multiplayer/position/plane" .. i .. "_psi")
	end

end



ase_circle = {}
range_circle = {}

function build_ase_circle()
	local radius = 3.5 * screen_hdegrees
	for i = 0, 72, 2 do
		ase_circle[i] = radius * math.sin(math.rad(-i*5)) --x
		ase_circle[i+1] = radius * math.cos(math.rad(-i*5)) --y
		end
end

build_ase_circle()

function build_range_circle(range, maxrange)
	local radius = 3.44 * screen_hdegrees
	local indrange = ((maxrange - range) / maxrange) * 360
	
	for i = 0, 72, 2 do
		range_circle[i] = 	radius * math.sin(math.rad(i * -indrange / 72)) --x
		range_circle[i+1] = radius * math.cos(math.rad(i * -indrange / 72)) --y
		end
		-- range_circle[73] = 	(radius-25) * math.sin(math.rad(indrange * 72/72)) --x
		-- range_circle[74] = 	(radius-25) * math.cos(math.rad(indrange* 72/72)) --y
end



function process_targets()


	local mp_thro = get(dr_multiplayer_yoke)
	local brg
	local elev
	local rollsin = math.sin(math.rad(sim_acf_roll))
	local rollcos = math.cos(math.rad(-sim_acf_roll))
	local hdgcos = math.sin(math.rad(head_heading))
	local dist_mem, x_mem, y_mem, z_mem = 0, 0, 0, 0
	
	local updown =  sim_acf_pitch * math.cos(math.rad(head_heading)) + math.sin(math.rad(head_heading)) * -sim_acf_roll

	for i = 2, 20 do
		if mp_thro[i] ~= nil then
			if target[i] == nil then target[i] = {} end
			
			dist_mem = target[i].dist or 0
			x_mem, y_mem, z_mem  = target[i].x  or 0, target[i].y or 0, target[i].z or 0
			
			-- target position, brg etc
			target[i].x, target[i].y, target[i].z = get(dr_multiplayer_x[i-1]), get(dr_multiplayer_y[i-1]), get(dr_multiplayer_z[i-1])
			target[i].brg, target[i].elev, target[i].dist = getangles(target[i].x, target[i].y, target[i].z, acf_x, acf_y, acf_z)
			target[i].hdg = get(dr_multiplayer_heading[i-1])



			brg = to_brg(target[i].brg - sim_true_heading) * screen_hdegrees * 0.9
			elev = to_brg(target[i].elev - sim_acf_pitch - 90) * screen_hdegrees * 0.9
				
			target[i].screen_x = brg * rollcos + elev * -rollsin
			target[i].screen_y = brg * rollsin + elev * rollcos
			target[i].dir = math.deg(math.atan2((target[i].screen_x),(target[i].screen_y)))
			target[i].clip = false

			
			if i == sim_act_target then 
				target[i].active = true 
				
				-- -- target AIMPOINT position, brg etc
				-- if sim_paused == 0 then
					-- target[i].x, target[i].y, target[i].z = get(dr_multiplayer_x[i-1]), get(dr_multiplayer_y[i-1]), get(dr_multiplayer_z[i-1])
					-- target[i].aim_x, target[i].aim_y, target[i].aim_z = 
						-- target[i].x + (target[i].x - x_mem) / sim_FRP * 20, 
						-- target[i].y + (target[i].y - y_mem) / sim_FRP * 20,
						-- target[i].z + (target[i].z - z_mem) / sim_FRP * 20
					-- target[i].aim_brg, target[i].aim_elev, target[i].aim_dist = getangles(target[i].aim_x, target[i].aim_y, target[i].aim_z, acf_x, acf_y, acf_z)
					-- brg = to_brg(target[i].aim_brg - sim_true_heading) * screen_hdegrees * 0.9
					-- elev = to_brg(target[i].aim_elev - sim_acf_pitch - 90) * screen_hdegrees * 0.9
					-- target[i].aim_screen_x = brg * rollcos + elev * -rollsin
					-- target[i].aim_screen_y = brg * rollsin + elev * rollcos
					-- end
				
				--Target rate of closure
				if sim_paused == 0 then target[i].roc = (target[i].roc or 0) + ((target[i].dist - dist_mem) / sim_FRP * 3600 - (target[i].roc or 0)) / 20 else target[i].roc = (target[i].roc or 0) end
				meteor_range = clamp(math.floor((sim_gs + 100 - target[i].roc)/700 * (sim_alt + 10000) / 50000 * 80 - math.abs(sim_alt - acf_y * 3.28)/1000), 20, 90)
				build_range_circle(target[i].dist, 100)
			else 
				target[i].active = false 
				end
			
			if not on_HMD then 
				if target[i].screen_y > 200 then target[i].screen_x = target[i].screen_x * 200 / target[i].screen_y ; target[i].screen_y = 200 ; target[i].clip = true end
				if target[i].screen_y < -300 then target[i].screen_x = target[i].screen_x * -300 / target[i].screen_y ; target[i].screen_y = -300 ; target[i].clip = true end
				if target[i].screen_x > 250 then target[i].screen_y = target[i].screen_y * 250 / target[i].screen_x; target[i].screen_x = 250 ; target[i].clip = true  end
				if target[i].screen_x < -250 then target[i].screen_y = target[i].screen_y * -250 / target[i].screen_x ; target[i].screen_x = -250 ; target[i].clip = true end
				end
		else
			if target[i] ~= nil then target[i] = nil end
			end		
		end



end

local yoffset = {
				--screen width, screen height, offset in y pixels from screen height/2
				{w=3440, h=1440, y=-40},
				{w=1920, h=1080, y=40},
				{w=1280, h=1080, y=90},
				{w=1680, h=1050, y=85},
				{w=1600, h=1024, y=92},
				{w=1536, h=864, y=30},
				{w=1440, h=900, y=73},
				{w=1366, h=768, y=28},
				{w=1280, h=1024, y=178},
				{w=1280, h=960, y=145},
				{w=1280, h=800, y=65},
				{w=1280, h=720, y=25},
				{w=1280, h=864, y=97},
				{w=1152, h=864, y=230},
				{w=1024, h=768, y=118}
				}

function get_yoffset()

	if window_width ~= window_w_old or window_height ~= window_h_old then 
		horizon_yoffset = 0 -- default offset, if no matching preset found
		for i = 1, #yoffset do
			if inrange(window_width, yoffset[i].w, 10) and inrange(window_height, yoffset[i].h, 10) then horizon_yoffset = yoffset[i].y ; break; end
			end
		print("screen rez changed: " .. window_width .. " x " .. window_height .. " horizon offset is " .. horizon_yoffset)
		end
		
	window_w_old = window_width
	window_h_old = window_height

end

function onAirportLoaded()
	-- init_stuff()
	-- sim_running = 0
	dr_dim_gload = globalPropertyf("sim/graphics/settings/dim_gload")
	blackout_setting = get(dr_dim_gload)
	set(dr_dim_gload, 0)
	-- get_stuff()
	-- update()
end

function onPlaneUnloaded()
	dr_dim_gload = globalPropertyf("sim/graphics/settings/dim_gload")
	set(dr_dim_gload, blackout_setting)
	sim_running = 0
end



function get_stuff()

	sim_acf_pitch = get(dr_acf_pitch) or 0
	sim_acf_roll = get(dr_acf_roll) or 0
	sim_acf_heading = get(dr_acf_heading) or 0
	sim_true_heading = get(dr_true_heading)
	sim_alpha = clamp(get(dr_alpha), -99, 99)
	sim_beta = get(dr_beta)
	sim_airspeed = get(dr_airspeed)	 or 0
	sim_vpath = get(dr_vpath)
	sim_hpath = get(dr_hpath)
	sim_gnrml = get(dr_gnrml) + 0.01
	sim_view_is_external = get(dr_view_is_external)
	sim_mach = get(dr_mach)
	sim_alt = get(dr_alt)
	sim_gear = get(dr_gear_handle)
	sim_gs = math.abs(get(dr_groundspeed) * 1.94)
	sim_radalt = get(dr_radalt) * 3.28
	sim_wow = get(dr_gear_depress, 2) 
	sim_FRP = get(dr_FRP); if sim_FRP == 0 then sim_FRP = 1 end
	sim_wind_dir = get(dr_wind_dir) 
	sim_wind_speed = get(dr_wind_speed) * 1.94
	sim_true_airspeed = get(dr_true_airspeed) 
	sim_acf_rollrate = get(dr_acf_rollrate) 
	sim_acf_pitchrate = get(dr_acf_pitchrate) 
	sim_total_weight_kg = get(dr_total_weight_kg) 
	sim_fuel_weight_kg = get(dr_fuel_weight_kg) 	
	sim_paused = get(dr_paused) 	
	sim_act_target = get(dr_target_index) + 1	
	sim_mis_arm = get(dr_mis_arm) 
	
	sim_acf_roll = sim_acf_roll + sim_acf_rollrate / 20
	sim_acf_pitch = sim_acf_pitch + sim_acf_pitchrate / 20 * math.cos(math.rad(sim_acf_roll))
	
	acf_x, acf_y, acf_z = get(dr_acf_x), get(dr_acf_y), get(dr_acf_z)
	own_pos.x = acf_x
	own_pos.y = acf_y
	own_pos.z = acf_z

end

function update()

	if sim_running == 0 then  sim_running = 1 ; init_stuff(); end
	
	if get(sim_running) == 1 then 
-- print("updating hud"  )
		update_screen_size()
		get_stuff()
		calc_stuff()
		process_targets()
		if sim_view_is_external == 0 then
			hud_subp.visible = true
		else	
			hud_subp.visible = false
			end
		end

end

function calc_stuff()
-- print("calcing" )
	get_yoffset()

	headpos_x, headpos_y, headpos_z = get(dr_pilots_head_x), get(dr_pilots_head_y)-0.60, get(dr_pilots_head_z)+3.99
	cam_x , cam_y , cam_z , cam_pitch , cam_yaw , cam_roll , cam_zoom = sasl.getCamera()
	

	proj_area_pxl	 = {
		-10 / hfov * window_width, 
		-10 / hfov * window_width, 
		20 / hfov * window_width, 
		20 / hfov * window_width 
		}
	
	-- head_pitch_rate = get(dr_pilot_pitch) - head_pitch
	-- head_heading_rate_rate = to_brg(get(dr_pilot_heading) - get(dr_pilot_heading))
	head_pitch = get(dr_pilot_pitch) 
	head_heading = clamp(to_brg(get(dr_pilot_heading)), -90, 90) 
	head_rel_pitch_px = window_center_y + horizon_yoffset -  math.tan(math.rad(head_pitch )) / math.tan(math.rad(hfov/2))/2 * window_width * cam_zoom --* math.tan(math.rad(head_pitch))
	head_rel_heading_px = window_center_x -  math.tan(math.rad(head_heading )) / math.tan(math.rad(hfov/2))/2 * window_width * cam_zoom --* math.tan(math.rad(head_heading))

	
	screen_hdegrees = 32 --1920 / 60 
	screen_vdegrees = 30.016 --1080 / 35.98 
	
	if math.abs(sim_acf_pitch) > 30 then 
		vector_mix = anim(vector_mix, 0, 1)
	else
		vector_mix = anim(vector_mix, 1, 1)
		end
		
	vector_mix = 1 - clamp((math.abs(sim_acf_pitch)-20)/50, 0, 1)

	ver_vector = to_brg(sim_acf_pitch - sim_vpath)  
	hor_vector = to_brg(sim_true_heading - sim_hpath) --* math.cos(math.rad(sim_acf_pitch)) 
	
	vvector = (ver_vector * math.cos(math.rad(sim_acf_roll)) + hor_vector * math.sin(math.rad(sim_acf_roll))) * vector_mix + sim_alpha * (1 - vector_mix)
	hvector = (ver_vector * -math.sin(math.rad(sim_acf_roll)) + hor_vector * math.cos(math.rad(sim_acf_roll))) * vector_mix + sim_beta * (1 - vector_mix)
	
	-- drift_angle = math.deg(math.asin(math.sin(math.rad(sim_true_heading-sim_wind_dir)) * sim_wind_speed / sim_true_airspeed))
	-- -- if sim_acf_pitch > 20 then 
		-- temp_roll = sim_acf_roll * clamp((1 - sim_acf_pitch / 70), 0, 1)
		-- vvector = sim_alpha - drift_angle * math.sin(math.rad(sim_acf_roll)) 
		-- hvector = sim_beta - drift_angle * math.cos(math.rad(sim_acf_roll)) 
		-- -- end

	
	if hud_mode == "to" then
		if sim_radalt > 200 or sim_airspeed > 200 then hud_mode = "flt" end
	elseif hud_mode == "flt" then
		if sim_gear == 1 then hud_mode = "land" end
	elseif hud_mode == "land" then
		if sim_wow > 0 then hud_mode = "to" end
		if sim_gear == 0 then hud_mode = "flt" end
		end
	
	if sim_airspeed < 30 then 
		sim_alpha = 0; 
		sim_beta = 0 
		vvector = 0
		hvector = 0
		hor_vector = 0
		sim_airspeed = 20
		sim_mach = 1
		end
	
	-- ref speeds
	weight_speed = (sim_total_weight_kg - 10000) / 4000 * 30
	landing_speed = 120 + weight_speed
	min_speed = 95 + weight_speed
	rotation_speed = 100 + weight_speed
	if sim_airspeed < 100 then transonic_speed = 660 else transonic_speed = sim_airspeed / sim_mach end
	
	if (math.abs(head_heading) > 15 and head_pitch > -30) or head_pitch > 10 then on_HMD = true else on_HMD = false end
	
	-- metrics conversion
	sim_airspeed_kmh = sim_airspeed * 1.852
	sim_alt_m = sim_alt * 0.3048
	
	-- alt ref poles
	if hud_mode == "land" then
		alt_pole_b = -84.05
	else	
		alt_pole_t = (math.deg(math.atan2((2800),(sim_radalt/3.28 - ref_alt/3.28))) - 90) * screen_vdegrees
		alt_pole_b = (math.deg(math.atan2((2800),(sim_radalt/3.28))) - 90) * screen_vdegrees		
		end
	ref_pole_t = (math.deg(math.atan2((2800),(sim_radalt/3.28 - 100))) - 90) * screen_vdegrees
	ref_pole_b = (math.deg(math.atan2((2800),(sim_radalt/3.28))) - 90) * screen_vdegrees	
	
end


function draw_alt_poles()


	if hud_mode == "land" then	-- Landing mode alt ref poles

		drawWideLine(-120, -89.6, -30, -89.6, 2, hudcol)
		drawWideLine(120, -89.6, 30, -89.6, 2, hudcol)

		drawWideLine(-48, -89.6, -48, alt_pole_b/2 - 89.6, 2, hudcol)
		drawWideLine(48, -89.6, 48, alt_pole_b/2 - 89.6, 2, hudcol)
		
		drawWideLine(-96, -89.6, -96, alt_pole_b - 89.6, 2, hudcol)
		drawWideLine(96, -89.6, 96, alt_pole_b - 89.6, 2, hudcol)

	elseif hud_mode == "flt" and sim_radalt - ref_alt < 1000 then --low alt nav mode ref poles
		-- drawTexturePart(symbols, -7, -8, 14, 14, 208, 8, 14, 14, hudcol)
		
		drawWideLine(-32, alt_pole_t/3, -32, alt_pole_b/3, 2, hudcol)
		drawWideLine(32, alt_pole_t/3, 32, alt_pole_b/3, 2, hudcol)
		
		drawWideLine(-64, alt_pole_t/3*2, -64, alt_pole_b/3*2, 2, hudcol)
		drawWideLine(64, alt_pole_t/3*2, 64, alt_pole_b/3*2, 2, hudcol)
		
		drawWideLine(-96, alt_pole_t, -96, alt_pole_b, 2, hudcol)
		drawWideLine(96, alt_pole_t, 96, alt_pole_b, 2, hudcol)
		end
	
	--300 ft ref poles
	if hud_mode ~= "land" then
		drawWideLine(-101, ref_pole_t, -101, ref_pole_b, 2, hudcol)
		drawWideLine(101, ref_pole_t, 101, ref_pole_b, 2, hudcol)
		end
	
end

function draw_speed_heading()
	
	
	local tmp = 0
-- Heading
			drawRectangle(-90, 30, 150, 30, black)
			drawTexturePart(symbols, -55, 30, 110, 45, 24 + (sim_acf_heading / 360 * 919), 63, 80, 30, hudcol)
			drawTexturePart(symbols, -12, 10, 24, 32, 117, 0, 24, 32, hudcol)
			drawTexturePart(symbols, -90, 35, 22, 22, 141, 8, 16, 16, hudcol)
			
			-- Speed
			drawRectangle(-270, -200, 80, 120, black)
			setClipArea(-270, -200, 100, 120)
			drawTexturePart(symbols, -200, -200, 11, 119, 42, 175 + (sim_airspeed_kmh/10) % 1 * 24, 11, 119, hudcol)
			if sim_airspeed_kmh > 40 then 
				drawTexturePart(symbols, -210, -150, 15, 15, 190, 8, 15, 15, hudcol)
				drawTexturePart(symbols, -225, -154, 13, 20, 7, 126 + sim_airspeed_kmh % 10 * 16, 11, 16, hudcol)
				if sim_airspeed_kmh > 9 then drawTexturePart(symbols, -238, -154, 13, 20, 7, 126 + math.floor(sim_airspeed_kmh/10) % 10 * 16, 11, 16, hudcol) end
				if sim_airspeed_kmh > 99 then drawTexturePart(symbols, -251, -154, 13, 20, 7, 126 + math.floor(sim_airspeed_kmh/100) % 10 * 16, 11, 16, hudcol) end
				if sim_airspeed_kmh > 999 then drawTexturePart(symbols, -264, -154, 13, 20, 7, 126 + math.floor(sim_airspeed_kmh/1000) % 1000 * 16, 11, 16, hudcol) end
			else
				drawTexturePart(symbols, -235, -154, 24, 18, 252, 6, 24, 18, hudcol)
				end
				
			
			-- Ref speeds
			if hud_mode == "land" then
				drawTexturePart(symbols, -193, -150 - (sim_airspeed - landing_speed) * 2.4, 14, 17, 280, 7, 14, 17, hudcol)
			elseif hud_mode == "to" then
				drawTexturePart(symbols, -193, -150 - (sim_airspeed - rotation_speed) * 2.4, 14, 17, 295, 7, 14, 17, hudcol)
				end
			drawTexturePart(symbols, -196, -150 - (sim_airspeed - min_speed) * 2.4, 16, 13, 312, 7, 16, 13, hudcol)
			drawTexturePart(symbols, -192, -150 - (sim_airspeed - transonic_speed) * 2.4, 22, 15, 330, 8, 22, 15, hudcol)
			
			resetClipArea()

				
			
			-- Altimeter
			drawRectangle(186, -200, 80, 120, black)
			setClipArea(200, -200, 70, 120)
			-- if sim_alt_m >= 3000 then 
				-- drawTexturePart(symbols, 200, -200, 11, 119, 69, 172 + (sim_alt_m/200) % 1 * 52, 11, 119, hudcol) --tape
				-- drawTexturePart(symbols, 185, -150, 15, 15, 190, 8, 15, 15, hudcol)
				-- for i = -1, 2, 1 do
					-- alt2 = sim_alt_m + 200 * i
					-- -- if sim_alt - alt2 < 120 and sim_alt - alt2 > -320 then 
						-- if alt2 >= 10000 then drawTexturePart(symbols, 215, -154 - (alt2/200) % 1 * 52 + 52 * i, 13, 20, 7, 126 + math.floor(alt2/10000 + 5000) % 10 * 16, 11, 16, hudcol) end
						-- if alt2 >= 1000 then drawTexturePart(symbols, 226, -154 - (alt2/200) % 1 * 52 + 52 * i, 13, 20, 7, 126 + math.floor(alt2/1000 + 500) % 10 * 16, 11, 16, hudcol) end
						-- drawTexturePart(symbols, 237, -153 - (alt2/200) % 1 * 52 + 52 * i, 5, 5, 9, 367, 5, 5, hudcol) -- dec
						-- drawTexturePart(symbols, 245, -154 - (alt2/200) % 1 * 52 + 52 * i, 13, 20, 7, 126 + math.floor(alt2/200) * 2 % 10 * 16, 11, 16, hudcol)
						-- -- end
					-- end
			-- else
				local yscale = 122 - clamp((sim_alt_m - 100)/1000 * 72, 10, 72)

				local xoffs = 0
				local rez = 100
				for i = -1, 2, 1 do
					xoffs = 0
					alt2 = sim_alt_m + 100 * i
						if alt2 >= 10000 then drawTexturePart(symbols, 210, -155 - (alt2/100) % 1 * yscale + yscale * i, 13, 20, 7, 126 + math.floor(alt2/10000 ) % 10 * 16, 11, 16, hudcol) ; xoffs = xoffs + 11  end
						if alt2 >= 1000 then drawTexturePart(symbols, 210 + xoffs, -155 - (alt2/100) % 1 * yscale + yscale * i, 13, 20, 7, 126 + math.floor(alt2/1000 ) % 10 * 16, 11, 16, hudcol) ; xoffs = xoffs + 11 end
						if alt2 >= 100 then drawTexturePart(symbols, 210 + xoffs, -154 - (alt2/100) % 1 * yscale + yscale * i, 11, 16, 7, 126 + math.floor(alt2/100) % 10 * 16, 11, 16, hudcol) xoffs = xoffs + 11 end
						if alt2 >= 100	then drawTexturePart(symbols, 210 + xoffs, -154 - (alt2/100) % 1 * yscale + yscale * i, 11, 16, 7, 126 , 11, 16, hudcol) ; xoffs = xoffs + 11 end
						drawTexturePart(symbols, 210 + xoffs, -154 - (alt2/100) % 1 * yscale + yscale * i, 11, 16, 7, 126 , 11, 16, hudcol)
						if alt2 <= 1100 then -- 50's increments
							xoffs = -22
							if alt2 >= 200 then  drawTexturePart(symbols, 232 + xoffs, -154 - (alt2/100) % 1 * yscale + yscale * i - yscale / 2, 11, 16, 7, 126 + math.floor(alt2/100 - 1) % 10 * 16, 11, 16, hudcol) else xoffs = -33 end
							drawTexturePart(symbols, 243 + xoffs, -154 - (alt2/100) % 1 * yscale + yscale * i - yscale / 2, 11, 16, 7, 206 , 11, 16, hudcol)
							drawTexturePart(symbols, 254 + xoffs, -154 - (alt2/100) % 1 * yscale + yscale * i - yscale / 2, 11, 16, 7, 126 , 11, 16, hudcol)				
							end
						-- end
						for t = -1, 4 do
							tmp = -146 - (alt2/100) % 1 * yscale + yscale * t / 2
							drawWideLine(200, tmp, 210, tmp, 2, hudcol)
							drawWideLine(205, tmp - yscale / 4, 210, tmp - yscale / 4 , 2, hudcol)
							end 
					end
				-- end
			resetClipArea()
			drawTexturePart(symbols, 185, -150, 15, 15, 190, 8, 15, 15, hudcol)
			

			
			-- G-load
			drawTexturePart(symbols, -240, -69, 16, 16, 156, 8, 16, 16, hudcol)
			if sim_gnrml >= 0 then 
				drawTexturePart(symbols, -215, -70, 11, 16, 7, 126 + math.floor(sim_gnrml) % 10 * 16, 11, 16, hudcol)
				drawTexturePart(symbols, -205, -70, 5, 5, 9, 367, 5, 5, hudcol)
				drawTexturePart(symbols, -200, -70, 11, 16, 7, 126 + math.floor(sim_gnrml * 10) % 10 * 16, 11, 16, hudcol)
			else
				drawTexturePart(symbols, -215, -70, 11, 16, 7, 126 + math.floor(-sim_gnrml+0.01) % 10 * 16, 11, 16, hudcol)
				drawTexturePart(symbols, -205, -70, 5, 5, 9, 367, 5, 5, hudcol)
				drawTexturePart(symbols, -200, -70, 11, 16, 7, 126 + math.floor(-sim_gnrml * 10) % 10 * 16, 11, 16, hudcol)
				drawTexturePart(symbols, -223, -63, 9, 9, 9, 415, 9, 9, hudcol) 
				end
				
			-- Alpha
			drawTexturePart(symbols, -242, -49, 16, 16, 170, 8, 16, 16, hudcol)
			if sim_airspeed > 20 then 
				if sim_alpha >= 0 then 
					if sim_alpha >= 10 then 
						drawTexturePart(symbols, -215, -49, 11, 16, 7, 126 + math.floor(sim_alpha/10) % 10 * 16, 11, 16, hudcol) 
						drawTexturePart(symbols, -203, -49, 11, 16, 7, 126 + math.floor(sim_alpha) % 10 * 16, 11, 16, hudcol)
					else
						drawTexturePart(symbols, -215, -49, 11, 16, 7, 126 + math.floor(sim_alpha) % 10 * 16, 11, 16, hudcol)
						end
				else
					if sim_alpha <= -10 then 
						drawTexturePart(symbols, -215, -49, 11, 16, 7, 126 + math.floor(-sim_alpha/10) % 10 * 16, 11, 16, hudcol) 
						drawTexturePart(symbols, -203, -49, 11, 16, 7, 126 + math.floor(-sim_alpha) % 10 * 16, 11, 16, hudcol)
					else
						drawTexturePart(symbols, -215, -49, 11, 16, 7, 126 + math.floor(-sim_alpha) % 10 * 16, 11, 16, hudcol)
						end
					drawTexturePart(symbols, -223, -43, 9, 9, 9, 415, 9, 9, hudcol) 
					end
			else
				drawTexturePart(symbols, -212, -49, 24, 18, 252, 6, 24, 18, hudcol)
				end
				
			-- Machno
			if sim_airspeed > 20 then 
				drawTexturePart(symbols, -240, -239, 16, 16, 141, 8, 16, 16, hudcol)
				if sim_mach >= 1 then 
					drawTexturePart(symbols, -220, -240, 11, 16, 7, 126 + math.floor(sim_mach+0.01) % 10 * 16, 11, 16, hudcol)
					end
				drawTexturePart(symbols, -210, -240, 5, 5, 9, 367, 5, 5, hudcol)
				drawTexturePart(symbols, -205, -240, 11, 16, 7, 126 + math.floor(sim_mach * 10) % 10 * 16, 11, 16, hudcol)
				drawTexturePart(symbols, -193, -240, 11, 16, 7, 126 + (sim_mach * 100) % 10 * 16, 11, 16, hudcol)
				-- drawTexturePart(symbols, -205, -240, 13, 20, 7, 126 + (sim_mach * 100) % 100 * 16, 11, 16, hudcol)
				end
				
			-- -- Groundspeed
			-- drawTexturePart(symbols, -245, -260, 24, 18, 222, 6, 24, 18, hudcol)
			-- if sim_gs >= 10 then 
				-- drawTexturePart(symbols, -193, -260, 11, 16, 7, 126 + sim_gs % 10 * 16, 11, 16, hudcol)
				-- if sim_airspeed > 9 then drawTexturePart(symbols, -204, -260, 11, 16, 7, 126 + math.floor(sim_gs/10) % 10 * 16, 11, 16, hudcol) end
				-- if sim_airspeed > 99 then drawTexturePart(symbols, -215, -260, 11, 16, 7, 126 + math.floor(sim_gs/100) % 100 * 16, 11, 16, hudcol) end				
			-- else	
				-- drawTexturePart(symbols, -215, -260, 24, 18, 252, 6, 24, 18, hudcol)
				-- end
				
				
			if hud_mode ~= "to" then restoreGraphicsContext() end

	end

function draw_target_marks()

	for i = 2, #target do
		saveGraphicsContext()
		setTranslateTransform(target[i].screen_x, target[i].screen_y)
			if not target[i].clip then
				if target[i].active then 
					sasl.gl.drawWideLine (-20, -20, 20, -20, 2, hudcol )
					sasl.gl.drawWideLine (20, 20, 20, -20, 2, hudcol )
					sasl.gl.drawWideLine (-20, 20, 20, 20, 2, hudcol )
					sasl.gl.drawWideLine (-20, 20, -20, -20, 2, hudcol )

					sasl.gl.drawWideLine (20, 0, 25, 0, 2, hudcol )
					sasl.gl.drawWideLine (25, 0, 25, clamp(target[i].roc / 10, -20, 20), 2, hudcol )
					
					-- sasl.gl.drawCircle(target[i].aim_screen_x - target[i].screen_x, target[i].aim_screen_y - target[i].screen_y, 10, false, hudcol)
										
				else
					sasl.gl.drawWideLine (-10, 0, 0, 10, 2, hudcol )
					sasl.gl.drawWideLine (10, 0, 0, 10, 2, hudcol )
					sasl.gl.drawWideLine (0, -10, -10, 0, 2, hudcol )
					sasl.gl.drawWideLine (0, -10, 10, 0, 2, hudcol )
					end
			else
				setRotateTransform(target[i].dir)
				setTranslateTransform(0, -40)
				-- if target[i].active then 
					-- sasl.gl.drawWideLine (0, 0, 0, -20 - math.abs(to_brg(target[i].brg - sim_true_heading))/2, 2,  hudcol )
				-- else
					-- sasl.gl.setLinePattern ({5.0 , -5.0 })
					drawWideLine (0, 20, 0, 40 + math.abs(to_brg(target[i].brg - sim_true_heading))/2, 2, hudcol )
					drawWidePolyLine ({0, 0, -5, 10, 0, 20, 5, 10, 0, 0}, 2, hudcol )
					-- end
				-- sasl.gl.drawWideLine (0, 0, -4, -15, 2,  hudcol )
				-- sasl.gl.drawWideLine (0, 0, 4, -15, 2,  hudcol )
				end
			restoreGraphicsContext()
			end

end

function draw()

	if get(sim_running) == 1 and hud_subp.visible then
		-- print("drawing " .. rendertarget )
	
	-- print("sim_running " .. sim_running)

		--***********************************************************************--		
		--************************* pre-render stuff ****************************--
		--***********************************************************************--		
		setRenderTarget(rendertarget, true, 3)
		
		-- restoreGraphicsContext()
		resetBlending()
		saveGraphicsContext()
			
			setTranslateTransform(512, 512)

			saveGraphicsContext()
			
				--hemispheral pitch ladder
				setRotateTransform(-sim_acf_roll)
				setTranslateTransform(0, -sim_acf_pitch * screen_vdegrees)
				
				
				-- upper hemisphere
				setTranslateTransform(0, 90 * screen_vdegrees)
				setRotateTransform(sim_acf_heading)
				drawTexture(horiz1, -2425, -2425, 4850, 4850, hudcol )
				setRotateTransform(-sim_acf_heading)
				
				-- lower hemisphere
				-- setBlendFunction(BLEND_SOURCE_COLOR, BLEND_DESTINATION_ALPHA)
				setTranslateTransform(0, -180 * screen_vdegrees)
				setRotateTransform(-sim_acf_heading)
				drawTexture(horiz2, -2425, -2425, 4850, 4850, hudcol)
				-- resetBlending()
		
				restoreGraphicsContext()
			
			-- pitch digits
			saveGraphicsContext()
				setRotateTransform(-sim_acf_roll)
				setTranslateTransform(0, -sim_acf_pitch * screen_vdegrees)
				setTranslateTransform(0, 90 * screen_vdegrees)
				setRotateTransform(-3)
				for i = 80.5, 20, -9.95 do 
					drawTexturePart(symbols, -15, -9 - i * screen_vdegrees , 29, 18, 516, 474 - i * 2.2, 29, 18, hudcol)
					end
				setRotateTransform(3)
				setTranslateTransform(0, -180 * screen_vdegrees)
				setRotateTransform(3)
				for i = 80, 20, -9.95 do 
					drawTexturePart(symbols, -15, -35 + i * screen_vdegrees , 29, 18, 516, 79 + i * 2.2, 29, 18, hudcol)
					end
				restoreGraphicsContext()
				
			-- horizon line
			saveGraphicsContext()
				setRotateTransform(-sim_acf_roll)
				setTranslateTransform(-hor_vector * screen_hdegrees, -sim_acf_pitch * screen_vdegrees)
				-- drawTexturePart(symbols, -273, -5, 542, 10, 0, 40, 542, 10, hudcol)
				drawWideLine(-400, 0, -50, 0, 2, hudcol)
				drawWideLine(400, 0, 50, 0, 2, hudcol)
				
			-- heading notches
			local tempheading 
			for i = -2, 2 do
				tempheading = ((sim_acf_heading - hor_vector) % 5 + 5 * i) * screen_hdegrees
				drawWideLine(-tempheading, 0, -tempheading, 5, 3, hudcol)
				end
			for i = -3, 2 do
				tempheading = ((sim_acf_heading - hor_vector) % 0.5 + 0.5 * i) * screen_hdegrees
				drawWideLine(-tempheading, -1, -tempheading, 2, 3, hudcol)
				end
				
			draw_alt_poles()
				

			
				restoreGraphicsContext()


			-- velocity vector
			saveGraphicsContext()
				if hud_mode ~= "to" then 
					setTranslateTransform(-hvector * screen_hdegrees, clamp(-vvector, -11, 5) * screen_vdegrees)
					if hud_mode == "land" then 
						local offs = clamp((sim_airspeed - landing_speed), -50, 50) / 2
						sasl.gl.drawWideLine(0, 7+offs, 0, 20+offs, 2, hudcol)
					else
						sasl.gl.drawWideLine(0, 7, 0, 20, 2, hudcol)
						end
					drawTexturePart(symbols, -27, -17, 54, 35, 0, 0, 52, 36, hudcol)
					if vvector >= 11 then 
						drawRectangle(-10, -10, 20, 18, black)
						end
					end
			
				restoreGraphicsContext()
			
			
			if hud_mode ~= "to" then 
				saveGraphicsContext()
				setTranslateTransform(clamp(-hvector, -3, 3) * screen_hdegrees, 130 + clamp(-vvector, -5.5, 1) * screen_vdegrees)
				end				
		
			-- speed & heading
			draw_speed_heading()	
			
			-- Bore sight
			if hud_mode == "to" then
				local offs = clamp((sim_airspeed - rotation_speed), -40, 40) 
				sasl.gl.drawWideLine(-30, 0, -15, 0, 2, hudcol)
				sasl.gl.drawWideLine(30, 0, 15, 0, 2, hudcol)
				sasl.gl.drawWideLine(0, 10+offs, 0, 25+offs, 2, hudcol)
				end
			
			
			-- Radar target marks
			draw_target_marks()
				
				
			-- Missile cue
			if sim_mis_arm == 1 and hud_mode == "flt" then 
				sasl.gl.drawWidePolyLine (ase_circle , 2, hudcol )
				sasl.gl.drawWidePolyLine (range_circle , 4, hudcol )
				if sim_act_target >= 2 then 
					saveGraphicsContext()
						setRotateTransform(meteor_range/100*360*0.4)
						drawWidePolyLine({-5, 119, 0, 112, 5, 119}, 2, hudcol)
						setRotateTransform(meteor_range/100*360*0.6)
						drawWidePolyLine({-5, 119, 0, 112, 5, 119}, 2, hudcol)		
						restoreGraphicsContext()
					end
				end

			restoreGraphicsContext()
		
		--************************* Masking ****************************--
		saveGraphicsContext()
		
			setTranslateTransform(510 - headpos_x * 3400, 520 - headpos_y * 3400)
			setScaleTransform(1 - headpos_z * 2, 1 - headpos_z * 2)
			
			drawTexturePart(symbols, 
				-562 ,
				-437 , 
				1125, 
				875, 
				550, 94, 474, 361, {1, 1, 1, 1})
			drawRectangle (-962, -437, 420, 1024 , {0,0,0,1} )
			drawRectangle (562, -437, 250, 1024 , {0,0,0,1} )
			drawRectangle (-762, 350, 1524, 400 , {0,0,0,1} )
			drawRectangle (-762, -700, 1524, 300 , {0,0,0,1} )


			restoreGraphicsContext()
			
		resetBlending()

		restoreRenderTarget()

		--******************************************************************************--	
		--************************* generate blur ****************************--
		--******************************************************************************--	
		
		setRenderTarget(renderblur, true, 0)
			drawTexture(rendertarget, 0, 0, 128, 128, {1, 1, 1, 1})		
		restoreRenderTarget()

		--******************************************************************************--	
		--************************* draw pre-rendered stuff ****************************--
		--******************************************************************************--	
		
		saveGraphicsContext()
		hfov2 = (hfov/60)^1.6	; if hfov < 60 then hfov2 = hfov/60 end
		setTranslateTransform(head_rel_heading_px, head_rel_pitch_px)

		setScaleTransform(cam_zoom / hfov2 * window_width / 1920, cam_zoom / hfov2 * window_width / 1920)

		setBlendFunction(BLEND_SOURCE_COLOR, BLEND_DESTINATION_ALPHA)
		drawTexture(renderblur, -512, -512, 1024, 1024, {1, 1, 1, 1.0})
		drawTexture(rendertarget, -512, -512, 1024, 1024, {1, 0.85, 1, 1.0})
		-- drawTexture(rendertarget, -512, -512, 1024, 1024, {1.0, 1.0, 1.0, 1.0})

		-- drawTexture(symbols, -512, -512, 1024, 1024)

		resetBlending()
		restoreGraphicsContext()
		end
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