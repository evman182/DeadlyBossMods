-- *********************************************************
-- **               Deadly Boss Mods - Core               **
-- **            http://www.deadlybossmods.com            **
-- *********************************************************
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
--    * zhTW: Hman						herman_c1@hotmail.com
--    * zhTW: Azael/kc10577				kc10577@hotmail.com
--    * koKR: BlueNyx					bluenyx@gmail.com
--    * esES: Interplay/1nn7erpLaY      http://www.1nn7erpLaY.com
--
-- Special thanks to:
--    * Arta (DBM-Party)
--    * Omegal @ US-Whisperwind (some patches, and DBM-Party updates)
--    * Tennberg (a lot of fixes in the enGB/enUS localization)
--
--
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 License. (see license.txt)
-- All included textures and sounds are copyrighted by their respective owners, license information for these media files can be found in the modules that make use of them.
--
--
--  You are free:
--    * to Share - to copy, distribute, display, and perform the work
--    * to Remix - to make derivative works
--  Under the following conditions:
--    * Attribution. You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work). (A link to http://www.deadlybossmods.com is sufficient)
--    * Noncommercial. You may not use this work for commercial purposes.
--    * Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.
--

-------------------------------
--  Globals/Default Options  --
-------------------------------
DBM = {
	Revision = ("$Revision$"):sub(12, -3),
	Version = "4.291",
	DisplayVersion = "4.29b"
}

DBM_SavedOptions = {}

DBM.DefaultOptions = {
	WarningColors = {
		{r = 0.41, g = 0.80, b = 0.94}, -- Color 1 - #69CCF0 - Turqoise
		{r = 0.95, g = 0.95, b = 0.00}, -- Color 2 - #F2F200 - Yellow
		{r = 1.00, g = 0.50, b = 0.00}, -- Color 3 - #FF8000 - Orange
		{r = 1.00, g = 0.10, b = 0.10}, -- Color 4 - #FF1A1A - Red
	},
	RaidWarningSound = "Sound\\Doodad\\BellTollNightElf.wav",
	SpecialWarningSound = "Sound\\Spells\\PVPFlagTaken.wav",
	RaidWarningPosition = {
		Point = "TOP",
		X = 0,
		Y = -185,
	},
	StatusEnabled = true,
	AutoRespond = true,
	Enabled = true,
	ShowWarningsInChat = true,
	ShowFakedRaidWarnings = false,
	WarningIconLeft = true,
	WarningIconRight = true,
	HideBossEmoteFrame = false,
	SpamBlockRaidWarning = true,
	SpamBlockBossWhispers = false,
	ShowMinimapButton = true,
	BlockVersionUpdatePopup = true,
	ShowSpecialWarnings = true,
	AlwaysShowHealthFrame = false,
	ShowBigBrotherOnCombatStart = false,
	RangeFramePoint = "CENTER",
	RangeFrameX = 50,
	RangeFrameY = -50,
	RangeFrameSound1 = "none",
	RangeFrameSound2 = "none",
	RangeFrameLocked = false,
	HPFramePoint = "CENTER",
	HPFrameX = -50,
	HPFrameY = 50,
	HPFrameMaxEntries = 5,
	SpecialWarningPoint = "CENTER",
	SpecialWarningX = 0,
	SpecialWarningY = 75,
	SpecialWarningFont = STANDARD_TEXT_FONT,
	SpecialWarningFontSize = 50,
	SpecialWarningFontColor = {0.0, 0.0, 1.0},
	HealthFrameGrowUp = false,
	HealthFrameLocked = false,
	HealthFrameWidth = 200
}

DBM.Bars = DBT:New()
DBM.Mods = {}

------------------------
-- Global Identifiers --
------------------------
DBM_DISABLE_ZONE_DETECTION = newproxy(false)
DBM_OPTION_SPACER = newproxy(false)

--------------
--  Locals  --
--------------
local inCombat = {}
local combatInfo = {}
local updateFunctions = {}
local raid = {}
local modSyncSpam = {}
local autoRespondSpam = {}
local chatPrefix = "<Deadly Boss Mods> "
local chatPrefixShort = "<DBM> "
local ver = ("%s (r%d)"):format(DBM.DisplayVersion, DBM.Revision)
local mainFrame = CreateFrame("Frame")
local showedUpdateReminder = false
local combatInitialized = false
local schedule
local unschedule
local loadOptions
local loadModOptions
local checkWipe
local fireEvent
local wowVersion = select(4, GetBuildInfo())

--------------------------------------------------------
--  Cache frequently used global variables in locals  --
--------------------------------------------------------
local DBM = DBM
-- these global functions are accessed all the time by the event handler
-- so caching them is worth the effort
local ipairs, pairs, next = ipairs, pairs, next
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe
local type = type
local select = select
local floor = math.floor

-- for Phanx' Class Colors
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

---------------------------------
--  General (local) functions  --
---------------------------------
-- checks if a given value is in an array
-- returns true if it finds the value, false otherwise
local function checkEntry(t, val)
	for i, v in ipairs(t) do
		if v == val then
			return true
		end
	end
	return false
end

-- removes all occurrences of a value in an array
-- returns true if at least one occurrence was remove, false otherwise
local function removeEntry(t, val)
	local existed = false
	for i = #t, 1, -1 do
		if t[i] == val then
			table.remove(t, i)
			existed = true
		end
	end
	return existed
end

-- automatically sends an addon message to the appropriate channel (BATTLEGROUND, RAID or PARTY)
local function sendSync(prefix, msg)
	if select(2, IsInInstance()) == "pvp" then
		SendAddonMessage(prefix, msg, "BATTLEGROUND")
	elseif GetNumRaidMembers() > 0 then
		SendAddonMessage(prefix, msg, "RAID")
	else
		SendAddonMessage(prefix, msg, "PARTY")
	end
end

--
local function strFromTime(time)
	if type(time) ~= "number" then time = 0 end
	time = math.floor(time)
	if time < 60 then
		return DBM_CORE_TIMER_FORMAT_SECS:format(time)
	elseif time % 60 == 0 then
		return DBM_CORE_TIMER_FORMAT_MINS:format(time/60)
	else
		return DBM_CORE_TIMER_FORMAT:format(time/60, time % 60)
	end
end

local pformat
do
	-- fail-safe format, replaces missing arguments with unknown
	-- note: doesn't handle cases like %%%s correct at the moment (should become %unknown, but becomes %%s)
	-- also, the end of the format directive is not detected in all cases, but handles everything that occurs in our boss mods ;)
	--> not suitable for general-purpose use, just for our warnings and timers (where an argument like a spell-target might be nil due to missing target information)
	
	local function replace(cap1, cap2)
		return cap1 == "%" and DBM_CORE_UNKNOWN
	end
	
	function pformat(fstr, ...)
		local ok, str = pcall(format, fstr, ...)
		return ok and str or fstr:gsub("(%%+)([^%%%s<]+)", replace):gsub("%%%%", "%%")
	end
end


