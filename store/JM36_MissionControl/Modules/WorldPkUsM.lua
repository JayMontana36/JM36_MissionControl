local Player = Info.Player
local World = Info.World

local RoundNumber = require'RoundNumber'

local yield = util.yield_once
local util_spoof_script = util.spoof_script

local DummyCmdTbl = _G2.DummyCmdTbl
local MenuRoot = Info.MenuLayout.World:list("PkUs (M)", DummyCmdTbl, "")



local MenuRootPkU;MenuRootPkU = MenuRoot:list("View PkUs (M) List", DummyCmdTbl, "",
	function()
		local PkUs = World.HandlesPickupsM
		for PkUs as PkU do
			local PkUMenu = MenuRootPkU:list(("%s (%sm)"):format(PkU.ModelString, RoundNumber(PkU.Distance)), DummyCmdTbl, "")
			PkUMenu:action("Teleport Self To PkU", DummyCmdTbl, "", function()
				if DoesEntityExist(PkU.Handle) then
					local PkUCoords = PkU.Coords
					SetEntityCoordsNoOffset(Player.Ped, PkUCoords.x, PkUCoords.y, PkUCoords.z, false, false, false)
				end
			end)
			PkUMenu:action("Teleport PkU To Self", DummyCmdTbl, "", function()
				local Handle = PkU.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					local SelfCoords = Player.Coords
					SetEntityCoordsNoOffset(Handle, SelfCoords.x, SelfCoords.y, SelfCoords.z, true, true, false)
				end
			end)
			--[[PkUMenu:action("Delete PkU", DummyCmdTbl, "", function()
				local Handle = PkU.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					SetEntityAsMissionEntity(Handle, true, true)
					DeleteEntity(Handle)
				end
			end)]]
		end
	end,
	function()
		local PkUMenuList = MenuRootPkU:getChildren()
		for PkUMenuList as PkUMenu do
			PkUMenu:delete()
		end
	end
)