----------------------------------------------------------
--- FLIGHT CONTROL SCRIPT by Nils Danielsson, (c)2019 ----
----------------------------------------------------------


dr_FRP = XLuaFindDataRef("sim/operation/misc/frame_rate_period")
dr_gear_handle = XLuaFindDataRef("sim/cockpit2/controls/gear_handle_down")
dr_groundspeed = XLuaFindDataRef("sim/flightmodel/position/groundspeed") 
dr_tail_gear_depress = XLuaFindDataRef("sim/flightmodel/parts/tire_vrt_def_veh[0]") 
dr_left_gear_depress = XLuaFindDataRef("sim/flightmodel/parts/tire_vrt_def_veh[1]") 
dr_right_gear_depress = XLuaFindDataRef("sim/flightmodel/parts/tire_vrt_def_veh[2]") 

dr_override_flightcontrol = XLuaFindDataRef("sim/operation/override/override_flightcontrol") 
dr_override_surfaces = XLuaFindDataRef("sim/operation/override/override_control_surfaces") 
dr_yoke_roll_ratio = XLuaFindDataRef("sim/joystick/yoke_roll_ratio") 
dr_yoke_heading_ratio = XLuaFindDataRef("sim/joystick/yoke_heading_ratio") 
dr_yoke_pitch_ratio = XLuaFindDataRef("sim/joystick/yoke_pitch_ratio") 
dr_FC_hdng = XLuaFindDataRef("sim/joystick/FC_hdng") 
dr_FC_ptch = XLuaFindDataRef("sim/joystick/FC_ptch") 
dr_FC_roll = XLuaFindDataRef("sim/joystick/FC_roll") 
dr_override_prop_pitch = XLuaFindDataRef("sim/operation/override/override_prop_pitch") 
dr_prop_pitch_0 = XLuaFindDataRef("sim/flightmodel/engine/POINT_pitch_deg_use[0]") 
dr_prop_pitch_1 = XLuaFindDataRef("sim/flightmodel/engine/POINT_pitch_deg_use[1]") 
dr_prop_pitch_2 = XLuaFindDataRef("sim/flightmodel/engine/POINT_pitch_deg_use[2]") 
dr_collective_angle_req = XLuaFindDataRef("sim/cockpit2/engine/actuators/prop_pitch_deg[0]") 
dr_pusher_angle_req = XLuaFindDataRef("sim/cockpit2/engine/actuators/prop_pitch_deg[2]") 
dr_override_artstab = XLuaFindDataRef("sim/operation/override/override_artstab") 
dr_acf_pitch = XLuaFindDataRef("sim/flightmodel/position/theta") 
dr_acf_roll = XLuaFindDataRef("sim/flightmodel/position/phi") 
dr_acf_hdg = XLuaFindDataRef("sim/flightmodel/position/psi") 
dr_acf_rollrate = XLuaFindDataRef("sim/flightmodel/position/P") 
dr_acf_pitchrate = XLuaFindDataRef("sim/flightmodel/position/Q") 
dr_acf_yawrate = XLuaFindDataRef("sim/flightmodel/position/R") 
dr_acf_rollrate_acc = XLuaFindDataRef("sim/flightmodel/position/P_dot") 
dr_acf_pitchrate_acc = XLuaFindDataRef("sim/flightmodel/position/Q_dot") 
dr_acf_yawrate_acc = XLuaFindDataRef("sim/flightmodel/position/R_dot") 
dr_airspeed_kts_pilot = XLuaFindDataRef("sim/cockpit2/gauges/indicators/airspeed_kts_pilot") 
dr_true_airspeed = XLuaFindDataRef("sim/flightmodel/position/true_airspeed") 
dr_flight_elapsed = XLuaFindDataRef("sim/time/total_flight_time_sec") 
dr_artstab_heading_ratio = XLuaFindDataRef("sim/joystick/artstab_heading_ratio") 
dr_joystick_axis_values_0 = XLuaFindDataRef("sim/joystick/joystick_axis_values[0]") 
dr_slip_deg = XLuaFindDataRef("sim/cockpit2/gauges/indicators/slip_deg") 
dr_beta = XLuaFindDataRef("sim/flightmodel/position/beta") 
dr_vvi_fpm_pilot = XLuaFindDataRef("sim/cockpit2/gauges/indicators/vvi_fpm_pilot") 
dr_alpha = XLuaFindDataRef("sim/flightmodel/position/alpha") 
dr_g_nrml = XLuaFindDataRef("sim/flightmodel/forces/g_nrml") 
dr_g_side = XLuaFindDataRef("sim/flightmodel/forces/g_side") 
dr_hpath = XLuaFindDataRef("sim/flightmodel/position/hpath") 
dr_acf_stall_warn_alpha = XLuaFindDataRef("sim/aircraft/overflow/acf_stall_warn_alpha") 
dr_artstab_pitch_ratio = XLuaFindDataRef("sim/joystick/artstab_pitch_ratio") 
dr_artstab_roll_ratio = XLuaFindDataRef("sim/joystick/artstab_roll_ratio") 
dr_machno = XLuaFindDataRef("sim/flightmodel/misc/machno") 
dr_sigma = XLuaFindDataRef("sim/weather/sigma") 
dr_N_plug = XLuaFindDataRef("sim/flightmodel/forces/N_plug_acf")
dr_L_plug = XLuaFindDataRef("sim/flightmodel/forces/L_plug_acf")
dr_M_plug = XLuaFindDataRef("sim/flightmodel/forces/M_plug_acf")
dr_vpath = XLuaFindDataRef("sim/flightmodel/position/vpath")
dr_hpath = XLuaFindDataRef("sim/flightmodel/position/hpath")
dr_psi = XLuaFindDataRef("sim/flightmodel/position/psi")
dr_faxil_plug_acf = XLuaFindDataRef("sim/flightmodel/forces/faxil_plug_acf")
dr_fnrml_plug_acf = XLuaFindDataRef("sim/flightmodel/forces/fnrml_plug_acf")

