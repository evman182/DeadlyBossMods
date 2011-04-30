local mod	= DBM:NewMod("Daakara", "DBM-Party-Cataclysm", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 5294 $"):sub(12, -3))
mod:SetCreatureID(23863)
mod:SetZone()

mod:RegisterCombat("combat")
mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START"
)

local warnThrow		= mod:NewTargetAnnounce(97639, 3)
local warnWhirlwind	= mod:NewSpellAnnounce(17207, 3)
local warnLynx		= mod:NewSpellAnnounce(42607, 3)
local warnClawRage	= mod:NewTargetAnnounce(97672, 3)

local timerLynx		= mod:NewNextTimer(40, 42607)
local timerThrow	= mod:NewNextTimer(15, 97639)

mod:AddBoolOption("ThrowIcon", true)
mod:AddBoolOption("ClawRageIcon", true)

function mod:OnCombatStart(delay)
	timerLynx:Start(40-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(97639) then
		warnThrow:Show(args.destName)
		timerThrow:Start()
		if self.Options.ThrowIcon then
			self:SetIcon(args.destName, 8)
		end
	elseif args:IsSpellID(17207) then
		warnWhirlwind:Show()
	elseif args:IsSpellID(97672) then
		warnClawRage:Show(args.destName)
		if self.Options.ClawRageIcon then
			self:SetIcon(args.destName, 8, 5)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(97639) and mod.Options.ThrowIcon then
		self:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(42607) then
		warnLynx:Show()
	end
end