--------------
--  Events  --
--------------
do
	local registeredEvents = {}
	local argsMT = {__index = {}}
	local args = setmetatable({}, argsMT)
	
	function argsMT.__index:IsSpellID(a1, a2, a3, a4)
		local v = self.spellId
		return v == a1 or v == a2 or v == a3 or v == a4
	end
	
	function argsMT.__index:IsPlayer()
		return bit.band(args.destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 and bit.band(args.destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
	end
	
	function argsMT.__index:IsPlayerSource()
		return bit.band(args.sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 and bit.band(args.sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
	end
	
	function argsMT.__index:IsPet()
		return bit.band(args.destFlags, COMBATLOG_OBJECT_TYPE_PET) ~= 0
	end
	
	function argsMT.__index:IsPetSource()
		return bit.band(args.sourceFlags, COMBATLOG_OBJECT_TYPE_PET) ~= 0
	end
	
	function argsMT.__index:GetSrcCreatureID()
		if wowVersion >= 30300 then
			return tonumber(self.sourceGUID:sub(7, 10), 16) or 0
		else
			return tonumber(self.sourceGUID:sub(9, 12), 16) or 0
		end
	end
	
	function argsMT.__index:GetDestCreatureID()
		if wowVersion >= 30300 then
			return tonumber(self.destGUID:sub(7, 10), 16) or 0
		else
			return tonumber(self.destGUID:sub(9, 12), 16) or 0
		end
	end
	
	local function handleEvent(self, event, ...)
		if not registeredEvents[event] or DBM.Options and not DBM.Options.Enabled then return end
		for i, v in ipairs(registeredEvents[event]) do
			if type(v[event]) == "function" and (not v.zones or checkEntry(v.zones, GetRealZoneText())) and (not v.Options or v.Options.Enabled) then
				v[event](v, ...)
			end
		end
	end

	function DBM:RegisterEvents(...)
		for i = 1, select("#", ...) do
			local ev = select(i, ...)
			registeredEvents[ev] = registeredEvents[ev] or {}
			tinsert(registeredEvents[ev], self)
			mainFrame:RegisterEvent(ev)
		end
	end
	
	function DBM:UnregisterAllEvents()
		for i, v in pairs(registeredEvents) do
			for i = #v, 1 do
				if v[i] == self then
					tremove(v, i)
				end
			end
			if #v == 0 then
				registeredEvents[i] = nil
				mainFrame:UnregisterEvent(i)
			end
		end
	end

	DBM:RegisterEvents("ADDON_LOADED")

	function DBM:FilterRaidBossEmote(msg, ...)
		return handleEvent(nil, "CHAT_MSG_RAID_BOSS_EMOTE_FILTERED", msg:gsub("\124c%x+(.-)\124r", "%1"), ...)
	end

	function DBM:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
		if not registeredEvents[event] then return end
		twipe(args)
		args.timestamp = timestamp
		args.event = event
		args.sourceGUID = sourceGUID
		args.sourceName = sourceName
		args.sourceFlags = sourceFlags
		args.destGUID = destGUID
		args.destName = destName
		args.destFlags = destFlags
		-- taken from Blizzard_CombatLog.lua
		if event == "SWING_DAMAGE" then
			args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(1, ...)
		elseif event == "SWING_MISSED" then
			args.spellName = ACTION_SWING
			args.missType = select(1, ...)
		elseif event:sub(1, 5) == "RANGE" then
			args.spellId, args.spellName, args.spellSchool = select(1, ...)
			if event == "RANGE_DAMAGE" then
				args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(4, ...)
			elseif event == "RANGE_MISSED" then
				args.missType = select(4, ...)
			end
		elseif event:sub(1, 5) == "SPELL" then
			args.spellId, args.spellName, args.spellSchool = select(1, ...)
			if event == "SPELL_DAMAGE" then
				args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(4, ...)
			elseif event == "SPELL_MISSED" then
				args.missType, args.amountMissed = select(4, ...)
			elseif event == "SPELL_HEAL" then
				args.amount, args.overheal, args.absorbed, args.critical = select(4, ...)
				args.school = args.spellSchool
			elseif event == "SPELL_ENERGIZE" then
				args.valueType = 2
				args.amount, args.powerType = select(4, ...)
			elseif event:sub(1, 14) == "SPELL_PERIODIC" then
				if event == "SPELL_PERIODIC_MISSED" then
					args.missType = select(4, ...)
				elseif event == "SPELL_PERIODIC_DAMAGE" then
					args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(4, ...)
				elseif event == "SPELL_PERIODIC_HEAL" then
					args.amount, args.overheal, args.absorbed, args.critical = select(4, ...)
					args.school = args.spellSchool
				elseif event == "SPELL_PERIODIC_DRAIN" then
					args.amount, args.powerType, args.extraAmount = select(4, ...)
					args.valueType = 2
				elseif event == "SPELL_PERIODIC_LEECH" then
					args.amount, args.powerType, args.extraAmount = select(4, ...)
					args.valueType = 2
				elseif event == "SPELL_PERIODIC_ENERGIZE" then
					args.amount, args.powerType = select(4, ...)
					args.valueType = 2
				end
			elseif event == "SPELL_DRAIN" then
				args.amount, args.powerType, args.extraAmount = select(4, ...)
				args.valueType = 2
			elseif event == "SPELL_LEECH" then
				args.amount, args.powerType, args.extraAmount = select(4, ...)
				args.valueType = 2
			elseif event == "SPELL_INTERRUPT" then
				args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
			elseif event == "SPELL_EXTRA_ATTACKS" then
				args.amount = select(4, ...)
			elseif event == "SPELL_DISPEL_FAILED" then
				args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
			elseif event == "SPELL_AURA_DISPELLED" then
				args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
				args.auraType = select(7, ...)
			elseif event == "SPELL_AURA_STOLEN" then
				args.extraSpellId, args.extraSpellName, args.extraSpellSchool = select(4, ...)
				args.auraType = select(7, ...)
			elseif event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" then
				args.auraType = select(4, ...)
				args.sourceName = args.destName
				args.sourceGUID = args.destGUID
				args.sourceFlags = args.destFlags
			elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
				args.auraType, args.amount = select(4, ...)
				args.sourceName = args.destName
				args.sourceGUID = args.destGUID
				args.sourceFlags = args.destFlags
			elseif event == "SPELL_CAST_FAILED" then
				args.missType = select(4, ...)
			end
		elseif event == "DAMAGE_SHIELD" then
			args.spellId, args.spellName, args.spellSchool = select(1, ...)
			args.amount, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(4, ...)
		elseif event == "DAMAGE_SHIELD_MISSED" then
			args.spellId, args.spellName, args.spellSchool = select(1, ...)
			args.missType = select(4, ...)
		elseif event == "ENCHANT_APPLIED" then
			args.spellName = select(1,...)
			args.itemId, args.itemName = select(2,...)
		elseif event == "ENCHANT_REMOVED" then
			args.spellName = select(1,...)
			args.itemId, args.itemName = select(2,...)
		elseif event == "UNIT_DIED" or event == "UNIT_DESTROYED" then
			args.sourceName = args.destName
			args.sourceGUID = args.destGUID
			args.sourceFlags = args.destFlags
		elseif event == "ENVIRONMENTAL_DAMAGE" then
			args.environmentalType = select(1,...)
			args.amount, args.overkill, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(2, ...)
			args.spellName = _G["ACTION_"..event.."_"..args.environmentalType]
			args.spellSchool = args.school
		elseif event == "DAMAGE_SPLIT" then
			args.spellId, args.spellName, args.spellSchool = select(1, ...)
			args.amount, args.school, args.resisted, args.blocked, args.absorbed, args.critical, args.glancing, args.crushing = select(4, ...)
		end
		return handleEvent(nil, event, args)
	end
	mainFrame:SetScript("OnEvent", handleEvent)
end


-----------------
--  Callbacks  --
-----------------
do
	local callbacks = {}

	function fireEvent(event, ...)
		if not callbacks[event] then return end
		for i, v in ipairs(callbacks[event]) do
			local ok, err = pcall(v, event, ...)
			if not ok then DBM:AddMsg(("Error while executing callback %s for event %s: %s"):format(tostring(v), tostring(event), err)) end
		end
	end

	function DBM:RegisterCallback(event, f)
		if not event or type(f) ~= "function" then
			error("Usage: DBM:RegisterCallback(event, callbackFunc)", 2)
		end
		callbacks[event] = callbacks[event] or {}
		table.insert(callbacks[event], f)
		return #callbacks[event]
	end
end


--------------------------
--  OnUpdate/Scheduler  --
--------------------------
do
	-- stack that stores a few tables (up to 8) which will be recycled
	local popCachedTable, pushCachedTable
	local numChachedTables = 0
	do
		local tableCache = nil
		
		-- gets a table from the stack, it will then be recycled.
		function popCachedTable()
			local t = tableCache
			if t then
				tableCache = t.next
				numChachedTables = numChachedTables - 1
			end
			return t
		end
		
		-- tries to push a table on the stack
		-- only tables with <= 4 array entries are accepted as cached tables are only used for tasks with few arguments for performance reasons
		-- also, the maximum number of cached tables is limited to 8 as DBM rarely has more than eight scheduled tasks with less than 4 arguments at the same time
		-- this is just to re-use all the tables of the small tasks that are scheduled all the time (like the wipe detection)
		-- note that the cache does not use weak references anywhere for performance reasons, so a cached table will never be deleted by the garbage collector
		function pushCachedTable(t)
			if numChachedTables < 8 and #t <= 4 then
				twipe(t)
				t.next = tableCache
				tableCache = t
				numChachedTables = numChachedTables + 1
			end
		end
	end
	
	-- priority queue (min-heap) that stores all scheduled tasks.
	-- insert: O(log n)
	-- deleteMin: O(log n)
	-- getMin: O(1)
	-- removeAllMatching: O(n)
	local insert, removeAllMatching, getMin, deleteMin
	do
		local heap = {}
		local firstFree = 1
		
		-- gets the next task
		function getMin()
			return heap[1]
		end
		
		-- restores the heap invariant by moving an item up
		local function siftUp(n)
			local parent = floor(n / 2)
			while n > 1 and heap[parent].time > heap[n].time do -- move the element up until the heap invariant is restored, meaning the element is at the top or the element's parent is <= the element
				heap[n], heap[parent] = heap[parent], heap[n] -- swap the element with its parent
				n = parent
				parent = floor(n / 2)
			end
		end
		
		-- restores the heap invariant by moving an item down
		local function siftDown(n)
			local m -- position of the smaller child
			while 2 * n < firstFree do -- #children >= 1
				-- swap the element with its smaller child
				if 2 * n + 1 == firstFree then -- n does not have a right child --> it only has a left child as #children >= 1
					m = 2 * n -- left child
				elseif heap[2 * n].time < heap[2 * n + 1].time then -- #children = 2 and left child < right child
					m = 2 * n -- left child
				else -- #children = 2 and right child is smaller than the left one
					m = 2 * n + 1 -- right
				end
				if heap[n].time <= heap[m].time then -- n is <= its smallest child --> heap invariant restored
					return
				end
				heap[n], heap[m] = heap[m], heap[n]
				n = m
			end
		end
		
		-- inserts a new element into the heap
		function insert(ele)
			heap[firstFree] = ele
			siftUp(firstFree)
			firstFree = firstFree + 1
		end
		
		-- deletes the min element
		function deleteMin()
			local min = heap[1]
			firstFree = firstFree - 1
			heap[1] = heap[firstFree]
			heap[firstFree] = nil
			siftDown(1)
			return min
		end
		
		-- removes multiple scheduled tasks from the heap
		-- note that this function is comparatively slow by design as it has to check all tasks and allows partial matches
		function removeAllMatching(f, mod, ...)
			-- remove all elements that match the signature, this destroyes the heap and leaves a normal array
			local v, match
			for i = #heap, 1, -1 do -- iterate backwards over the array to allow usage of table.remove
				v = heap[i]
				if (not f or v.func == f) and (not mod or v.mod == mod) then
					match = true
					for i = 1, select("#", ...) do
						if select(i, ...) ~= v[i] then
							match = false
							break
						end
					end
					if match then
						table.remove(heap, i)
						firstFree = firstFree - 1
					end
				end
			end
			-- rebuild the heap from the array in O(n)
			for i = floor((firstFree - 1) / 2), 1, -1 do
				siftDown(i)
			end
		end
	end

	mainFrame:SetScript("OnUpdate", function(self, elapsed)
		local time = GetTime()
		
		-- execute scheduled tasks
		local nextTask = getMin()
		while nextTask and nextTask.time <= time do
			deleteMin()
			nextTask.func(unpack(nextTask))
			pushCachedTable(nextTask)
			nextTask = getMin()
		end
		
		-- execute OnUpdate handlers of all modules
		for i, v in pairs(updateFunctions) do
			if i.Options.Enabled and (not i.zones or checkEntry(i.zones, GetRealZoneText())) then
				i.elapsed = (i.elapsed or 0) + elapsed
				if i.elapsed >= (i.updateInterval or 0) then
					v(i, i.elapsed)
					i.elapsed = 0
				end
			end
		end
		
		-- clean up sync spam timers and auto respond spam blockers
		-- TODO: optimize (but how?); using next(t, k) all the time on nearly empty hash tables is not a good idea...doesn't really matter here as modSyncSpam only very rarely contains more than a few entries...
		local k, v = next(modSyncSpam, nil)
		if v and (time - v > 2.5) then
			modSyncSpam[k] = nil
		end
		for k, v in pairs(autoRespondSpam) do
			if v and (time - v > 60) then
				autoRespondSpam[k] = nil
			end
		end
	end)

	function schedule(t, f, mod, ...)
		local v
		if numChachedTables > 0 and select("#", ...) <= 4 then -- a cached table is available and all arguments fit into an array with four slots
			v = popCachedTable()
			v.time = GetTime() + t
			v.func = f
			v.mod = mod
			for i = 1, select("#", ...) do
				v[i] = select(i, ...)
			end
		else -- create a new table
			v = {time = GetTime() + t, func = f, mod = mod, ...}
		end
		insert(v)
	end

	function unschedule(f, mod, ...)
		return removeAllMatching(f, mod, ...)
	end
end

function DBM:Schedule(t, f, ...)
	return schedule(t, f, nil, ...)
end

function DBM:Unschedule(f, ...)
	return unschedule(f, nil, ...)
end

function DBM:ForceUpdate()
	mainFrame:GetScript("OnUpdate")(mainFrame, 0)
end

----------------------
--  Slash Commands  --
----------------------
SLASH_DEADLYBOSSMODS1 = "/dbm"
SlashCmdList["DEADLYBOSSMODS"] = function(msg)
	local cmd = msg:lower()
	if cmd == "ver" or cmd == "version" then
		DBM:ShowVersions()
	elseif cmd == "unlock" or cmd == "move" then
		DBM.Bars:ShowMovableBar()
	elseif cmd == "help" then
		for i, v in ipairs(DBM_CORE_SLASHCMD_HELP) do DBM:AddMsg(v) end
	elseif cmd:sub(1, 5) == "timer" then
		local time, text = msg:match("^%w+ ([%d:]+) (.+)$")
		if not (time and text) then
			DBM:AddMsg(DBM_PIZZA_ERROR_USAGE)
			return
		end
		local min, sec = string.split(":", time)
		min = tonumber(min or "") or 0
		sec = tonumber(sec or "")
		if min and not sec then
			sec = min
			min = 0
		end
		time = min * 60 + sec
		DBM:CreatePizzaTimer(time, text)
	elseif cmd:sub(1, 15) == "broadcast timer" then
		local time, text = msg:match("^%w+ %w+ ([%d:]+) (.+)$")
		if DBM:GetRaidRank() == 0 then
			DBM:AddMsg(DBM_ERROR_NO_PERMISSION)
		end
		if not (time and text) then
			DBM:AddMsg(DBM_PIZZA_ERROR_USAGE)
			return
		end
		local min, sec = string.split(":", time)
		min = tonumber(min or "") or 0
		sec = tonumber(sec or "")
		if min and not sec then
			sec = min
			min = 0
		end
		time = min * 60 + sec
		DBM:CreatePizzaTimer(time, text, true)
	elseif cmd:sub(1, 4) == "pull" then
		if DBM:GetRaidRank() == 0 then
			return DBM:AddMsg(DBM_ERROR_NO_PERMISSION)
		end
		local timer = tonumber(cmd:sub(5)) or 10
		DBM:CreatePizzaTimer(timer, DBM_CORE_TIMER_PULL, true)
		SendChatMessage(DBM_CORE_ANNOUNCE_PULL:format(timer), "RAID_WARNING")
		if timer > 7 then DBM:Schedule(timer - 7, SendChatMessage, DBM_CORE_ANNOUNCE_PULL:format(7), "RAID_WARNING") end
		if timer > 5 then DBM:Schedule(timer - 5, SendChatMessage, DBM_CORE_ANNOUNCE_PULL:format(5), "RAID_WARNING") end
		if timer > 3 then DBM:Schedule(timer - 3, SendChatMessage, DBM_CORE_ANNOUNCE_PULL:format(3), "RAID_WARNING") end
		if timer > 2 then DBM:Schedule(timer - 2, SendChatMessage, DBM_CORE_ANNOUNCE_PULL:format(2), "RAID_WARNING") end
		if timer > 1 then DBM:Schedule(timer - 1, SendChatMessage, DBM_CORE_ANNOUNCE_PULL:format(1), "RAID_WARNING") end
		DBM:Schedule(timer, SendChatMessage, DBM_CORE_ANNOUNCE_PULL_NOW, "RAID_WARNING")
	else
		DBM:LoadGUI()
	end
end

SLASH_DBMRANGE1 = "/range"
SLASH_DBMRANGE2 = "/distance"
SlashCmdList["DBMRANGE"] = function(msg)
	if DBM.RangeCheck:IsShown() then
		DBM.RangeCheck:Hide()
	else
		local r = tonumber(msg)
		if r and (r == 10 or r == 11 or r == 15 or r == 28) then
			DBM.RangeCheck:Show(r)
		else
			DBM.RangeCheck:Show(10)
		end
	end
end

do
	local sortMe = {}
	local function sort(v1, v2)
		return (v1.revision or 0) > (v2.revision or 0)
	end
	function DBM:ShowVersions()
		for i, v in pairs(raid) do
			table.insert(sortMe, v)
		end
		table.sort(sortMe, sort)
		self:AddMsg(DBM_CORE_VERSIONCHECK_HEADER)
		for i, v in ipairs(sortMe) do
			if v.displayVersion then
				self:AddMsg(DBM_CORE_VERSIONCHECK_ENTRY:format(v.name, v.displayVersion, v.revision))
			else
				self:AddMsg(DBM_CORE_VERSIONCHECK_ENTRY_NO_DBM:format(v.name))
			end
		end
		for i = #sortMe, 1, -1 do
			if not sortMe[i].revision then
				table.remove(sortMe, i)
			end
		end
		self:AddMsg(DBM_CORE_VERSIONCHECK_FOOTER:format(#sortMe))
		for i = #sortMe, 1, -1 do
			sortMe[i] = nil
		end
	end
end


-------------------
--  Pizza Timer  --
-------------------
do
	local ignore = {}
	function DBM:CreatePizzaTimer(time, text, broadcast, sender)
		if sender and ignore[sender] then return end
		text = text:sub(1, 16)
		text = text:gsub("%%t", UnitName("target") or "<no target>")
		self.Bars:CreateBar(time, text)
		if broadcast and self:GetRaidRank() >= 1 then
			sendSync("DBMv4-Pizza", ("%s\t%s"):format(time, text))
		end
		if sender then DBM:ShowPizzaInfo(text, sender) end
	end

	function DBM:AddToPizzaIgnore(name)
		ignore[name] = true
	end
end

function DBM:ShowPizzaInfo(id, sender)
	self:AddMsg(DBM_PIZZA_SYNC_INFO:format(sender, id))
end



------------------
--  Hyperlinks  --
------------------
do
	local ignore, cancel
	StaticPopupDialogs["DBM_CONFIRM_IGNORE"] = {
		text = DBM_PIZZA_CONFIRM_IGNORE,
		button1 = YES,
		button2 = NO,
		OnAccept = function(self)
			DBM:AddToPizzaIgnore(ignore)
			DBM.Bars:CancelBar(cancel)
		end,
		timeout = 0,
		hideOnEscape = 1,
	}

	DEFAULT_CHAT_FRAME:HookScript("OnHyperlinkClick", function(self, link, string, button, ...)
		local linkType, arg1, arg2, arg3 = strsplit(":", link)
		if linkType == "DBM" and arg1 == "cancel" then
			DBM.Bars:CancelBar(link:match("DBM:cancel:(.+):nil$"))
		elseif linkType == "DBM" and arg1 == "ignore" then
			cancel = link:match("DBM:ignore:(.+):[^%s:]+$")
			ignore = link:match(":([^:]+)$")
			StaticPopup_Show("DBM_CONFIRM_IGNORE", ignore)
		elseif linkType == "DBM" and arg1 == "update" then
			DBM:ShowUpdateReminder(arg2, arg3) -- displayVersion, revision			
		end
	end)
end

do
	local old = ItemRefTooltip.SetHyperlink -- we have to hook this function since the default ChatFrame code assumes that all links except for player and channel links are valid arguments for this function
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link:match("^DBM") then return end
		return old(self, link, ...)
	end
end


-----------------
--  GUI Stuff  --
-----------------
do
	local callOnLoad = {}
	function DBM:LoadGUI()
		if not IsAddOnLoaded("DBM-GUI") then
			local _, _, _, enabled = GetAddOnInfo("DBM-GUI")
			if not enabled then
				EnableAddOn("DBM-GUI")
			end
			local loaded, reason = LoadAddOn("DBM-GUI")
			if not loaded then
				if reason then
					self:AddMsg(DBM_CORE_LOAD_GUI_ERROR:format(tostring(_G["ADDON_"..reason or ""])))
				else
					self:AddMsg(DBM_CORE_LOAD_GUI_ERROR:format(DBM_CORE_UNKNOWN))
				end
				return false
			end
			table.sort(callOnLoad, function(v1, v2) return v1[2] < v2[2] end)
			for i, v in ipairs(callOnLoad) do v[1]() end
			collectgarbage("collect")
		end
		return DBM_GUI:ShowHide()
	end

	function DBM:RegisterOnGuiLoadCallback(f, sort)
		table.insert(callOnLoad, {f, sort or math.huge})
	end
end


----------------------
--  Minimap Button  --
----------------------
do
	local dragMode = nil
	
	local function moveButton(self)
		if dragMode == "free" then
			local centerX, centerY = Minimap:GetCenter()
			local x, y = GetCursorPosition()
			x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
			self:ClearAllPoints()
			self:SetPoint("CENTER", x, y)
		else
			local centerX, centerY = Minimap:GetCenter()
			local x, y = GetCursorPosition()
			x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
			centerX, centerY = math.abs(x), math.abs(y)
			centerX, centerY = (centerX / math.sqrt(centerX^2 + centerY^2)) * 76, (centerY / sqrt(centerX^2 + centerY^2)) * 76
			centerX = x < 0 and -centerX or centerX
			centerY = y < 0 and -centerY or centerY
			self:ClearAllPoints()
			self:SetPoint("CENTER", centerX, centerY)
		end
	end

	local button = CreateFrame("Button", "DBMMinimapButton", Minimap)
	button:SetHeight(32)
	button:SetWidth(32)
	button:SetFrameStrata("MEDIUM")
	button:SetPoint("CENTER", -65.35, -38.8)
	button:SetMovable(true)
	button:SetUserPlaced(true)
	button:SetNormalTexture("Interface\\AddOns\\DBM-Core\\textures\\Minimap-Button-Up")
	button:SetPushedTexture("Interface\\AddOns\\DBM-Core\\textures\\Minimap-Button-Down")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	button:SetScript("OnMouseDown", function(self, button)
		if IsShiftKeyDown() and IsAltKeyDown() then
			dragMode = "free"
			self:SetScript("OnUpdate", moveButton)
		elseif IsShiftKeyDown() or button == "RightButton" then
			dragMode = nil
			self:SetScript("OnUpdate", moveButton)
		end
	end)
	button:SetScript("OnMouseUp", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	button:SetScript("OnClick", function(self, button)
		if IsShiftKeyDown() or button == "RightButton" then return end
		DBM:LoadGUI()
	end)
	button:SetScript("OnEnter", function(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetText(DBM_CORE_MINIMAP_TOOLTIP_HEADER, 1, 1, 1)
		GameTooltip:AddLine(ver, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(DBM_CORE_MINIMAP_TOOLTIP_FOOTER, RAID_CLASS_COLORS.MAGE.r, RAID_CLASS_COLORS.MAGE.g, RAID_CLASS_COLORS.MAGE.b, 1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	function DBM:ToggleMinimapButton()
		self.Options.ShowMinimapButton = not self.Options.ShowMinimapButton
		if self.Options.ShowMinimapButton then
			button:Show()
		else
			button:Hide()
		end
	end

	function DBM:HideMinimapButton()
		return button:Hide()
	end
end


---------------------------
--  Raid/Party Handling  --
---------------------------
do
	local inRaid = false
	local playerRank = 0

	function DBM:RAID_ROSTER_UPDATE()
		if GetNumRaidMembers() >= 1 then
			for i = 1, GetNumRaidMembers() do
				local name, rank, subgroup, _, _, fileName = GetRaidRosterInfo(i)
				if (not raid[name]) and inRaid then
					fireEvent("raidJoin", name)
				end
				if name then
					raid[name] = raid[name] or {}
					raid[name].name = name
					raid[name].rank = rank
					raid[name].subgroup = subgroup
					raid[name].class = fileName
					raid[name].id = "raid"..i
					raid[name].updated = true
				end
			end
			if not inRaid then
				inRaid = true
				sendSync("DBMv4-Ver", "Hi!")
				self:Schedule(2, DBM.RequestTimers, DBM)
				fireEvent("raidJoin", UnitName("player"))
			end
			for i, v in pairs(raid) do
				if not v.updated then
					raid[i] = nil
					fireEvent("raidLeave", i)
				else
					v.updated = nil
				end
			end
		else
			inRaid = false
			fireEvent("raidLeave", UnitName("player"))
		end
	end

	function DBM:PARTY_MEMBERS_CHANGED()
		if GetNumRaidMembers() > 0 then return end
		if GetNumPartyMembers() >= 1 then
			if not inRaid then
				inRaid = true
				sendSync("DBMv4-Ver", "Hi!")
				self:Schedule(2, DBM.RequestTimers, DBM)
			end
			for i = 0, GetNumPartyMembers() do
				local id
				if (i == 0) then
					id = "player"
				else
					id = "party"..i
				end
				local name, rank, _, fileName = UnitName(id), UnitIsPartyLeader(id), UnitClass(id)
				if name then
					raid[name] = raid[name] or {}
					raid[name].name = name
					if rank then
						raid[name].rank = 2
					else
						raid[name].rank = 0
					end
					raid[name].class = fileName
					raid[name].id = id
					raid[name].updated = true
				end
			end
			for i, v in pairs(raid) do
				if not v.updated then
					raid[i] = nil
				else
					v.updated = nil
				end
			end
		else
			inRaid = false
		end
	end

	function DBM:IsInRaid()
		return inRaid
	end

	function DBM:GetRaidRank(name)
		name = name or UnitName("player")
		return (raid[name] and raid[name].rank) or 0
	end

	function DBM:GetRaidSubgroup(name)
		name = name or UnitName("player")
		return (raid[name] and raid[name].subgroup) or 0
	end

	function DBM:GetRaidClass(name)
		name = name or UnitName("player")
		return (raid[name] and raid[name].class) or "UNKNOWN"
	end

	function DBM:GetRaidUnitId(name)
		name = name or UnitName("player")
		return (raid[name] and raid[name].id) or "none"
	end
end


---------------
--  Options  --
---------------
do
	local function addDefaultOptions(t1, t2)
		for i, v in pairs(t2) do
			if t1[i] == nil then
				t1[i] = v
			elseif type(v) == "table" then
				addDefaultOptions(v, t2[i])
			end
		end
	end
	
	local function setRaidWarningPositon()
		RaidWarningFrame:ClearAllPoints()
		RaidWarningFrame:SetPoint(DBM.Options.RaidWarningPosition.Point, UIParent, DBM.Options.RaidWarningPosition.Point, DBM.Options.RaidWarningPosition.X, DBM.Options.RaidWarningPosition.Y)
	end
	
	function loadOptions()
		DBM.Options = DBM_SavedOptions
		addDefaultOptions(DBM.Options, DBM.DefaultOptions)
		-- load special warning options
		DBM:UpdateSpecialWarningOptions()
		-- set this with a short delay to prevent issues with other addons also trying to do the same thing with another position ;)
		DBM:Schedule(5, setRaidWarningPositon)
	end

	function loadModOptions(modId)
		local savedOptions = _G[modId:gsub("-", "").."_SavedVars"] or {}
		local savedStats = _G[modId:gsub("-", "").."_SavedStats"] or {}
		for i, v in ipairs(DBM.Mods) do
			if v.modId == modId then
				savedOptions[v.id] = savedOptions[v.id] or v.Options
				for option, optionValue in pairs(v.Options) do
					if savedOptions[v.id][option] == nil then
						savedOptions[v.id][option] = optionValue
					end
				end
				v.Options = savedOptions[v.id] or {}
				savedStats[v.id] = savedStats[v.id] or {
					kills = 0,
					pulls = 0,
					heroicKills = 0,
					heroicPulls = 0,
				}
				v.stats = savedStats[v.id]
				if v.OnInitialize then v:OnInitialize() end
				for i, cat in ipairs(v.categorySort) do -- temporary hack
					if cat == "misc" then
						table.remove(v.categorySort, i)
						table.insert(v.categorySort, cat)
						break
					end
				end
			end
		end
		_G[modId:gsub("-", "").."_SavedVars"] = savedOptions
		_G[modId:gsub("-", "").."_SavedStats"] = savedStats
	end
end


--------------
--  OnLoad  --
--------------
do
	local function showOldVerWarning()
		StaticPopupDialogs["DBM_OLD_VERSION"] = {
			text = DBM_CORE_ERROR_DBMV3_LOADED,
			button1 = DBM_CORE_OK,
			OnAccept = function()
				DisableAddOn("DBM_API")
				ReloadUI()
			end,
			timeout = 0,
			exclusive = 1,
			whileDead = 1,
		}
		StaticPopup_Show("DBM_OLD_VERSION")
	end
	
	local function setCombatInitialized()
		combatInitialized = true
	end
	
	function DBM:ADDON_LOADED(modname)
		if modname == "DBM-Core" then
			loadOptions()
			DBM.Bars:LoadOptions("DBM")
			if not DBM.Options.ShowMinimapButton then DBM:HideMinimapButton() end
			self.AddOns = {}
			for i = 1, GetNumAddOns() do
				if GetAddOnMetadata(i, "X-DBM-Mod") then
					table.insert(self.AddOns, {
						sort		= tonumber(GetAddOnMetadata(i, "X-DBM-Mod-Sort") or math.huge) or math.huge,
						category	= GetAddOnMetadata(i, "X-DBM-Mod-Category") or "Other",
						name		= GetAddOnMetadata(i, "X-DBM-Mod-Name") or "",
						zone		= {strsplit(",", GetAddOnMetadata(i, "X-DBM-Mod-LoadZone") or "")},
						subTabs		= GetAddOnMetadata(i, "X-DBM-Mod-SubCategories") and {strsplit(",", GetAddOnMetadata(i, "X-DBM-Mod-SubCategories"))},
						hasHeroic	= tonumber(GetAddOnMetadata(i, "X-DBM-Mod-Has-Heroic-Mode") or 1) == 1,
						modId		= GetAddOnInfo(i),
					})
				end
			end
			table.sort(self.AddOns, function(v1, v2) return v1.sort < v2.sort end)
			self:RegisterEvents(
				"COMBAT_LOG_EVENT_UNFILTERED",
				"ZONE_CHANGED_NEW_AREA",
				"RAID_ROSTER_UPDATE",
				"PARTY_MEMBERS_CHANGED",
				"CHAT_MSG_ADDON",
				"PLAYER_REGEN_DISABLED",
				"UNIT_DIED",
				"UNIT_DESTROYED",
				"CHAT_MSG_WHISPER",
				"CHAT_MSG_MONSTER_YELL",
				"CHAT_MSG_MONSTER_EMOTE",
				"CHAT_MSG_MONSTER_SAY",
				"CHAT_MSG_RAID_BOSS_EMOTE",
				"PLAYER_ENTERING_WORLD"
			)
			self:ZONE_CHANGED_NEW_AREA()
			self:RAID_ROSTER_UPDATE()
			self:PARTY_MEMBERS_CHANGED()
			DBM:Schedule(1.5, setCombatInitialized)
			local enabled, loadable = select(4, GetAddOnInfo("DBM_API"))
			if enabled and loadable then showOldVerWarning() end
		end
	end
end

-- Remove this in 4.30
local checkZone
do
	local zoneName
	if GetLocale() == "koKR" then
		zoneName = "얼음 왕관"
	elseif GetLocale() == "ruRU" then
		zoneName = "Цитадель Ледяная Корона"
	elseif GetLocale() == "zhTW" then
		zoneName = "冰冠城塞"
	elseif GetLocale() == "deDE" then
		zoneName = "Eiskronenzitadelle"
	else
		zoneName = "Icecrown Citadel"
	end
	-- It's not really worth translating this message as it will be removed in the next version
	local msg = string.format("Your version of Deadly Boss Mods does not support '%s', please visit http://www.deadlybossmods.com to obtain the latest version.", zoneName)
	local warningShown
	function checkZone()
		if not warningShown and GetRealZoneText() == zoneName then
			warningShown = true
			DBM:AddMsg(msg)
		end
	end
end

--------------------------------
--  Load Boss Mods on Demand  --
--------------------------------
function DBM:ZONE_CHANGED_NEW_AREA()
	for i, v in ipairs(self.AddOns) do
		if checkEntry(v.zone, GetRealZoneText()) and not IsAddOnLoaded(v.modId) then
			DBM:Unschedule(DBM.LoadMod, DBM, v) -- srsly, wtf? LoadAddOn doesn't work properly on ZONE_CHANGED_NEW_AREA when reloading the UI
			DBM:Schedule(3, DBM.LoadMod, DBM, v)
		end
	end
	if select(2, IsInInstance()) == "pvp" and not DBM:GetModByName("Alterac") then
		for i, v in ipairs(DBM.AddOns) do
			if v.modId == "DBM-Battlegrounds" then
				DBM:LoadMod(v)
				break
			end
		end
	end
	checkZone()
end

function DBM:LoadMod(mod)
	if type(mod) ~= "table" then return false end
	local _, _, _, enabled = GetAddOnInfo(mod.modId)
	if not enabled then
		EnableAddOn(mod.modId)
	end

	local loaded, reason = LoadAddOn(mod.modId)
	if not loaded then
		if reason then
			self:AddMsg(DBM_CORE_LOAD_MOD_ERROR:format(tostring(mod.name), tostring(_G["ADDON_"..reason or ""])))
		else
--			self:AddMsg(DBM_CORE_LOAD_MOD_ERROR:format(tostring(mod.name), DBM_CORE_UNKNOWN)) -- wtf, this should never happen....(but it does happen sometimes if you reload your UI in an instance...)
		end
		return false
	else
		self:AddMsg(DBM_CORE_LOAD_MOD_SUCCESS:format(tostring(mod.name)))
		loadModOptions(mod.modId)
		for i, v in ipairs(DBM.Mods) do -- load the hasHeroic attribute from the toc into all boss mods as required by the GetDifficulty() method
			if v.modId == mod.modId then
				v.hasHeroic = mod.hasHeroic
			end
		end
		if DBM_GUI then
			DBM_GUI:UpdateModList()
		end
		collectgarbage("collect")
		return true
	end
end

do
	if select(4, GetAddOnInfo("DBM-Battlegrounds")) and select(5, GetAddOnInfo("DBM-Battlegrounds")) then
		local checkBG
		function checkBG()
			if not DBM:GetModByName("Alterac") and MAX_BATTLEFIELD_QUEUES then
				for i = 1, MAX_BATTLEFIELD_QUEUES do
					if GetBattlefieldStatus(i) == "confirm" then
						for i, v in ipairs(DBM.AddOns) do
							if v.modId == "DBM-Battlegrounds" then
								DBM:LoadMod(v)
								return
							end
						end
					end
				end
				DBM:Schedule(1, checkBG)
			end
		end
		DBM:Schedule(1, checkBG)
	end
end



-----------------------------
--  Handle Incoming Syncs  --
-----------------------------
do
	local syncHandlers = {}
	local whisperSyncHandlers = {}

	syncHandlers["DBMv4-Mod"] = function(msg, channel, sender)
		local mod, revision, event, arg = strsplit("\t", msg)
		mod = DBM:GetModByName(mod or "")
		if mod and event and arg and revision then
			mod:ReceiveSync(event, arg, sender, revision)
		end
	end

	syncHandlers["DBMv4-Pull"] = function(msg, channel, sender)
		if select(2, IsInInstance()) == "pvp" then return end
		local delay, mod = strsplit("\t", msg)
		local lag = select(3, GetNetStats()) / 1000
		delay = tonumber(delay or 0) or 0
		mod = DBM:GetModByName(mod or "")
		if mod and delay and (not mod.zones or #mod.zones == 0 or checkEntry(mod.zones, GetRealZoneText())) then
			DBM:StartCombat(mod, delay + lag, true)
		end
	end

	syncHandlers["DBMv4-Kill"] = function(msg, channel, sender)
		if select(2, IsInInstance()) == "pvp" then return end
		local cId = tonumber(msg)
		if cId then DBM:OnMobKill(cId, true) end
	end

	syncHandlers["DBMv4-Ver"] = function(msg, channel, sender)
		if msg == "Hi!" then
			sendSync("DBMv4-Ver", ("%s\t%s\t%s\t%s"):format(DBM.Revision, DBM.Version, DBM.DisplayVersion, GetLocale()))
		else
			local revision, version, displayVersion, locale = strsplit("\t", msg)
			revision, version = tonumber(revision or ""), tonumber(version or "")
			if revision and version and displayVersion and raid[sender] then
				raid[sender].revision = revision
				raid[sender].version = version
				raid[sender].displayVersion = displayVersion
				raid[sender].locale = locale
				if version > tonumber(DBM.Version) and not showedUpdateReminder then
					local found = false
					for i, v in pairs(raid) do
						if v.version == version and v ~= raid[sender] then
							found = true
							break
						end
					end
					if found then
						showedUpdateReminder = true
						if not DBM.Options.BlockVersionUpdatePopup then
							DBM:ShowUpdateReminder(displayVersion, revision)
						else 
							DBM:AddMsg(DBM_CORE_UPDATEREMINDER_HEADER:match("([^\n]*)"))
							DBM:AddMsg(DBM_CORE_UPDATEREMINDER_HEADER:match("\n(.*)"):format(displayVersion, revision))
							DBM:AddMsg(("|HDBM:update:%s:%s|h|cff3588ff[http://deadlybossmods.com]"):format(displayVersion, revision))
						end
					end
				end
			end
		end
	end

	syncHandlers["DBMv4-Pizza"] = function(msg, channel, sender)
		if select(2, IsInInstance()) == "pvp" then return end
		if DBM:GetRaidRank(sender) == 0 then return end
		if sender == UnitName("player") then return end
		local time, text = strsplit("\t", msg)
		time = tonumber(time or 0)
		text = tostring(text)
		if time and text then
			DBM:CreatePizzaTimer(time, text, nil, sender)
		end
	end

	whisperSyncHandlers["DBMv4-RequestTimers"] = function(msg, channel, sender)
		DBM:SendTimers(sender)
	end

	whisperSyncHandlers["DBMv4-CombatInfo"] = function(msg, channel, sender)
		local mod, time = strsplit("\t", msg)
		mod = DBM:GetModByName(mod or "")
		time = tonumber(time or 0)
		if mod and time then
			DBM:ReceiveCombatInfo(sender, mod, time)
		end
	end

	whisperSyncHandlers["DBMv4-TimerInfo"] = function(msg, channel, sender)
		local mod, timeLeft, totalTime, id = strsplit("\t", msg)
		mod = DBM:GetModByName(mod or "")
		timeLeft = tonumber(timeLeft or 0)
		totalTime = tonumber(totalTime or 0)
		if mod and timeLeft and timeLeft > 0 and totalTime and totalTime > 0 and id then
			DBM:ReceiveTimerInfo(sender, mod, timeLeft, totalTime, id, select(5, strsplit("\t", msg)))
		end
	end

	function DBM:CHAT_MSG_ADDON(prefix, msg, channel, sender)
		if msg and channel ~= "WHISPER" and channel ~= "GUILD" then
			local handler = syncHandlers[prefix]
			if handler then handler(msg, channel, sender) end
		elseif msg and channel == "WHISPER" and self:GetRaidUnitId(sender) ~= "none" then
			local handler = whisperSyncHandlers[prefix]
			if handler then handler(msg, channel, sender) end
		end
	end
end


-----------------------
--  Update Reminder  --
-----------------------
function DBM:ShowUpdateReminder(newVersion, newRevision)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(430)
	frame:SetHeight(155)
	frame:SetPoint("TOP", 0, -230)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
		insets = {left = 11, right = 12, top = 12, bottom = 11},
	})
	local fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontstring:SetWidth(410)
	fontstring:SetHeight(0)
	fontstring:SetPoint("TOP", 0, -16)
	fontstring:SetText(DBM_CORE_UPDATEREMINDER_HEADER:format(newVersion, newRevision))
	local editBox = CreateFrame("EditBox", nil, frame)
	do
		local editBoxLeft = editBox:CreateTexture(nil, "BACKGROUND")
		local editBoxRight = editBox:CreateTexture(nil, "BACKGROUND")
		local editBoxMiddle = editBox:CreateTexture(nil, "BACKGROUND")
		editBoxLeft:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
		editBoxLeft:SetHeight(32)
		editBoxLeft:SetWidth(32)
		editBoxLeft:SetPoint("LEFT", -14, 0)
		editBoxLeft:SetTexCoord(0, 0.125, 0, 1)
		editBoxRight:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		editBoxRight:SetHeight(32)
		editBoxRight:SetWidth(32)
		editBoxRight:SetPoint("RIGHT", 6, 0)
		editBoxRight:SetTexCoord(0.875, 1, 0, 1)
		editBoxMiddle:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		editBoxMiddle:SetHeight(32)
		editBoxMiddle:SetWidth(1)
		editBoxMiddle:SetPoint("LEFT", editBoxLeft, "RIGHT")
		editBoxMiddle:SetPoint("RIGHT", editBoxRight, "LEFT")
		editBoxMiddle:SetTexCoord(0, 0.9375, 0, 1)
	end
	editBox:SetHeight(32)
	editBox:SetWidth(250)
	editBox:SetPoint("TOP", fontstring, "BOTTOM", 0, -4)
	editBox:SetFontObject("GameFontHighlight")
	editBox:SetTextInsets(0, 0, 0, 1)
	editBox:SetFocus()
	editBox:SetText("http://www.deadlybossmods.com")
	editBox:HighlightText()
	editBox:SetScript("OnHide", function(self)
		if ChatFrameEditBox:IsVisible() then
			ChatFrameEditBox:SetFocus()
		end
	end)
	editBox:SetScript("OnTextChanged", function(self)
		editBox:SetText("http://www.deadlybossmods.com")
		editBox:HighlightText()
	end)
	local fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontstring:SetWidth(410)
	fontstring:SetHeight(0)
	fontstring:SetPoint("TOP", editBox, "BOTTOM", 0, 0)
	fontstring:SetText(DBM_CORE_UPDATEREMINDER_FOOTER)
	local button = CreateFrame("Button", nil, frame)
	button:SetHeight(24)
	button:SetWidth(75)
	button:SetPoint("BOTTOM", 0, 13)
	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")
	button:SetNormalTexture(button:CreateTexture(nil, nil, "UIPanelButtonUpTexture"))
	button:SetPushedTexture(button:CreateTexture(nil, nil, "UIPanelButtonDownTexture"))
	button:SetHighlightTexture(button:CreateTexture(nil, nil, "UIPanelButtonHighlightTexture"))
	button:SetText(DBM_CORE_OK)
	button:SetScript("OnClick", function(self)
		frame:Hide()
	end)
end

----------------------
--  Pull Detection  --
----------------------
do
	local targetList = {}
	local function buildTargetList()
		local uId = ((GetNumRaidMembers() == 0) and "party") or "raid"
		for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
			local id = (i == 0 and "target") or uId..i.."target"
			local guid = UnitGUID(id)
			if guid and (bit.band(guid:sub(1, 5), 0x00F) == 3 or bit.band(guid:sub(1, 5), 0x00F) == 5) then
				local cId
				if wowVersion >= 30300 then
					cId = tonumber(guid:sub(7, 10), 16)
				else
					cId = tonumber(guid:sub(9, 12), 16)
				end
				targetList[cId] = id
			end
		end
	end

	local function clearTargetList()
		table.wipe(targetList)
	end

	local function scanForCombat(mod, mob)
		if not checkEntry(inCombat, mod) then
			buildTargetList()
			if targetList[mob] and UnitAffectingCombat(targetList[mob]) then
				DBM:StartCombat(mod, 3)
			end
			clearTargetList()
		end
	end
	
	local function checkForPull(mob, combatInfo)
		local uId = targetList[mob]
		if uId and UnitAffectingCombat(uId) then
			DBM:StartCombat(combatInfo.mod, 0)
			return true
		elseif uId then
			DBM:Schedule(3, scanForCombat, combatInfo.mod, mob)
		end
	end

	function DBM:PLAYER_REGEN_DISABLED()
		if not combatInitialized then return end
		if combatInfo[GetRealZoneText()] then
			buildTargetList()
			for i, v in ipairs(combatInfo[GetRealZoneText()]) do
				if v.type == "combat" then
					if v.multiMobPullDetection then
						for _, mob in ipairs(v.multiMobPullDetection) do
							if checkForPull(mob, v) then
								break
							end
						end
					else
						checkForPull(v.mob, v)
					end
				end
			end
			clearTargetList()
		end
	end
end

do
	-- called for all mob chat events
	local function onMonsterMessage(type, msg)
		-- pull detection
		if combatInfo[GetRealZoneText()] then
			for i, v in ipairs(combatInfo[GetRealZoneText()]) do
				if v.type == type and checkEntry(v.msgs, msg) then
					DBM:StartCombat(v.mod, 0)
				end
			end
		end
		-- kill detection (wipe detection would also be nice to have)
		-- todo: add sync
		for i = #inCombat, 1, -1 do
			local v = inCombat[i]
			if not v.combatInfo then return end
			if v.combatInfo.killType == type and v.combatInfo.killMsgs[msg] then
				DBM:EndCombat(v)
			end
		end
	end

	function DBM:CHAT_MSG_MONSTER_YELL(msg)
		return onMonsterMessage("yell", msg)
	end

	function DBM:CHAT_MSG_MONSTER_EMOTE(msg)
		return onMonsterMessage("emote", msg)
	end

	function DBM:CHAT_MSG_RAID_BOSS_EMOTE(msg, ...)
		onMonsterMessage("emote", msg)
		return self:FilterRaidBossEmote(msg, ...)
	end

	function DBM:CHAT_MSG_MONSTER_SAY(msg)
		return onMonsterMessage("say", msg)
	end
end


---------------------------
--  Kill/Wipe Detection  --
---------------------------
function checkWipe(confirm)
	if #inCombat > 0 then
		local wipe = true
		local uId = ((GetNumRaidMembers() == 0) and "party") or "raid"
		for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
			local id = (i == 0 and "player") or uId..i
			if UnitAffectingCombat(id) and not UnitIsDeadOrGhost(id) then
				wipe = false
				break
			end
		end
		if not wipe then
			DBM:Schedule(3, checkWipe)
		elseif confirm then
			for i = #inCombat, 1, -1 do
				DBM:EndCombat(inCombat[i], true)
			end
		else
			DBM:Schedule(5, checkWipe, true)
		end
	end
end

function DBM:StartCombat(mod, delay, synced)
	if not checkEntry(inCombat, mod) then
		if not mod.combatInfo then return end
		table.insert(inCombat, mod)
		self:AddMsg(DBM_CORE_COMBAT_STARTED:format(mod.combatInfo.name))
		if mod:IsDifficulty("heroic5", "heroic25") then
			mod.stats.heroicPulls = mod.stats.heroicPulls + 1
		elseif mod:IsDifficulty("normal5", "heroic10") then
			mod.stats.pulls = mod.stats.pulls + 1
		end
		mod.inCombat = true
		mod.blockSyncs = nil
		mod.combatInfo.pull = GetTime() - (delay or 0)
		self:Schedule(mod.minCombatTime or 3, checkWipe)
		if (DBM.Options.AlwaysShowHealthFrame or mod.Options.HealthFrame) and mod.Options.Enabled then
			DBM.BossHealth:Show(mod.localization.general.name)
			if mod.bossHealthInfo then
				for i = 1, #mod.bossHealthInfo, 2 do
					DBM.BossHealth:AddBoss(mod.bossHealthInfo[i], mod.bossHealthInfo[i + 1])
				end
			else
				DBM.BossHealth:AddBoss(mod.combatInfo.mob, mod.localization.general.name)
			end
		end
		if mod.OnCombatStart and mod.Options.Enabled then mod:OnCombatStart(delay or 0) end
		if not synced then
			sendSync("DBMv4-Pull", (delay or 0).."\t"..mod.id)
		end
		fireEvent("pull", mod, delay, synced)
		-- http://www.deadlybossmods.com/forum/viewtopic.php?t=1464
		if DBM.Options.ShowBigBrotherOnCombatStart and BigBrother and type(BigBrother.ConsumableCheck) == "function" then
			BigBrother:ConsumableCheck("SELF")
		end		
	end
end


function DBM:EndCombat(mod, wipe)
	if removeEntry(inCombat, mod) then
		mod:Stop()
		mod.inCombat = false
		mod.blockSyncs = true
		if mod.combatInfo.killMobs then
			for i, v in pairs(mod.combatInfo.killMobs) do
				mod.combatInfo.killMobs[i] = true
			end
		end
		if wipe then
			local thisTime = GetTime() - mod.combatInfo.pull
			if thisTime < 30 then
				if mod:IsDifficulty("heroic5", "heroic25") then
					mod.stats.heroicPulls = mod.stats.heroicPulls - 1
				elseif mod:IsDifficulty("normal5", "heroic10") then
					mod.stats.pulls = mod.stats.pulls - 1
				end
			end
			self:AddMsg(DBM_CORE_COMBAT_ENDED:format(mod.combatInfo.name, strFromTime(thisTime)))
			fireEvent("wipe", mod)
		else
			local thisTime = GetTime() - mod.combatInfo.pull
			local lastTime = (mod:IsDifficulty("heroic5", "heroic25") and mod.stats.heroicLastTime) or mod:IsDifficulty("normal5", "heroic10") and mod.stats.lastTime
			local bestTime = (mod:IsDifficulty("heroic5", "heroic25") and mod.stats.heroicBestTime) or mod:IsDifficulty("normal5", "heroic10") and mod.stats.bestTime
			if mod:IsDifficulty("heroic5", "heroic25") then
				mod.stats.heroicKills = mod.stats.heroicKills + 1
				mod.stats.heroicLastTime = thisTime
				mod.stats.heroicBestTime = math.min(bestTime or math.huge, thisTime)
			elseif mod:IsDifficulty("normal5", "heroic10") then
				mod.stats.kills = mod.stats.kills + 1
				mod.stats.lastTime = thisTime
				mod.stats.bestTime = math.min(bestTime or math.huge, thisTime)
			end
			if not lastTime then
				self:AddMsg(DBM_CORE_BOSS_DOWN:format(mod.combatInfo.name, strFromTime(thisTime)))
			elseif thisTime < (bestTime or math.huge) then
				self:AddMsg(DBM_CORE_BOSS_DOWN_NEW_RECORD:format(mod.combatInfo.name, strFromTime(thisTime), strFromTime(bestTime)))
			else
				self:AddMsg(DBM_CORE_BOSS_DOWN_LONG:format(mod.combatInfo.name, strFromTime(thisTime), strFromTime(lastTime), strFromTime(bestTime)))
			end
			fireEvent("kill", mod)
		end
		if mod.OnCombatEnd then mod:OnCombatEnd(wipe) end
		DBM.BossHealth:Hide()
	end
end

function DBM:OnMobKill(cId, synced)
	for i = #inCombat, 1, -1 do
		local v = inCombat[i]
		if not v.combatInfo then
			return
		end
		if v.combatInfo.killMobs and v.combatInfo.killMobs[cId] then
			if not synced then
				sendSync("DBMv4-Kill", cId)
			end
			v.combatInfo.killMobs[cId] = false
			local allMobsDown = true
			for i, v in pairs(v.combatInfo.killMobs) do
				if v then
					allMobsDown = false
					break
				end
			end
			if allMobsDown then
				self:EndCombat(v)
			end
		elseif cId == v.combatInfo.mob and not v.combatInfo.killMobs and not v.combatInfo.multiMobPullDetection then
			if not synced then
				sendSync("DBMv4-Kill", cId)
			end
			self:EndCombat(v)
		end
	end
end

function DBM:UNIT_DIED(args)
	if bit.band(args.destGUID:sub(1, 5), 0x00F) == 3 or bit.band(args.destGUID:sub(1, 5), 0x00F) == 5  then
		if wowVersion >= 30300 then
			self:OnMobKill(tonumber(args.destGUID:sub(7, 10), 16))
		else
			self:OnMobKill(tonumber(args.destGUID:sub(9, 12), 16))
		end
	end
end
DBM.UNIT_DESTROYED = DBM.UNIT_DIED


----------------------
--  Timer recovery  --
----------------------
do
	local requestedFrom = nil
	local requestTime = 0

	function DBM:RequestTimers()
		local bestClient
		for i, v in pairs(raid) do
			if v.name ~= UnitName("player") and UnitIsConnected(v.id) and (not UnitIsGhost(v.id)) and (v.revision or 0) > ((bestClient and bestClient.revision) or 0) then
				bestClient = v
			end
		end
		if not bestClient then return end
		requestedFrom = bestClient.name
		requestTime = GetTime()
		SendAddonMessage("DBMv4-RequestTimers", "", "WHISPER", bestClient.name)
	end

	function DBM:ReceiveCombatInfo(sender, mod, time)
		if sender == requestedFrom and (GetTime() - requestTime) < 5 and #inCombat == 0 then
			local lag = select(3, GetNetStats()) / 1000
			if not mod.combatInfo then return end
			table.insert(inCombat, mod)
			mod.inCombat = true
			mod.blockSyncs = nil
			mod.combatInfo.pull = GetTime() - time + lag
			self:Schedule(3, checkWipe)
		end
	end

	function DBM:ReceiveTimerInfo(sender, mod, timeLeft, totalTime, id, ...)
		if sender == requestedFrom and (GetTime() - requestTime) < 5 then
			local lag = select(3, GetNetStats()) / 1000
			for i, v in ipairs(mod.timers) do
				if v.id == id then
					v:Start(totalTime, ...)
					v:Update(totalTime - timeLeft + lag, totalTime, ...)
				end
			end
		end
	end
end

function DBM:SendTimers(target)
	if #inCombat < 1 then return end
	local mod
	for i, v in ipairs(inCombat) do
		mod = not v.isCustomMod and v
	end
	mod = mod or inCombat[1]
	self:SendCombatInfo(mod, target)
	self:SendTimerInfo(mod, target)
end

function DBM:SendCombatInfo(mod, target)
	return SendAddonMessage("DBMv4-CombatInfo", ("%s\t%s"):format(mod.id, GetTime() - mod.combatInfo.pull), "WHISPER", target)
end

function DBM:SendTimerInfo(mod, target)
	for i, v in ipairs(mod.timers) do
		for _, uId in ipairs(v.startedTimers) do
			local elapsed, totalTime, timeLeft
			if select("#", string.split("\t", uId)) > 1 then
				elapsed, totalTime = v:GetTime(select(2, string.split("\t", uId)))
			else
				elapsed, totalTime = v:GetTime()
			end
			timeLeft = totalTime - elapsed
			if timeLeft > 0 and totalTime > 0 then
				SendAddonMessage("DBMv4-TimerInfo", ("%s\t%s\t%s\t%s"):format(mod.id, timeLeft, totalTime, uId), "WHISPER", target)
			end
		end
	end
end

do
	local function requestTimers()
		local uId = ((GetNumRaidMembers() == 0) and "party") or "raid"
		for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
			local id = (i == 0 and "player") or uId..i
			if UnitAffectingCombat(id) and not UnitIsDeadOrGhost(id) then
				DBM:RequestTimers()
				break
			end
		end
	end

	function DBM:PLAYER_ENTERING_WORLD()
		if #inCombat == 0 then
			DBM:Schedule(0, requestTimers)
		end
	end
end


------------------------------------
--  Auto-respond/Status whispers  --
------------------------------------
do
	local function getNumAlivePlayers()
		local alive = 0
		if GetNumRaidMembers() > 0 then
			for i = 1, GetNumRaidMembers() do
				alive = alive + ((UnitIsDeadOrGhost("raid"..i) and 0) or 1)
			end
		else
			alive = (UnitIsDeadOrGhost("player") and 0) or 1
			for i = 1, GetNumPartyMembers() do
				alive = alive + ((UnitIsDeadOrGhost("party"..i) and 0) or 1)
			end
		end
		return alive
	end

	function DBM:CHAT_MSG_WHISPER(msg, sender)
		if msg == "status" and #inCombat > 0 and self.Options.StatusEnabled then
			local mod
			for i, v in ipairs(inCombat) do
				mod = not v.isCustomMod and v
			end
			mod = mod or inCombat[1]
			SendChatMessage(chatPrefix..DBM_CORE_STATUS_WHISPER:format((mod.combatInfo.name or ""), mod:GetHP() or "unknown", getNumAlivePlayers(), math.max(GetNumRaidMembers(), GetNumPartyMembers() + 1)), "WHISPER", nil, sender)
		elseif #inCombat > 0 and self.Options.AutoRespond and self:GetRaidUnitId(sender) == "none" then
			local mod
			for i, v in ipairs(inCombat) do
				mod = not v.isCustomMod and v
			end
			mod = mod or inCombat[1]
			if not autoRespondSpam[sender] then
				SendChatMessage(chatPrefix..DBM_CORE_AUTO_RESPOND_WHISPER:format(UnitName("player"), mod.combatInfo.name or "", mod:GetHP() or "unknown", getNumAlivePlayers(), math.max(GetNumRaidMembers(), GetNumPartyMembers() + 1)), "WHISPER", nil, sender)
				self:AddMsg(DBM_CORE_AUTO_RESPONDED)
			end
			autoRespondSpam[sender] = GetTime()
		end
	end
end


-------------------
--  Chat Filter  --
-------------------
do
	local function filterOutgoing(self, event, ...)
		local msg = ...
		if not msg and self then -- compatibility mode!
			-- we also check if self exists to prevent a possible freeze if the function is called without arguments at all
			-- as this would be even worse than the issue with missing whisper messages ;)
			return filterOutgoing(nil, nil, self, event)
		end
		return msg:sub(1, chatPrefix:len()) == chatPrefix or msg:sub(1, chatPrefixShort:len()) == chatPrefixShort, ...
	end

	local function filterIncoming(self, event, ...)
		local msg = ...
		if not msg and self then -- compatibility mode!
			return filterIncoming(nil, nil, self, event)
		end
		if DBM.Options.SpamBlockBossWhispers then
			return #inCombat > 0 and (msg == "status" or msg:sub(1, chatPrefix:len()) == chatPrefix or msg:sub(1, chatPrefixShort:len()) == chatPrefixShort), ...
		else
			return msg == "status" and #inCombat > 0, ...
		end
	end

	local function filterRaidWarning(self, event, ...)
		local msg = ...
		if not msg and self then -- compatibility mode!
			return filterRaidWarning(nil, nil, self, event)
		end
		return DBM.Options.SpamBlockRaidWarning and type(msg) == "string" and (not not msg:match("^%s*%*%*%*")), ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterOutgoing)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterIncoming)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filterRaidWarning)
end


do
	local old = RaidWarningFrame:GetScript("OnEvent")
	RaidWarningFrame:SetScript("OnEvent", function(self, event, msg, ...)
		if DBM.Options.SpamBlockRaidWarning and msg:find("%*%*%* .* %*%*%*") then
			return
		end
		return old(self, event, msg, ...)
	end)
end

do	
	local old = RaidBossEmoteFrame:GetScript("OnEvent")
	RaidBossEmoteFrame:SetScript("OnEvent", function(...)
		if DBM.Options.HideBossEmoteFrame and #inCombat > 0 then
			return
		end
		return old(...)
	end)
end


--------------------------
--  Enable/Disable DBM  --
--------------------------
function DBM:Disable()
	unschedule()
	self.Options.Enabled = false
end

function DBM:Enable()
	self.Options.Enabled = true
end

function DBM:IsEnabled()
	return self.Options.Enabled
end


-----------------------
--  Misc. Functions  --
-----------------------
function DBM:AddMsg(text, prefix)
	prefix = prefix or (self.localization and self.localization.general.name) or "Deadly Boss Mods"
	DEFAULT_CHAT_FRAME:AddMessage(("|cffff7d0a<|r|cffffd200%s|r|cffff7d0a>|r %s"):format(tostring(prefix), tostring(text)), 0.41, 0.8, 0.94)
end

do
	local testMod
	local testWarning1, testWarning2, testWarning3
	local testTimer
	local testSpecialWarning
	function DBM:DemoMode()
		if not testMod then
			testMod = DBM:NewMod("TestMod")
			testWarning1 = testMod:NewAnnounce("%s", 1, "Interface\\Icons\\Spell_Nature_WispSplode")
			testWarning2 = testMod:NewAnnounce("%s", 2, "Interface\\Icons\\Spell_Shadow_ShadesOfDarkness")
			testWarning3 = testMod:NewAnnounce("%s", 3, "Interface\\Icons\\Spell_Fire_SelfDestruct")
			testTimer = testMod:NewTimer(20, "%s")			
			testSpecialWarning = testMod:NewSpecialWarning("%s")
		end
		testTimer:Start(20, "Pew Pew Pew...")
		testTimer:UpdateIcon("Interface\\Icons\\Spell_Nature_Starfall", "Pew Pew Pew...")
		testTimer:Start(10, "Test Bar")
		testTimer:UpdateIcon("Interface\\Icons\\Spell_Nature_WispSplode", "Test Bar")
		testTimer:Start(43, "Evil Spell")
		testTimer:UpdateIcon("Interface\\Icons\\Spell_Shadow_ShadesOfDarkness", "Evil Spell")
		testTimer:Start(60, "Boom!")
		testTimer:UpdateIcon("Interface\\Icons\\Spell_Fire_SelfDestruct", "Boom!")
		testWarning1:Show("Test-mode started...")
		testWarning1:Schedule(62, "Test-mode finished!")
		testWarning3:Schedule(50, "Boom in 10 sec!")
		testWarning3:Schedule(20, "Pew Pew Laser Owl!")
		testWarning2:Schedule(38, "Evil Spell in 5 sec!")
		testWarning2:Schedule(43, "Evil Spell!")
		testWarning1:Schedule(10, "Test bar expired!")
		testSpecialWarning:Schedule(60, "Boom!")
	end
end

DBM.Bars:SetAnnounceHook(function(bar)
	local prefix
	if bar.color and bar.color.r == 1 and bar.color.g == 0 and bar.color.b == 0 then
		prefix = DBM_CORE_HORDE
	elseif bar.color and bar.color.r == 0 and bar.color.g == 0 and bar.color.b == 1 then
		prefix = DBM_CORE_ALLIANCE
	end
	if prefix then
		return ("%s: %s  %d:%02d"):format(prefix, _G[bar.frame:GetName().."BarName"]:GetText(), math.floor(bar.timer / 60), bar.timer % 60)
	end
end)

--------------------------
--  Boss Mod Prototype  --
--------------------------
local bossModPrototype = {}


----------------------------
--  Boss Mod Constructor  --
----------------------------
do
	local modsById = setmetatable({}, {__mode = "v"})
	local mt = {__index = bossModPrototype}

	function DBM:NewMod(name, modId, modSubTab)
		if modsById[name] then error("DBM:NewMod(): Mod names are used as IDs and must therefore be unique.", 2) end
		local obj = setmetatable(
			{
				Options = {
					Enabled = true,
					Announce = false,
				},
				subTab = modSubTab,
				optionCategories = {
				},
				categorySort = {},
				id = name,
				announces = {},
				timers = {},
				modId = modId,
				revision = 0,
				localization = self:GetModLocalization(name)
			},
			mt
		)
		for i, v in ipairs(self.AddOns) do
			if v.modId == modId then
				obj.addon = v
				break
			end
		end
		if obj.localization.general.name == "name" then obj.localization.general.name = name end
		table.insert(self.Mods, obj)
		modsById[name] = obj
		obj:AddBoolOption("HealthFrame", false, "misc")
		obj:SetZone()
		return obj
	end

	function DBM:GetModByName(name)
		return modsById[name]
	end
end


-----------------------
--  General Methods  --
-----------------------
bossModPrototype.RegisterEvents = DBM.RegisterEvents
bossModPrototype.UnregisterAllEvents = DBM.UnregisterAllEvents
bossModPrototype.AddMsg = DBM.AddMsg

function bossModPrototype:SetZone(...)
	if select("#", ...) == 0 then
		self.zones = (self.addon and self.addon.zone) or {}
	elseif select(1, ...) ~= DBM_DISABLE_ZONE_DETECTION then
		self.zones = {...}
	else -- disable zone detection
		self.zones = nil
	end
end

function bossModPrototype:SetCreatureID(...)
	self.creatureId = ...
	if select("#", ...) > 1 then
		self.multiMobPullDetection = {...}
		if self.combatInfo then
			self.combatInfo.multiMobPullDetection = self.multiMobPullDetection
		end
	end
end

function bossModPrototype:Toggle()
	if self.Options.Enabled then
		self:DisableMod()
	else
		self:EnableMod()
	end
end

function bossModPrototype:EnableMod()
	self.Options.Enabled = true
end

function bossModPrototype:DisableMod()
	self:Stop()
	self.Options.Enabled = false
end

function bossModPrototype:RegisterOnUpdateHandler(func, interval)
	if type(func) ~= "function" then return end
	self.elapsed = 0
	self.updateInterval = interval or 0
	updateFunctions[self] = func
end

function bossModPrototype:SetRevision(revision)
	self.revision = revision
end

function bossModPrototype:SendWhisper(msg, target)
	return SendChatMessage(chatPrefixShort..msg, "WHISPER", nil, target)
end

function bossModPrototype:GetUnitCreatureId(uId)
	local guid = UnitGUID(uId)
	if wowVersion >= 30300 then
		return (guid and tonumber(guid:sub(7, 10), 16)) or 0
	else
		return (guid and tonumber(guid:sub(9, 12), 16)) or 0
	end
end

function bossModPrototype:GetCIDFromGUID(guid)
	if wowVersion >= 30300 then
		return (guid and tonumber(guid:sub(7, 10), 16)) or 0
	else
		return (guid and tonumber(guid:sub(9, 12), 16)) or 0
	end
end

function bossModPrototype:GetBossTarget(cid)
	cid = cid or self.creatureId
	for i = 1, GetNumRaidMembers() do
		if self:GetUnitCreatureId("raid"..i.."target") == cid then
			return UnitName("raid"..i.."targettarget"), "raid"..i.."targettarget"
		elseif self:GetUnitCreatureId("focus") == cid then	-- we check our own focus frame, maybe the boss is there ;)
			return UnitName("focustarget"), "focustarget"
		end
	end
end

function bossModPrototype:Stop(cid)
	for i, v in ipairs(self.timers) do
		v:Stop()
	end
	self:Unschedule()
end

-- hard coded party-mod support, yay :)
-- returns heroic for old instances that do not have a heroic mode (Naxx, Ulduar...)
function bossModPrototype:GetDifficulty()
	if GetInstanceDifficulty() == 1 then
		return self.modId == "DBM-Party-WotLK" and "normal5" or
		self.hasHeroic and "normal10" or "heroic10"
	elseif GetInstanceDifficulty() == 2 then
		return self.modId == "DBM-Party-WotLK" and "heroic5" or
		self.hasHeroic and "normal25" or "heroic25"
	elseif GetInstanceDifficulty() == 3 then
		return "heroic10"
	elseif GetInstanceDifficulty() == 4 then
		return "heroic25"
	end
end

function bossModPrototype:IsDifficulty(...)
	local diff = self:GetDifficulty()
	for i = 1, select("#", ...) do
		if diff == select(i, ...) then
			return true
		end
	end
	return false
end

function bossModPrototype:SetUsedIcons(...)
	self.usedIcons = {}
	for i = 1, select("#", ...) do
		self.usedIcons[select(i, ...)] = true
	end
end


-------------------------
--  Boss Health Frame  --
-------------------------
function bossModPrototype:SetBossHealthInfo(...)
	self.bossHealthInfo = {...}
end


-----------------------
--  Announce Object  --
-----------------------
do
	local textureCode = " |T%s:24:24|t "
	local textureExp = " |T(%S+):24:24|t "
	local announcePrototype = {}
	local mt = {__index = announcePrototype}
	
	local cachedColorFunctions = setmetatable({}, {__mode = "kv"})

	function announcePrototype:Show(...) -- todo: reduce amount of unneeded strings
		if not self.option or self.mod.Options[self.option] then
			if self.mod.Options.Announce and (DBM:GetRaidRank() > 0 or (GetNumRaidMembers() == 0 and GetNumPartyMembers() >= 1)) then
				SendChatMessage(("*** %s ***"):format(pformat(self.text, ...)), "RAID_WARNING")
			end
			local colorCode = ("|cff%.2x%.2x%.2x"):format(self.color.r * 255, self.color.g * 255, self.color.b * 255)
			local text = ("%s%s%s|r%s"):format(
				(DBM.Options.WarningIconLeft and self.icon and textureCode:format(self.icon)) or "",
				colorCode,
				pformat(self.text, ...),
				(DBM.Options.WarningIconRight and self.icon and textureCode:format(self.icon)) or ""
			)
			if not cachedColorFunctions[self.color] then
				local color = self.color -- upvalue for the function to colorize names
				cachedColorFunctions[color] = function(cap)
					cap = cap:sub(2, -2)
					if DBM:GetRaidClass(cap) then
						local playerColor = RAID_CLASS_COLORS[DBM:GetRaidClass(cap)] or color
						cap = ("|r|cff%.2x%.2x%.2x%s|r|cff%.2x%.2x%.2x"):format(playerColor.r * 255, playerColor.g * 255, playerColor.b * 255, cap, color.r * 255, color.g * 255, color.b * 255)
					end
					return cap
				end
			end
			text = text:gsub(">%S+<", cachedColorFunctions[self.color])
			RaidNotice_AddMessage(RaidWarningFrame, text, ChatTypeInfo["RAID_WARNING"]) -- the color option doesn't work (at least it didn't work during the WotLK beta...todo: check this)
			if DBM.Options.ShowWarningsInChat then
				text = text:gsub(textureExp, "") -- textures @ chat frame can (and will) distort the font
				if DBM.Options.ShowFakedRaidWarnings then
					for i = 1, select("#", GetFramesRegisteredForEvent("CHAT_MSG_RAID_WARNING")) do
						local frame = select(i, GetFramesRegisteredForEvent("CHAT_MSG_RAID_WARNING"))
						if frame ~= RaidWarningFrame and frame:GetScript("OnEvent") then
							frame:GetScript("OnEvent")(frame, "CHAT_MSG_RAID_WARNING", text, UnitName("player"), GetDefaultLanguage("player"), "", UnitName("player"), "", 0, 0, "", 0, 99, "")
						end
					end
				else
					self.mod:AddMsg(text, nil)
				end
			end
			PlaySoundFile(DBM.Options.RaidWarningSound)
		end
	end

	function announcePrototype:Schedule(t, ...)
		return schedule(t, self.Show, self.mod, self, ...)
	end

	function announcePrototype:Cancel(...)
		return unschedule(self.Show, self.mod, self, ...)
	end

	-- old constructor (no auto-localize)
	function bossModPrototype:NewAnnounce(text, color, icon, optionDefault, optionName)
		local obj = setmetatable(
			{
				text = self.localization.warnings[text],
				color = DBM.Options.WarningColors[color or 1] or DBM.Options.WarningColors[1],
				option = optionName or text,
				mod = self,
				icon = (type(icon) == "number" and select(3, GetSpellInfo(icon))) or icon,
			},
			mt
		)
		if optionName == false then
			obj.option = nil
		else
			self:AddBoolOption(optionName or text, optionDefault, "announce")
		end
		table.insert(self.announces, obj)
		return obj
	end
	
	-- new constructor (auto-localized warnings and options, yay!)
	local function newAnnounce(self, announceType, spellId, color, icon, optionDefault, optionName, castTime, preWarnTime)
		spellName = GetSpellInfo(spellId) or "unknown"
		icon = icon or spellId
		local text
		if announceType == "cast" then
			local spellHaste = select(7, GetSpellInfo(53142)) / 10000 -- 53142 = Dalaran Portal, should have 10000 ms cast time
			local timer = (select(7, GetSpellInfo(spellId)) or 1000) / spellHaste
			text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announceType]:format(spellName, castTime or (timer / 1000))
		elseif announceType == "prewarn" then
			if type(preWarnTime) == "string" then
				text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announceType]:format(spellName, preWarnTime)
			else
				text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announceType]:format(spellName, DBM_CORE_SEC_FMT:format(preWarnTime or 5))
			end
		elseif announceType == "phase" then
			text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announceType]:format(spellId)
		else
			text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announceType]:format(spellName)
		end
		local obj = setmetatable( -- todo: fix duplicate code
			{
				text = text,
				announceType = announceType,
				color = DBM.Options.WarningColors[color or 1] or DBM.Options.WarningColors[1],
				option = optionName or text,
				mod = self,
				icon = (type(icon) == "number" and select(3, GetSpellInfo(icon))) or icon,
			},
			mt
		)
		if optionName == false then
			obj.option = nil
		else
			self:AddBoolOption(optionName or text, optionDefault, "announce")
		end
		table.insert(self.announces, obj)
		self.localization.options[text] = DBM_CORE_AUTO_ANNOUNCE_OPTIONS[announceType]:format(spellId, spellName)
		return obj
	end
	
	function bossModPrototype:NewTargetAnnounce(spellId, color, ...)
		return newAnnounce(self, "target", spellId, color or 2, ...)
	end
	
	function bossModPrototype:NewSpellAnnounce(spellId, color, ...)
		return newAnnounce(self, "spell", spellId, color or 3, ...)
	end

	function bossModPrototype:NewCastAnnounce(spellId, color, castTime, icon, optionDefault, optionName)
		return newAnnounce(self, "cast", spellId, color or 3, icon, optionDefault, optionName, castTime)
	end

	function bossModPrototype:NewSoonAnnounce(spellId, color, ...)
		return newAnnounce(self, "soon", spellId, color or 1, ...)
	end
	
	function bossModPrototype:NewPreWarnAnnounce(spellId, time, color, icon, optionDefault, optionName)
		return newAnnounce(self, "prewarn", spellId, color or 1, icon, optionDefault, optionName, nil, time)
	end
	
	function bossModPrototype:NewPhaseAnnounce(phase, color, icon, ...)
		return newAnnounce(self, "phase", phase, color or 1, icon or "Interface\\Icons\\Spell_Nature_WispSplode", ...)
	end