dr_left_elevator = XLuaFindDataRef("sim/flightmodel/controls/wing1l_ail1def")
dr_right_elevator = XLuaFindDataRef("sim/flightmodel/controls/wing1r_ail1def")
dr_left_aileron = XLuaFindDataRef("sim/flightmodel/controls/wing1l_ail2def")
dr_right_aileron = XLuaFindDataRef("sim/flightmodel/controls/wing1r_ail2def")
dr_left_canard = XLuaFindDataRef("sim/flightmodel/controls/wing2l_elv2def")
dr_right_canard = XLuaFindDataRef("sim/flightmodel/controls/wing2r_elv2def")
dr_vstab = XLuaFindDataRef("sim/flightmodel/controls/vstab1_rud1def")
dr_gear_deploy = XLuaFindDataRef("sim/aircraft/parts/acf_gear_deploy[1]")
dr_N1 = XLuaFindDataRef("sim/flightmodel/engine/ENGN_N1_[0]")
dr_braking_ratio = XLuaFindDataRef("sim/cockpit2/controls/parking_brake_ratio")
dr_burner_ratio = XLuaFindDataRef("sim/flightmodel2/engines/afterburner_ratio[0]")
dr_elevation =  XLuaFindDataRef("sim/flightmodel/position/elevation")
dr_override_engines =  XLuaFindDataRef("sim/operation/override/override_engines")
dr_faxil_prop =  XLuaFindDataRef("sim/flightmodel/forces/faxil_prop")
dr_POINT_thrust =  XLuaFindDataRef("sim/flightmodel/engine/POINT_thrust[0]")
dr_ecam_mode =  XLuaFindDataRef("sim/cockpit2/EFIS/ecam_mode")


dr_gripen_le_flap = create_dataref("gripen/le_flap","number") 
dr_gripen_nozzle = create_dataref("gripen/nozzle","number")

dr_view_type =  XLuaFindDataRef("sim/graphics/view/view_type")
dr_gripen_view_is_static = create_dataref("gripen/view_is_static","number")
dr_gripen_view_distance = create_dataref("gripen/view_distance","number")
dr_gripen_view_relspeed = create_dataref("gripen/view_relspeed","number")
dr_view_x = XLuaFindDataRef("sim/graphics/view/view_x")
dr_view_y = XLuaFindDataRef("sim/graphics/view/view_y")
dr_view_z = XLuaFindDataRef("sim/graphics/view/view_z")
dr_acf_x = XLuaFindDataRef("sim/flightmodel/position/local_x")
dr_acf_y = XLuaFindDataRef("sim/flightmodel/position/local_y")
dr_acf_z = XLuaFindDataRef("sim/flightmodel/position/local_z")



