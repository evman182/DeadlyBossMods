local mod	= DBM:NewMod(1873, "DBM-TombofSargeras", nil, 875)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(116939)--Maiden of Valor 120437
mod:SetEncounterID(2038)
mod:SetZone()
mod:SetBossHPInfoToHighest()
mod:SetUsedIcons(1, 2, 3, 4, 5, 6)
mod:SetHotfixNoticeRev(16287)
mod.respawnTime = 25

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 239207 239132 235572 233856 233556 240623",
	"SPELL_CAST_SUCCESS 239132 236494 240594",
	"SPELL_AURA_APPLIED 234009 234059 236494 240728 239739",
	"SPELL_AURA_APPLIED_DOSE 236494 240728",
	"SPELL_AURA_REMOVED 234009 234059 239739",
	"SPELL_PERIODIC_DAMAGE 239212",
	"SPELL_PERIODIC_MISSED 239212",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"RAID_BOSS_WHISPER",
	"CHAT_MSG_ADDON",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2"
)

--TODO, two entirely different version sof Touch of Sargeras. Figure out which one is actually used where
--TODO, verify phase 2 trigger is in combat log, or use UNIT event instead
--TODO, Matrix stuff to be improved when I see how they activate/deactivate (cooldown? power based? health based?)
--TODO, figure out mythic stack count to start warning. Right now it's 4
--TODO, improve Dark Mark to match Touch of Sargeras if multiple targets, else, clean it up for 1 target
--TODO, unbound chaos seems affected by something, possibly energy getting to boss.
--TOOD, dark mark cast not in combat log, see if need to use APPIED or UNIT event
--TODO, and again, black winds not in combat log, find way to do it besides spell damage
--[[
(ability.id = 239207 or ability.id = 239132 or ability.id = 236571 or ability.id = 233856 or ability.id = 233556 or ability.id = 240623 or ability.id = 239418) and type = "begincast" or
(ability.id = 236571 or ability.id = 236494 or ability.id = 240594 or ability.id = 239739) and type = "cast" or
(ability.id = 234009 or ability.id = 234059) and type = "applydebuff"
 or ability.name = "Shadowy Blades" or ability.name = "Black Winds"
--]]
--Stage One: A Slumber Disturbed
local warnTouchofSargeras			= mod:NewTargetAnnounce(234009, 3)
local warnUnboundChaos				= mod:NewTargetAnnounce(234059, 3, nil, false, 2)
local warnShadowyBlades				= mod:NewTargetAnnounce(236571, 3)
local warnDesolate					= mod:NewStackAnnounce(236494, 3, nil, "Healer|Tank")
local warnPhase2					= mod:NewPhaseAnnounce(2, 2)
--Stage Two: An Avatar Awakened
local warnDarkmark					= mod:NewTargetAnnounce(239739, 3)
--local warnBlackWinds				= mod:NewSpellAnnounce(239418, 2)

--Stage One: A Slumber Disturbed
local specWarnTouchofSargerasGround	= mod:NewSpecialWarningSpell(239207, nil, nil, nil, 1, 2)
local specWarnTouchofSargeras		= mod:NewSpecialWarningYou(234009, nil, nil, nil, 1, 2)--Where is this used?
local specWarnTouchofSargerasOther	= mod:NewSpecialWarningMoveTo(234009, nil, nil, nil, 1, 2)--Exclude tank?
local yellTouchofSargeras			= mod:NewPosYell(234009)
local yellTouchofSargerasFades		= mod:NewFadesYell(234009)
local specWarnRuptureRealities		= mod:NewSpecialWarningRun(239132, nil, nil, nil, 4, 2)
local specWarnUnboundChaos			= mod:NewSpecialWarningMoveAway(234059, nil, nil, nil, 1, 2)
local yellUnboundChaos				= mod:NewYell(234059, nil, false, 2)
local specWarnShadowyBlades			= mod:NewSpecialWarningMoveAway(236571, nil, nil, nil, 1, 2)
local yellShadowyBlades				= mod:NewYell(236571)
local specWarnLingeringDarkness		= mod:NewSpecialWarningMove(239212, nil, nil, nil, 1, 2)
local specWarnDesolateYou			= mod:NewSpecialWarningStack(236494, nil, 2, nil, nil, 1, 6)
local specWarnDesolateOther			= mod:NewSpecialWarningTaunt(236494, nil, nil, nil, 1, 2)
----Maiden of Valor
local specWarnCorruptedMatrix		= mod:NewSpecialWarningMoveTo(233556, "Tank", nil, nil, 1, 2)
local specWarnCleansingProtocol		= mod:NewSpecialWarningSwitch(233856, "-Healer", nil, nil, 3, 2)
local specWarnTaintedEssence		= mod:NewSpecialWarningStack(240728, nil, 3, nil, nil, 1, 6)
--Stage Two: An Avatar Awakened
local specWarnDarkMark				= mod:NewSpecialWarningYou(239739, nil, nil, nil, 1, 2)
local specWarnDarkMarkOther			= mod:NewSpecialWarningMoveTo(239739, nil, nil, nil, 1, 2)
local yellDarkMark					= mod:NewYell(239739)
local yellDarkMarkFades				= mod:NewFadesYell(239739)
local specWarnRainoftheDestroyer	= mod:NewSpecialWarningDodge(240396, nil, nil, nil, 2, 2)