end

--------------------
--  Sound Object  --
--------------------
do
	local soundPrototype = {}
	local mt = { __index = soundPrototype }
	function bossModPrototype:NewSound(spellId, optionName, optionDefault)
		self.numSounds = self.numSounds and self.numSounds + 1 or 1
		local obj = setmetatable(
			{
				option = optionName or "Sound"..spellId..self.numSounds,
				mod = self,
			},
			mt
		)
		if optionName == false then
			obj.option = nil
		else
			self:AddBoolOption(obj.option, optionDefault, "misc")
		end
		return obj
	end
	bossModPrototype.NewRunAwaySound = bossModPrototype.NewSound
	
	function soundPrototype:Play(file)
		if not self.option or self.mod.Options[self.option] then
			PlaySoundFile(file or "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	end

	function soundPrototype:Schedule(t, ...)
		return schedule(t, self.Play, self.mod, self, ...)
	end

	function soundPrototype:Cancel(...)
		return unschedule(self.Play, self.mod, self, ...)
	end	
end

------------------------------
--  Special Warning Object  --
------------------------------
do	
	local frame = CreateFrame("Frame", nil, UIParent)
	local font = frame:CreateFontString(nil, "OVERLAY", "ZoneTextFont")
	frame:SetMovable(1)
	frame:SetWidth(1)
	frame:SetHeight(1)	
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen()
	frame:Hide()
	font:SetWidth(1024)
	font:SetHeight(0)
	font:SetPoint("CENTER", 0, 0)
		
	local moving
	local specialWarningPrototype = {}
	local mt = {__index = specialWarningPrototype}

	function DBM:UpdateSpecialWarningOptions()
		frame:ClearAllPoints()
		frame:SetPoint(DBM.Options.SpecialWarningPoint, UIParent, DBM.Options.SpecialWarningPoint, DBM.Options.SpecialWarningX, DBM.Options.SpecialWarningY)
		font:SetFont(DBM.Options.SpecialWarningFont, DBM.Options.SpecialWarningFontSize, "THICKOUTLINE")
		font:SetTextColor(unpack(DBM.Options.SpecialWarningFontColor))
	end
	
	local shakeFrame = CreateFrame("Frame")
	shakeFrame:SetScript("OnUpdate", function(self, elapsed)
		self.timer = self.timer - elapsed
	end)
	shakeFrame:Hide()
	
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.timer = self.timer - elapsed
		if self.timer >= 3 and self.timer <= 4 then
			LowHealthFrame:SetAlpha(self.timer - 3)
		elseif self.timer <= 2 then
			frame:SetAlpha(self.timer/2)
		elseif self.timer <= 0 then
			frame:Hide()
		end
	end)

	function specialWarningPrototype:Show(...)
		if DBM.Options.ShowSpecialWarnings and (not self.option or self.mod.Options[self.option]) and not moving and frame then	
			font:SetText(pformat(self.text, ...))
			LowHealthFrame:Show()
			LowHealthFrame:SetAlpha(1)
			frame:Show()
			frame:SetAlpha(1)
			frame.timer = 5
			if self.sound then
				PlaySoundFile(DBM.Options.SpecialWarningSound)
			end
		end
	end

	function specialWarningPrototype:Schedule(t, ...)
		return schedule(t, self.Show, self.mod, self, ...)
	end

	function specialWarningPrototype:Cancel(t, ...)
		return unschedule(self.Show, self.mod, self, ...)
	end

	function bossModPrototype:NewSpecialWarning(text, optionDefault, optionName, noSound, runSound)
		local obj = setmetatable(
			{
				text = self.localization.warnings[text], 
				option = optionName or text,
				mod = self,
				sound = not noSound,
			},
			mt
		)
		if optionName == false then
			obj.option = nil
		else
			self:AddBoolOption(optionName or text, optionDefault, "announce")		
		end
		table.insert(self.announces, obj)
		return obj
	end
	
	do
		local anchorFrame
		local function moveEnd()
			moving = false
			anchorFrame:Hide()
			frame.timer = 1.5 -- fade out
			frame:SetFrameStrata("HIGH")
			DBM:Unschedule(moveEnd)
			DBM.Bars:CancelBar(DBM_CORE_MOVE_SPECIAL_WARNING_BAR)
		end
		
		function DBM:MoveSpecialWarning()
			if not anchorFrame then
				anchorFrame = CreateFrame("Frame", nil, frame)
				anchorFrame:SetWidth(32)
				anchorFrame:SetHeight(32)
				anchorFrame:EnableMouse(true)
				anchorFrame:SetPoint("CENTER", 0, -32)
				anchorFrame:RegisterForDrag("LeftButton")
				anchorFrame:SetClampedToScreen()
				anchorFrame:Hide()
				local texture = anchorFrame:CreateTexture()
				texture:SetTexture("Interface\\Addons\\DBM-GUI\\textures\\dot.blp")
				texture:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
				texture:SetWidth(32)
				texture:SetHeight(32)
				anchorFrame:SetScript("OnDragStart", function() 
					frame:StartMoving()
					DBM:Unschedule(moveEnd)
					DBM.Bars:CancelBar(DBM_CORE_MOVE_SPECIAL_WARNING_BAR)
				end)
				anchorFrame:SetScript("OnDragStop", function() 
					frame:StopMovingOrSizing()
					local point, _, _, xOfs, yOfs = frame:GetPoint(1)		
					DBM.Options.SpecialWarningPoint = point
					DBM.Options.SpecialWarningX = xOfs
					DBM.Options.SpecialWarningY = yOfs	
					DBM:Schedule(15, moveEnd)
					DBM.Bars:CreateBar(15, DBM_CORE_MOVE_SPECIAL_WARNING_BAR)
				end)
			end
			if anchorFrame:IsShown() then
				moveEnd()
			else
				moving = true
				anchorFrame:Show()
				self:Schedule(15, moveEnd)
				DBM.Bars:CreateBar(15, DBM_CORE_MOVE_SPECIAL_WARNING_BAR)
				font:SetText(DBM_CORE_MOVE_SPECIAL_WARNING_TEXT)
				frame:Show()
				frame:SetFrameStrata("TOOLTIP")
				frame:SetAlpha(1)
				frame.timer = math.huge
			end
		end
	end
	
	local function testWarningEnd()
		frame:SetFrameStrata("HIGH")
	end
	
	function DBM:ShowTestSpecialWarning(text)
		if moving then
			return
		end
		font:SetText(DBM_CORE_MOVE_SPECIAL_WARNING_TEXT)
		frame:Show()
		frame:SetAlpha(1)
		frame:SetFrameStrata("TOOLTIP")
		self:Unschedule(testWarningEnd)
		self:Schedule(3, testWarningEnd)
		frame.timer = 3
	end
