-- ***************************************************
-- **             DBM Range Check Frame             **
-- **         http://www.deadlybossmods.com         **
-- ***************************************************
--
-- This addon is written and copyrighted by:
--    * Paul Emmerich (Tandanu @ EU-Aegwynn) (DBM-Core)
--    * Martin Verges (Nitram @ EU-Azshara) (DBM-GUI)
--
-- The localizations are written by:
--    * enGB/enUS: Tandanu				http://www.deadlybossmods.com
--    * deDE: Tandanu					http://www.deadlybossmods.com
--    * zhCN: Diablohu					http://wow.gamespot.com.cn
--    * ruRU: BootWin					bootwin@gmail.com
--    * ruRU: Vampik					admin@vampik.ru
--    * zhTW: Hman						herman_c1@hotmail.com
--    * zhTW: Azael/kc10577				paul.poon.kw@gmail.com
--    * koKR: BlueNyx/nBlueWiz			bluenyx@gmail.com / everfinale@gmail.com
--    * esES: Snamor/1nn7erpLaY      	romanscat@hotmail.com
--
-- Special thanks to:
--    * Arta
--    * Omegal @ US-Whisperwind (continuing mod support for 3.2+)
--    * Tennberg (a lot of fixes in the enGB/enUS localization)
--
--
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 License. (see license.txt)
-- All included textures and sounds are copyrighted by their respective owners.
--
--
--  You are free:
--    * to Share ?to copy, distribute, display, and perform the work
--    * to Remix ?to make derivative works
--  Under the following conditions:
--    * Attribution. You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).
--    * Noncommercial. You may not use this work for commercial purposes.
--    * Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.
--
--
-- This file makes use of the following free (Creative Commons Sampling Plus 1.0) sounds:
--    * alarmclockbeeps.ogg by tedthetrumpet (http://www.freesound.org/usersViewSingle.php?id=177)
--    * blip_8.ogg by Corsica_S (http://www.freesound.org/usersViewSingle.php?id=7037)
--  The full of text of the license can be found in the file "Sounds\Creative Commons Sampling Plus 1.0.txt".

---------------
--  Globals  --
---------------
DBM.RangeCheck = {}


--------------
--  Locals  --
--------------
local rangeCheck = DBM.RangeCheck
local checkFuncs = {}
local frame
local createFrame
local radarFrame
local createRadarFrame
local onUpdate
local onUpdateRadar
local dropdownFrame
local initializeDropdown
local initRangeCheck -- initializes the range check for a specific range (if necessary), returns false if the initialization failed (because of a map range check in an unknown zone)
local dots = {}
local charms = {}

-- for Phanx' Class Colors
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local BLIP_TEX_COORDS = {
	["WARRIOR"]	= { 0,	   0.125, 0,    0.25 },
	["PALADIN"]	= { 0.125, 0.25,  0,    0.25 },
	["HUNTER"]	= { 0.25,  0.375, 0,    0.25 },
	["ROGUE"]	= { 0.375, 0.5,   0,    0.25 },
	["PRIEST"]	= { 0.5,   0.625, 0,    0.25 },
	["DEATHKNIGHT"]	= { 0.625, 0.75,  0,    0.25 },
	["SHAMAN"]	= { 0.75,  0.875, 0,    0.25 },
	["MAGE"]	= { 0.875, 1,     0,    0.25 },
	["WARLOCK"]	= { 0,     0.125, 0.25, 0.5  },
	["DRUID"]	= { 0.25,  0.375, 0.25, 0.5  },
	["MONK"]	= { 0.125, 0.25, 0.25, 0.5 }
}
local CHARM_TEX_COORDS = {
	[1] = 	{ 0,	0.25, 0,    0.25 },
	[2] = 	{ 0.25, 0.5,  0,    0.25 },
	[3] = 	{ 0.5, 	0.75, 0,    0.25 },
	[4] = 	{ 0.75, 1,    0,    0.25 },
	[5] = 	{ 0, 	0.25, 0.25, 0.5  },
	[6] = 	{ 0.25, 0.5,  0.25, 0.5  },
	[7] = 	{ 0.5, 	0.75, 0.25, 0.5  },
	[8] = 	{ 0.75, 1,    0.25, 0.5  }
}
---------------------
--  Dropdown Menu  --
---------------------

-- todo: this dropdown menu is somewhat ugly and unflexible....
do
	local function setRange(self, range)
		rangeCheck:Show(range)
	end

	local sound0 = "none"
	local sound1 = "Interface\\AddOns\\DBM-Core\\Sounds\\blip_8.ogg"
	local sound2 = "Interface\\AddOns\\DBM-Core\\Sounds\\alarmclockbeeps.ogg"
	local function setSound(self, option, sound)
		DBM.Options[option] = sound
		if sound ~= "none" then
			if DBM.Options.UseMasterVolume then
				PlaySoundFile(sound, "Master")
			else
				PlaySoundFile(sound)
			end
		end
	end

	local function setFrames(self, option)
		DBM.Options.RangeFrameFrames = option
		radarFrame:Hide()
		frame:Hide()
		rangeCheck:Show(frame.range, frame.filter)
	end

--	local function setSpeed(self, option)
--		DBM.Options.RangeFrameUpdates = option
--	end

	local function toggleLocked()
		DBM.Options.RangeFrameLocked = not DBM.Options.RangeFrameLocked
	end

	local function toggleRadar()
		DBM.Options.RangeFrameRadar = not DBM.Options.RangeFrameRadar
		if DBM.Options.RangeFrameRadar then
			radarFrame = radarFrame or createRadarFrame()
			radarFrame:Show()
		else
			radarFrame:Hide()
		end
	end

	function initializeDropdown(dropdownFrame, level, menu)
		local info
		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_SETRANGE
			info.notCheckable = true
			info.hasArrow = true
			info.menuList = "range"
			UIDropDownMenu_AddButton(info, 1)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_SOUNDS
			info.notCheckable = true
			info.hasArrow = true
			info.menuList = "sounds"
			UIDropDownMenu_AddButton(info, 1)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_OPTION_FRAMES
			info.notCheckable = true
			info.hasArrow = true
			info.menuList = "frames"
			UIDropDownMenu_AddButton(info, 1)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_LOCK
			if DBM.Options.RangeFrameLocked then
				info.checked = true
			end
			info.func = toggleLocked
			UIDropDownMenu_AddButton(info, 1)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_HIDE
			info.notCheckable = true
			info.func = rangeCheck.Hide
			info.arg1 = rangeCheck
			UIDropDownMenu_AddButton(info, 1)

		elseif level == 2 then
			if menu == "range" then
				if initRangeCheck() then
					info = UIDropDownMenu_CreateInfo()
					info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(6)
					info.func = setRange
					info.arg1 = 6
					info.checked = (frame.range == 6)
					UIDropDownMenu_AddButton(info, 2)
				end

				if initRangeCheck() then
					info = UIDropDownMenu_CreateInfo()
					info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(8)
					info.func = setRange
					info.arg1 = 8
					info.checked = (frame.range == 8)
					UIDropDownMenu_AddButton(info, 2)
				end

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(10)
				info.func = setRange
				info.arg1 = 10
				info.checked = (frame.range == 10)
				UIDropDownMenu_AddButton(info, 2)

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(11)
				info.func = setRange
				info.arg1 = 11
				info.checked = (frame.range == 11)
				UIDropDownMenu_AddButton(info, 2)

				if initRangeCheck() then
					info = UIDropDownMenu_CreateInfo()
					info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(12)
					info.func = setRange
					info.arg1 = 12
					info.checked = (frame.range == 12)
					UIDropDownMenu_AddButton(info, 2)
				end

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(15)
				info.func = setRange
				info.arg1 = 15
				info.checked = (frame.range == 15)
				UIDropDownMenu_AddButton(info, 2)

				if initRangeCheck() then
					info = UIDropDownMenu_CreateInfo()
					info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(20)
					info.func = setRange
					info.arg1 = 20
					info.checked = (frame.range == 20)
					UIDropDownMenu_AddButton(info, 2)
				end

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_SETRANGE_TO:format(28)
				info.func = setRange
				info.arg1 = 28
				info.checked = (frame.range == 28)
				UIDropDownMenu_AddButton(info, 2)
			elseif menu == "sounds" then
				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_SOUND_OPTION_1
				info.notCheckable = true
				info.hasArrow = true
				info.menuList = "RangeFrameSound1"
				UIDropDownMenu_AddButton(info, 2)

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_SOUND_OPTION_2
				info.notCheckable = true
				info.hasArrow = true
				info.menuList = "RangeFrameSound2"
				UIDropDownMenu_AddButton(info, 2)
			elseif menu == "frames" then
				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_OPTION_TEXT
				info.func = setFrames
				info.arg1 = "text"
				info.checked = (DBM.Options.RangeFrameFrames == "text")
				UIDropDownMenu_AddButton(info, 2)

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_OPTION_RADAR
				info.func = setFrames
				info.arg1 = "radar"
				info.checked = (DBM.Options.RangeFrameFrames == "radar")
				UIDropDownMenu_AddButton(info, 2)

				info = UIDropDownMenu_CreateInfo()
				info.text = DBM_CORE_RANGECHECK_OPTION_BOTH
				info.func = setFrames
				info.arg1 = "both"
				info.checked = (DBM.Options.RangeFrameFrames == "both")
				UIDropDownMenu_AddButton(info, 2)
			end
		elseif level == 3 then
			local option = menu
			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_SOUND_0
			info.func = setSound
			info.arg1 = option
			info.arg2 = sound0
			info.checked = (DBM.Options[option] == sound0)
			UIDropDownMenu_AddButton(info, 3)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_SOUND_1
			info.func = setSound
			info.arg1 = option
			info.arg2 = sound1
			info.checked = (DBM.Options[option] == sound1)
			UIDropDownMenu_AddButton(info, 3)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_RANGECHECK_SOUND_2
			info.func = setSound
			info.arg1 = option
			info.arg2 = sound2
			info.checked = (DBM.Options[option] == sound2)
			UIDropDownMenu_AddButton(info, 3)
		end
	end
end

-----------------
-- Play Sounds --
-----------------
local function updateSound(numPlayers) -- called every 5 seconds
	if not UnitAffectingCombat("player") then
		return
	end
	if numPlayers == 1 then
		if DBM.Options.RangeFrameSound1 ~= "none" then
			if DBM.Options.UseMasterVolume then
				PlaySoundFile(DBM.Options.RangeFrameSound1, "Master")
			else
				PlaySoundFile(DBM.Options.RangeFrameSound1)
			end
		end
	elseif numPlayers > 1 then
		if DBM.Options.RangeFrameSound2 ~= "none" then
			if DBM.Options.UseMasterVolume then
				PlaySoundFile(DBM.Options.RangeFrameSound2, "Master")
			else
				PlaySoundFile(DBM.Options.RangeFrameSound2)
			end
		end
	end
end

------------------------
--  Create the frame  --
------------------------
function createFrame()
	local elapsed = 0
	local frame = CreateFrame("GameTooltip", "DBMRangeCheck", UIParent, "GameTooltipTemplate")
	dropdownFrame = CreateFrame("Frame", "DBMRangeCheckDropdown", frame, "UIDropDownMenuTemplate")
	frame:SetFrameStrata("DIALOG")
	frame:SetPoint(DBM.Options.RangeFramePoint, UIParent, DBM.Options.RangeFramePoint, DBM.Options.RangeFrameX, DBM.Options.RangeFrameY)
	frame:SetHeight(64)
	frame:SetWidth(64)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetMovable()
	GameTooltip_OnLoad(frame)
	frame:SetPadding(16)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if not DBM.Options.RangeFrameLocked then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ValidateFramePosition(self)
		local point, _, _, x, y = self:GetPoint(1)
		DBM.Options.RangeFrameX = x
		DBM.Options.RangeFrameY = y
		DBM.Options.RangeFramePoint = point
	end)
	frame:SetScript("OnUpdate", function(self, e)
		elapsed = elapsed + e
		if elapsed >= 0.04 and self.checkFunc then
			onUpdate(self, elapsed)
			elapsed = 0
		end
	end)
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			UIDropDownMenu_Initialize(dropdownFrame, initializeDropdown, "MENU")
			ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
		end
	end)
	return frame
