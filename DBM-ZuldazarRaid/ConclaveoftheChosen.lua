local mod	= DBM:NewMod(2330, "DBM-ZuldazarRaid", 2, 1176)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(144747, 144767, 144963, 144941, 145388)--Bwonsamdi's ID needs to be found, and if it's needed
mod:SetEncounterID(2268)
--mod:DisableESCombatDetection()
mod:SetZone()
mod:SetBossHPInfoToHighest()
--mod:SetUsedIcons(1, 2, 8)
--mod:SetHotfixNoticeRev(17775)
--mod:SetMinSyncRevision(16950)
--mod.respawnTime = 35

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 282098 282107 285889 282155 282411",
	"SPELL_CAST_SUCCESS 282135 282444 282834 285878 283685 284666",
	"SPELL_AURA_APPLIED 282079 285945 282135 286007 282209 282444 282834 286811 284663",
--	"SPELL_AURA_REFRESH 282079",
	"SPELL_AURA_APPLIED_DOSE 285945 282444",
	"SPELL_AURA_REMOVED 282079 282135 286007 282834 286811",
	"UNIT_DIED",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_TARGETABLE_CHANGED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5"
)

--TODO, Fix phase change stuff.
--TODO, figure out what IDs actually die during fight for total boss count
--TODO, fine tune hastening winds swap stacks
--TODO, fine tune Lacerating Claws swap stacks
--General
local warnActivated						= mod:NewTargetAnnounce(118212, 3, 78740, nil, nil, nil, nil, nil, true)
--Gonk's Aspect
local warnCrawlingHex					= mod:NewTargetAnnounce(282135, 2)
--Kimbul's Aspect
local warnLaceratingClaws				= mod:NewStackAnnounce(282444, 2, nil, "Tank")
--Akunda's Aspect
local warnMindWipe						= mod:NewTargetNoFilterAnnounce(285878, 4)
local warnAkundasWrath					= mod:NewTargetAnnounce(286811, 2)
--Bwonsamdi
local warnBwonsamdisWrath				= mod:NewTargetNoFilterAnnounce(284663, 4, nil, "Healer")

--General
local specWarnActivated					= mod:NewSpecialWarningSwitchCount(118212, "Tank", DBM_CORE_AUTO_SPEC_WARN_OPTIONS.switch:format(118212), nil, 3, 2)
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 2)
--Pa'ku's Aspect
local specWarnGiftofWind				= mod:NewSpecialWarningSpell(282098, nil, nil, nil, 2, 2)
local specWarnHasteningWinds			= mod:NewSpecialWarningCount(270447, nil, DBM_CORE_AUTO_SPEC_WARN_OPTIONS.stack:format(5, 270447), nil, 1, 2)
local specWarnHasteningWindsOther		= mod:NewSpecialWarningTaunt(270447, nil, nil, nil, 1, 2)
local specWarnPakusWrath				= mod:NewSpecialWarningMoveTo(282107, nil, nil, nil, 3, 2)
local specWarnPakusWrathDefensive		= mod:NewSpecialWarningDefensive(282107, nil, nil, nil, 3, 2)
--Gonk's Aspect
local specWarnCrawlingHex				= mod:NewSpecialWarningYou(282135, nil, nil, nil, 1, 2)
local yellCrawlingHex					= mod:NewYell(282135)
local yellCrawlingHexFades				= mod:NewFadesYell(282135)
local specWarnCrawlingHexNear			= mod:NewSpecialWarningClose(282135, nil, nil, nil, 1, 2)
local specWarnRaptorForm				= mod:NewSpecialWarningDefensive(285889, nil, nil, nil, 3, 2)
local specWarnGonksWrath				= mod:NewSpecialWarningSwitch(282155, "Dps", nil, nil, 1, 2)
local specWarnMarkofPrey				= mod:NewSpecialWarningRun(282209, nil, nil, nil, 4, 2)
local yellMarkofPrey					= mod:NewYell(282209)
--Kimbul's Aspect
local specWarnLaceratingClaws			= mod:NewSpecialWarningStack(282444, nil, 8, nil, nil, 1, 6)
local specWarnLaceratingClawsTaunt		= mod:NewSpecialWarningTaunt(282444, nil, nil, nil, 1, 2)
local specWarnKimbulsWrath				= mod:NewSpecialWarningYou(282834, nil, nil, nil, 1, 2)
local yellKimbulsWrath					= mod:NewYell(282834)
local yellKimbulsWrathFades				= mod:NewFadesYell(282834)
--Akunda's Aspect
local specWarnThunderingStorm			= mod:NewSpecialWarningRun(282411, "Melee", nil, nil, 4, 2)
local specWarnMindWipe					= mod:NewSpecialWarningYou(285878, nil, nil, nil, 1, 2)
local specWarnAkundasWrath				= mod:NewSpecialWarningYou(286811, nil, nil, nil, 1, 2)
local yellAkundasWrath					= mod:NewYell(286811)
local yellAkundasWrathFades				= mod:NewFadesYell(286811)
--Krag'wa
local specWarnBwonsamdisWrath			= mod:NewSpecialWarningYou(284663, nil, nil, nil, 3, 2)
--Bwonsamdi

