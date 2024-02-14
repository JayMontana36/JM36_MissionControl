local DummyCmdTbl = _G2.DummyCmdTbl

local CreateThread = JM36.CreateThread
local yield = JM36.yield
local yield_once = JM36.yield_once

local players_get_host = players.get_host
local players_get_script_host = players.get_script_host
local util_is_session_started = util.is_session_started
local util_is_session_transition_active = util.is_session_transition_active

local NetworkIsActivitySession = NetworkIsActivitySession



local PlayerScriptHostRefs = {[0]=false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false} -- 0-31

local GiveScriptHostToSessionHost = function()
	if PlayerScriptHostRef := PlayerScriptHostRefs[players_get_host()] then
		PlayerScriptHostRef:trigger()
	end
end

local Enabled, ActivitySessionOnly, Delay = false, false, 20000

local Menu = menu.my_root():list("Script Host Rotation Options", DummyCmdTbl, "")
Menu:toggle("Enable Automatic Script Host Rotation", DummyCmdTbl, "", function(on)
	Enabled = on;if on then
		CreateThread(function()
			local PlayerId, PlayerScriptHostRef = -1, false
			while Enabled do
				if util_is_session_started() and not util_is_session_transition_active() then
					if NetworkIsActivitySession() then
						if players_get_host() ~= players_get_script_host() then
							GiveScriptHostToSessionHost()
						end
						yield_once()
					elseif not ActivitySessionOnly then
						repeat
							PlayerId += 1
							PlayerScriptHostRef = PlayerScriptHostRefs[PlayerId]
						until PlayerScriptHostRef or PlayerId == 32
						if PlayerScriptHostRef then
							PlayerScriptHostRef:trigger()
							yield(Delay)
						else PlayerId = -1 end
					end
				else
					yield_once()
				end
			end
			GiveScriptHostToSessionHost()
		end)
	end
end, Enabled)
Menu:toggle("For Missions/Heists Only", DummyCmdTbl, "Enable Automatic Script Host Rotation Only In Missions/Heists", function(on)
	ActivitySessionOnly = on
end, Enabled)
Menu:slider("Set Automatic Script Host Rotation Delay", DummyCmdTbl, "", 15, 45, Delay/1000, 5, function(value)
	Delay = value * 1000
end)

return{
	join	=	function(PlayerId, PlayerRoot)
					PlayerScriptHostRefs[PlayerId] = PlayerRoot:refByRelPath"Friendly>Give Script Host"
				end,
	left	=	function(PlayerId, PlayerName)
					PlayerScriptHostRefs[PlayerId] = false
				end,
}