end

function createRadarFrame()
	local elapsed = 0
	local radarFrame = CreateFrame("Frame", "DBMRangeCheckRadar", UIParent)
	radarFrame:SetFrameStrata("DIALOG")

	radarFrame:SetPoint(DBM.Options.RangeFrameRadarPoint, UIParent, DBM.Options.RangeFrameRadarPoint, DBM.Options.RangeFrameRadarX, DBM.Options.RangeFrameRadarY)
	radarFrame:SetHeight(128)
	radarFrame:SetWidth(128)
	radarFrame:EnableMouse(true)
	radarFrame:SetToplevel(true)
	radarFrame:SetMovable()
	radarFrame:RegisterForDrag("LeftButton")
	radarFrame:SetScript("OnDragStart", function(self)
		if not DBM.Options.RangeFrameLocked then
			self:StartMoving()
		end
	end)
	radarFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ValidateFramePosition(self)
		local point, _, _, x, y = self:GetPoint(1)
		DBM.Options.RangeFrameRadarX = x
		DBM.Options.RangeFrameRadarY = y
		DBM.Options.RangeFrameRadarPoint = point
	end)
	radarFrame:SetScript("OnUpdate", function(self, e)
		elapsed = elapsed + e
		if elapsed >= 0.04 then
			onUpdateRadar(self, elapsed)
			elapsed = 0
		end
	end)
	radarFrame:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			UIDropDownMenu_Initialize(dropdownFrame, initializeDropdown, "MENU")
			ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
		end
	end)

	local bg = radarFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(radarFrame)
	bg:SetBlendMode("BLEND")
	bg:SetTexture(0, 0, 0, 0.3)
	radarFrame.background = bg

	local circle = radarFrame:CreateTexture(nil, "ARTWORK")
	circle:SetPoint("CENTER")
	circle:SetTexture("Interface\\AddOns\\DBM-Core\\textures\\radar_circle.blp")
	circle:SetBlendMode("ADD")
	radarFrame.circle = circle

	local player = radarFrame:CreateTexture(nil, "OVERLAY")
	player:SetSize(32, 32)
	player:SetTexture("Interface\\Minimap\\MinimapArrow.blp")
	player:SetBlendMode("ADD")
	player:SetPoint("CENTER")

	local text = radarFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	text:SetWidth(128)
	text:SetHeight(15)
	text:SetPoint("BOTTOMLEFT", radarFrame, "TOPLEFT", 0,0)
	text:SetTextColor(1, 1, 1, 1)
	text:Show()
	radarFrame.text = text

	local inRangeText = radarFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	inRangeText:SetWidth(128)
	inRangeText:SetHeight(15)
	inRangeText:SetPoint("TOPLEFT", radarFrame, "BOTTOMLEFT", 0,0)
	inRangeText:SetTextColor(1, 1, 1, 1)
	inRangeText:Hide()
	radarFrame.inRangeText = inRangeText
	
