local Player = Info.Player
local Vehicle = Player.Vehicle
local Vehicle_Type = Vehicle.Type

local table_sort = table.sort
local table_remove = table.remove

local GetStandardBlipEnumId = GetStandardBlipEnumId
local GetFirstBlipInfoId = GetFirstBlipInfoId
local GetBlipColour = GetBlipColour
local GetBlipInfoIdCoord = GetBlipInfoIdCoord
local GetNextBlipInfoId = GetNextBlipInfoId
local ClearPedTasks = ClearPedTasks
local ClearGpsCustomRoute = ClearGpsCustomRoute
local ClearGpsMultiRoute = ClearGpsMultiRoute
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

local Task, SGCR, SGMR
local function Clear()
	if Task then
		ClearPedTasks(Player.Ped)
		Task = nil
	end
	if SGCR then
		ClearGpsCustomRoute()
		SGCR = nil
	end
	if SGMR then
		ClearGpsMultiRoute()
		SGMR = nil
	end
end
local function SetSGCR(ArrayCoords, ArrayCoordsCount)
	if ArrayCoords then
		SGCR = true
		StartGpsCustomRoute(6, true, true)
		AddPointToGpsCustomRoute(Player.Coords:get())
		for i=1,ArrayCoordsCount do
			AddPointToGpsCustomRoute(ArrayCoords[i].Coords:get())
		end
		SetGpsCustomRouteRender(true, 50, -1) -- -1 (defaults) too small for flying (minimap)
	end
end
local function SetSGMR(ArrayCoords, ArrayCoordsCount)
	if ArrayCoords then
		SGMR = true
		StartGpsMultiRoute(6, true, true)
		AddPointToGpsMultiRoute(Player.Coords:get())
		for i=1,ArrayCoordsCount do
			AddPointToGpsMultiRoute(ArrayCoords[i].Coords:get())
		end
		SetGpsMultiRouteRender(true)
	end
end



local NoCommand = {}
local Menu = menu.my_root():list("Mission Objective Effecient Routing")

Menu:action("Clear", NoCommand, "", Clear)

Menu:action("Calculate Hard Point To Point", NoCommand, "", function()
	Clear()
	SetSGCR(GetObjectivePositionsSortedLightA())
end)

--local CSPTP_Running
Menu:action("Calculate Soft Point To Point", NoCommand, "", function()
--	if CSPTP_Running then return end;CSPTP_Running=true
	Clear()
	SetSGMR(GetObjectivePositionsSortedLightA())
--	CSPTP_Running=nil
end)