--Stage One: A Slumber Disturbed
local timerTouchofSargerasCD		= mod:NewCDTimer(42, 239207, nil, nil, nil, 3)--42+
local timerRuptureRealitiesCD		= mod:NewCDTimer(60, 239132, nil, nil, nil, 2)
local timerUnboundChaosCD			= mod:NewCDTimer(35, 234059, nil, nil, nil, 3)--35-43
local timerShadowyBladesCD			= mod:NewCDTimer(30, 236571, nil, nil, nil, 3)--34.1-36
local timerDesolateCD				= mod:NewCDTimer(11.4, 236494, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
----Maiden of Valor
local timerCorruptedMatrixCD		= mod:NewNextTimer(40, 233556, nil, nil, nil, 5)
local timerCorruptedMatrix			= mod:NewCastTimer(10, 233556, nil, nil, nil, 5)
local timerTaintedMatrixCD			= mod:NewCastTimer(10, 240623, nil, nil, nil, 6)--Mythic
--Stage Two: An Avatar Awakened
local timerDarkMarkCD				= mod:NewCDTimer(20.5, 239739, nil, nil, nil, 3)
--local timerBlackWindsCD				= mod:NewCDTimer(31, 239418, nil, nil, nil, 3)
--local timerRainoftheDestroyerCD		= mod:NewCDTimer(44, 240396, nil, nil, nil, 3)

--local berserkTimer				= mod:NewBerserkTimer(300)

--Stage One: A Slumber Disturbed
local countdownRuptureRealities		= mod:NewCountdown(60, 239132)
local countdownCorruptedMatrix		= mod:NewCountdown("Alt40", 233556)

--Stage One: A Slumber Disturbed
local voiceTouchofSargerasGround	= mod:NewVoice(239207)--helpsoak
local voiceTouchofSargeras			= mod:NewVoice(234009)--gathershare/targetyou
local voiceRuptureRealities			= mod:NewVoice(239132)--justrun
local voiceUnboundChaos				= mod:NewVoice(234059)--runout/keepmove
local voiceShadowyBlades			= mod:NewVoice(236571)--scatter
local voiceLingeringDarkness		= mod:NewVoice(239212)--runaway
local voiceDesolate					= mod:NewVoice(236494, "Tank")--stackhigh/tauntboss
----Maiden of Valor
local voiceCorruptedMatrix			= mod:NewVoice(233556, "Tank")--bossout (TEMP. bosstobeam when added)
local voiceCleansingProtocol		= mod:NewVoice(233856, "-Healer")--targetchange
local voiceTaintedEssence			= mod:NewVoice(240728)--stackhigh
--Stage Two: An Avatar Awakened
local voiceDarkMark					= mod:NewVoice(239739)--gathershare/targetyou
local voiceRainoftheDestroyer		= mod:NewVoice(240396)--watchstep

mod:AddSetIconOption("SetIconOnShadowyBlades", 236571, true)
mod:AddSetIconOption("SetIconOnTouchofSargeras", 234009, true)
mod:AddBoolOption("InfoFrame", true)
mod:AddRangeFrameOption(10, 236571)
--Not used yet, just populating until more data can verify actual sequences are better than standard lowest variance cd
local normalTimers = {
	[234057] = {8.5, 39.0, 36.5, 36.5, 36.6},--Unbound Chaos
	[236573] = {20.7, 34.1, 35.4, 36.5},--Shadowy Blades
	[239132] = {31.6, 64.5, 67.1},--Rupture Realities
 }
 local heroicTimers = {--Needs verification, shared by justw8t
	[234057] = {7, 42, 35, 41, 36, 35, 43},--Unbound Chaos
	[239207] = {15, 42.5, 55, 43, 42.5, 42.5},--Touch of Sargeras
	[236573] = {30, 42.5, 36.5, 30, 30, 30, 33},--Shadowy Blades
	[239132] = {37, 60.8, 60, 62},--Rupture Realities
 }

mod.vb.phase = 1
mod.vb.bladesIcon = 3
local TouchofSargerasTargets = {}
local playerName = UnitName("player")
--local unboundChaos = {7, 43.7(40), 37.7(35.7), 40.1, 36.5}

--Change to be more complex like touch of sargeras if more than one target
local function checkDarkMark(self, spellName)
	local playerDebuffed = UnitDebuff("player", spellName)
	if playerDebuffed then
		specWarnDarkMarkOther:Show(DBM_ALLY)
		voiceDarkMark:Play("gathershare")
	end
end

local function showTouchofSargerasTargets(self)
	table.sort(TouchofSargerasTargets)
	local playerAffected = false
	warnTouchofSargeras:Show(table.concat(TouchofSargerasTargets, "<, >"))
	for i = 1, #TouchofSargerasTargets do
		if i == 9 then break end--It's a wipe, plus can't do more than 8 of these with icons
		local name = TouchofSargerasTargets[i]
		if name == playerName then
			yellTouchofSargeras:Yell(i, i, i)
			playerAffected = true
		end
		if self.Options.SetIconOnTouchofSargeras then
			self:SetIcon(name, i)
		end
	end
	if not playerAffected then
		specWarnTouchofSargerasOther:Show(DBM_ALLY)
		voiceTouchofSargeras:Play("gathershare")
	end
	table.wipe(TouchofSargerasTargets)--Remove from here if cast start event works
end

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	self.vb.bladesIcon = 3
	table.wipe(TouchofSargerasTargets)
	timerUnboundChaosCD:Start(7-delay)--7
	timerDesolateCD:Start(13-delay)--13
	if not self:IsEasy() then
		timerTouchofSargerasCD:Start(15.4-delay)--15.5
	end
	timerShadowyBladesCD:Start(20.7-delay)
	timerRuptureRealitiesCD:Start(31.6-delay)--34-37
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(POWER_TYPE_POWER)
		DBM.InfoFrame:Show(2, "enemypower", 2, ALTERNATE_POWER_INDEX)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 239207 then
		specWarnTouchofSargerasGround:Show()
		voiceTouchofSargerasGround:Play("helpsoak")
		table.wipe(TouchofSargerasTargets)
		timerTouchofSargerasCD:Start()
	elseif spellId == 239132 or spellId == 235572 then
		specWarnRuptureRealities:Show()
		voiceRuptureRealities:Play("justrun")
		if self.vb.phase == 2 then
			timerRuptureRealitiesCD:Start(37)
			countdownRuptureRealities:Start(37)
		else
			timerRuptureRealitiesCD:Start()
		end
	elseif spellId == 233856 then
		specWarnCleansingProtocol:Show()
		voiceCleansingProtocol:Play("targetchange")
	elseif spellId == 233556 and self:AntiSpam(2, 2) then
		specWarnCorruptedMatrix:Show(TARGET)
		voiceCorruptedMatrix:Play("bossout")
		timerCorruptedMatrix:Start(10)
	elseif spellId == 240623 and self:AntiSpam(2, 3) then
		timerTaintedMatrixCD:Start(10)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 236494 then
		timerDesolateCD:Start()
	elseif spellId == 233556 and self:AntiSpam(2, 4) then
		timerCorruptedMatrixCD:Start()
		countdownCorruptedMatrix:Start()
	elseif spellId == 240594 then
		self.vb.phase = 2
		timerTouchofSargerasCD:Stop()
		timerShadowyBladesCD:Stop()
		timerRuptureRealitiesCD:Stop()
		timerDesolateCD:Stop()
		timerUnboundChaosCD:Stop()
		timerCorruptedMatrix:Stop()
		timerCorruptedMatrixCD:Stop()
		countdownCorruptedMatrix:Cancel()
		timerTaintedMatrixCD:Stop()
		
		warnPhase2:Show()
		timerDesolateCD:Start(21)
		timerDarkMarkCD:Start(23)
		if not self:IsEasy() then
			--timerRainoftheDestroyerCD:Start(25)--Disabled for now until it can be transcribed
			--timerBlackWindsCD:Start(35)
		end
		timerRuptureRealitiesCD:Start(41)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 234009 then
		TouchofSargerasTargets[#TouchofSargerasTargets+1] = args.destName
		self:Unschedule(showTouchofSargerasTargets)
		self:Schedule(0.3, showTouchofSargerasTargets, self)--Change to 0.5 for laggy users?
		if args:IsPlayer() then
			specWarnTouchofSargeras:Show()
			voiceTouchofSargeras:Play("targetyou")
			yellTouchofSargerasFades:Schedule(9, 1)
			yellTouchofSargerasFades:Schedule(8, 2)
			yellTouchofSargerasFades:Schedule(7, 3)
		end
	elseif spellId == 239739 then
		warnDarkmark:CombinedShow(0.3, args.destName)
		self:Unschedule(checkDarkMark)
		self:Schedule(0.3, checkDarkMark, self, args.spellName)
		if args:IsPlayer() then
			specWarnDarkMark:Show()
			voiceDarkMark:Play("targetyou")
			yellDarkMark:Yell()
			yellDarkMarkFades:Schedule(9, 1)
			yellDarkMarkFades:Schedule(8, 2)
			yellDarkMarkFades:Schedule(7, 3)
		end
	elseif spellId == 234059 then
		warnUnboundChaos:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnUnboundChaos:Show()
			voiceUnboundChaos:Play("watchstep")
			yellUnboundChaos:Yell()
		end
	elseif spellId == 236494 then
		local amount = args.amount or 1
		if args:IsPlayer() then
			if amount >= 2 then
				specWarnDesolateYou:Show(amount)
				voiceDesolate:Play("stackhigh")
			else
				warnDesolate:Show(args.destName, amount)
			end
		else
			if not UnitIsDeadOrGhost("player") and not UnitDebuff("player", args.spellName) then
				specWarnDesolateOther:Show(args.destName)
				voiceDesolate:Play("tauntboss")
			else
				warnDesolate:Show(args.destName, amount)
			end
		end
	elseif spellId == 240728 then
		if args:IsPlayer() then
			local amount = args.amount or 1
			if amount >= 4 then
				specWarnTaintedEssence:Show(amount)
				voiceTaintedEssence:Play("stackhigh")
			end
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 234009 then
		if args:IsPlayer() then
			yellTouchofSargerasFades:Cancel()
		end
		if self.Options.SetIconOnTouchofSargeras then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 239739 then
		if args:IsPlayer() then
			yellDarkMarkFades:Cancel()
		end
	elseif spellId == 234059 then
		--Do Stuff?
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 239212 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnLingeringDarkness:Show()
		voiceLingeringDarkness:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, npc, _, _, target)
	if msg:find("spell:234418") then
		specWarnRainoftheDestroyer:Show()
		voiceRainoftheDestroyer:Play("watchstep")
		--timerRainoftheDestroyerCD:Start()
	end
end

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("spell:236604") then
		specWarnShadowyBlades:Show()
		voiceShadowyBlades:Play("runout")
	end
end

function mod:CHAT_MSG_ADDON(prefix, msg, channel, targetName)
	if prefix ~= "Transcriptor" then return end
	if msg:find("spell:236604") then--Rapid fire
		targetName = Ambiguate(targetName, "none")
		if self:AntiSpam(4, targetName) then
			warnShadowyBlades:CombinedShow(0.5, targetName)
			if self.Options.SetIconOnShadowyBlades then
				self:SetIcon(targetName, self.vb.bladesIcon, 5)
			end
			self.vb.bladesIcon = self.vb.bladesIcon + 1
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 234057 then
		timerUnboundChaosCD:Start()
	elseif spellId == 239739 then
		timerDarkMarkCD:Start()
	elseif spellId == 239418 then
		--warnBlackWinds:Show()
		--timerBlackWindsCD:Start()
	elseif spellId == 236571 or spellId == 236573 then--Shadow Blades
		self.vb.bladesIcon = 3--SHOULD always fire first, fixme if it doesn't
		if self:IsEasy() then
			timerShadowyBladesCD:Start(34)
		else
			timerShadowyBladesCD:Start(30)
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(10, nil, nil, nil, nil, 5)
		end
	elseif spellId == 235597 then--Annihilation
		--Slower phase 2, but in off chance consume isn't good enough and boss can throw one last cast off in 3 seconds between that event and this on
	end
end