--	for i=1, 40 do
--		local dot = CreateFrame("Frame", "DBMRangeCheckRadarDot"..i, radarFrame, "WorldMapPartyUnitTemplate")
--		dot:SetWidth(24)
--		dot:SetHeight(24)
--		dot:SetFrameStrata("TOOLTIP")
--		dot:Hide()
--		dots[i] = {dot = dot}
--	end
	for i=1, 8 do
		local charm = radarFrame:CreateTexture("DBMRangeCheckRadarCharm"..i, "OVERLAY")
		charm:SetTexture("interface\\targetingframe\\UI-RaidTargetingIcons.blp")
		charm:SetWidth(16)
		charm:SetHeight(16)
		charm:SetTexCoord(
			CHARM_TEX_COORDS[i][1],
			CHARM_TEX_COORDS[i][2],
			CHARM_TEX_COORDS[i][3],
			CHARM_TEX_COORDS[i][4]
		)
		charm:Hide()
		charms[i] = charm
	end

	radarFrame:Hide()
	return radarFrame
end

----------------
--  OnUpdate  --
----------------

local soundUpdate = 0
function onUpdate(self, elapsed)
	local color
	local j = 0
	self:ClearLines()
	self:SetText(DBM_CORE_RANGECHECK_HEADER:format(self.range), 1, 1, 1)
	if initRangeCheck(self.range) then
		if IsInRaid() then
			for i = 1, GetNumGroupMembers() do
				local uId = "raid"..i
				if not UnitIsUnit(uId, "player") and not UnitIsDeadOrGhost(uId) and self.checkFunc(uId, self.range) and (not self.filter or self.filter(uId)) then
					j = j + 1
					color = RAID_CLASS_COLORS[select(2, UnitClass(uId))] or NORMAL_FONT_COLOR
					local icon = GetRaidTargetIndex(uId)
					local text = icon and ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t %s"):format(icon, UnitName(uId)) or UnitName(uId)
					self:AddLine(text, color.r, color.g, color.b)
					if j >= 5 then
						break
					end
				end
			end
		elseif GetNumSubgroupMembers() > 0 then
			for i = 1, GetNumSubgroupMembers() do
				local uId = "party"..i
				if not UnitIsUnit(uId, "player") and not UnitIsDeadOrGhost(uId) and self.checkFunc(uId, self.range) and (not self.filter or self.filter(uId)) then
					j = j + 1
					color = RAID_CLASS_COLORS[select(2, UnitClass(uId))] or NORMAL_FONT_COLOR
					local icon = GetRaidTargetIndex(uId)
					local text = icon and ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t %s"):format(icon, UnitName(uId)) or UnitName(uId)
					self:AddLine(text, color.r, color.g, color.b)
					if j >= 5 then
						break
					end
				end
			end
		end
	else
		self:AddLine(DBM_CORE_RANGE_CHECK_ZONE_UNSUPPORTED:format(self.range))
	end
	soundUpdate = soundUpdate + elapsed
	if soundUpdate >= 5 and j >= self.redCircleNumPlayers then
		updateSound(j)
		soundUpdate = 0
	end
	self:Show()
