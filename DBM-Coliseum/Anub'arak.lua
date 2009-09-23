﻿local mod = DBM:NewMod("Anub'arak_Coliseum", "DBM-Coliseum")
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(34564)  

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

-- Pursue
local warnPursue			= mod:NewAnnounce("WarnPursue", 2)
local specWarnPursue		= mod:NewSpecialWarning("SpecWarnPursue")
mod:AddBoolOption("PlaySoundOnPursue")
mod:AddBoolOption("PursueIcon")

-- Emerge
local warnEmerge			= mod:NewAnnounce("WarnEmerge", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local warnEmergeSoon		= mod:NewAnnounce("WarnEmergeSoon", 1, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local timerEmerge			= mod:NewTimer(65, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

-- Submerge
local warnSubmerge			= mod:NewAnnounce("WarnSubmerge", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnSubmergeSoon		= mod:NewAnnounce("WarnSubmergeSoon", 1, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local timerSubmerge			= mod:NewTimer(75, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")

-- Phases
local warnPhase3			= mod:NewPhaseAnnounce(3)
local enrageTimer			= mod:NewEnrageTimer(570)	-- 9:30 ? hmpf (no enrage while submerged... this sucks)

-- Penetrating Cold
local specWarnPCold			= mod:NewSpecialWarning("SpecWarnPCold", false)
local timerPCold			= mod:NewTargetTimer(15, 68509)
mod:AddBoolOption("SetIconsOnPCold", true, "announce")

-- Shadow Strike
--local timerShadowStrike		= mod:NewNextTimer(30, 66134)
--local preWarnShadowStrike	= mod:NewCastTimer(66134, 3)
--local warnShadowStrike		= mod:NewCastTimer(66134, 4)


local PColdIcon = 7
function mod:resetIcons()
	PColdIcon = 7
end

function mod:OnCombatStart(delay)
	timerSubmerge:Start(80-delay)
	enrageTimer:Start(-delay)
	self:resetIcons()
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(67574) then			-- Pursue
		if args:IsPlayer() then
			specWarnPursue:Show()
			if self.Options.PlaySoundOnPursue then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end
		if self.Options.PursueIcon then
			self:SetIcon(args.destName, 8, 15)
		end
		warnPursue:Show(args.destName)

	elseif args:IsSpellID(66013, 67700, 68509, 68510) then		-- Penetrating Cold
		mod:ScheduleMethod(3, "resetIcons")		
		if args:IsPlayer() then
			specWarnPCold:Show()
		end
		if self.Options.SetIconsOnPCold and PColdIcon > 0 then
			mod:SetIcon(args.destName, PColdIcon, 15)
			PColdIcon = PColdIcon - 1
		end
		timerPCold:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(66013, 67700, 68509, 68510) then			-- Penetrating Cold
		mod:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(66118, 67630, 68646, 68647) then
		warnPhase3:Show()
		warnEmergeSoon:Cancel()
		warnSubmergeSoon:Cancel()
		timerEmerge:Stop()
		timerSubmerge:Stop()
	end
end


function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.Burrow then
		warnSubmerge:Show()
		warnEmergeSoon:Schedule(55)
		timerEmerge:Start()
	elseif msg == L.Emerge then
		warnEmerge:Show()
		warnSubmergeSoon:Schedule(75)
		timerSubmerge:Start()
	end
end



