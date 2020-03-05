--gripen_map module

karta3 = loadImage("images/karta3.png", 0, 0, 4096, 4096)
mask = loadImage("images/screenmask.png", 0, 0, 4096, 4096)
miref = loadImage("images/miref.png", 0, 0, 4096, 4096)
rendertarget2 = createRenderTarget ( 1024 , 1024 )

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
local black = {0, 0, 0, 1.0}
local grey = {0, 0.3, 0, 1.0}
local white = {1, 1, 1, 1.0}
local g01 = {0.0, 0.2, 0.0, 1.0}
local g02 = {0.0, 0.4, 0.0, 1.0}
local g03 = {0.2, 0.6, 0.0, 1.0}
local g04 = {0.3, 0.8, 0.0, 1.0}
local g05 = {0.7, 1.0, 0.0, 1.0}
-- local lon_pix = 2071 / (16.880663 - 14.063089)
-- local lat_pix = 1424 / (58.786733 - 57.748439)
local lon_pix = 512 / (16.880663 - 14.063089)
local lat_pix = 362 / (58.786733 - 57.748439)
-- local map_ctr_x = 2106
-- local map_ctr_y = 2267
local map_ctr_x = 1681
local map_ctr_y = 2371
local sim_lon = 0
local sim_lat = 0

local use_zoom = map_zoom * 1.6
rend_timer = 0


function draw_adi()

	if math.abs(sim_acf_pitch) < 45 then 
		saveGraphicsContext()
			setRotateTransform(-sim_acf_roll)
			setTranslateTransform((sim_acf_heading - sim_hpath) * -20 -128, -sim_acf_pitch * 20)
			drawWideLine(-1300, 0, -40, 0, line_w, g05)
			drawWideLine(1300, 0, 40, 0, line_w, g05)
			drawText( regfont, 150, 3, math.floor(0.5 + sim_alt/100)/10, 25, true, false, TEXT_ALIGN_LEFT, g05 )
			
			setTranslateTransform(0, sim_vpath * 20)
			setRotateTransform(sim_acf_roll)
			drawWideLine(-35, 0, -14, 0, line_w, g05)
			drawWideLine(35, 0, 14, 0, line_w, g05)
			drawWideLine(0, 35, 0, 14, line_w, g05)
			drawTexturePart(mask, -20, -20, 40, 40, 895, 4, 40, 40, g05) 
			restoreGraphicsContext()
			end

end

function render()

	rend_timer = (rend_timer + 1) % 3 
	
	if rend_timer == 2 then 
		setRenderTarget(rendertarget2, true, 3)

		setClipArea(0, 0, 400, 300)

		saveGraphicsContext()
			setTranslateTransform(200,  30) --center drawing on screen

			setRotateTransform(get(dr_true_heading) * -1) --rotate for heading
			setScaleTransform(map_zoom, map_zoom)
			setTranslateTransform( -- translate with position
				-map_ctr_x - (sim_lon - 16.880663) * lon_pix,
				-map_ctr_y - (sim_lat - 58.786733) * lat_pix
				)
			drawTexture(karta3, 0, 0, 4096, 4096, green)
						
			
			restoreGraphicsContext()
			

	
		--map grid
		-- saveGraphicsContext()		
			-- setTranslateTransform(200,  30) 
			
			-- sasl.gl.drawWideLine (-7, -20, 0, 0, 2, black )
			-- sasl.gl.drawWideLine (7, -20, 0, 0, 2, black )
		
		-- restoreGraphicsContext()		
		

		drawTexturePart(mask, 0, 0, 400, 300, 480, 570, 546, 455, green)
			
			-- setRotateTransform(get(dr_true_heading) * -1) --rotate for heading
			-- setScaleTransform(map_zoom, map_zoom)
			-- setTranslateTransform( -- translate with position
				-- (sim_lon - math.floor(sim_lon)) * -lon_pix,
				-- (sim_lat - math.floor(sim_lat)) * -lat_pix
				-- )
				
			-- for i = -5, 5 do
				-- drawLine(i * lon_pix, lat_pix*5, i * lon_pix, -lat_pix*5, grey)
				-- drawLine(-lon_pix*5, i * lat_pix, lon_pix*5, i * lat_pix, grey)
				
				-- for i2 = -15, 15 do
					-- drawLine(i2 * lon_pix/3, i * lat_pix + 5, i2 * lon_pix/3, i * lat_pix -5, grey)
					-- drawLine(i * lon_pix + 5, i2 * lat_pix/3, i * lon_pix -5, i2 * lat_pix/3, grey)
					-- end
				
				-- end
				

			-- restoreGraphicsContext()			
	
		--plane symbol
		-- saveGraphicsContext()
			-- setTranslateTransform(200,  100) 
			
			
			restoreRenderTarget()
		end
	
end

function update()

	sim_lon = get(dr_lon)
	sim_lat = get(dr_lat)
	sim_acf_pitch = get(dr_acf_pitch)
	sim_acf_roll = get(dr_acf_roll) 
	sim_acf_heading = get(dr_acf_heading)
	sim_vpath = get(dr_vpath)
	sim_hpath = get(dr_hpath)
	sim_mach = get(dr_mach)
	sim_alt = get(dr_alt) * 0.348
	sim_true_heading = get(dr_true_heading)
	
	-- render()
end

function draw()
	
	drawRectangle(0, 0, 1024, 768, black)

	drawTexturePart(miref, 0, 0, 1024, 768, 0, 0, 1024, 768, {1, 1, 1, 0.7})
	
	-- Radar angle limits
	saveGraphicsContext()
	
		setClipArea(135, 45, 620, 670)
		
		setTranslateTransform(450, 40)
		drawTriangle(0, 0, -400, 240, -400, 0, g01)
		drawTriangle(0, 0, 400, 240, 400, 0, g01)	
		
		-- heading pointer
		drawWidePolyLine( {-10, 640, 0, 655, 10, 640}, 5, g05)
		
		
		--- Radar targets
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
		
		
		resetClipArea()
		
		restoreGraphicsContext()	

	-- ADI
	saveGraphicsContext()
		setClipArea(10, 10, 1004, 748)
		setTranslateTransform(450, 380)	
		setScaleTransform(1.5, 1.5)
		draw_adi()
		resetClipArea()
		restoreGraphicsContext()	

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