end


--------------------
--  Timer Object  --
--------------------
do
	local timerPrototype = {}
	local mt = {__index = timerPrototype}

	function timerPrototype:Start(timer, ...)
		if timer and type(timer) ~= "number" then
			return self:Start(nil, timer, ...) -- first argument is optional!
		end
		if not self.option or self.mod.Options[self.option] then
			local timer = timer and ((timer > 0 and timer) or self.timer + timer) or self.timer
			local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
			local bar = DBM.Bars:CreateBar(timer, id, self.icon)
			if not bar then
				return false, "error" -- creating the timer failed somehow, maybe hit the hard-coded timer limit of 15
			end
			if self.type and not self.text then
				bar:SetText(pformat(self.mod:GetLocalizedTimerText(self.type, self.spellId), ...))
			else				
				bar:SetText(pformat(self.text, ...))
			end
			table.insert(self.startedTimers, id)
			self.mod:Unschedule(removeEntry, self.startedTimers, id)
			self.mod:Schedule(timer, removeEntry, self.startedTimers, id)
			return bar
		else
			return false, "disabled"
		end
	end
	timerPrototype.Show = timerPrototype.Start

	function timerPrototype:Schedule(t, ...)
		return schedule(t, self.Start, self.mod, self, ...)
	end
	
	function timerPrototype:Unschedule(t, ...)
		return unschedule(self.Start, self.mod, self, ...)
	end

	function timerPrototype:Stop(...)
		if select("#", ...) == 0 then
			for i = #self.startedTimers, 1, -1 do
				DBM.Bars:CancelBar(self.startedTimers[i])
				self.startedTimers[i] = nil
			end
		else
			local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
			for i = #self.startedTimers, 1, -1 do
				if self.startedTimers[i] == id then
					DBM.Bars:CancelBar(id)
					table.remove(self.startedTimers, i)
				end
			end
		end
	end
	
	function timerPrototype:Cancel(...)
		self:Stop(...)
		self:Unschedule(...)
	end

	function timerPrototype:GetTime(...)
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		local bar = DBM.Bars:GetBar(id)
		return bar and (bar.totalTime - bar.timer) or 0, (bar and bar.totalTime) or 0
	end
	
	function timerPrototype:IsStarted(...)
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		local bar = DBM.Bars:GetBar(id)
		return bar and true
	end
	
	function timerPrototype:SetTimer(timer)
		self.timer = timer
	end

	function timerPrototype:Update(elapsed, totalTime, ...)
		if self:GetTime(...) == 0 then
			self:Start(totalTime, ...)
		end
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		return DBM.Bars:UpdateBar(id, elapsed, totalTime)
	end

	function timerPrototype:UpdateIcon(icon, ...)
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		local bar = DBM.Bars:GetBar(id)
		if bar then
			return bar:SetIcon((type(icon) == "number" and select(3, GetSpellInfo(icon))) or icon)
		end
	end

	function timerPrototype:UpdateName(name, ...)
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		local bar = DBM.Bars:GetBar(id)
		if bar then
			return bar:SetText(name)
		end
	end

	function timerPrototype:SetColor(c, ...)
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		local bar = DBM.Bars:GetBar(id)
		if bar then
			return bar:SetColor(c)
		end
	end
	
	function timerPrototype:DisableEnlarge(...)
		local id = self.id..pformat((("\t%s"):rep(select("#", ...))), ...)
		local bar = DBM.Bars:GetBar(id)
		if bar then
			bar.small = true
		end
	end
	
	function timerPrototype:AddOption(optionDefault, optionName)
		if optionName ~= false then
			self.option = optionName or self.id
			self.mod:AddBoolOption(self.option, optionDefault, "timer")
		end
	end
	
	function bossModPrototype:NewTimer(timer, name, icon, optionDefault, optionName, r, g, b)
		local icon = type(icon) == "number" and select(3, GetSpellInfo(icon)) or icon
		local obj = setmetatable(
			{
				text = self.localization.timers[name],
				timer = timer,
				id = name,
				icon = icon,
				r = r,
				g = g,
				b = b,
				startedTimers = {},
				mod = self,
			},
			mt
		)
		obj:AddOption(optionDefault, optionName)
		table.insert(self.timers, obj)
		return obj
	end
	
	-- new constructor for the new auto-localized timer types
	-- note that the function might look unclear because it needs to handle different timer types, especially achievement timers need special treatment
	-- todo: disable the timer if the player already has the achievement and when the ACHIEVEMENT_EARNED event is fired
	-- problem: heroic/normal achievements :[
	-- local achievementTimers = {}
	local function newTimer(self, timerType, timer, spellId, timerText, optionDefault, optionName, texture, r, g, b)
		-- new argument timerText is optional (usually only required for achievement timers as they have looooong names)
		if type(timerText) == "boolean" or type(optionDefault) == "string" then -- check if the argument was skipped
			return newTimer(self, timerType, timer, spellId, nil, timerText, optionDefault, optionName, texture, r, g, b)
		end
		local spellName, icon
		if timerType == "achievement" then
			spellName = select(2, GetAchievementInfo(spellId))
			icon = type(texture) == "number" and select(10, GetAchievementInfo(texture)) or texture or spellId and select(10, GetAchievementInfo(spellId))
--			if optionDefault == nil then
--				local completed = select(4, GetAchievementInfo(spellId))
--				optionDefault = not completed
--			end
		else
			spellName = GetSpellInfo(spellId)
			icon = type(texture) == "number" and select(3, GetSpellInfo(texture)) or texture or spellId and select(3, GetSpellInfo(spellId))
		end
		spellName = spellName or tostring(spellId)
		local id = "Timer"..spellId..self.id..#self.timers
		local obj = setmetatable(
			{
				text = self.localization.timers[timerText],
				type = timerType,
				spellId = spellId,
				timer = timer,
				id = id,
				icon = icon,
				r = r,
				g = g,
				b = b,
				startedTimers = {},
				mod = self,
			},
			mt
		)
		obj:AddOption(optionDefault, optionName)
		table.insert(self.timers, obj)
		-- todo: move the string creation to the GUI with SetFormattedString...
		if timerType == "achievement" then
			self.localization.options[id] = DBM_CORE_AUTO_TIMER_OPTIONS[timerType]:format(GetAchievementLink(spellId):gsub("%[(.+)%]", "%1"))
		else
			self.localization.options[id] = DBM_CORE_AUTO_TIMER_OPTIONS[timerType]:format(spellId, spellName)
		end
		return obj
	end

	function bossModPrototype:NewTargetTimer(...)
		return newTimer(self, "target", ...)
	end
	
	function bossModPrototype:NewBuffActiveTimer(...)
		return newTimer(self, "active", ...)
	end

	function bossModPrototype:NewCastTimer(timer, ...)
		if timer > 1000 then -- hehe :) best hack in DBM. This makes the first argument optional, so we can omit it to use the cast time from the spell id ;)
			local spellId = timer
			timer = select(7, GetSpellInfo(spellId)) or 1000 -- GetSpellInfo takes YOUR spell haste into account...WTF?
			local spellHaste = select(7, GetSpellInfo(53142)) / 10000 -- 53142 = Dalaran Portal, should have 10000 ms cast time
			timer = timer / spellHaste -- calculate the real cast time of the spell...
			return self:NewCastTimer(timer / 1000, spellId, ...)
		end
		return newTimer(self, "cast", timer, ...)
	end
	
	function bossModPrototype:NewCDTimer(...)
		return newTimer(self, "cd", ...)
	end
	
	function bossModPrototype:NewNextTimer(...)
		return newTimer(self, "next", ...)
	end
	
	function bossModPrototype:NewAchievementTimer(...)
		return newTimer(self, "achievement", ...)
	end
	
	function bossModPrototype:GetLocalizedTimerText(timerType, spellId)
		local spellName
		if timerType == "achievement" then
			spellName = select(2, GetAchievementInfo(spellId))
		else
			spellName = GetSpellInfo(spellId)
		end
		return pformat(DBM_CORE_AUTO_TIMER_TEXTS[timerType], spellName)
	end