--mod:AddTimerLine(DBM:EJ_GetSectionInfo(18527))
--Pa'ku's Aspect
local timerGiftofWindCD					= mod:NewAITimer(55, 282098, nil, nil, nil, 2)
local timerPakusWrathCD					= mod:NewAITimer(55, 282107, nil, nil, nil, 2)
--Gonk's Aspect
local timerCrawlingHexCD				= mod:NewAITimer(14.1, 282135, nil, nil, nil, 3, nil, DBM_CORE_CURSE_ICON)
local timerRaptorFormCD					= mod:NewAITimer(14.1, 285889, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerGonksWrathCD					= mod:NewAITimer(14.1, 282155, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
--Kimbul's Aspect
local timerLaceratingClawsCD			= mod:NewAITimer(14.1, 282444, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerKinbulsWrathCD				= mod:NewAITimer(14.1, 282834, nil, nil, nil, 3)
--Akunda's Aspect
local timerThunderingStormCD			= mod:NewAITimer(14.1, 282411, nil, "Melee", nil, 3, nil, DBM_CORE_TANK_ICON)
local timerMindWipeCD					= mod:NewAITimer(14.1, 285878, nil, nil, nil, 3)
local timerAkundasWrathCD				= mod:NewAITimer(14.1, 283685, nil, nil, nil, 3)
--Krag'wa
local timerKragwasWrathCD				= mod:NewAITimer(14.1, 282636, nil, nil, nil, 3)
--Bwonsamdi
local timerBwonsamdisWrathCD			= mod:NewAITimer(14.1, 284666, nil, nil, nil, 3, nil, DBM_CORE_CURSE_ICON..DBM_CORE_HEALER_ICON)

--local berserkTimer					= mod:NewBerserkTimer(600)

--local countdownCollapsingWorld			= mod:NewCountdown(50, 243983, true, 3, 3)
--local countdownLaceratingClaws				= mod:NewCountdown("Alt12", 244016, false, 2, 3)
--local countdownFelstormBarrage			= mod:NewCountdown("AltTwo32", 244000, nil, nil, 3)

--mod:AddSetIconOption("SetIconGift", 255594, true)
--mod:AddRangeFrameOption("8/10")
mod:AddInfoFrameOption(282079, true)--Not real spellID, just filler for now
mod:AddNamePlateOption("NPAuraOnPact", 282079)
mod:AddNamePlateOption("NPAuraOnPackHunter", 286007)
mod:AddNamePlateOption("NPAuraOnFixate", 282209)
--mod:AddSetIconOption("SetIconDarkRev", 273365, true)

--mod.vb.phase = 1

function mod:OnCombatStart(delay)
	if self.Options.NPAuraOnPact or self.Options.NPAuraOnPackHunter or self.Options.NPAuraOnFixate then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM_CORE_INFOFRAME_POWER)
		DBM.InfoFrame:Show(4, "enemypower", 2)
	end
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
	if self.Options.NPAuraOnPact or self.Options.NPAuraOnPackHunter or self.Options.NPAuraOnFixate then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 282098 then
		specWarnGiftofWind:Show()
		timerGiftofWindCD:Start()
	elseif spellId == 282107 then
		local foundBossID
		for i = 1, 2 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID then
				foundBossID = bossUnitID
				break
			end
		end
		if foundBossID and self:IsTank() and not UnitDetailedThreatSituation("player", foundBossID) then
			--Tank that's on other boss, they need to stay out
			specWarnPakusWrathDefensive:Show()
			specWarnPakusWrathDefensive:Play("defensive")
		else
			specWarnPakusWrath:Show(args.sourceName)
			specWarnPakusWrath:Play("gathershare")
		end
		timerPakusWrathCD:Start()
	elseif spellId == 285889 then
		timerRaptorFormCD:Start()
		for i = 1, 2 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID and UnitDetailedThreatSituation("player", bossUnitID) then--We are highest threat target
				specWarnRaptorForm:Show()
				specWarnRaptorForm:Play("defensive")
				break
			end
		end
	elseif spellId == 282155 then
		specWarnGonksWrath:Show()
		specWarnGonksWrath:Play("killmob")
		timerGonksWrathCD:Start()
	elseif spellId == 282411 then
		timerThunderingStormCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, true, false) then--Only show warning if target/focus on caster
			specWarnThunderingStorm:Show()
			specWarnThunderingStorm:Play("justrun")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 282135 then
		timerCrawlingHexCD:Start()
	elseif spellId == 282444 then
		timerLaceratingClawsCD:Start()
	elseif spellId == 282834 then
		timerKinbulsWrathCD:Start()
	elseif spellId == 285878 then
		timerMindWipeCD:Start()
	elseif spellId == 283685 then
		timerAkundasWrathCD:Start()
	elseif spellId == 284666 then
		timerBwonsamdisWrathCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 282444 then
		local uId = DBM:GetRaidUnitId(args.destName)
		if self:IsTanking(uId) then
			local amount = args.amount or 1
			if amount >= 8 then
				if args:IsPlayer() then
					specWarnLaceratingClaws:Show(amount)
					specWarnLaceratingClaws:Play("stackhigh")
				else
					if not UnitIsDeadOrGhost("player") and not DBM:UnitDebuff("player", spellId) then--Can't taunt less you've dropped yours off, period.
						specWarnLaceratingClawsTaunt:Show(args.destName)
						specWarnLaceratingClawsTaunt:Play("tauntboss")
					else
						warnLaceratingClaws:Show(args.destName, amount)
					end
				end
			else
				warnLaceratingClaws:Show(args.destName, amount)
			end
		end
	elseif spellId == 285945 then
		local amount = args.amount or 1
		if (amount >= 5) and self:AntiSpam(3, 4) then--Fine Tune
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnHasteningWinds:Show(amount)
				specWarnHasteningWinds:Play("changemt")
			else
				specWarnHasteningWindsOther:Show(args.destName)
				specWarnHasteningWindsOther:Play("changemt")
			end
		end
	elseif spellId == 282079 then
		if self.Options.NPAuraOnPact then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	elseif spellId == 286007 then
		if self.Options.NPAuraOnPackHunter then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	elseif spellId == 282135 then
		if args:IsPlayer() then
			specWarnCrawlingHex:Show()
			specWarnCrawlingHex:Play("targetyou")
			yellCrawlingHex:Yell()
			yellCrawlingHexFades:Countdown(5)
		elseif self:CheckNearby(8, args.destName) and not DBM:UnitDebuff("player", spellId) then
			specWarnCrawlingHexNear:CombinedShow(0.3, args.destName)
			specWarnCrawlingHexNear:CancelVoice()--Avoid spam
			specWarnCrawlingHexNear:ScheduleVoice(0.3, "runaway")
		else
			warnCrawlingHex:CombinedShow(0.3, args.destName)
		end
	elseif spellId == 282209 then
		if args:IsPlayer() then
			specWarnMarkofPrey:Show()
			specWarnMarkofPrey:Play("justrun")
			yellMarkofPrey:Yell()
			if self.Options.NPAuraOnFixate then
				DBM.Nameplate:Show(true, args.sourceGUID, spellId)
			end
		end
	elseif spellId == 282834 then
		if args:IsPlayer() then
			specWarnKimbulsWrath:Show()
			specWarnKimbulsWrath:Play("targetyou")
			yellKimbulsWrath:Yell()
			yellKimbulsWrathFades:Countdown(12)
		end
	elseif spellId == 285878 then
		if args:IsPlayer() then
			specWarnMindWipe:Show()
			specWarnMindWipe:Play("targetyou")
		else
			warnMindWipe:CombinedShow(0.3, args.destName)
		end
	elseif spellId == 286811 then
		if args:IsPlayer() then
			specWarnAkundasWrath:Show()
			specWarnAkundasWrath:Play("runout")
			yellAkundasWrath:Yell()
			yellAkundasWrathFades:Countdown(6)
		else
			warnAkundasWrath:CombinedShow(0.3, args.destName)
		end
	elseif spellId == 284663 then
		if args:IsPlayer() then
			specWarnBwonsamdisWrath:Show()
			specWarnBwonsamdisWrath:Play("targetyou")
		else
			warnBwonsamdisWrath:Show(args.destName)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 282079 then
		if self.Options.NPAuraOnPact then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	elseif spellId == 282135 then
		if args:IsPlayer() then
			yellCrawlingHexFades:Cancel()
		end
	elseif spellId == 286007 then
		if self.Options.NPAuraOnPackHunter then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	elseif spellId == 282209 then
		if self.Options.NPAuraOnFixate then
			DBM.Nameplate:Hide(true, args.sourceGUID, spellId)
		end
	elseif spellId == 282834 then
		if args:IsPlayer() then
			yellKimbulsWrathFades:Cancel()
		end
	elseif spellId == 286811 then
		if args:IsPlayer() then
			yellAkundasWrathFades:Cancel()
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 228007 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--If UNIT_DIED doesn't fire, move to targetWeWarn false on UNIT_TARGETABLE_CHANGED
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 144747 then--Pa'ku's Aspect
		timerGiftofWindCD:Stop()
		timerPakusWrathCD:Stop()
	elseif cid == 144767 then--Gonk's Aspect
		timerCrawlingHexCD:Stop()
		timerRaptorFormCD:Stop()
		timerGonksWrathCD:Stop()
	elseif cid == 144963 then--Kimbul's Aspect
		timerLaceratingClawsCD:Stop()
		timerKinbulsWrathCD:Stop()
	elseif cid == 144941 then--Akunda's Aspect
		timerThunderingStormCD:Stop()
		timerMindWipeCD:Stop()
		timerAkundasWrathCD:Stop()
	elseif cid == 145388 then--Krag'wa
		timerKragwasWrathCD:Stop()
	--elseif cid == 148714 then--Bwonsamdi
		
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, npc, _, _, target)
	if msg:find("spell:282107") then
		specWarnPakusWrath:Show(args.sourceName)
		specWarnPakusWrath:Play("gathershare")
		timerPakusWrathCD:Start()
	end