dr_gripen_print = create_dataref("gripen/print","number") 


--*****************************MISC FUNCTIONS********************************--
function clamp(inval, minv, maxv)

	if inval > maxv then return maxv
	elseif inval < minv then return minv
	else return inval
		end

end


--*****************************UTILITIES********************************--
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
--*************************************************************************************--

--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

g_set_collective = 0.0
g_min_coll = -6	; g_max_coll = 16
g_pitch_tgt = 0
g_pitchr_tgt = 0
g_roll_tgt = 0
g_rollr_tgt = 0
g_pitch_trim = 0 
g_pitch_d = 0 
g_pitch_rlim = 0 
g_turn_comp = 0 
g_roll_trim = 0 
g_roll_d = 0 
g_yawr_tgt = 0
g_yaw_d = 0
g_yaw_trim = 0
g_wow = 1
g_wow_anim = 0
g_yaw_turncoord1 = 0
g_pitch_hold = 0
g_pitch_overbank = 0
g_coll_d_helo = 0
g_coll_d_airplane = 0
g_coll_d_mix = 0
g_coll_d_mix_tgt = 0
g_coll_trim = 0
g_push_rst = 0
g_lon_gs = 0
g_lat_gs = 0
g_aoa_lmt = 12
g_aoa_cmd = 0
sim_alpha_mem = 0
sim_beta_mem = 0
sim_alpha_rate = 0
sim_beta_rate = 0
sim_as_rate = 0
sim_as_mem = 0
sim_gnrmal_rate = 0
sim_gnrmal_mem = 0

g_att_rate = 0
g_att_mem = 0
g_nrm_yaw_rate = 0
sim_vpath_mem = 0


local burner_add = 0


function flight_start() 
	dr_fuel1 =  XLuaFindDataRef("sim/flightmodel/weight/m_fuel1")
	dr_fuel2 =  XLuaFindDataRef("sim/flightmodel/weight/m_fuel2")
	XLuaSetNumber(dr_fuel1, 1600) 
	XLuaSetNumber(dr_fuel2, 1600) 
	XLuaSetNumber(dr_override_surfaces, 1) 
	XLuaSetNumber(dr_ecam_mode, 1) 

	
end

g_view_dist_mem = 0

function sound_stuff()

	sim_view_type = XLuaGetNumber(dr_view_type )
	if sim_view_type == 1014 or sim_view_type == 1015 or sim_view_type == 1020 or sim_view_type == 1028 then
		dr_gripen_view_is_static = clamp(sim_airspeed_kts_pilot / 400, 0, 1)
	else
		dr_gripen_view_is_static = 0
		end

end