end

do
	local rotation, pixelsperyard, prevNumPlayers, range, isInSupportedArea, prevNumPlayersTooClose
	local function createDot(id)
		local dot = CreateFrame("Frame", "DBMRangeCheckRadarDot"..id, radarFrame, "WorldMapPartyUnitTemplate")
		dot:SetFrameStrata("TOOLTIP")
		dot:SetWidth(24)
		dot:SetHeight(24)
		dot:Hide()

		dots[id].dot = dot	-- store the dot so we can use it later again
		return dot
	end

	local function setDotColor(id, class)
		if class and class == dots[id].class then return end
		if not class then class = "PRIEST" end	-- if class=nil -> use white dots (priest)
		dots[id].dot.icon:SetTexCoord(
			BLIP_TEX_COORDS[class][1],
			BLIP_TEX_COORDS[class][2],
			BLIP_TEX_COORDS[class][3],
			BLIP_TEX_COORDS[class][4]
		)
		dots[id].class = class
	end

	local function setDot(id, icon, filtered)
		local dot = dots[id].dot or createDot(id)		-- load the dot, or create a new one if none exists yet (creating new probably never happens as the dots are created when the frame is created)
		local x = dots[id].x
		local y = dots[id].y
		local range = (x*x + y*y) ^ 0.5
		if range < (1.5 * frame.range) then							-- if person is closer than 1.5 * range, show the dot. Else hide it
			local dx = ((x * math.cos(rotation)) - (-y * math.sin(rotation))) * pixelsperyard		-- Rotate the X,Y based on player facing
			local dy = ((x * math.sin(rotation)) + (-y * math.cos(rotation))) * pixelsperyard

			if icon and type(icon) == "number" and icon >= 1 and icon <= 8 then -- GetRaidTargetIndex seems to return strange values sometimes; see http://www.deadlybossmods.com/phpbb3/viewtopic.php?f=2&t=3213&p=30889#p30889
				if dots[id].icon and dots[id].icon ~= icon then
					charms[dots[id].icon]:Hide()
				end
				if not filtered then
					charms[icon]:ClearAllPoints()
					charms[icon]:SetPoint("CENTER", radarFrame, "CENTER", dx, dy)
					charms[icon]:Show()
				else
					charms[icon]:Hide()
				end
				dot:Hide()
				dots[id].icon = icon
			elseif not filtered then
				dot:ClearAllPoints()
				dot:SetPoint("CENTER", radarFrame, "CENTER", dx, dy)
				dot:Show()
				if dots[id].icon then
					charms[dots[id].icon]:Hide()
					dots[id].icon = nil
				end
			else
				if dots[id].icon and dots[id].icon ~= icon then
					charms[dots[id].icon]:Hide()
					dots[id].icon = nil
				end
				dot:Hide()
			end
		else
			dot:Hide()
			if dots[id].icon then
				charms[dots[id].icon]:Hide()
				dots[id].icon = nil
			end
		end
		if range < 1.10 * frame.range and not filtered then		-- add an  extra 10% in case of inaccuracy
			dots[id].tooClose = true
		else
			dots[id].tooClose = false
		end
	end

	function onUpdateRadar(self, elapsed)
		if initRangeCheck(frame.range) then--This is basically fixing a bug with map not being on right dungeon level half the time.
			pixelsperyard = min(radarFrame:GetWidth(), radarFrame:GetHeight()) / (frame.range * 3)
			radarFrame.circle:SetSize(frame.range * pixelsperyard * 2, frame.range * pixelsperyard * 2)

			if frame.range ~= (range or 0) then
				range = frame.range
				radarFrame.text:SetText(DBM_CORE_RANGERADAR_HEADER:format(range))
			end

			local mapName = GetMapInfo()
			local dims  = DBM.MapSizes[mapName] and DBM.MapSizes[mapName][GetCurrentMapDungeonLevel()]
			if not dims then -- This ALWAYS happens when leaving a zone that has a map and moving into one that does not.
				if select(3, radarFrame.circle:GetVertexColor()) < 0.5 then
					radarFrame.circle:SetVertexColor(1,1,1)
				end
				for i, v in pairs(dots) do
					v.dot:Hide()
				end
				for i = 1, 8 do
					charms[i]:Hide()
				end
			else
				isInSupportedArea = true
				rotation = (2 * math.pi) - GetPlayerFacing()
				local numPlayers = 0
				local unitID = "raid%d"
				if IsInRaid() then
					unitID = "raid%d"
					numPlayers = GetNumGroupMembers()
				elseif GetNumSubgroupMembers() > 0 then
					unitID = "party%d"
					numPlayers = GetNumSubgroupMembers()
				end
				if numPlayers < (prevNumPlayers or 0) then
					for i = numPlayers, prevNumPlayers do
						if dots[i] then
							if dots[i].dot then
								dots[i].dot:Hide()		-- Hide dots when people leave the group
							end
							dots[i].tooClose = false
							dots[i].icon = nil
						end
					end
					for i=1, 8 do
						charms[i]:Hide()
					end
				end
				prevNumPlayers = numPlayers

				local playerX, playerY = GetPlayerMapPosition("player")
				if playerX == 0 and playerY == 0 then return end		-- Somehow we can't get the correct position?

				for i=1, numPlayers do
					local uId = unitID:format(i)
					if not UnitIsUnit(uId, "player") then
						local x,y = GetPlayerMapPosition(uId)
						if UnitIsDeadOrGhost(uId) then x = 100 end	-- hack to make sure dead people aren't shown
						if not dots[i] then
							dots[i] = {
								icon = nil,
								class = "none",
								x = (x - playerX) * dims[1],
								y = (y - playerY) * dims[2]
							}
						else
							dots[i].x = (x - playerX) * dims[1]
							dots[i].y = (y - playerY) * dims[2]
						end
						setDot(i, GetRaidTargetIndex(uId), (frame.filter and not frame.filter(uId)))
						setDotColor(i, (select(2, UnitClass(uId))))
					else
						if dots[i] and dots[i].dot then
							dots[i].dot:Hide()
							dots[i].tooClose = false
						end
					end
				end

				local exceedsPlayersTooClose = false
				local numPlayersTooClose = 0
				for i,v in pairs(dots) do
					if v.tooClose then
						numPlayersTooClose = numPlayersTooClose + 1
						if numPlayersTooClose >= frame.redCircleNumPlayers then
							exceedsPlayersTooClose = true
						end
					end
				end
				if numPlayersTooClose ~= (prevNumPlayersTooClose or 0) then
					radarFrame.inRangeText:SetText(DBM_CORE_RANGERADAR_IN_RANGE_TEXT:format(numPlayersTooClose))
					if exceedsPlayersTooClose then	-- only show the text if the circle is red
						radarFrame.inRangeText:Show()
					else
						radarFrame.inRangeText:Hide()
					end
				end
				prevNumPlayersTooClose = numPlayersTooClose
				
				if UnitIsDeadOrGhost("player") then
					radarFrame.circle:SetVertexColor(1,1,1)
				elseif exceedsPlayersTooClose then
					radarFrame.circle:SetVertexColor(1,0,0)
				else
					radarFrame.circle:SetVertexColor(0,1,0)
				end
				self:Show()
			end
		else
			if isInSupportedArea then
				-- we were in an area with known map dimensions during the last update but looks like we left it
				isInSupportedArea = false
				-- white frame
				radarFrame.circle:SetVertexColor(1,1,1)
				-- hide everything
				for i, v in pairs(dots) do
					v.dot:Hide()
				end
				for i = 1, 8 do
					charms[i]:Hide()
				end
			end
		end
	end
