local mod = DBM:NewMod("SalrammTheFleshcrafter", "DBM-Party-WotLK", 3)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(26530)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_SUMMON"
)

local warningCurse	= mod:NewTargetAnnounce(58845, 1)
local warningSteal	= mod:NewTargetAnnounce(52709, 2)
local warningGhoul	= mod:NewSpellAnnounce(52451, 3)
local timerGhoulCD	= mod:NewCDTimer(20, 52451)
local timerCurse	= mod:NewTargetTimer(30, 58845)

function mod:SPELL_SUMMON(args)
	if args.spellId == 52451 then
		warningGhoul:Show(args.spellName)
		timerGhoulCD:Start(args.spellName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 58845 then
		warningCurse:Show(args.spellName, args.destName)
		timerCurse:Start(args.spellName, args.destName)
	elseif args.spellId == 52709 then
		wagningSteal:Show(args.spellName, args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 58845 then
		timerCurse:Cancel()
	end
end