Menu:action("Travel", NoCommand, "", function()
	Clear()
	local ArrayCoords, ArrayCoordsCount = GetObjectivePositionsSortedLightA()
	if ArrayCoords then
		local Veh
		if not Vehicle.IsOp then
			local VehLast = Vehicle.HandleScript
			if DoesEntityExist(VehLast) and (GetPedInVehicleSeat(VehLast,-1) == 0) and not IsEntityDead(VehLast) then
				Veh = VehLast
			end
		else
			Veh = Vehicle.IsIn
		end
		if Veh then
			Task = true
			local SelfPed = Player.Ped
			SetDriveTaskDrivingStyle(SelfPed, 4981308)
			SetBlockingOfNonTemporaryEvents(SelfPed, false)
			SetPedShootRate(SelfPed, 1000)
			SetPedAccuracy(SelfPed, 100)
			SetPedCombatRange(SelfPed, 3)
			SetPedCombatMovement(SelfPed, 2)
			
			do -- use a for loop here instead, with a table containing index=bool
			SetPedCombatAttributes(SelfPed,0,true)
			SetPedCombatAttributes(SelfPed,1,true)
			SetPedCombatAttributes(SelfPed,2,true)
			SetPedCombatAttributes(SelfPed,3,true)
			SetPedCombatAttributes(SelfPed,4,true)
			SetPedCombatAttributes(SelfPed,5,true)
			SetPedCombatAttributes(SelfPed,12,true)
			SetPedCombatAttributes(SelfPed,13,true)
			SetPedCombatAttributes(SelfPed,14,false)
			SetPedCombatAttributes(SelfPed,17,false)
			SetPedCombatAttributes(SelfPed,20,false)
			SetPedCombatAttributes(SelfPed,21,false)
			SetPedCombatAttributes(SelfPed,23,true)
			SetPedCombatAttributes(SelfPed,24,true)
			SetPedCombatAttributes(SelfPed,25,false)
			SetPedCombatAttributes(SelfPed,26,true)
			SetPedCombatAttributes(SelfPed,27,true)
			SetPedCombatAttributes(SelfPed,28,true)
			SetPedCombatAttributes(SelfPed,29,true)
			SetPedCombatAttributes(SelfPed,30,false)
			SetPedCombatAttributes(SelfPed,31,false)
			SetPedCombatAttributes(SelfPed,34,false)
			SetPedCombatAttributes(SelfPed,35,true)
			SetPedCombatAttributes(SelfPed,36,false)
			SetPedCombatAttributes(SelfPed,38,false)
			SetPedCombatAttributes(SelfPed,41,true)
			SetPedCombatAttributes(SelfPed,42,true)
			SetPedCombatAttributes(SelfPed,43,true)
			SetPedCombatAttributes(SelfPed,44,false)
			SetPedCombatAttributes(SelfPed,46,false)
			SetPedCombatAttributes(SelfPed,47,true)
			SetPedCombatAttributes(SelfPed,49,false)
			SetPedCombatAttributes(SelfPed,50,true)
			SetPedCombatAttributes(SelfPed,52,false)
			SetPedCombatAttributes(SelfPed,53,true)
			SetPedCombatAttributes(SelfPed,54,true)
			SetPedCombatAttributes(SelfPed,55,true)
			SetPedCombatAttributes(SelfPed,56,false)
			SetPedCombatAttributes(SelfPed,57,false)
			SetPedCombatAttributes(SelfPed,58,true)
			SetPedCombatAttributes(SelfPed,59,false)
			SetPedCombatAttributes(SelfPed,60,false)
			SetPedCombatAttributes(SelfPed,65,true)
			SetPedCombatAttributes(SelfPed,66,true)
			SetPedCombatAttributes(SelfPed,67,false)
			SetPedCombatAttributes(SelfPed,68,false)
			SetPedCombatAttributes(SelfPed,72,true)
			SetPedCombatAttributes(SelfPed,74,false)
			SetPedCombatAttributes(SelfPed,78,true)
			SetPedCombatAttributes(SelfPed,79,false)
			SetPedCombatAttributes(SelfPed,80,true)
			SetPedCombatAttributes(SelfPed,81,false)
			SetPedCombatAttributes(SelfPed,85,false)
			SetPedCombatAttributes(SelfPed,86,true)
			end
			
			SetPedHighlyPerceptive(SelfPed, true)
			
			SetPedAllowedToDuck(SelfPed, true)
			
			SetPedCanEvasiveDive(SelfPed, true)
			
			SetPedFiringPattern(SelfPed, -957453492)
			
			local MemPtr_TaskSequence = memory.alloc_int()
			local RetVal, TaskSequenceId = OpenSequenceTask(MemPtr_TaskSequence)
			if not (Vehicle_Type.Boat or Vehicle_Type.Heli or Vehicle_Type.Jetski or Vehicle_Type.Plane or Vehicle_Type.Train) then
				SetSGMR(ArrayCoords,ArrayCoordsCount)
				for i=1,ArrayCoordsCount-1 do
					local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[i].Coords:get()
					TaskVehicleDriveToCoordLongrange
					(
						0,
						Veh,
						CoordsA_x, CoordsA_y, CoordsA_z,
						150*0.44704,
						786469,
						62.5*0.3048
					)
				end
				local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[ArrayCoordsCount].Coords:get()
				TaskVehicleDriveToCoordLongrange
				(
					0,
					Veh,
					CoordsA_x, CoordsA_y, CoordsA_z,
					150*0.44704,
					786469,
					62.5*0.3048
				)
				TaskVehicleMission
				(
					0,
					Veh,
					0,
					18,
					15*0.44704,
					786469,
					62.5*0.3048,
					25.0*0.3048,
					false
				)
			else
				SetSGCR(ArrayCoords,ArrayCoordsCount)
				if Vehicle_Type.Heli then
					for i=1,ArrayCoordsCount-1 do
						local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[i].Coords:get()
						local CoordsB_x, CoordsB_y, CoordsB_z = ArrayCoords[i+1].Coords:get()
						local Heading = GetHeadingFromVector2d(CoordsA_x-CoordsB_x,CoordsA_y-CoordsB_y)
						TaskHeliMission
						(
							0,
							Veh,
							0,
							0,
							CoordsA_x, CoordsA_y, CoordsA_z,
							14,--4
							225.0*0.5144444,
							125.0*0.3048,
							Heading,
							CoordsA_z,
							50.0*0.3048,
							-1.0,
							897
						)
					end
					local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[ArrayCoordsCount].Coords:get()
					TaskHeliMission
					(
						0,
						Veh,
						0,
						0,
						CoordsA_x, CoordsA_y, CoordsA_z,
						14,--4
						225.0*0.5144444,
						125.0*0.3048,
						-1.0,
						CoordsA_z,
						50.0*0.3048,
						-1.0,
						897
					)
				elseif Vehicle_Type.Plane then
					for i=1,ArrayCoordsCount-1 do
						local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[i].Coords:get()
						local CoordsB_x, CoordsB_y, CoordsB_z = ArrayCoords[i+1].Coords:get()
						local Heading = GetHeadingFromVector2d(CoordsA_x-CoordsB_x,CoordsA_y-CoordsB_y)
						TaskPlaneMission
						(
							0,
							Veh,
							0,
							0,
							CoordsA_x, CoordsA_y, CoordsA_z,
							14,--4
							225.0*0.5144444,
							250.0*0.3048,
							Heading,
							CoordsA_z,
							50.0*0.3048,
							true
						)
					end
					local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[ArrayCoordsCount].Coords:get()
					TaskPlaneMission
					(
						0,
						Veh,
						0,
						0,
						CoordsA_x, CoordsA_y, CoordsA_z,
						14,--4
						225.0*0.5144444,
						250.0*0.3048,
						-1.0,
						CoordsA_z,
						50.0*0.3048,
						true
					)
				elseif (Vehicle_Type.Boat or Vehicle_Type.Jetski) then
					for i=1,ArrayCoordsCount-1 do
						local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[i].Coords:get()
						TaskBoatMission
						(
							0,
							Veh,
							0,
							0,
							CoordsA_x, CoordsA_y, CoordsA_z,
							14,--4
							225.0*0.5144444,
							786469,
							62.5*0.3048,
							1135
						)
					end
					local CoordsA_x, CoordsA_y, CoordsA_z = ArrayCoords[ArrayCoordsCount].Coords:get()
					TaskBoatMission
					(
						0,
						Veh,
						0,
						0,
						CoordsA_x, CoordsA_y, CoordsA_z,
						14,--4
						225.0*0.5144444,
						786469,
						62.5*0.3048,
						1135
					)
				end
			end
			CloseSequenceTask(TaskSequenceId)
			TaskPerformSequence(SelfPed, TaskSequenceId)
			ClearSequenceTask(MemPtr_TaskSequence)
		end
	end
end)



NoCommand = nil
