local mod	= DBM:NewMod("EternalPalaceTrash", "DBM-EternalPalace", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone()
mod.isTrashMod = true

mod:RegisterEvents(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED"
--	"SPELL_AURA_REMOVED 289917"
)

--local warnBwonSamdiPact					= mod:NewTargetNoFilterAnnounce(289917, 3)

--local specWarnBwonSamdiPact				= mod:NewSpecialWarningYou(289917, nil, nil, nil, 1, 2)
--local yellCorruptingGaze				= mod:NewYell(289917)
--local specWarnBloodShield				= mod:NewSpecialWarningInterrupt(276540, "HasInterrupt", nil, nil, 1, 2)

--mod:AddRangeFrameOption(10, 221028)

--[[
function mod:GazeTarget(targetname, uId)
	if not targetname then return end
	if self:AntiSpam(5, targetname) then
		if targetname == UnitName("player") then
			specWarnCorruptingGaze:Show()
			specWarnCorruptingGaze:Play("runout")
			yellCorruptingGaze:Yell()
		elseif self:CheckNearby(5, targetname) then
			specWarnCorruptingGazeNear:Show(targetname)
			specWarnCorruptingGazeNear:Play("watchstep")
		else
			warnCorruptingGaze:Show(targetname)
		end
	end
end
--]]

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 277047 then
		--self:BossTargetScanner(args.sourceGUID, "SubmergeTarget", 0.1, 14)
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "GazeTarget", 0.1, 12)
	elseif spellId == 276540 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBloodShield:Show(args.sourceName)
		specWarnBloodShield:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 290578 then

	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 289917 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 289917 then

	end
end
--]]
