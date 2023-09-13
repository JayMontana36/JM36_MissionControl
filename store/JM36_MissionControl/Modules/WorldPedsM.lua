local Player = Info.Player
local World = Info.World

local RoundNumber = require'RoundNumber'

local yield = util.yield_once
local util_spoof_script = util.spoof_script

local DummyCmdTbl = _G2.DummyCmdTbl
local MenuRoot = Info.MenuLayout.World:list("Peds (M)", DummyCmdTbl, "")

local function IsPedEnemy(Ped)
	return not Ped.Dead and (Ped.CombatToSelf or Ped.RelationshipToSelf ~= 255 and Ped.RelationshipToSelf > 2) and NetworkRequestControlOfEntity(Ped.Handle)
end

MenuRoot:toggle_loop("Auto Kill Enemy Peds (M)", DummyCmdTbl, "", function()
	local Peds = World.HandlesPedsM
	for Peds as Ped do
		if IsPedEnemy(Ped) then
			SetEntityHealth(Ped.Handle, 0)
		end
	end
end)
MenuRoot:toggle_loop("Make Enemy Peds (M) Fragile", DummyCmdTbl, "", function()
	local Peds = World.HandlesPedsM
	for Peds as Ped do
		if IsPedEnemy(Ped) then
			local Health = -100 + (Ped.Health + Ped.Armor)
			--SetEntityHealth(Ped.Handle, 100)
			ApplyDamageToPed(Ped.Handle, Health, true)
		end
	end
end)

local FIRING_PATTERN_SINGLE_SHOT = GetHashKey"FIRING_PATTERN_SINGLE_SHOT"
MenuRoot:toggle_loop("Remove Enemy Peds (M) Weapons", DummyCmdTbl, "", function()
	local Peds = World.HandlesPedsM
	for Peds as Ped do
		if IsPedEnemy(Ped) then
			--RemoveAllPedWeapons(Ped.Handle, false)
			local Handle = Ped.Handle
			local SelectedPedWeapon = GetSelectedPedWeapon(Handle)
			SetPedInfiniteAmmo(Handle, false, SelectedPedWeapon)
			SetPedInfiniteAmmoClip(Handle, false)
			SetPedAmmo(Handle, SelectedPedWeapon, 0, true)
			AddAmmoToPed(Handle, SelectedPedWeapon, -9999)
			SetAmmoInClip(Handle, SelectedPedWeapon, 0)
			SetPedFiringPattern(Handle, FIRING_PATTERN_SINGLE_SHOT)
			SetPedAccuracy(Handle, 0)
		end
	end
end)
MenuRoot:toggle_loop("Delete Enemy Peds (M)", DummyCmdTbl, "", function()
	local Peds = World.HandlesPedsM
	for Peds as Ped do
		if IsPedEnemy(Ped) then
			SetEntityAsMissionEntity(Ped.Handle, false, true)
			DeleteEntity(Ped.Handle)
		end
	end
end)




local MenuRootPed;MenuRootPed = MenuRoot:list("View Peds (M) List", DummyCmdTbl, "",
	function()
		local Peds = World.HandlesPedsM
		for Peds as Ped do
			local Handle = Ped.Handle
			local PedMenu = MenuRootPed:list(("%s (%sm)"):format(Ped.ModelString, RoundNumber(Ped.Distance)), DummyCmdTbl, "")
			PedMenu:action("Kill Ped", DummyCmdTbl, "", function()
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					SetEntityHealth(Handle, 0)
				end
			end)
			PedMenu:action("Teleport Self To Ped", DummyCmdTbl, "", function()
				if DoesEntityExist(Handle) then
					local PedCoords = Ped.Coords
					SetEntityCoordsNoOffset(Player.Ped, PedCoords.x, PedCoords.y, PedCoords.z, false, false, false)
				end
			end)
			PedMenu:action("Teleport Ped To Self", DummyCmdTbl, "", function()
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					local SelfCoords = Player.Coords
					SetEntityCoordsNoOffset(Handle, SelfCoords.x, SelfCoords.y, SelfCoords.z, true, true, false)
				end
			end)
			PedMenu:action("Disarm Ped", DummyCmdTbl, "", function()
				while DoesEntityExist(Handle) and not NetworkRequestControlOfEntity(Handle) do
					yield()
				end
				if DoesEntityExist(Handle) then
					RemoveAllPedWeapons(Handle, false)
				end
			end)
			PedMenu:action("Delete Ped", DummyCmdTbl, "", function()
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
		local PedMenuList = MenuRootPed:getChildren()
		for PedMenuList as PedMenu do
			PedMenu:delete()
		end
	end
)