--gripen_map module


rendertarget2 = createRenderTarget ( 4096 , 4096 )



dr_true_heading = globalPropertyf("sim/flightmodel/position/true_psi")
dr_lon = globalPropertyf("sim/flightmodel/position/longitude")
dr_lat = globalPropertyf("sim/flightmodel/position/latitude")
dr_acf_pitch = globalPropertyf("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot")
dr_acf_roll = globalPropertyf("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
dr_acf_heading = globalPropertyf("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
dr_vpath = globalPropertyf("sim/flightmodel/position/vpath")
dr_hpath = globalPropertyf("sim/flightmodel/position/hpath")
dr_mach = globalPropertyf("sim/flightmodel/misc/machno")
dr_alt = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")

local green = {0.0, 1.0, 0.0, 1.0}

local g02 = {0.0, 0.8, 0.0, 1.0}
local g03 = {0.3, 0.7, 0.0, 1.0}
local g04 = {0.4, 0.8, 0.0, 1.0}
local g05 = {0.7, 1.0, 0.0, 1.0}
local black = {0, 0, 0, 1.0}
local grey = {0, 0.3, 0, 1.0}
local white = {1, 1, 1, 1.0}
local size = 35
local lon_pix = 512 / (16.880663 - 14.063089)
local lat_pix = 362 / (58.786733 - 57.748439) --348.64 px per grad = 5.811 px per NM = 
local map_ctr_x = 1681
local map_ctr_lon = 16.880663
local map_ctr_y = 2371
local map_ctr_lat = 58.786733
local sim_lon = 0
local sim_lat = 0
local sim_true_heading = 0
local rend_timer = 0
local time_to_render = true

local sim_acf_pitch = 0
local sim_acf_roll = 0
local sim_acf_heading = 0
local sim_vpath = 0
local sim_hpath = 0
local sim_mach = 0
local sim_alt = 0


local use_zoom = map_zoom * 1.15
local map_range_ref = 100 / map_zoom
local sym_circle = {}
local fpl = {}

function set_fpl()
	fpl = {
			{id = "B1", 	lat = 58.9, 	lon = 17.6, x = 0, y = 0},
			{id = "B2", 	lat = 58.2, 	lon = 18.9, x = 0, y = 0},
			{id = "M1", 	lat = 57.1, 	lon = 17.4, x = 0, y = 0},
			{id = "M2", 	lat = 57.8, 	lon = 16.7, x = 0, y = 0},
			{id = "L1", 	lat = 58.79, 	lon = 16.88, x = 0, y = 0}
			}
	end

function fpl2pix()

	for i = 2, #fpl do
		fpl[i].x = (fpl[i].lon - fpl[1].lon) * lon_pix
		fpl[i].y = (fpl[i].lat - fpl[1].lat) * lat_pix	
		end

end


function draw_adi()

	if math.abs(sim_acf_pitch) < 45 then 
		saveGraphicsContext()
			setRotateTransform(-sim_acf_roll)
			setTranslateTransform((sim_acf_heading - sim_hpath) * -20 -128, -sim_acf_pitch * 20)
			drawWideLine(-1300, 0, -40, 0, line_w, g04)
			drawWideLine(1300, 0, 40, 0, line_w, g04)
			drawText( regfont, 90, 5, math.floor(0.5 + sim_alt/100)/10, 30, true, false, TEXT_ALIGN_LEFT, g04 )
			
			setTranslateTransform(0, sim_vpath * 20)
			setRotateTransform(sim_acf_roll)
			drawWideLine(-35, 0, -14, 0, line_w, g04)
			drawWideLine(35, 0, 14, 0, line_w, g04)
			drawWideLine(0, 35, 0, 14, line_w, g04)
			drawTexturePart(mask, -20, -20, 40, 40, 895, 4, 40, 40, g04) 
			restoreGraphicsContext()
			end

end

function draw_fpl()

	saveGraphicsContext()		


		setTranslateTransform( 
			map_ctr_x - (map_ctr_lon - fpl[1].lon) * lon_pix,
			map_ctr_y - (map_ctr_lat - fpl[1].lat) * lat_pix
			)		
		-- setRotateTransform(sim_true_heading * -1) 
		
		
		drawWideLine(fpl[#fpl].x, fpl[#fpl].y, fpl[1].x, fpl[1].y, line_w, g05)
		drawTexturePart(mask, fpl[1].x-20, fpl[1].y-20, 40, 40, 895, 4, 40, 40, g05) 
		-- drawText( regfont, fpl[1].x + 20, fpl[1].y - 12, fpl[1].id, 30, true, false, TEXT_ALIGN_LEFT, g05 )		
		for i = 2, #fpl do
			drawWideLine(fpl[i-1].x, fpl[i-1].y, fpl[i].x, fpl[i].y, line_w, g05)
			drawTexturePart(mask, fpl[i].x-20, fpl[i].y-20, 40, 40, 895, 4, 40, 40, g05) 
			-- drawText( regfont, fpl[i].x + 20, fpl[i].y - 12, fpl[i].id, 30, true, false, TEXT_ALIGN_LEFT, g05 )
			end
		
		
		
		restoreGraphicsContext()
		
end

function render()
	
	rend_timer = (rend_timer + 1) % 3 
	
	if rend_timer ~= -1 then 
	

		setRenderTarget(rendertarget2, true, 0)
		
		
		----------- Map texture	
		drawTexture(karta, 0, 0, 4096, 4096, {0, 0.8, 0, 1})
		

		----------- Map grid	
		saveGraphicsContext()		
			setTranslateTransform(
				map_ctr_x - (map_ctr_lon - math.floor(map_ctr_lon)) * lon_pix,
				map_ctr_y - (map_ctr_lat - math.floor(map_ctr_lat)) * lat_pix
				)
			
			local temp_x = 0
			local temp_y = 0
			for i = -2, 2 do
				for u = -3, 3 do
					temp_x = lon_pix * i * 2
					temp_y = lat_pix * u
					
					drawWideLine(-temp_x, temp_y, temp_x*2, temp_y , line_w, g03)
					drawWideLine(temp_x, -temp_y, temp_x , temp_y*2, line_w, g03)		

					drawText( regfont, temp_x + 2, temp_y - 28, math.floor(map_ctr_lon/2) * 2 + i * 2, 30, true, false, TEXT_ALIGN_CENTER, g03 )
					drawText( regfont, temp_x - 2, temp_y + 2, math.floor(map_ctr_lat) + u, 30, true, false, TEXT_ALIGN_RIGHT, g03 )
					
					-- North arrow
					drawWideLine(temp_x, temp_y+50, temp_x+10, temp_y+40, line_w, g03)
					drawWideLine(temp_x, temp_y+50, temp_x-10, temp_y+40, line_w, g03)
					end
					

				end
				
			restoreGraphicsContext()	

		draw_fpl()	

			
	
		restoreRenderTarget()
		end
	
end

function update()

	sim_acf_pitch = get(dr_acf_pitch)
	sim_acf_roll = get(dr_acf_roll) 
	sim_acf_heading = get(dr_acf_heading)
	sim_vpath = get(dr_vpath)
	sim_hpath = get(dr_hpath)
	sim_mach = get(dr_mach)
	sim_alt = get(dr_alt) * 0.348
	
	sim_lon = get(dr_lon)
	sim_lat = get(dr_lat)
	sim_true_heading = get(dr_true_heading)
	
	if time_to_render then 
		karta = loadImage("images/karta3.png", 0, 0, 4096, 4096)
		set_fpl()
		fpl2pix()
		render()
		unloadImage(karta)
		time_to_render = false
		end
end

function draw()

	setClipArea(129, 1, 767, 1023)

	---------- Map image
	saveGraphicsContext()
		setTranslateTransform(512,  300) --center drawing on screen

		setRotateTransform(sim_true_heading * -1) --rotate for heading
		setScaleTransform(use_zoom, use_zoom)
		setTranslateTransform( -- translate with position
			-map_ctr_x - (sim_lon - 16.880663) * lon_pix,
			-map_ctr_y - (sim_lat - 58.786733) * lat_pix
			)
		drawTexture(rendertarget2, 0, 0, 4096, 4096, {1, 1, 1, 1})
					
		
		restoreGraphicsContext()
		

	
	---------- Own plane and other fixed overlays
		saveGraphicsContext()		
			setTranslateTransform(512,  300) 
			
			-- flight plan wpt numbering
			saveGraphicsContext()		
				
				setRotateTransform(sim_true_heading * -1)
				setScaleTransform(use_zoom, use_zoom)
				for i = 1, #fpl do
					saveGraphicsContext()		
						setTranslateTransform((fpl[i].lon - sim_lon) * lon_pix,  (fpl[i].lat - sim_lat) * lat_pix ) 
						setRotateTransform(sim_true_heading * 1)
						drawText( regfont, 20, -10, fpl[i].id, 30, true, false, TEXT_ALIGN_LEFT, g05 )
						restoreGraphicsContext()			
					end
				
				restoreGraphicsContext()			
			
			-- Radar targets
			saveGraphicsContext()		
				
				setRotateTransform(sim_true_heading * -1)
				-- setScaleTransform(use_zoom, use_zoom)
				for i = 2, #target do
					saveGraphicsContext()		
						setTranslateTransform((target[i].x - own_pos.x) * lat_pix / 1852 / 60 * use_zoom,  (target[i].z - own_pos.z) * -lat_pix / 1852 / 60 * use_zoom) 
						setRotateTransform(target[i].hdg)
						drawWideLine (0, 10, 0, 30, line_w, g05 )
						drawWideLine (-10, 0, 0, 10, line_w, g05 )
						drawWideLine (10, 0, 0, 10, line_w, g05 )
						drawWideLine (-10, 0, 0, -10, line_w, g05 )
						drawWideLine (10, 0, 0, -10, line_w, g05 )
						drawText( regfont, 0, -30, math.ceil(target[i].y/1000+0.5), 25, true, false, TEXT_ALIGN_CENTER, g05 )
						restoreGraphicsContext()			
					end
				restoreGraphicsContext()			
			
			-- Plane triangle with velocity vector
			drawWideLine (0, 0, 0, 20, line_w, g05 )
			
			drawWideLine (-12, -35, 0, 0, line_w, g05 )
			drawWideLine (12, -35, 0, 0, line_w, g05 )
			drawWideLine (12, -35, -12, -35, line_w, g05 )
			
			-- Map scale ref
			drawText( regfont, 335, 420, map_range_ref, size, true, false, TEXT_ALIGN_RIGHT, g05 )
			drawWideLine (330, 0, 330, 400, line_w, g05 )
			drawWideLine (315, 0, 330, 0, line_w, g05 )
			drawWideLine (315, 200, 330, 200, line_w, g05 )
			drawWideLine (315, 400, 330, 400, line_w, g05 )
				
			restoreGraphicsContext()	
		
		if sim_alt < 3000 and sim_mach > 0.15 then 
			saveGraphicsContext()
				setTranslateTransform(512,  512) --center drawing on screen
				draw_adi()
				restoreGraphicsContext()	
			end	
				
			
		drawTexturePart(mask, 128, 0, 768, 1024, 0, 0, 882, 1167, white)
		
		resetClipArea()

end

--oskarshamn
--- lon 16.495191
--- lat 57.351229

-- lon dist = 0.411971	; 	295
-- lat dist = 1.447737	; 	1983	;	


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