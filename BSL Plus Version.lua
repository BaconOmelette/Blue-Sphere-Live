--Blue Sphere Live
--Created by BaconOmelette
--www.baconomelette.com
local Map = gui.createcanvas(512, 512) -- Popout a window to display map

Grid = {} -- Initialize Grid Array, keep in mind that LUA arrays start at 1 where as the game's array for blue spheres starts at 0
for Col=1,32 do
	Grid[Col] = {}
	for Row=1,32 do	
		Grid[Col][Row] = {}
	end
end

ReDraw = false --set ReDraw to false

function MapDisplay()
    GameMode = memory.readbyte(0xFFF600) --Game Mode Flag
	Map.SetTitle("Blue Sphere Live")
    if GameMode == 8 then --Check for Special Stage Game Mode Flag
		--Drawing the display
		if ReDraw == true then --Lets draw ourselves a grid!
			Map.Clear(0) --Wipe map window clear before redrawing
			Col = 0 --Set sights on first position
			while Col <32 do --Stop after out of range
				Row = 0 --Set sights on first position
				while Row < 32 do --Stop after out of range
					DrawSlot = memory.readbyte(((0xFFF4E0-(Col*32))+Row)) --Memory address for currently targetted position
					if DrawSlot < 11 then --Safeguard to not draw images that don't exist
						--gui.drawImage(DrawSlot .. ".png", (320+(Col*8)),(Row*8)) --Grab the image, place it in the proper position in the display
						Map.DrawImage(DrawSlot .. ".png", ((Col*16)),(Row*16))
						Grid[(Col+1)][(Row+1)] = DrawSlot --Write the the Grid Array to compare with later
					end
					Row = Row + 1 --Set sights on the next position
				end
				Col = Col + 1 --Set sights on the next position
			end
			ReDraw = false --set ReDraw to false, its finished and we can go back to comparing
		end
		
		--Comparing game memory addresses with the Grid array in LUA
        Col = 0 --Set sights on first position
        while Col <32 do --Stop after out of range
            Row = 0 --Set sights on first position
            while Row < 32 do --Stop after out of range
				DrawSlot = memory.readbyte(((0xFFF4E0-(Col*32))+Row)) --Memory address for currently targetted position
                if DrawSlot < 11 then --Safeguard to not draw images that don't exist
					if Grid[(Col+1)][(Row+1)] ~= DrawSlot then --If the game has something different than what we have in the Grid array, lets get to work!
						
						--Ignore the in between states of collecting a ring or sphere here. This reduces SO MUCH LAG since it doesn't need to redraw pointless transitional frames.
						--I couldn't make it run with comparing it as a range >5 so instead we get if statements for each number because I'm a dumb dumb (:
						if Grid[(Col+1)][(Row+1)] == 6 then
							Grid[(Col+1)][(Row+1)] = DrawSlot --Write the the Grid Array to compare with later
							break
						end
						if Grid[(Col+1)][(Row+1)] == 7 then
							Grid[(Col+1)][(Row+1)] = DrawSlot --Write the the Grid Array to compare with later
							break
						end
						if Grid[(Col+1)][(Row+1)] == 8 then
							Grid[(Col+1)][(Row+1)] = DrawSlot --Write the the Grid Array to compare with later
							break
						end
						if Grid[(Col+1)][(Row+1)] == 9 then
							Grid[(Col+1)][(Row+1)] = DrawSlot --Write the the Grid Array to compare with later
							break
						end
						if Grid[(Col+1)][(Row+1)] == 10 then
							Grid[(Col+1)][(Row+1)] = DrawSlot --Write the the Grid Array to compare with later
							break
						end
						--End of dumb dumb code, back to somewhat smarter after this.
						
						ReDraw = true --set ReDraw to true
						break --we no longer need to check the rest of the data because a change is detected
					end
                end
				Row = Row + 1 --Set sights on the next position
            end
            if ReDraw == true then --again, bail out of our loop because we detected a change
                break
            end
			Col = Col + 1 --Set sights on the next position
        end	
    end
end

while true do
	MapDisplay()
	Map.Refresh()
	
	--Text File Outputs (outputs a text file with the level currently on, useful if you want to display on a stream overlay but can be deleted if not wanted)
	LevelNumber = (memory.read_u32_be(0xFFFFA6)+1)
	filewrite = io.open("output.txt", "w")
	filewrite:write("Level #" .. LevelNumber)
	filewrite:close()
	--end of level text file output code
	
	emu.frameadvance() --absolutely necessary
end

