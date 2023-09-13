local Player = Info.Player
local World = Info.World

local RoundNumber = require'RoundNumber'

local yield = util.yield_once
local util_spoof_script = util.spoof_script

local DummyCmdTbl = _G2.DummyCmdTbl
local MenuRoot = Info.MenuLayout.World:list("Objs (M)", DummyCmdTbl, "")



local MenuRootObj;MenuRootObj = MenuRoot:list("View Objs (M) List", DummyCmdTbl, "",
	function()
		local Objs = World.HandlesObjectsM
		for Objs as Obj do
			local ObjMenu = MenuRootObj:list(("%s (%sm)"):format(Obj.ModelString, RoundNumber(Obj.Distance)), DummyCmdTbl, "")
			ObjMenu:action("Teleport Self To Obj", DummyCmdTbl, "", function()
				if DoesEntityExist(Obj.Handle) then
					local ObjCoords = Obj.Coords
					SetEntityCoordsNoOffset(Player.Ped, ObjCoords.x, ObjCoords.y, ObjCoords.z, false, false, false)
				end
			end)
			ObjMenu:action("Teleport Obj To Self", DummyCmdTbl, "", function()
				local Handle = Obj.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					local SelfCoords = Player.Coords
					SetEntityCoordsNoOffset(Handle, SelfCoords.x, SelfCoords.y, SelfCoords.z, true, true, false)
				end
			end)
			ObjMenu:action("Delete Obj", DummyCmdTbl, "", function()
				local Handle = Obj.Handle
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					SetEntityAsMissionEntity(Handle, true, true)
					DeleteEntity(Handle)
				end
			end)
		end
	end,
	function()
		local ObjMenuList = MenuRootObj:getChildren()
		for ObjMenuList as ObjMenu do
			ObjMenu:delete()
		end
	end
)