local World = Info.World

local util_is_session_transition_active = util.is_session_transition_active

local DoesEntityExist = DoesEntityExist
local NetworkHasControlOfEntity = NetworkHasControlOfEntity
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteEntity = DeleteEntity

local CT_HP = JM36.CreateThread_HighPriority
local yield = util.yield_once

local function Clear(Table)
	for Table as Entry do
		local Handle = Entry.Handle
		if DoesEntityExist(Handle) and NetworkHasControlOfEntity(Handle) then
			SetEntityAsMissionEntity(Handle, true, true)
			DeleteEntity(Handle)
		end
	end
end

local Enabled
local MenuRoot = Info.MenuLayout.World:toggle("Auto Clear Bullshit (M) On Transition", _G2.DummyCmdTbl, "", function(on)
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
