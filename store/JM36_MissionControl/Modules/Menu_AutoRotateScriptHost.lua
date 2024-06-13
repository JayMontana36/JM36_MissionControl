local DummyCmdTbl = _G2.DummyCmdTbl

local Info = Info
local CreateThread = JM36.CreateThread
local yield = JM36.yield
local yield_once = JM36.yield_once

local players_get_host = players.get_host
local players_get_script_host = players.get_script_host
local util_is_session_started = util.is_session_started
local util_is_session_transition_active = util.is_session_transition_active
local players_exists = players.exists

local NetworkIsActivitySession = NetworkIsActivitySession



local PlayerScriptHostRefs = {[0]=false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false} -- 0-31

local GiveScriptHostToPlayer = function(PlayerId)
	if PlayerScriptHostRef := PlayerScriptHostRefs[PlayerId] then
		PlayerScriptHostRef:trigger()
	end
end

local Enabled, ActivitySessionOnly, Delay = true, true, 20000
local ___Pause;do
	local ARSH = Script("AutoRotateScriptHost")
	--ARSH.IsEnabled = function()return Enabled end
	--ARSH.IsPaused = function()return ___Pause end
	ARSH.Pause = function(State)___Pause=State end
	--ARSH.IsActivitySessionOnly = function()return ActivitySessionOnly end
	ARSH.GiveScriptHostToPlayer = GiveScriptHostToPlayer
end

local Menu = menu.my_root():list("Script Host Rotation Options", DummyCmdTbl, "")
Menu:toggle("Enable Automatic Script Host Rotation", DummyCmdTbl, "", function(on)
	Enabled = on;if on then
		CreateThread(function()
			local PlayerId, PlayerScriptHostRef = -1, false
			while Enabled do
				if util_is_session_started() and not util_is_session_transition_active() then
					if NetworkIsActivitySession() then
						while ___Pause do
							yield_once()
						end
						if (SessionHost := players_get_host()) and SessionHost ~= players_get_script_host() then
							GiveScriptHostToPlayer(SessionHost)
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
					else
						yield_once()
					end
				else
					yield_once()
				end
			end
			GiveScriptHostToPlayer(players_get_host())
		end)
	end
end, Enabled)
Menu:toggle("For Missions/Heists Only", DummyCmdTbl, "Limit Automatic Script Host Rotation To Missions/Heists", function(on)
	ActivitySessionOnly = on
end, ActivitySessionOnly)
Menu:slider("Set Automatic Script Host Rotation Delay", DummyCmdTbl, "", 15, 45, Delay/1000, 5, function(value)
	Delay = value * 1000
end)

return{
	join	=	function(PlayerId, PlayerRoot)
					local TimeAdd = Info.Time + 105000 -- 1m45s aka 90s+15s
					local StillHere
					repeat
						yield_once()
						StillHere = players_exists(PlayerId)
					until not StillHere or Info.Time > TimeAdd
					if not StillHere then return end
					PlayerScriptHostRefs[PlayerId] = PlayerRoot:refByRelPath"Friendly>Give Script Host"
				end,
	left	=	function(PlayerId, PlayerName)
					PlayerScriptHostRefs[PlayerId] = false
				end,
}
