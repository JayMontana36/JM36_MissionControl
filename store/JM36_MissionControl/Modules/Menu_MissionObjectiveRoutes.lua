local Player = Info.Player

local table_sort = table.sort
local table_remove = table.remove

local ClearGpsCustomRoute = ClearGpsCustomRoute
local ClearGpsMultiRoute = ClearGpsMultiRoute
local GetStandardBlipEnumId = GetStandardBlipEnumId
local GetFirstBlipInfoId = GetFirstBlipInfoId
local GetBlipColour = GetBlipColour
local GetBlipInfoIdCoord = GetBlipInfoIdCoord
local GetNextBlipInfoId = GetNextBlipInfoId
local StartGpsCustomRoute = StartGpsCustomRoute
local AddPointToGpsCustomRoute = AddPointToGpsCustomRoute
local SetGpsCustomRouteRender = SetGpsCustomRouteRender
local StartGpsMultiRoute = StartGpsMultiRoute
local AddPointToGpsMultiRoute = AddPointToGpsMultiRoute
local SetGpsMultiRouteRender = SetGpsMultiRouteRender



local function SortByDist(a,b)
	return a.Dist < b.Dist
end

local function GetObjectivePositions()
	local BlipSprite = GetStandardBlipEnumId()
	local Blip = GetFirstBlipInfoId(BlipSprite)
	if Blip ~= 0 then
		local ArrayTemp = {}
		local ArrayTempCount = 0
		repeat
			switch GetBlipColour(Blip) do
				case 60:
				case 5:
				case 66:
				case 70:
				case 71:
				case 73:
				--case 49:
				--case 54:
					local BlipCoords = GetBlipInfoIdCoord(Blip)
					ArrayTempCount += 1
					ArrayTemp[ArrayTempCount] =
					{
						Blip = Blip,
						Coords = BlipCoords,
					}
			end
			Blip = GetNextBlipInfoId(BlipSprite)
		until Blip == 0
		if ArrayTempCount ~= 0 then
			return ArrayTemp, ArrayTempCount
		end
	end
end

local function GetObjectivePositionsSortedLightA()
	local ArrayTemp, ArrayTempCount = GetObjectivePositions()
	if ArrayTemp then
		local Coords = Player.Coords
		for i=1,ArrayTempCount do
			ArrayTemp[i].Dist = Coords:distance(ArrayTemp[i].Coords)
		end
		local ArrayCoords = {}
		local ArrayCoordsCount = 0
		repeat
			table_sort(ArrayTemp,SortByDist)
			local BlipClosest = table_remove(ArrayTemp,1)
			ArrayTempCount -= 1
			ArrayCoordsCount += 1
			ArrayCoords[ArrayCoordsCount] = BlipClosest
			Coords = BlipClosest.Coords
			for i=1,ArrayTempCount do
				ArrayTemp[i].Dist = Coords:distance(ArrayTemp[i].Coords)
			end
		until ArrayTempCount == 0
		return ArrayCoords, ArrayCoordsCount
	end
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



local NoCommand = {}
local Menu = menu.my_root():list("Mission Objective Effecient Routing")

Menu:action("Clear", NoCommand, "", Clear)

Menu:action("Calculate Hard Point To Point", NoCommand, "", function()
	Clear()
	local ArrayCoords, ArrayCoordsCount = GetObjectivePositionsSortedLightA()
	if ArrayCoords then
		SGCR = true
		StartGpsCustomRoute(6, true, true)
		AddPointToGpsCustomRoute(Player.Coords:get())
		for i=1,ArrayCoordsCount do
			AddPointToGpsCustomRoute(ArrayCoords[i].Coords:get())
		end
		SetGpsCustomRouteRender(true, 50, -1) -- -1 (defaults) too small for flying (minimap)
	end
end)

--local CSPTP_Running
Menu:action("Calculate Soft Point To Point", NoCommand, "", function()
--	if CSPTP_Running then return end;CSPTP_Running=true
	Clear()
	local ArrayCoords, ArrayCoordsCount = GetObjectivePositionsSortedLightA()
	if ArrayCoords then
		SGMR = true
		StartGpsMultiRoute(6, true, true)
		AddPointToGpsMultiRoute(Player.Coords:get())
		for i=1,ArrayCoordsCount do
			AddPointToGpsMultiRoute(ArrayCoords[i].Coords:get())
		end
		SetGpsMultiRouteRender(true)
	end
--	CSPTP_Running=nil
end)

NoCommand = nil