end


---------------------
--  Enrage Object  --
---------------------
do
	local enragePrototype = {}
	local mt = {__index = enragePrototype}

	function enragePrototype:Start(timer)
		timer = timer or self.timer or 600
		timer = timer <= 0 and self.timer - timer or timer
		self.bar:SetTimer(timer)
		self.bar:Start()
		if timer > 660 then self.warning1:Schedule(timer - 600, 10, DBM_CORE_MIN) end
		if timer > 300 then self.warning1:Schedule(timer - 300, 5, DBM_CORE_MIN) end
		if timer > 180 then self.warning2:Schedule(timer - 180, 3, DBM_CORE_MIN) end
		if timer > 60 then self.warning2:Schedule(timer - 60, 1, DBM_CORE_MIN) end
		if timer > 30 then self.warning2:Schedule(timer - 30, 30, DBM_CORE_SEC) end
		if timer > 10 then self.warning2:Schedule(timer - 10, 10, DBM_CORE_SEC) end
	end

	function enragePrototype:Schedule(t)
		return self.owner:Schedule(t, self.Start, self)
	end

	function enragePrototype:Cancel()
		self.owner:Unschedule(self.Start, self)
		self.warning1:Cancel()
		self.warning2:Cancel()
		self.bar:Stop()
	end
	enragePrototype.Stop = enragePrototype.Cancel

	function bossModPrototype:NewEnrageTimer(timer, text, barText, barIcon)
		timer = timer or 600
		local warning1 = self:NewAnnounce(text or DBM_CORE_GENERIC_WARNING_ENRAGE, 1, nil, "warning_enrage", false)
		local warning2 = self:NewAnnounce(text or DBM_CORE_GENERIC_WARNING_ENRAGE, 4, nil, "warning_enrage", false)
		local bar = self:NewTimer(timer or 600, barText or DBM_CORE_GENERIC_TIMER_ENRAGE, barIcon or 28131, nil, "timer_enrage")
		local obj = setmetatable(
			{
				warning1 = warning1,
				warning2 = warning2,
				bar = bar,
				timer = timer,
				owner = self
			},
			mt
		)
		return obj
	end
