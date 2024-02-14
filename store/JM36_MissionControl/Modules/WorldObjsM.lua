local Player = Info.Player
local World = Info.World

local RoundNumber = require'RoundNumber'

local yield = util.yield_once
local util_spoof_script = util.spoof_script

local DummyCmdTbl = _G2.DummyCmdTbl
local MenuRoot = Info.MenuLayout.World:list("Objs (M)", DummyCmdTbl, "")

do
	local HashesCameras =
	{
		[0xF140D36C]	= true,--xm_prop_x17_server_farm_cctv_01
		[0xEBCF6F88]	= true,--ba_prop_battle_cctv_cam_01a
		[0x8FA9BC27]	= true,--prop_cctv_cam_04c
		[0x11DBA8EE]	= true,--prop_cctv_pole_02
		[0xFF958462]	= true,--prop_cctv_pole_03
		[0x7C37905E]	= true,--ba_prop_battle_cctv_cam_01b
		[0xB0AC0A70]	= true,--xm_prop_x17_cctv_01a
		[0xB67CFFA2]	= true,--ch_prop_ch_cctv_cam_02a
		[0xBEB71A3D]	= true,--prop_cctv_cam_04a
		[0x72628199]	= true,--prop_cctv_cam_04b
		[0xC3F4FCDB]	= true,--hei_prop_bank_cctv_01
		[0xB01B091D]	= true,--prop_cctv_cam_07a
		[0x7C95FA6E]	= true,--prop_cs_cctv
		[0x922F1950]	= true,--hei_prop_bank_cctv_02
		[0x56605A21]	= true,--prop_cctv_cam_03a
		[0x72E32F7F]	= true,--prop_cctv_pole_01a
		[0xBAE4A210]	= true,--prop_cctv_cam_02a
		[0xA113C6C]		= true,--prop_cctv_cam_06a
		[0x20B56CBC]	= true,--prop_cctv_cam_01a
		[0xEAE30118]	= true,--prop_cctv_cam_01b
		[0xF5AD127C]	= true,--prop_cctv_cam_05a
		[0x1140AC51]	= true,--p_cctv_s
		[0xBB947154]	= true,--tr_prop_tr_cctv_cam_01a
		[0x3C8C0EF5]	= true,--tr_prop_tr_camhedz_cctv_01a
		[0x4DE126A4]	= true,--ch_prop_ch_cctv_cam_01a
		[0x813C7637]	= true,--h4_prop_h4_cctv_pole_04
		[0x7F4B83CC]	= true,--prop_cctv_pole_04
	}
	MenuRoot:toggle_loop("Delete Cameras (M)", DummyCmdTbl, "", function()
		local Objs = World.HandlesObjectsM
		for Objs as Obj do
			if HashesCameras[Obj.ModelHash] and NetworkRequestControlOfEntity(Obj.Handle) then
				SetEntityAsMissionEntity(Obj.Handle, false, true)
				DeleteEntity(Obj.Handle)
			end
		end
	end)
end



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