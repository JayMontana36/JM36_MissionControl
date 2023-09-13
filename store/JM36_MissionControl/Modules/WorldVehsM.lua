local Player = Info.Player
local World = Info.World

local RoundNumber = require'RoundNumber'

local yield = util.yield_once
local util_spoof_script = util.spoof_script

local DummyCmdTbl = _G2.DummyCmdTbl
local MenuRoot = Info.MenuLayout.World:list("Vehs (M)", DummyCmdTbl, "")



local MenuRootVeh;MenuRootVeh = MenuRoot:list("View Vehs (M) List", DummyCmdTbl, "",
	function()
		local Vehs = World.HandlesVehiclesM
		for Vehs as Veh do
			local VehMenu = MenuRootVeh:list(("%s (%sm) %s | %s %s"):format(Veh.ModelString, RoundNumber(Veh.Distance), Veh.PropertyOf, Veh.ScriptStr, Veh.ScriptInt), DummyCmdTbl, "")
			VehMenu:action("Kill Veh", DummyCmdTbl, "", function()
				local Handle = Veh.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					SetEntityHealth(Handle, 0)
					SetVehicleEngineHealth(Handle, 0.0)
					SetVehiclePetrolTankHealth(Handle, 0.0)
					SetVehicleBodyHealth(Handle, 0.0)
				end
			end)
			VehMenu:action("Teleport Self To Veh", DummyCmdTbl, "", function()
				if DoesEntityExist(Veh.Handle) then
					local VehCoords = Veh.Coords
					SetEntityCoordsNoOffset(Player.Ped, VehCoords.x, VehCoords.y, VehCoords.z, false, false, false)
				end
			end)
			VehMenu:action("Teleport Veh To Self", DummyCmdTbl, "", function()
				local Handle = Veh.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					local SelfCoords = Player.Coords
					SetEntityCoordsNoOffset(Handle, SelfCoords.x, SelfCoords.y, SelfCoords.z, true, true, false)
					SetVehicleOnGroundProperly(Handle, 5.0)
				end
			end)
			VehMenu:action("Teleport Self Into Veh", DummyCmdTbl, "", function()
				if DoesEntityExist(Veh.Handle) then
					--SetPedIntoVehicle(Player.Ped, Veh.Handle, -2)
					TaskWarpPedIntoVehicle(Player.Ped, Veh.Handle, -2)
				end
			end)
			VehMenu:action("Delete Veh", DummyCmdTbl, "", function()
				local Handle = Veh.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					util_spoof_script(Veh.ScriptStr, function()
						SetEntityAsMissionEntity(Handle, true, true)
						DeleteEntity(Handle)
					end)
					SetEntityAsMissionEntity(Handle, true, true)
					DeleteEntity(Handle)
				end
			end)
		end
	end,
	function()
		local VehMenuList = MenuRootVeh:getChildren()
		for VehMenuList as VehMenu do
			VehMenu:delete()
		end
	end
)