end


---------------
--  Options  --
---------------
function bossModPrototype:AddBoolOption(name, default, cat, func)
	cat = cat or "misc"
	self.Options[name] = (default == nil) or default
	self:SetOptionCategory(name, cat)
	if func then
		self.optionFuncs = self.optionFuncs or {}
		self.optionFuncs[name] = func
	end
end

function bossModPrototype:RemoveOption(name)
	self.Options[name] = nil
	for i, options in pairs(self.optionCategories) do
		removeEntry(options, name)
		if #options == 0 then
			self.optionCategories[i] = nil
			removeEntry(self.categorySort, i)
		end
	end
	if self.optionFuncs then
		self.optionFuncs[name] = nil
	end
end

function bossModPrototype:AddSliderOption(name, minValue, maxValue, valueStep, default, cat, func)
	cat = cat or "misc"
	self.Options[name] = default or 0
	self:SetOptionCategory(name, cat)
	self.sliders = self.sliders or {}
	self.sliders[name] = {
		minValue = minValue,
		maxValue = maxValue,
		valueStep = valueStep,
	}
	if func then
		self.optionFuncs = self.optionFuncs or {}
		self.optionFuncs[name] = func
	end
end

function bossModPrototype:AddButton(name, onClick, cat, func)
	cat = cat or misc
	self:SetOptionCategory(name, cat)
	self.buttons = self.buttons or {}
	self.buttons[name] = onClick
	if func then
		self.optionFuncs = self.optionFuncs or {}
		self.optionFuncs[name] = func
	end
