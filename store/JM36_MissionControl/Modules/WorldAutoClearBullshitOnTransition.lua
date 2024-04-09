local Vehicle = Info.Player.Vehicle
local World = Info.World

local util_is_session_transition_active = util.is_session_transition_active

local DoesEntityExist = DoesEntityExist
local NetworkHasControlOfEntity = NetworkHasControlOfEntity
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteEntity = DeleteEntity

local CT_HP = JM36.CreateThread_HighPriority
local yield = util.yield_once

local function Clear(Table)
	local EntityExempt = Vehicle.IsOp and Vehicle.IsIn
	for Table as Entry do
		local Handle = Entry.Handle
		if Handle ~= EntityExempt and DoesEntityExist(Handle) and NetworkHasControlOfEntity(Handle) then
			SetEntityAsMissionEntity(Handle, true, true)
			DeleteEntity(Handle)
		end
	end
end

local Enabled
Info.MenuLayout.World:toggle("Auto Clear Bullshit (M) On Transition", _G2.DummyCmdTbl, "", function(on)
	Enabled = on
	if Enabled then
		CT_HP(function()
			while Enabled do
				while not util_is_session_transition_active() do
					yield()
				end
				Clear(World.HandlesPedsM)
				Clear(World.HandlesVehiclesM)
				Clear(World.HandlesObjectsM)
				while util_is_session_transition_active() do
					yield()
				end
			end
		end)
	end
end, Enabled)

local function Clear2(Table)
	local EntityExempt = Vehicle.IsOp and Vehicle.IsIn
	for Table as Entry do
		local Handle = Entry.Handle
		if Handle ~= EntityExempt and (not Entry.PropertyOf or Entry.PropertyOf=="N/A") and DoesEntityExist(Handle) then
			NETWORK_SET_NO_LONGER_NEEDED(Handle, true)
			if GetEntityType(Handle) == 2 then
				local Handle2 = GetPedInVehicleSeat(Handle, -1)
				if Handle2 == 0 or not IsPedAPlayer(Handle2) then
					if NetworkRequestControlOfEntity(Handle) then
						SetEntityAsMissionEntity(Handle, true, true)
						DeleteEntity(Handle)
					end
				end
			else
				if NetworkRequestControlOfEntity(Handle) then
					SetEntityAsMissionEntity(Handle, true, true)
					DeleteEntity(Handle)
				end
			end
		end
	end
end
Info.MenuLayout.World:action("Clear Bullshit", _G2.DummyCmdTbl, "", function()
	Clear2(World.HandlesPedsM)
	Clear2(World.HandlesVehiclesM)
	Clear2(World.HandlesObjectsM)
end)