function get_drefs()

	local getnumber = XLuaGetNumber

	sim_left_gear_depress = getnumber(dr_left_gear_depress)
	sim_right_gear_depress = getnumber(dr_right_gear_depress)
	sim_tail_gear_depress = getnumber(dr_tail_gear_depress)
	-- sim_yoke_pitch_ratio = math.floor(getnumber(dr_yoke_pitch_ratio) * 5 + 0.5) / 5
	-- sim_yoke_roll_ratio = math.floor(getnumber(dr_yoke_roll_ratio) * 5 + 0.5) / 5
	sim_yoke_pitch_ratio = getnumber(dr_yoke_pitch_ratio) 
	sim_yoke_roll_ratio = getnumber(dr_yoke_roll_ratio) 
	sim_yoke_heading_ratio = getnumber(dr_yoke_heading_ratio)
	sim_acf_pitchrate = getnumber(dr_acf_pitchrate)
	sim_acf_rollrate = getnumber(dr_acf_rollrate)
	sim_acf_yawrate = getnumber(dr_acf_yawrate)
	sim_acf_pitchrate_acc = getnumber(dr_acf_pitchrate_acc)
	sim_acf_rollrate_acc = getnumber(dr_acf_rollrate_acc)
	sim_acf_yawrate_acc = getnumber(dr_acf_yawrate_acc)
	sim_FRP = getnumber(dr_FRP); if sim_FRP == 0 then sim_FRP = 1 end
	sim_acf_pitch = getnumber(dr_acf_pitch)
	sim_acf_roll = getnumber(dr_acf_roll)
	sim_airspeed_kts_pilot = getnumber(dr_airspeed_kts_pilot)
	sim_flight_elapsed = getnumber(dr_flight_elapsed)
	sim_FC_ptch = getnumber(dr_FC_ptch)
	sim_FC_roll = getnumber(dr_FC_roll)
	sim_FC_hdng = getnumber(dr_FC_hdng)
	sim_collective_angle_req = getnumber(dr_joystick_axis_values_0)
	sim_true_airspeed = getnumber(dr_true_airspeed); 		if sim_true_airspeed == 0 then sim_true_airspeed = 1 end
	sim_slip_deg = getnumber(dr_slip_deg)
	sim_groundspeed = math.abs(getnumber(dr_groundspeed) * 1.94)
	sim_beta = getnumber(dr_beta)
	sim_vvi_fpm_pilot = getnumber(dr_vvi_fpm_pilot)
	sim_alpha = getnumber(dr_alpha)
	sim_prop_pitch_0 = getnumber(dr_prop_pitch_0)
	sim_prop_pitch_1 = getnumber(dr_prop_pitch_1)
	sim_g_nrml = getnumber(dr_g_nrml)
	sim_g_side = getnumber(dr_g_side)
	sim_prop_pitch_2 = getnumber(dr_prop_pitch_2)
	sim_dr_hpath = getnumber(dr_hpath)
	sim_acf_hdg = getnumber(dr_acf_hdg)
	sim_machno = getnumber(dr_machno); if sim_machno == 0 then sim_machno = 1 end
	sim_sigma = getnumber(dr_sigma)
	sim_gear_handle = getnumber(dr_gear_handle)
	sim_vpath = getnumber(dr_vpath)
	sim_hpath = getnumber(dr_hpath)
	sim_psi = getnumber(dr_psi)
	sim_N1 = getnumber(dr_N1)
	sim_braking_ratio = getnumber(dr_braking_ratio)
	sim_burner_ratio = getnumber(dr_burner_ratio)
	sim_elevation = getnumber(dr_elevation) * 3.28
	sim_thrust_lbs = getnumber(dr_POINT_thrust) / 4.45	

		
	sim_left_elevator = getnumber(dr_left_elevator)
	sim_right_elevator = getnumber(dr_right_elevator)
	sim_left_aileron = getnumber(dr_left_aileron )
	sim_right_aileron = getnumber(dr_right_aileron )
	sim_left_canard = getnumber(dr_left_canard )
	sim_right_canard = getnumber(dr_right_canard )
	sim_vstab = getnumber(dr_vstab )
	sim_gear_deploy = getnumber(dr_gear_deploy )

	

	
end

	g_alpha_filtered = 0
	g_beta_filtered = 0
	
	g_ftim = 0
	g_beta_rate_mem = 0
	g_beta = 0 
	g_beta_rate = 0
	gnd_spoiler = 0