end


-----------------------
--  Check functions  --
-----------------------
checkFuncs[11] = function(uId)
	return CheckInteractDistance(uId, 2)
end

checkFuncs[10] = function(uId)
	return CheckInteractDistance(uId, 3)
end

checkFuncs[28] = function(uId)
	return CheckInteractDistance(uId, 4)
end


local getDistanceBetween
do
	local mapSizes = DBM.MapSizes

	function getDistanceBetween(uId, x, y)
		local startX, startY = GetPlayerMapPosition(uId)
		local mapName = GetMapInfo()
		local dims  = mapSizes[mapName] and mapSizes[mapName][GetCurrentMapDungeonLevel()]
		if not dims then
			return
		end
		local dX = (startX - x) * dims[1]
		local dY = (startY - y) * dims[2]
		return math.sqrt(dX * dX + dY * dY)
	end

	local function mapRangeCheck(uId, range)
		return getDistanceBetween(uId, GetPlayerMapPosition("player")) < range
	end

	function initRangeCheck(range)
		if checkFuncs[range] ~= mapRangeCheck then
			return true
		end
		local pX, pY = GetPlayerMapPosition("player")
		if pX == 0 and pY == 0 then
			SetMapToCurrentZone()
			pX, pY = GetPlayerMapPosition("player")
		end
		local levels = mapSizes[GetMapInfo()]
		if not levels then
			return false
		end
		local dims = levels[GetCurrentMapDungeonLevel()]
		if not dims and levels and GetCurrentMapDungeonLevel() == 0 then -- we are in a known zone but the dungeon level seems to be wrong
			SetMapToCurrentZone() -- fixes the dungeon level
			dims = levels[GetCurrentMapDungeonLevel()] -- try again
			if not dims then -- there is actually a level 0 in this zone but we don't know about it...too bad :(
				return false
			end
		elseif not dims then
			return false
		end
		return true -- everything ok!
	end

	setmetatable(checkFuncs, {
		__index = function(t, k)
			return mapRangeCheck
		end
	})
