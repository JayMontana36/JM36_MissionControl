local Info = Info
local Player = Info.Player
local Players = Info.Players
local World



local entities_get_all_vehicles_as_pointers	= entities.get_all_vehicles_as_pointers	;	entities.get_all_vehicles_as_pointers		= function()return World.PointersVehicles end
local entities_get_all_peds_as_pointers		= entities.get_all_peds_as_pointers		;	entities.get_all_peds_as_pointers			= function()return World.PointersPeds end
local entities_get_all_objects_as_pointers	= entities.get_all_objects_as_pointers	;	entities.get_all_objects_as_pointers		= function()return World.PointersObjects end
local entities_get_all_pickups_as_pointers	= entities.get_all_pickups_as_pointers	;	entities.get_all_pickups_as_pointers		= function()return World.PointersPickups end
local entities_get_all_pickups_as_handles	= entities.get_all_pickups_as_handles	;	entities.get_all_pickups_as_handles			= function()return World.HandlesPickups end



local entities_has_handle = entities.has_handle
local entities_pointer_to_handle = entities.pointer_to_handle
local entities_get_model_hash = entities.get_model_hash
local util_reverse_joaat = util.reverse_joaat
local entities_get_position = entities.get_position



local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetEntityPopulationType = GetEntityPopulationType
local IsEntityAMissionEntity = IsEntityAMissionEntity
local IsEntityDead = IsEntityDead
local GetEntityScript = GetEntityScript
local GetRelationshipBetweenPeds = GetRelationshipBetweenPeds
local IsPedInCombat = IsPedInCombat



local MemPtr = memory.alloc_int()



local table_sort = table.sort
--[[local function SortHandles(a,b)
	if a.ModelString == b.ModelString then
		return a.Distance < b.Distance
	end
	return a.ModelString < b.ModelString
end]]
local function SortHandles(a,b)
	return a.Distance < b.Distance
end



World = setmetatable
(
	{
		PointersVehicles	=	0,
		PointersPeds		=	0,
		PointersObjects		=	0,
		PointersPickups		=	0,
		HandlesVehiclesM	=	0,
		HandlesPedsM		=	0,
		HandlesObjectsM		=	0,
		HandlesPickupsM		=	0,
	},
	{
		__index	=	function(Self,Key)
						local Value
						switch Key do
							case "PointersVehicles":
								Value = entities_get_all_vehicles_as_pointers()
								break
							case "PointersPeds":
								Value = entities_get_all_peds_as_pointers()
								break
							case "PointersObjects":
								Value = entities_get_all_objects_as_pointers()
								break
							case "PointersPickups":
								Value = entities_get_all_pickups_as_pointers()
								break
							case "HandlesVehiclesM":
								Value = Self.PointersVehicles
								break
							case "HandlesPedsM":
								Value = Self.PointersPeds
								break
							case "HandlesObjectsM":
								Value = Self.PointersObjects
								break
							case "HandlesPickupsM":
								Value = entities_get_all_pickups_as_handles()
								break
						end
						switch Key do
							case "HandlesVehiclesM":
							case "HandlesPedsM":
							case "HandlesObjectsM":
							case "_HandlesM":
								local _Value = Value
								Value = {}
								local SelfCoords = GetFinalRenderedCamCoord() --Player.Coords
								local Count = 0
								for _Value as Pointer do
									if (Handle := entities_has_handle(Pointer) and entities_pointer_to_handle(Pointer)) and GetEntityPopulationType(Handle) == 7 and IsEntityAMissionEntity(Handle) then
										local Model = entities_get_model_hash(Pointer)
										local Coords = entities_get_position(Pointer)
										local ScriptStr, ScriptInt = GetEntityScript(Handle,MemPtr)
										Count += 1
										Value[Count] =
										{
											Pointer = Pointer,
											Handle = Handle,
											ModelHash = Model,
											ModelString = util_reverse_joaat(Model),
											Dead = IsEntityDead(Handle),
											Coords = Coords,
											Distance = Coords:distance(SelfCoords),
											ScriptStr = ScriptStr,
											ScriptInt = ScriptInt,
										}
									end
								end
								table_sort(Value,SortHandles)
								break
							case "HandlesPickupsM":
								local _Value = Value
								Value = {}
								local SelfCoords = GetFinalRenderedCamCoord() --Player.Coords
								local Count = 0
								for _Value as Handle do
									local HandleObject = GET_PICKUP_OBJECT(Handle)
									local Model = GET_ENTITY_MODEL(HandleObject)
									local Coords = GET_PICKUP_COORDS(Handle)
									local ScriptStr, ScriptInt = GetEntityScript(HandleObject,MemPtr)
									Count += 1
									Value[Count] =
									{
										--Pointer = Pointer,
										--Handle = Handle,
										Handle = HandleObject,
										ModelHash = Model,
										ModelString = util_reverse_joaat(Model),
										--Dead = IsEntityDead(HandleObject),
										Coords = Coords,
										Distance = Coords:distance(SelfCoords),
										ScriptStr = ScriptStr,
										ScriptInt = ScriptInt,
									}
								end
								table_sort(Value,SortHandles)
						end
						switch Key do
							case "HandlesVehiclesM":
								--local SelfPed = Player.Ped
								local NetworkPlayerHashes = {}
								for i=0,31 do
									if _Player := Players[i] then
										NetworkPlayerHashes[_Player.NetworkHash] = _Player.Name
									end
								end
								for Value as Veh do
									local Handle = Veh.Handle
									Veh.PropertyOf = DecorExistOn(Handle, "Player_Vehicle") and NetworkPlayerHashes[DecorGetInt(Handle, "Player_Vehicle")] or "N/A"
								end
								break
							case "HandlesPedsM":
								local SelfPed = Player.Ped
								for Value as Ped do
									local Handle = Ped.Handle
									Ped.RelationshipToSelf = GetRelationshipBetweenPeds(Handle, SelfPed)
									Ped.CombatToSelf = IsPedInCombat(Handle, SelfPed)
									Ped.Health = GetEntityHealth(Handle)
									Ped.Armor = GetPedArmour(Handle)
								end
								break
							case "HandlesObjectsM":
								--[[local SelfPed = Player.Ped
								for Value as Obj do
									local Handle = Obj.Handle
									
								end]]
								break
							case "HandlesPickupsM":
								--[[local SelfPed = Player.Ped
								for Value as Pickup do
									local Handle = Pickup.Handle
									
								end]]
								break
						end
						Self[Key] = Value
						return Value
					end
	}
)
Info.World = World



local yield = JM36.yield_once

JM36.CreateThread_HighPriority(function()
	while true do
		World.PointersVehicles = nil
		World.PointersPeds = nil
		World.PointersObjects = nil
		World.PointersPickups = nil
		World.HandlesVehiclesM = nil
		World.HandlesPedsM = nil
		World.HandlesObjectsM = nil
		World.HandlesPickupsM = nil
		yield()
	end
end)
