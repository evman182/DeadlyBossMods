local mod	= DBM:NewMod("Rotface", "DBM-Icecrown", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(36627)
mod:SetUsedIcons(6, 7, 8)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"CHAT_MSG_MONSTER_YELL"
)

local InfectionIcon	-- alternating between 2 icons (2 debuffs can be up at the same time in 25man at least)

local warnSlimeSpray			= mod:NewSpellAnnounce(69508)
local warnOozeExplosionCast		= mod:NewCastAnnounce(69839)
local warnMutatedInfection		= mod:NewTargetAnnounce(71224)
local warnRadiatingOoze			= mod:NewSpellAnnounce(69760, false)--Some strats purposely run to this so option is defaulted to off
local warnOozeSpawn				= mod:NewAnnounce("WarnOozeSpawn")
local warnStickyOoze			= mod:NewSpellAnnounce(69774)
local warnUnstableOoze			= mod:NewAnnounce("WarnUnstableOoze")

local specWarnMutatedInfection	= mod:NewSpecialWarningYou(71224)
local specWarnStickyOoze		= mod:NewSpecialWarningMove(69774)
local specWarnOozeExplosion		= mod:NewSpecialWarningRun(69839)
local specWarnSlimeSpray		= mod:NewSpecialWarningSpell(69508, false)--For people that need a bigger warning to move
local specWarnRadiatingOoze		= mod:NewSpecialWarningSpell(69760, false)--Some strats purposely run to this so option is defaulted to off

local timerStickyOoze			= mod:NewNextTimer(16, 69774)
local timerWallSlime			= mod:NewTimer(20, "NextPoisonSlimePipes")
local timerSlimeSpray			= mod:NewNextTimer(21, 69508)
local timerMutatedInfection		= mod:NewTargetTimer(12, 71224)
local timerOozeExplosion		= mod:NewCastTimer(4, 69839)

local soundStickyOoze			= mod:NewSound(71208)
mod:AddBoolOption("InfectionIcon")
mod:AddBoolOption("ExplosionIcon")

function mod:OnCombatStart(delay)
	timerWallSlime:Start(25-delay)
	self:ScheduleMethod(25-delay, "WallSlime")
	InfectionIcon = 7
end

function mod:WallSlime()
	if self:IsInCombat() then
		timerWallSlime:Start()
		self:UnscheduleMethod("WallSlime")
		self:ScheduleMethod(20, "WallSlime")
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(69508) then
		timerSlimeSpray:Start()
		warnSlimeSpray:Show()
		specWarnSlimeSpray:Show()
	elseif args:IsSpellID(69774) then
		timerStickyOoze:Start()
		warnStickyOoze:Show()
	elseif args:IsSpellID(69839) then
		warnOozeExplosionCast:Show()
		specWarnOozeExplosion:Schedule(4)
		timerOozeExplosion:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsPlayer() and args:IsSpellID(71208) then
		specWarnStickyOoze:Show()
		soundStickyOoze:Play()
	elseif args:IsSpellID(69760) then
		warnRadiatingOoze:Show()
	elseif args:IsSpellID(69558) then
		warnUnstableOoze:Show(args.spellName, args.destName, args.amount or 1)
		if (args.amount or 1) >= 5 then	--It's about to blow
			if self.Options.ExplosionIcon then
				mod:SetIcon(args.destName, 8, 8)
			end
		end
	elseif args:IsSpellID(69674, 71224) then
		warnMutatedInfection:Show(args.destName)
		timerMutatedInfection:Start(args.destName)
		if args:IsPlayer() then
			specWarnMutatedInfection:Show()
		end
		if self.Options.InfectionIcon then
			mod:SetIcon(args.destName, InfectionIcon, 12)
			if InfectionIcon == 7 then	-- After ~3mins there is a chance 2 ppl will have the debuff, so we are alternating between 2 icons
				InfectionIcon = 6
			else
				InfectionIcon = 7
			end
		end	
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(69674, 71224) then
		timerMutatedInfection:Cancel(args.destName)
		warnOozeSpawn:Show()
		if self.Options.InfectionIcon then
			mod:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(69761, 71212) and args:IsPlayer() then
		specWarnRadiatingOoze:Show()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellSlimePipes1 or msg:find(L.YellSlimePipes1)) or (msg == L.YellSlimePipes2 or msg:find(L.YellSlimePipes2)) then
		self:SendSync("PoisonSlimePipes")
	end
end

function mod:OnSync(msg, arg)
	if msg == "PoisonSlimePipes" then
		self:WallSlime()
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