function before_physics() 
	local lclamp = clamp
	local ipol = interpolate

	get_drefs()
	sound_stuff()

	thrust_sea = interpolate(sim_machno, {0, 0.4, 0.8, 1.2, 1.4, 1.6, 2.0}, {1, 	1.12, 	1.5, 	2.2, 	1.20, 	0.66, 0.36}, 7) 
	-- thrust_10k = interpolate(sim_machno, {0, 0.4, 0.8, 1.2, 1.4, 1.6, 2.0}, {0.77, 	0.85, 	1.3, 	1.5, 	1.13, 	0.95, 0.66}, 7) 
	-- thrust_20k = interpolate(sim_machno, {0, 0.4, 0.8, 1.2, 1.4, 1.6, 2.0}, {0.55, 	0.62, 	0.9, 	1.02, 	1.09, 	0.95, 0.73}, 7) 
	-- thrust_30k = interpolate(sim_machno, {0, 0.4, 0.8, 1.2, 1.4, 1.6, 2.0}, {0.33, 	0.4, 	0.61, 	0.73, 	0.88, 	0.91, 0.69}, 7) 
	thrust_40k = interpolate(sim_machno, {0, 0.4, 0.8, 1.2, 1.4, 1.6, 2.0}, {0.22, 	0.3, 	0.50, 	0.5, 	0.5, 	0.5, 0.50}, 7) 
	thrust_60k = interpolate(sim_machno, {0, 0.4, 0.8, 1.2, 1.4, 1.6, 2.0}, {0.04, 	0.15, 	0.2, 	0.2, 	0.15, 	0.15, 0.15}, 7) 
	
	-- max_thrust_rat = interpolate(sim_elevation, {0, 10000, 20000, 30000, 40000, 60000}, {thrust_sea, thrust_10k, thrust_20k, thrust_30k, thrust_40k, thrust_60k}, 6) 
	max_thrust_rat = interpolate(sim_elevation, {0, 40000, 60000}, {thrust_sea, thrust_40k, thrust_60k}, 3) 

	g_mach_washout = lclamp(1.0 - (sim_airspeed_kts_pilot / 655), 0.2, 1)
	
	if sim_airspeed_kts_pilot < 1 then sim_airspeed_kts_pilot = 1 end

	if (sim_left_gear_depress + sim_right_gear_depress) > 0 then 
		g_wow = 1 
		g_wow_anim = anim(g_wow_anim, g_wow, 2)
	else 
		g_wow = 0 
		g_wow_anim = anim(g_wow_anim, g_wow, 0.5)
		end

	
		-- flight model hack: simulate energized vortex flow over stabs at high alpha -----
	XLuaSetNumber(dr_N_plug, (sim_vstab/5 - sim_beta/5) * 15000 * lclamp(sim_alpha/20, 0, 1) * lclamp((sim_airspeed_kts_pilot/200), 0, 1))
	XLuaSetNumber(dr_L_plug, (sim_left_aileron - sim_right_aileron)/2 * 20000 * lclamp(sim_alpha/20, 0, 1) * lclamp((sim_airspeed_kts_pilot/100), 0, 1))
	XLuaSetNumber(dr_M_plug, 140000 * lclamp((sim_alpha + sim_left_canard) / 20, -1, 1) * (sim_airspeed_kts_pilot/200))-- + ipol(sim_alpha, {0, 5, 20, 30}, {0, 60000, 12000, 0}, 4) * (sim_airspeed_kts_pilot/300)^2)-- * lclamp((sim_airspeed_kts_pilot/100), 0, 1))-- + sim_FC_ptch * 600000 * lclamp(sim_alpha/30, 0, 1) * lclamp((sim_airspeed_kts_pilot/100), 0, 1))
	add_lift = 50000 * sim_gear_deploy * (sim_alpha / 15) * lclamp((sim_airspeed_kts_pilot/130)^2, 0, 1) + (sim_alpha / 20)^2 * 200000 * (sim_airspeed_kts_pilot/300)^2
	XLuaSetNumber(dr_fnrml_plug_acf, add_lift)
	
	burner_add = 6100 + sim_elevation/10 + sim_machno 
	tgt_thrust_lbs = (max_thrust_rat * lclamp(sim_N1 / 100, 0, 1)^3 * 12000 + max_thrust_rat * sim_burner_ratio * burner_add)
	XLuaSetNumber(dr_faxil_plug_acf, (tgt_thrust_lbs - sim_thrust_lbs) * -4.45 + ipol(sim_machno, {1.0, 1.2, 1.6, 2.0}, {0, -25000, -33000, -43000}, 3)  + add_lift / 10)


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
	sim_as_rate = (sim_airspeed_kts_pilot - sim_as_mem) / lclamp(sim_FRP, 0.001, 0.5)
	sim_as_mem = sim_airspeed_kts_pilot	
	
	-- sim_vpath_rate = (sim_vpath - sim_vpath_mem) / lclamp(sim_FRP, 0.001, 0.5)
	-- sim_vpath_mem = sim_vpath
	
	grav = math.cos(math.rad(sim_acf_roll)) * math.cos(math.rad(sim_acf_pitch))
	grav2 = math.cos(math.rad(sim_acf_roll - 90)) * math.cos(math.rad(sim_acf_pitch)) 

	sim_alpha_rate = ((sim_acf_pitchrate * ((sim_true_airspeed ) * 3.14159) / 180 / 9.81) - sim_g_nrml + grav) * 1.5 * g_mach_washout
	g_alpha_filtered = g_alpha_filtered + (sim_alpha - g_alpha_filtered) / 50  + sim_alpha_rate * 4 * sim_FRP -- sim_as_rate * sim_FRP * 0.1
			dr_f35_alpha = sim_alpha - g_alpha_filtered	
	sim_alpha = g_alpha_filtered

	sim_beta_rate = ((sim_acf_yawrate * (sim_true_airspeed * 3.14159) / 180 / 9.81) - sim_g_side - grav2) * 5

	sim_beta = (sim_g_side * 40 - grav2) * ipol(sim_airspeed_kts_pilot, {150, 300, 450, 600}, {1.6, 0.23, 0.2, 0.1}, 4) 

		dr_f35_beta = grav2
		
	-- sim_beta = sim_beta_rate
	

		
	sim_gnrmal_rate = (sim_g_nrml - sim_gnrmal_mem) / lclamp(sim_FRP, 0.001, 0.5)
	sim_gnrmal_mem = sim_g_nrml
	
	if XLuaGetNumber(dr_alpha) > 23 then 
		sim_alpha = XLuaGetNumber(dr_alpha)	
		end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
	hi_alpha_boost = 1 + lclamp(sim_alpha/20, 0, 1) * 2

	-- pitch laws ----------------------
	rlx = math.abs(sim_acf_roll / 180) * math.cos(math.rad(sim_acf_pitch)) 
	if sim_yoke_pitch_ratio > 0 then g_command_g = sim_yoke_pitch_ratio * (lclamp((sim_airspeed_kts_pilot/300) * 9, 1.5, 9) - rlx) else g_command_g = 0 + sim_yoke_pitch_ratio * ( lclamp(sim_airspeed_kts_pilot/300, 0, 1) * 4 -rlx) end

	if sim_machno > 0.95 and sim_machno < 1.05 and g_command_g > 7 then g_command_g = 7 end
	g_command_g = g_command_g + rlx

	max_pitch_rate = 35
	g_command_pitch_rate = lclamp((180 * 9.81 * g_command_g)/((sim_true_airspeed ) * 3.14159), -10, max_pitch_rate)--lclamp(60 - math.abs(sim_alpha), 10, 40))

	g_command_pitch = 	((g_command_pitch_rate - sim_acf_pitchrate) * 0.02 ) - (sim_acf_pitchrate_acc * 0.01 * lclamp(1 - sim_airspeed_kts_pilot/300, 0, 1)) 
	

	
	if g_wow == 0 then 
		if sim_alpha > 0 then g_aoa_limit = 26 - math.abs(sim_yoke_roll_ratio) * 4 else g_aoa_limit = -10 end
		g_aoa_command = (g_aoa_limit - sim_alpha) * 0.03 - sim_alpha_rate * 0.3 --* g_mach_washout 
		if (sim_alpha > 0 and g_command_pitch > g_aoa_command) or (sim_alpha < 0 and g_command_pitch < g_aoa_command) then 
			g_command_pitch = g_aoa_command 
			end
		end
	
	g_command_pitch = (g_command_pitch * g_mach_washout) * (1-g_wow_anim) + (sim_yoke_pitch_ratio - sim_acf_pitchrate * 0.1 - sim_acf_pitch * 0.01) * g_wow_anim

	if g_wow == 0 then 
		g_pitch_trim = lclamp(g_pitch_trim + g_command_pitch * sim_FRP * 7 , -1, 1) 
	else
		g_pitch_trim = anim(g_pitch_trim, 0, 0.2)
		end
	
	
	-- roll laws -----------------------
	roll_choke = lclamp((1 - sim_alpha/38) * (sim_airspeed_kts_pilot / 300), 0.1, 1) 
	g_rollr_tgt = sim_yoke_roll_ratio * 250 * roll_choke-- lclamp(sim_airspeed_kts_pilot * 0.8 * lclamp(1 - sim_alpha/60, 0.2, 1), 15, 250)
	g_command_roll = (sim_yoke_roll_ratio * 0.3 * roll_choke + (g_rollr_tgt - sim_acf_rollrate) * 0.01) * g_mach_washout 
	g_roll_trim = lclamp((g_roll_trim + g_rollr_tgt - sim_acf_rollrate) * sim_FRP * g_mach_washout / 2 , -0.25, 0.25)
	
	-- yaw laws ------------------------
	g_command_heading = ((sim_yoke_heading_ratio * 10 - sim_beta) * (0.02) - sim_beta_rate * 0.02) * g_mach_washout * hi_alpha_boost-- (sim_acf_yawrate * 0.05 * lclamp(1 - sim_airspeed_kts_pilot/100, 0, 1))
	if math.abs(g_command_g) < 2 and math.abs(sim_acf_roll) < 10 and math.abs(sim_acf_pitch) < 13 and math.abs(sim_yoke_roll_ratio) < 0.1  then 
		g_command_heading = g_command_heading - sim_acf_yawrate * 0.1 * g_mach_washout
		end
	g_yaw_trim = lclamp((g_yaw_trim + g_command_heading) * sim_FRP * 10 * g_mach_washout, -1, 1) 
	g_yaw_roll = g_rollr_tgt * 0.017 * lclamp( sim_alpha/20, -1 , 1) * g_mach_washout	--g_command_roll * math.sin(math.rad(sim_alpha)) * 3 --+ sim_yoke_roll_ratio * lclamp(1 - sim_airspeed_kts_pilot/300, 0, 0.3)
	g_command_heading = g_command_heading + sim_yoke_heading_ratio * 0.3
	if g_wow == 1 then g_command_heading = sim_yoke_heading_ratio - sim_acf_yawrate * 0.1 end
	
	-- set flight controls -------------
	XLuaSetNumber(dr_override_surfaces, 1) 
	fc_pitch = (g_command_pitch + g_pitch_trim + sim_yoke_pitch_ratio * 0.1) * 45
	fc_roll = (g_command_roll + g_roll_trim) * 20
	fc_yaw = (g_command_heading + g_yaw_trim + g_yaw_roll) * 25
	lowspeed_flap =  -fc_pitch  + ipol(sim_alpha, {5, 10, 20, 30}, {0, 10, 15, 0}, 4) 
	down_lmt = 20 * lclamp(1 - sim_alpha / 20, 0, 1)
	landing_flap = sim_gear_deploy * 20 * (1 - g_wow_anim) * ipol(sim_airspeed_kts_pilot, {150, 170, 220}, {1, 0.5, 0}, 3)
	if sim_N1 < 50 and g_wow == 1 and sim_braking_ratio > 0.01 and sim_airspeed_kts_pilot > 40 then 
		gnd_spoiler = anim(gnd_spoiler, 1, 0.2)
	else	
		gnd_spoiler = anim(gnd_spoiler, 0, 0.2)
		end
	
	alpha_align =  lclamp(sim_alpha, -0, 15) * (1-g_wow_anim) * -1
	XLuaSetNumber(dr_left_elevator, anim(sim_left_elevator, lclamp(lowspeed_flap + fc_roll - gnd_spoiler * 60, -20, 20), 100))
	XLuaSetNumber(dr_right_elevator, anim(sim_right_elevator, lclamp(lowspeed_flap - fc_roll - gnd_spoiler * 60, -20, 20), 100))
	XLuaSetNumber(dr_left_aileron, anim(sim_left_aileron, lclamp(lowspeed_flap + fc_roll - gnd_spoiler * 60, -20, down_lmt), 100))
	XLuaSetNumber(dr_right_aileron, anim(sim_right_aileron, lclamp(lowspeed_flap -fc_roll - gnd_spoiler * 60, -20, down_lmt), 100))
	XLuaSetNumber(dr_left_canard, anim(sim_left_canard, lclamp(fc_pitch - sim_machno * 1 + 0.5 + alpha_align  + landing_flap - gnd_spoiler * 40, -45, 15), 100))
	XLuaSetNumber(dr_right_canard, anim(sim_right_canard, lclamp(fc_pitch - sim_machno * 1 + 0.5 + alpha_align  + landing_flap - gnd_spoiler * 40, -45, 15), 100))
	XLuaSetNumber(dr_vstab, anim(sim_vstab, clamp(fc_yaw, -20, 20), 50))
	dr_gripen_le_flap = anim(dr_gripen_le_flap, lclamp(sim_alpha -3 - landing_flap, 0, 20), 50)
	dr_gripen_nozzle = 6 - sim_N1 * 0.15 + sim_burner_ratio * 15

	
	
end

-- temp = 0
-- function after_physics() 	
	
-- end

--function after_replay() end
