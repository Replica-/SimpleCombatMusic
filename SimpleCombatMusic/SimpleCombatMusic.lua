local combatFlag = false
local songId = false
local defaultVol = '1'  -- GetCVar("Sound_MusicVolume")
local stepSize = 0.2
local fadeStep = 0.1
local frame = nil

local function PlaySong(self, type)

	if SongCountTotal == nil then
		return nil
	end

	type = type or 'song'

	local fullPath = "Interface\\Music\\Battles" .. "\\" .. type .. random(1, SongCountTotal) ..  ".mp3"
	local song = PlayMusic(fullPath)
	local unitName = UnitName('target')
	local bossMode = UnitIsBossMob('target')
	return song
end

local function OnAddonEvent(self, event, arg1)

	-- Only when FrameXML loads & Only when saved variable is imported in
	if (event == "ADDON_LOADED" and arg1 == "SimpleCombatMusic" and frame ~= nil) then
		local panel = frame
		local helloFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		helloFS:SetPoint("TOPLEFT", panel, 0, -20);
		helloFS:SetText("Song Count")

		editFrame = CreateFrame("EditBox", nil, panel, "InputBoxTemplate");
		editFrame:SetPoint("TOPLEFT", panel, 80, -19);
		editFrame:SetWidth(40);
		editFrame:SetHeight(20);
		editFrame:SetMovable(false);
		editFrame:SetAutoFocus(false);
		editFrame:SetMultiLine(1000);
		editFrame:SetNumeric(true)

		if SongCountTotal ~= nil then
			editFrame:SetText(SongCountTotal)
		end
	
		editFrame:SetScript("OnTextChanged", function(self)
		  local val = self:GetText()
		  SongCountTotal = val
		end)
	
	elseif event == "PLAYER_LOGOUT" then
        -- Save the time at which the character logs out
        
	end
end

local function OnEvent(self, event, ...)
	if (event == "PLAYER_REGEN_DISABLED") then
		local instance = GetInstanceInfo()
		combatFlag = true
		
		-- We need black list for Ashran because the music there is pretty good
		
	elseif (event =="PLAYER_REGEN_ENABLED") then
		combatFlag = false
		playerEngaged = false
	
	elseif (event =="COMBAT_LOG_EVENT") then
		local _, subevent, _, sourceGUID, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
		if sourceGUID == UnitGUID("player") then
			playerEngaged = true
		end
	end
end

local function tick(self)
	currentVol = tonumber(GetCVar("Sound_MusicVolume"))

	-- We are playing a song and in combat
	if (songId == false and combatFlag == true) then
		songId = PlaySong('song')
	end
		
	-- We are playing a song but no longer in combat but we haven't faded completely
	if (songId and combatFlag == false and currentVol > fadeStep) then
		currentVol = currentVol - stepSize	
		SetCVar("Sound_MusicVolume", currentVol)
	end

	-- We are playing a song but no longer in combat but we haven't faded completely
	if (songId and combatFlag == true and currentVol < 1) then
		currentVol = currentVol + (stepSize *2)	
		SetCVar("Sound_MusicVolume", currentVol)
	end

	-- We are playing a song and we've completely faded it
	if (songId and combatFlag == false and currentVol <= fadeStep) then
		if songId then
			StopMusic()
		end
		SetCVar("Sound_MusicVolume", defaultVol)
		songId = false
	end

end

local g = CreateFrame("Frame")
g:RegisterEvent("ADDON_LOADED")
g:RegisterEvent("PLAYER_LOGOUT")
g:SetScript("OnEvent", OnAddonEvent)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
--f:RegisterEvent("COMBAT_LOG_EVENT")
f:SetScript("OnEvent", OnEvent)
C_Timer.NewTicker(0.5, tick)


-- Enable the music, dummy!
if not GetCVarBool("Sound_EnableMusic") then
	SetCVar("Sound_MusicVolume", "0")
end
SetCVar("Sound_EnableMusic", "1")

function Panel_OnLoad(panel)
   	
    panel.name = 'SimpleCombatMusic'
	frame = panel

    InterfaceOptions_AddCategory(panel);
end