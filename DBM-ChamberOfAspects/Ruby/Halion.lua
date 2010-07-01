local mod	= DBM:NewMod("Halion", "DBM-ChamberOfAspects", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(39863)--40141 (twilight form)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_HEALTH"
)

local warnPhase2Soon				= mod:NewAnnounce("WarnPhase2Soon", 2)
local warnPhase3Soon				= mod:NewAnnounce("WarnPhase3Soon", 2)
local warnPhase2					= mod:NewPhaseAnnounce(2)
local warnPhase3					= mod:NewPhaseAnnounce(3)
local warningShadowConsumption		= mod:NewTargetAnnounce(74792, 4)
local warningFieryConsumption		= mod:NewTargetAnnounce(74562, 4)
local warningMeteor					= mod:NewSpellAnnounce(74648, 3)
local warningShadowBreath			= mod:NewSpellAnnounce(75954, 2, nil, mod:IsTank() or mod:IsHealer())
local warningFieryBreath			= mod:NewSpellAnnounce(74526, 2, nil, mod:IsTank() or mod:IsHealer())
local warningTwilightCutter			= mod:NewSpellAnnounce(77844, 3)

local specWarnShadowConsumption		= mod:NewSpecialWarningRun(74792)
local specWarnFieryConsumption		= mod:NewSpecialWarningRun(74562)

local timerShadowConsumptionCD		= mod:NewNextTimer(25, 74792)
local timerFieryConsumptionCD		= mod:NewNextTimer(25, 74562)
--local timerDebuffCD				= mod:NewTimer(25, "timerDebuffCD", 74792)--They are on same CD. But i like the unique icons so not sure if i'll use this yet.
local timerMeteorCD					= mod:NewNextTimer(40, 74648)
local timerMeteorCast				= mod:NewCastTimer(7.5, 74648)--7 seconds from boss yell the meteor impacts.
local timerTwilightCutter			= mod:NewBuffActiveTimer(10, 77844)
local timerTwilightCutterCD			= mod:NewNextTimer(15, 77844)
local timerShadowBreathCD			= mod:NewCDTimer(20, 75954, nil, mod:IsTank() or mod:IsHealer())--Same as debuff timers, same CD, can be merged into 1.
local timerFieryBreathCD			= mod:NewCDTimer(20, 74526, nil, mod:IsTank() or mod:IsHealer())--But unique icons are nice pertaining to phase you're in ;)

mod:AddBoolOption("AnnounceAlternatePhase", false, "announce")
local soundConsumption 			= mod:NewSound(74562, "SoundOnConsumption")
mod:AddBoolOption("SetIconOnConsumption", true)

local warned_preP2 = false
local warned_preP3 = false

function mod:OnCombatStart(delay)--These may still need retuning too, log i had didn't have pull time though.
		timerMeteorCD:Start(20-delay)
		timerFieryConsumptionCD:Start(15-delay)
		timerFieryBreathCD:Start(10-delay)
	warned_preP2 = false
	warned_preP3 = false
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(74806, 75954, 75955, 75956) then
		warningShadowBreath:Show()
		timerShadowBreathCD:Start()
	elseif args:IsSpellID(74525, 74526, 74527, 74528) then
		warningFieryBreath:Show()
		timerFieryBreathCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
--[[	if args:IsSpellID(74648, 75877, 75878, 75879) then--Meteor Strike Landed
		if not self.Options.AnnounceAlternatePhase then
			warningMeteor:Show()
			timerMeteorCD:Start()
		end
		if mod:LatencyCheck() then
			self:SendSync("Meteor")
		end--]]
	if args:IsSpellID(74792) then
		timerShadowConsumptionCD:Start()
		if not self.Options.AnnounceAlternatePhase then
			warningShadowConsumption:Show(args.destName)
		end
		if mod:LatencyCheck() then
			self:SendSync("ShadowTarget", args.destName)
		end
		if args:IsPlayer() then
			specWarnShadowConsumption:Show()
			soundConsumption:Play()
		end
		if self.Options.SetIconOnConsumption then
			self:SetIcon(args.destName, 8)
		end
	elseif args:IsSpellID(74562) then
		timerFieryConsumptionCD:Start()
		if not self.Options.AnnounceAlternatePhase then
			warningFieryConsumption:Show(args.destName)
		end
		if mod:LatencyCheck() then
			self:SendSync("FieryTarget", args.destName)
		end
		if args:IsPlayer() then
			specWarnFieryConsumption:Show()
			soundConsumption:Play()
		end
		if self.Options.SetIconOnConsumption then
			self:SetIcon(args.destName, 7)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(74792) then
		if self.Options.SetIconOnConsumption then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(74562) then
		if self.Options.SetIconOnConsumption then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if not warned_preP2 and self:GetUnitCreatureId(uId) == 39863 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.79 then
		warned_preP2 = true
		warnPhase2Soon:Show()	
	elseif not warned_preP3 and (self:GetUnitCreatureId(uId) == 40141 or self:GetUnitCreatureId(uId) == 39863) and UnitHealth(uId) / UnitHealthMax(uId) <= 0.54 then
		warned_preP3 = true
		warnPhase3Soon:Show()	
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:match(L.Phase2) then
		timerFieryBreathCD:Cancel()
		timerMeteorCD:Cancel()--This one i'm not sure if it cancels or not.
--		timerMeteorCast:Cancel()--This one i'm not sure if it cancels or not.
		warnPhase2:Show()
		timerTwilightCutterCD:Start(35)
		timerShadowBreathCD:Start(25)
	elseif msg:match(L.Phase3) then--This phase doesn't appear to reset the timers like previous phase change.
		warnPhase3:Show()
--		timerMeteorCD:Start()--Don't have timing for this yet, the person that sent log stayed below.
	elseif msg:match(L.MeteorCast) then--There is no CLEU cast trigger for meteor, only yell
		if not self.Options.AnnounceAlternatePhase then
			warningMeteor:Show()
			timerMeteorCast:Start()--7 seconds from boss yell the meteor impacts.
			timerMeteorCD:Start()
		end
		if mod:LatencyCheck() then
			self:SendSync("Meteor")
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:match(L.twilightcutter) then
		if not self.Options.AnnounceAlternatePhase then
			warningTwilightCutter:Show()
			timerTwilightCutter:Schedule(5)--Delay it since it happens 5 seconds after the emote
			timerTwilightCutterCD:Schedule(15)
		end
		if mod:LatencyCheck() then
			self:SendSync("TwilightCutter")
		end
	end
end

function mod:OnSync(msg, target)
	if msg == "TwilightCutter" then
		if self.Options.AnnounceAlternatePhase then
			warningTwilightCutter:Show()
			timerTwilightCutter:Schedule(5)--Delay it since it happens 5 seconds after the emote
			timerTwilightCutterCD:Schedule(15)
		end
	elseif msg == "Meteor" then
		if self.Options.AnnounceAlternatePhase then
			warningMeteor:Show()
			timerMeteorCast:Start()
			timerMeteorCD:Start()
		end
	elseif msg == "ShadowTarget" then
		if self.Options.AnnounceAlternatePhase then
			warningShadowConsumption:Show(target)
		end
	elseif msg == "FieryTarget" then
		if self.Options.AnnounceAlternatePhase then
			warningFieryConsumption:Show(target)
		end
	end
end
