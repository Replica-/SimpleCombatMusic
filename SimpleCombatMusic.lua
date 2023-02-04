local combatFlag = false
local songId = false
local stepSize = 0.2
local fadeStep = 0.1
local frame = nil
local warning = false;

BINDING_NAME_SIMPLECOMBATMUSIC_NEXTSONG = 'Play Next Song'	

function PlaySong(self, type)

	if (SongCountTotal == nil or SongCountTotal == '' or SongCountTotal == '0') then
		if (warning == false) then
			print "Simple Combat Music: Please set Song Total in Addon Options"
			warning = true
		end
		return false
	else

		type = type or 'song'

		local fullPath = "Interface\\Music\\Battles" .. "\\" .. type .. random(1, SongCountTotal) ..  ".mp3"
		local song = PlayMusic(fullPath)
		local unitName = UnitName('target')
		local bossMode = UnitIsBossMob('target')
		return song
	end
end

function PlaySimpleCombatSong() 
	PlaySong()
	print('Simple Combat Music: Playing random song....')
end

local function OnAddonEvent(self, event, arg1)

	-- Only when FrameXML loads & Only when saved variable is imported in
	if (event == "ADDON_LOADED" and arg1 == "SimpleCombatMusic" and frame ~= nil) then
		local panel = frame
		local helloFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		helloFS:SetPoint("TOPLEFT", panel, 0, -20);
		helloFS:SetText("Song Count")

		editFrame = CreateFrame("EditBox", nil, panel, "InputBoxTemplate");
		editFrame:SetPoint("TOPLEFT", panel, 123, -19);
		editFrame:SetWidth(40);
		editFrame:SetHeight(20);
		editFrame:SetMovable(false);
		editFrame:SetAutoFocus(false);
		editFrame:SetMultiLine(1000);
		editFrame:SetNumeric(true)

		if (SongCountTotal == nil or SongCountTotal == '') then
			SongCountTotal = '0'
		end

		if SongCountTotal ~= nil then
			editFrame:SetText(SongCountTotal)
		end

		editFrame:SetScript("OnTextChanged", function(self)
		  local val = self:GetText()
		  SongCountTotal = val
		end)

		local helloFSS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		helloFSS:SetPoint("TOPLEFT", panel, 0, -60);
		helloFSS:SetText("Combat Volume")

		SongCountMusicVolume = tonumber(SongCountMusicVolume)
		if SongCountMusicVolume == nil or SongCountMusicVolume > 1 or SongCountMusicVolume < 0 then
			SongCountMusicVolume = 1
		end

		local MySlider = CreateFrame("Slider", "MySliderSimpleCombatMusic", panel, "OptionsSliderTemplate")
		MySlider:SetWidth(200)
		MySlider:SetHeight(20)
		MySlider:SetOrientation('HORIZONTAL')
		getglobal(MySlider:GetName() .. 'Low'):SetText('0%'); --Sets the left-side slider text (default is "Low").
		getglobal(MySlider:GetName() .. 'High'):SetText('100%'); --Sets the right-side slider text (default is "High").
		local formatted = string.format( "%.2f %%", SongCountMusicVolume*100)
		getglobal(MySlider:GetName() .. 'Text'):SetText(formatted); --Sets the "title" text (top-centre of slider).
		MySlider:SetMinMaxValues(0, 1)
		MySlider:SetValueStep(0.1)
		MySlider:Show()
		MySlider:SetPoint("TOPLEFT", panel, 120, -59);
		
		MySlider:SetValue(SongCountMusicVolume)
			
		MySlider:SetScript("OnValueChanged", function(self)
		  local val = self:GetValue()
		  SongCountMusicVolume = tonumber(val)
		   
			local formatted = string.format( "%.2f %%", SongCountMusicVolume*100)
		  getglobal(MySlider:GetName() .. 'Text'):SetText(formatted); --Sets the "title" text (top-centre of slider).
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
	if (songId and combatFlag == true and currentVol < SongCountMusicVolume) then
		currentVol = currentVol + (stepSize *2)	
		SetCVar("Sound_MusicVolume", currentVol)
	end

	-- We are playing a song and we've completely faded it
	if (songId and combatFlag == false and currentVol <= fadeStep) then
		if songId then
			StopMusic()
		end
		SetCVar("Sound_MusicVolume", tostring(SongCountMusicVolume))
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
