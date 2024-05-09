local DummyCmdTbl = _G2.DummyCmdTbl

local yield_once = util.yield_once

local menu_ref_by_command_name = menu.ref_by_command_name
local players_get_script_host = players.get_script_host
local players_user = players.user
local players_get_host = players.get_host

local GetScriptHostRef = menu_ref_by_command_name("scripthost")

local ARSH = Script("AutoRotateScriptHost")

local CommandNames = {"hcinsfincp","hcinsfincah","hcinsfindooms"}
local __Commands = {}
local DeleteCommands = function()
	for i, Command in __Commands do
		if Command:isValid() then Command:delete() end
		__Commands[i]=nil
	end
end

local Menu;Menu = menu.my_root():list("Heist Control - Instant Finish", DummyCmdTbl, "",
	function()
		DeleteCommands()
		if not menu_ref_by_command_name("hcinsfin"):isValid() then return end
		for i=1,#CommandNames do
			local CommandRef = menu_ref_by_command_name(CommandNames[i])
			if CommandRef:isValid() then
				__Commands[#__Commands+1]=Menu:action(CommandRef.menu_name, DummyCmdTbl, CommandRef.help_text, function()
					ARSH.Pause(true)
					if players_get_script_host() ~= players_user() then
						GetScriptHostRef:trigger()
						repeat
							yield_once()
						until players_get_script_host() == players_user()
					end
					CommandRef:trigger()
					ARSH.Pause(false)
					--if not ARSH.IsEnabled() then
						ARSH.GiveScriptHostToPlayer(players_get_host())
					--end
				end)
			end
		end
	end,
	DeleteCommands
)
