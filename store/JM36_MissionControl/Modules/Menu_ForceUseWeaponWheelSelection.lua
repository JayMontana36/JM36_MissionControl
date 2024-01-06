local Info = Info
local Player = Info.Player
local Vehicle = Player.Vehicle

local GiveWeaponToPed = GiveWeaponToPed
local HudGetWeaponWheelCurrentlyHighlighted = HudGetWeaponWheelCurrentlyHighlighted

local CT = JM36.CreateThread
local yield = util.yield_once

--local Zero <const> = -1569615261

local Enabled
--local TimeLastPressed = 0
--local WeaponWheelLastHighlighted
local MenuRoot = menu.my_root():toggle("Force use weapon wheel selection", _G2.DummyCmdTbl, "", function(on)
	Enabled = on
	if Enabled then
		CT(function()
			while Enabled do
				if not Vehicle.IsIn then
					GiveWeaponToPed(Player.Ped, HudGetWeaponWheelCurrentlyHighlighted(), 9999, true, true)
				end
				--[[local WeaponWheelCurrentlyHighlighted = HudGetWeaponWheelCurrentlyHighlighted()
				if (Info.Time - TimeLastPressed) <= 100 and IsControlJustReleased(2,37) then
					if GetSelectedPedWeapon(Player.Ped) ~= Zero then
						GiveWeaponToPed(Player.Ped, Zero, 9999, true, true)
					else
						GiveWeaponToPed(Player.Ped, WeaponWheelCurrentlyHighlighted, 9999, true, true)
					end
				elseif IsControlJustPressed(2,37) then
					TimeLastPressed = Info.Time
				else
					GiveWeaponToPed(Player.Ped, WeaponWheelCurrentlyHighlighted, 9999, true, true)
				end]]
				yield()
			end
		end)
	end
end, Enabled)