end

function bossModPrototype:AddDropdownOption(name, options, default, cat, func)
	cat = cat or "misc"
	self.Options[name] = default
	self:SetOptionCategory(name, cat)
	self.dropdowns = self.dropdowns or {}
	self.dropdowns[name] = options
	if func then
		self.optionFuncs = self.optionFuncs or {}
		self.optionFuncs[name] = func
	end
end

function bossModPrototype:AddOptionSpacer(cat)
	cat = cat or "misc"
	if self.optionCategories[cat] then
		table.insert(self.optionCategories[cat], DBM_OPTION_SPACER)
	end
end

function bossModPrototype:AddAnnounceSpacer()
	return self:AddOptionSpacer("announce")
end

function bossModPrototype:AddTimerSpacer()
	return self:AddOptionSpacer("timer")
end
	

function bossModPrototype:SetOptionCategory(name, cat)
	for _, options in pairs(self.optionCategories) do
		removeEntry(options, name)
	end
	if not self.optionCategories[cat] then
		self.optionCategories[cat] = {}
		table.insert(self.categorySort, cat)
	end
	table.insert(self.optionCategories[cat], name)
end


--------------
--  Combat  --
--------------
function bossModPrototype:RegisterCombat(cType, ...)
	local info = {
		type = cType,
		mob = self.creatureId,
		name = self.localization.general.name or self.id,
		msgs = (cType ~= "combat") and {...},
		mod = self
	}
	if self.multiMobPullDetection then
		info.multiMobPullDetection = self.multiMobPullDetection
	end
	local addedKillMobs = false
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if type(v) == "number" then
			info.killMobs = info.killMobs or {}
			info.killMobs[select(i, ...)] = true
			addedKillMobs = true
		end
	end
	if not addedKillMobs and self.multiMobPullDetection then
		for i, v in ipairs(self.multiMobPullDetection) do
			info.killMobs = info.killMobs or {}
			info.killMobs[v] = true
		end
	end
	self.combatInfo = info
	if not self.zones then return end
	for i, v in ipairs(self.zones) do
		combatInfo[v] = combatInfo[v] or {}
		table.insert(combatInfo[v], info)
	end
