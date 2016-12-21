local mod	= DBM:NewMod(1665, "DBM-Party-Legion", 5, 767)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(91004)
mod:SetEncounterID(1791)
mod:SetZone()
mod:SetHotfixNoticeRev(15186)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 198496 216290 193375",
	"SPELL_CAST_SUCCESS 216290 198717",
	"SPELL_SUMMON",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnStrikeofMountain			= mod:NewTargetAnnounce(216290, 2)
local warnBellowofDeeps				= mod:NewSpellAnnounce(193375, 2)--Change to special warning if they become important enough to switch to
local warnStanceofMountain			= mod:NewSpellAnnounce(216249, 2)

local specWarnSunder				= mod:NewSpecialWarningDefensive(198496, "Tank", nil, nil, 1, 2)
local specWarnStrikeofMountain		= mod:NewSpecialWarningDodge(216290, nil, nil, nil, 1, 2)
local yellStrikeofMountain			= mod:NewYell(216290)

local timerSunderCD					= mod:NewCDTimer(7.5, 198496, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerStrikeCD					= mod:NewCDTimer(15, 216290, nil, nil, nil, 3)
local timerStanceOfMountainCD		= mod:NewCDTimer(119.5, 216249, nil, nil, nil, 6)

local voiceSunder					= mod:NewVoice(198496, "Tank")--defensive
local voiceStrikeofMountain			= mod:NewVoice(216290)--targetyou

mod:AddSetIconOption("SetIconOnIdol", 216249, true, true)

local stanceMobs = {}

function mod:OnCombatStart(delay)
	table.wipe(stanceMobs)
	timerSunderCD:Start(7-delay)
	timerStrikeCD:Start(15.8-delay)
	timerStanceOfMountainCD:Start(26.7-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 198496 then
		specWarnSunder:Show()
		voiceSunder:Play("defensive")
		timerSunderCD:Start()
	elseif spellId == 216290 then
		timerStrikeCD:Start()
	elseif spellId == 193375 then
		warnBellowofDeeps:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 216290 then
		if args:IsPlayer() then
			specWarnStrikeofMountain:Show()
			voiceStrikeofMountain:Play("targetyou")
			yellStrikeofMountain:Yell()
		else
			warnStrikeofMountain:Show(args.destName)
		end
	elseif spellId == 198717 then--Fallen Debris (and args:GetSrcCreatureID() == 100818)
		if not stanceMobs[args.sourceGUID] and self.Options.SetIconOnIdol then
			self:ScanForMobs(args.sourceGUID, 2, 8, 1, 0.2, 10, "SetIconOnIdol")
		end
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	--Spellname also added in case of any missing spellids, but goal is to find all spell ids so it works for all languages
	if (spellId == 216249 or spellId == 198564 or spellId == 216250 or spellId == 198565) or args.spellName == "Stance of the Mountain" then
		stanceMobs[args.destGUID] = true
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 198509 then--Stance of the Mountain
		table.wipe(stanceMobs)
		warnStanceofMountain:Show()
		timerSunderCD:Stop()
		timerStrikeCD:Stop()
		--timerStanceOfMountainCD:Start()--Only seems to do it once now
	elseif spellId == 198631 then--Stance of mountain ending
		timerSunderCD:Start(3)
		timerStrikeCD:Start(16)
	end
end