end

--Assumed
function mod:UNIT_TARGETABLE_CHANGED(uId)
	local cid = self:GetUnitCreatureId(uId)
	local targetWeWarn = false
	if UnitExists(uId) then
		targetWeWarn = true
		DBM:Debug("UNIT_TARGETABLE_CHANGED, Boss Engaging", 2)
	else
		DBM:Debug("UNIT_TARGETABLE_CHANGED, Boss Leaving", 2)
	end
	if targetWeWarn then
		if self.Options.SpecWarn118212switchcount then
			specWarnActivated:Show(UnitName(uId))
			specWarnActivated:Play("changetarget")
		else
			warnActivated:Show(UnitName(uId))
		end
		--Start Timers
		if cid == 144747 then--Pa'ku's Aspect
			timerGiftofWindCD:Start(2)
			timerPakusWrathCD:Start(2)
		elseif cid == 144767 then--Gonk's Aspect
			timerCrawlingHexCD:Start(2)
			timerRaptorFormCD:Start(2)
			timerGonksWrathCD:Start(2)
		elseif cid == 144963 then--Kimbul's Aspect
			timerLaceratingClawsCD:Start(2)
			timerKinbulsWrathCD:Start(2)
		elseif cid == 144941 then--Akunda's Aspect
			timerThunderingStormCD:Start(2)
			timerMindWipeCD:Start(2)
			timerAkundasWrathCD:Start(2)
		elseif cid == 145388 then--Krag'wa
			timerKragwasWrathCD:Start(2)
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 282635 then--Krag'wa's Wrath
		timerKragwasWrathCD:Start()
	end
end
