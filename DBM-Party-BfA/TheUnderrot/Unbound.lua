local mod	= DBM:NewMod(2158, "DBM-Party-BfA", 8, 1001)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(133007)
mod:SetEncounterID(2123)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 269843 269310",
	"SPELL_PERIODIC_DAMAGE",
	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED"
)

--TODO, target scanning cleansing light?
--TODO, rotting spore timer? probably x time after vile
--TODO, verify GTFO
local warnVisage					= mod:NewAddsLeftAnnounce("ej18312", 2, 269692)

local specWarnVileExpulsion			= mod:NewSpecialWarningDodge(269843, nil, nil, nil, 2, 2)
local specWarnCleansingLight		= mod:NewSpecialWarningMoveTo(269310, nil, nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(269838, nil, nil, nil, 1, 2)

local timerVileExpulsionCD			= mod:NewAITimer(13, 269843, nil, nil, nil, 3)
local timerCleansingLightCD			= mod:NewAITimer(13, 269310, nil, nil, nil, 5)

mod:AddInfoFrameOption(269301, "Healer")

mod.vb.remainingAdds = 10--Assumed based on 10% per link
local vileExpulsion = DBM:GetSpellInfo(269843)

function mod:OnCombatStart(delay)
	self.vb.remainingAdds = 10
	timerVileExpulsionCD:Start(1-delay)
	timerCleansingLightCD:Start(1-delay)
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(269301))
		DBM.InfoFrame:Show(5, "playerdebuffstacks", 269301, 1)
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 269843 then
		specWarnVileExpulsion:Show()
		specWarnVileExpulsion:Play("watchwave")
		timerVileExpulsionCD:Start()
	elseif spellId == 269310 then
		specWarnCleansingLight:Show(vileExpulsion)
		specWarnCleansingLight:Play("gathershare")
		timerCleansingLightCD:Start()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 269838 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show()
		specWarnGTFO:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 137103 then--Visage
		self.vb.remainingAdds = self.vb.remainingAdds - 1
		warnVisage:Show(self.vb.remainingAdds)
	end
end