end

do
	local bandages = {21991, 34721, 34722, 53049, 53050, 53051}  -- you should have one of these bandages in your cache

	checkFuncs[15] = function(uId)
		for i, v in ipairs(bandages) do
			if IsItemInRange(v, uId) == 1 then
				return true
			elseif IsItemInRange(v, uId) == 0 then
				return false
			end
		end
	end
end

---------------
--  Methods  --
---------------
function rangeCheck:Show(range, filter, forceshow, redCircleNumPlayers)
	if DBM.Options.DontShowRangeFrame and not forceshow then return end
	SetMapToCurrentZone()--Set map to current zone before checking other stuff, work around annoying bug i hope?
	if type(range) == "function" then -- the first argument is optional
		return self:Show(nil, range)
	end
	local mapName = GetMapInfo()
	range = range or 10
	redCircleNumPlayers = redCircleNumPlayers or 1
	frame = frame or createFrame()
	radarFrame = radarFrame or createRadarFrame()
	frame.checkFunc = checkFuncs[range] or error(("Range \"%d yd\" is not supported."):format(range), 2)
	frame.range = range
	frame.filter = filter
	frame.redCircleNumPlayers = redCircleNumPlayers
	if DBM.Options.RangeFrameFrames == "text" or DBM.Options.RangeFrameFrames == "both" or DBM.MapSizes[mapName] == nil or (DBM.MapSizes[mapName] and DBM.MapSizes[mapName][GetCurrentMapDungeonLevel()] == nil) then
		frame:Show()
		frame:SetOwner(UIParent, "ANCHOR_PRESERVE")
		onUpdate(frame, 0)
	end
	if (DBM.Options.RangeFrameFrames == "radar" or DBM.Options.RangeFrameFrames == "both") and (DBM.MapSizes[GetMapInfo()] and DBM.MapSizes[mapName][GetCurrentMapDungeonLevel()] ~= nil) then
		onUpdateRadar(radarFrame, 1)
	end
end

function rangeCheck:Hide()
	if frame then frame:Hide() end
	if radarFrame then radarFrame:Hide() end
end

function rangeCheck:IsShown()
	return frame and frame:IsShown() or radarFrame and radarFrame:IsShown()
end

function rangeCheck:GetDistance(...)
	if initRangeCheck() then
		return getDistanceBetween(...)
	end
end