end

-- needs to be called _AFTER_ RegisterCombat
function bossModPrototype:RegisterKill(msgType, ...)
	if not self.combatInfo then
		return
	end
	self.combatInfo.killType = msgType
	self.combatInfo.killMsgs = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		self.combatInfo.killMsgs[v] = true
	end
end

function bossModPrototype:IsInCombat()
	return self.inCombat
end

function bossModPrototype:SetMinCombatTime(t)
	self.minCombatTime = t
end

function bossModPrototype:GetBossHPString(cId)
	local idType = (GetNumRaidMembers() == 0 and "party") or "raid"
	for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
		local unitId = ((i == 0) and "target") or idType..i.."target"
		local guid = UnitGUID(unitId)
		if wowVersion >= 30300 then
			if guid and tonumber(guid:sub(7, 10), 16) == cId then
				return math.floor(UnitHealth(unitId)/UnitHealthMax(unitId) * 100).."%"
			end
		else
			if guid and tonumber(guid:sub(9, 12), 16) == cId then
				return math.floor(UnitHealth(unitId)/UnitHealthMax(unitId) * 100).."%"
			end
		end
	end
	return DBM_CORE_UNKNOWN
end

function bossModPrototype:GetHP()
	return self:GetBossHPString((self.combatInfo and self.combatInfo.mob) or self.creatureId)
end

function bossModPrototype:IsWipe()
	local wipe = true
	local uId = ((GetNumRaidMembers() == 0) and "party") or "raid"
	for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
		local id = (i == 0 and "player") or uId..i
		if UnitAffectingCombat(id) and not UnitIsDeadOrGhost(id) then
			wipe = false
			break
		end
	end
	return wipe
end



-----------------------
--  Synchronization  --
-----------------------
function bossModPrototype:SendSync(event, arg)
	event = event or ""
	arg = arg or ""
	local str = ("%s\t%s\t%s\t%s"):format(self.id, self.revision, event, arg)
	local spamId = self.id..event..arg
	local time = GetTime()
	if not modSyncSpam[spamId] or (time - modSyncSpam[spamId]) > 2.5 then
		self:ReceiveSync(event, arg, nil, self.revision)
		sendSync("DBMv4-Mod", str)
	end
end

function bossModPrototype:ReceiveSync(event, arg, sender, revision)
	local spamId = self.id..event..arg
	local time = GetTime()
	if (not modSyncSpam[spamId] or (time - modSyncSpam[spamId]) > 2.5) and self.OnSync and (not (self.blockSyncs and sender)) and (not sender or (not self.minSyncRevision or revision >= self.minSyncRevision)) then
		modSyncSpam[spamId] = time
		self:OnSync(event, arg, sender)
	end
end

function bossModPrototype:SetMinSyncRevision(revision)
	self.minSyncRevision = revision
end


-----------------
--  Scheduler  --
-----------------
function bossModPrototype:Schedule(t, f, ...)
	return schedule(t, f, self, ...)
end

function bossModPrototype:Unschedule(f, ...)
	return unschedule(f, self, ...)
end

function bossModPrototype:ScheduleMethod(t, method, ...)
	if not self[method] then
		error(("Method %s does not exist"):format(tostring(method)), 2)
	end
	return self:Schedule(t, self[method], self, ...)
end
bossModPrototype.ScheduleEvent = bossModPrototype.ScheduleMethod

function bossModPrototype:UnscheduleMethod(method, ...)
	if not self[method] then
		error(("Method %s does not exist"):format(tostring(method)), 2)
	end
	return self:Unschedule(self[method], self, ...)
end
bossModPrototype.UnscheduleEvent = bossModPrototype.UnscheduleMethod


-------------
--  Icons  --
-------------
function bossModPrototype:SetIcon(target, icon, timer)
	if DBM:GetRaidRank() == 0 then return end
	icon = (icon and icon >= 0 and icon <= 8 and icon) or 8
	local oldIcon = self:GetIcon(target) or 0
	SetRaidTarget(DBM:GetRaidUnitId(target), icon)
	self:UnscheduleMethod("SetIcon", target)
	if timer then
		self:ScheduleMethod(timer, "RemoveIcon", target)
		if oldIcon then
			self:ScheduleMethod(timer + 1, "SetIcon", target, oldIcon)
		end
	end
end

function bossModPrototype:GetIcon(target)
	return GetRaidTargetIndex(DBM:GetRaidUnitId(target))
end

function bossModPrototype:RemoveIcon(target, timer)
	return self:SetIcon(target, 0, timer)
end

function bossModPrototype:ClearIcons()
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			if UnitExists("raid"..i) and GetRaidTargetIndex("raid"..i) then
				SetRaidTarget("raid"..i, 0)
			end
		end
	else
		for i = 1, GetNumPartyMembers() do
			if UnitExists("party"..i) and GetRaidTargetIndex("party"..i) then
				SetRaidTarget("party"..i, 0)
			end
		end
	end	
end

-----------------------
--  Model Functions  --
-----------------------
function bossModPrototype:SetModelScale(scale)
	self.modelScale = scale
end

function bossModPrototype:SetModelOffset(x, y, z)
	self.modelOffsetX = x
	self.modelOffsetY = y
	self.modelOffsetZ = z
end

function bossModPrototype:SetModelRotation(r)
	self.modelRotation = r
end

function bossModPrototype:SetModelMoveSpeed(v)
	self.modelMoveSpeed = v
end

function bossModPrototype:SetModelID(id)
	self.modelId = id
end

function bossModPrototype:EnableModel()
	self.modelEnabled = true
end

function bossModPrototype:DisableModel()
	self.modelEnabled = nil
end


--------------------
--  Localization  --
--------------------
function bossModPrototype:GetLocalizedStrings()
	return self.localization.miscStrings
end

-- Not really good, needs a few updates 
do
	local modLocalizations = {}
	local modLocalizationPrototype = {}
	local mt = {__index = modLocalizationPrototype}
	local returnKey = {__index = function(t, k) return k end}
	local defaultCatLocalization = {
		__index = setmetatable({
			timer		= DBM_CORE_OPTION_CATEGORY_TIMERS,
			announce	= DBM_CORE_OPTION_CATEGORY_WARNINGS,
			misc		= DBM_CORE_OPTION_CATEGORY_MISC
		}, returnKey)
	}
	local defaultTimerLocalization = {
		__index = setmetatable({
			timer_enrage = DBM_CORE_GENERIC_TIMER_ENRAGE,
			TimerSpeedKill = DBM_CORE_ACHIEVEMENT_TIMER_SPEED_KILL
		}, returnKey)
	}
	local defaultAnnounceLocalization = {
		__index = setmetatable({
			warning_enrage = DBM_CORE_GENERIC_WARNING_ENRAGE
		}, returnKey)
	}
	local defaultOptionLocalization = {
		__index = setmetatable({
			timer_enrage = DBM_CORE_OPTION_TIMER_ENRAGE,
			HealthFrame = DBM_CORE_OPTION_HEALTH_FRAME
		}, returnKey)
	}
	local defaultMiscLocalization = {
		__index = function(t, k)
			return t.misc.general[k] or t.misc.options[k] or t.misc.warnings[k] or t.misc.timers[k] or t.misc.cats[k] or k
		end
	}

	function modLocalizationPrototype:SetGeneralLocalization(t)
		for i, v in pairs(t) do
			self.general[i] = v
		end
	end

	function modLocalizationPrototype:SetWarningLocalization(t)
		for i, v in pairs(t) do
			self.warnings[i] = v
		end
	end

	function modLocalizationPrototype:SetTimerLocalization(t)
		for i, v in pairs(t) do
			self.timers[i] = v
		end
	end

	function modLocalizationPrototype:SetOptionLocalization(t)
		for i, v in pairs(t) do
			self.options[i] = v
		end
	end

	function modLocalizationPrototype:SetOptionCatLocalization(t)
		for i, v in pairs(t) do
			self.cats[i] = v
		end
	end

	function modLocalizationPrototype:SetMiscLocalization(t)
		for i, v in pairs(t) do
			self.miscStrings[i] = v
		end
	end

	function DBM:CreateModLocalization(name)
		local obj = {
			general = setmetatable({}, returnKey),
			warnings = setmetatable({}, defaultAnnounceLocalization),
			options = setmetatable({}, defaultOptionLocalization),
			timers = setmetatable({}, defaultTimerLocalization),
			miscStrings = setmetatable({}, defaultMiscLocalization),
			cats = setmetatable({}, defaultCatLocalization),
		}
		obj.miscStrings.misc = obj
		setmetatable(obj, mt)
		modLocalizations[name] = obj
		return obj
	end

	function DBM:GetModLocalization(name)
		return modLocalizations[name] or self:CreateModLocalization(name)
	end
end

