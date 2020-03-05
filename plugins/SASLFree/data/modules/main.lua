-- main.lua

newtex = sasl.gl.createTexture(1024, 1024)
mask = loadImage("images/screenmask.png", 0, 0, 4096, 4096)
regfont = sasl.gl.loadFont("fonts/regular_cozy.otf")


defineProperty("win_h", globalPropertyi("sim/graphics/view/window_height"))
defineProperty("win_w", globalPropertyi("sim/graphics/view/window_width"))
defineProperty("sim_vfov", globalPropertyf("sim/graphics/view/vertical_field_of_view_deg"))
defineProperty("sim_hfov", globalPropertyf("sim/graphics/view/field_of_view_deg"))


line_w = 3
map_zoom = 1


vfov = get(sim_vfov)
hfov = get(sim_hfov)
window_height = get(win_h)
window_width = get(win_w)
defineProperty("last_window_height", window_height)
defineProperty("last_window_width", window_width)
defineProperty("last_vfov", vfov)
defineProperty("last_hfov", hfov)
window_center = {window_width / 2, window_height / 2}
screen_vdegrees = window_height / vfov
screen_hdegrees = window_width / hfov
window_center_x = 0
window_center_y = 0
target = {}

own_pos = {}
-- dr_flight_time = globalPropertyf("sim/time/total_flight_time_sec") 
-- defineProperty("sim_running", 0)

sasl.options.setLuaErrorsHandling ( SASL_STOP_PROCESSING )

components = {
		FI {
			position = { 0 , 0, 768, 1024 } ,
			visible = true ;
			clip = false
			}
}



hud_subp = subpanel {
	name = "hud symbology";
	position = { 0 , 0 , 1 , 1 };
	savePosition = false ;
	noBackground = true ;
	noClose = true ;
	noMove = true ;
	visible = true ;
	noResize = true ;
	pinnedToXWindow = { false , false } ;
	proportionalToXWindow = false ;
	components = {
		hud {
			position = { 0 , 0 , 600 , 600 } ,
			clip = false
		};
	};
}

TI_subp = subpanel {
	name = "TI";
	position = { 0 , 0 , 1024 , 1024 };
	savePosition = true ;
	noBackground = true ;
	noClose = false ;
	noMove = false ;
	visible = true ;
	noResize = false ;
	pinnedToXWindow = { false , false } ;
	proportionalToXWindow = false ;
	components = {
		TI {
			position = { 0 , 0, 384, 512 } ,
			clip = false
		};
	};
}

FI_subp = subpanel {
	name = "FI";
	position = { 0 , 0 , 1024 , 1024 };
	savePosition = true ;
	noBackground = true ;
	noClose = false ;
	noMove = false ;
	visible = true ;
	noResize = false ;
	pinnedToXWindow = { false , false } ;
	proportionalToXWindow = false ;
	components = {
		FI {
			position = { 0 , 0, 512, 384 } ,
			clip = false
		};
	};
}

MI_subp = subpanel {
	name = "MI";
	position = { 0 , 0 , 1024 , 1024 };
	savePosition = true ;
	noBackground = true ;
	noClose = false ;
	noMove = false ;
	visible = true ;
	noResize = false ;
	pinnedToXWindow = { false , false } ;
	proportionalToXWindow = false ;
	components = {
		MI {
			position = { 0 , 0, 512, 384 } ,
			clip = false
		};
	};
}



function update_screen_size()
	window_height = get(win_h)
	window_width = get(win_w)
	vfov = get(sim_vfov)
	hfov = get(sim_hfov)
	window_center_x = window_width / 2
	window_center_y = window_height / 2
	screen_vdegrees = window_height / vfov
	screen_hdegrees = window_width / hfov
end

function update()
	-- if get(sim_running) == 0 and get(dr_flight_time) > 2 then 
		-- set(sim_running, 1)
		-- -- init_stuff()
		-- end
	
	-- if get(sim_running) == 1 then
-- print("main updating " .. get(dr_flight_time) )	
		update_screen_size()
		updateAll(components)
		-- end
	
end


sasl.options.setRenderingMode2D (SASL_RENDER_2D_MULTIPASS)



function draw()
-- resetBlending()
	
	if sasl.gl.isNonLitStage() then
		sasl.gl.getTargetTextureData( newtex , 0, 0 , 1024 ,768 ) ---- USE WHEN MONITOR USAGE = FULL SCREEN SIM
		-- sasl.gl.getTargetTextureData( newtex , 438, 0 , 1024 ,768 ) ---- USE WHEN MONITOR USAGE = 2D PANEL
		end
	-- drawAll(components)
end