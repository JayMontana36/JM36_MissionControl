local Player = Info.Player

local Menu = menu.my_root():list("Mission Objective Effecient Routing")

local NoCommand = {}

local function SortByDist(a,b)
	return a.Dist < b.Dist
end

local SGCR, SGMR
local function Clear()
	if SGCR then
		ClearGpsCustomRoute()
		SGCR = nil
	end
	if SGMR then
		ClearGpsMultiRoute()
		SGMR = nil
	end
end

Menu:action("Clear", NoCommand, "", Clear)

Menu:action("Calculate Hard Point To Point", NoCommand, "", function()
	Clear()
	local BlipSprite = GetStandardBlipEnumId()
	local Blip = GetFirstBlipInfoId(BlipSprite)
	if Blip ~= 0 then
		local Coords = Player.Coords
		local ArrayTemp = {}
		local ArrayTempCount = 0
		
		repeat
			local BlipColor = GetBlipColour(Blip)
			--print("BlipColor", BlipColor)
			if BlipColor == 60 or BlipColor == 5 or BlipColor == 66 or BlipColor == 49 or BlipColor == 54 then
				local BlipCoords = GetBlipInfoIdCoord(Blip)
				ArrayTempCount += 1
				ArrayTemp[ArrayTempCount] =
				{
					Blip = Blip,
					Coords = BlipCoords,
					Dist = Coords:distance(BlipCoords)
				}
			end
			Blip = GetNextBlipInfoId(BlipSprite)
		until Blip == 0
		
		if ArrayTempCount == 0 then return end
		SGCR = true
		
		local ArrayCoords = {}
		local ArrayCoordsCount = 0
		
		repeat
			table.sort(ArrayTemp,SortByDist)
			
			local BlipClosest = table.remove(ArrayTemp,1)
			ArrayTempCount -= 1
			ArrayCoordsCount += 1
			ArrayCoords[ArrayCoordsCount] = BlipClosest
			Coords = BlipClosest.Coords
			
			for i=1,ArrayTempCount do
				ArrayTemp[i].Dist = Coords:distance(ArrayTemp[i].Coords)
			end
		until ArrayTempCount == 0
		
		StartGpsCustomRoute(6, false, true)
		for i=1,ArrayCoordsCount do
			AddPointToGpsCustomRoute(ArrayCoords[i].Coords:get())
		end
		SetGpsCustomRouteRender(true, 50, 25) -- -1,-1 (defaults) too small for flying
	end
end)

Menu:action("Calculate Soft Point To Point", NoCommand, "", function()
	Clear()--;SGMR = true
	
end)

NoCommand = nil