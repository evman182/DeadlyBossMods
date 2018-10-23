local mod	= DBM:NewMod(2165, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(135322)
mod:SetEncounterID(2139)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 265773",
	"SPELL_CAST_START 265773 265923 265781 265910",
	"SPELL_PERIODIC_DAMAGE 265914",
	"SPELL_PERIODIC_MISSED 265914"
)

--TODO, longer pull for a second LucreCall
local warnSpitGold					= mod:NewTargetAnnounce(265773, 2)

local specWarnTailThrash			= mod:NewSpecialWarningDefensive(265910, nil, nil, nil, 1, 2)
local specWarnSpitGold				= mod:NewSpecialWarningMoveAway(265773, nil, nil, nil, 1, 2)
local yellSpitGold					= mod:NewYell(265773)
local specWarnLucreCall				= mod:NewSpecialWarningSwitch(265923, nil, nil, nil, 1, 2)--Only non Tank
local specWarnLucreCallTank			= mod:NewSpecialWarningMove(265923, nil, nil, nil, 1, 2)--Only Tank
local specWarnSerpentine			= mod:NewSpecialWarningRun(265781, nil, nil, nil, 4, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(265914, nil, nil, nil, 1, 8)

local timerTailThrashCD				= mod:NewCDTimer(16.9, 265910, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON..DBM_CORE_DEADLY_ICON)
local timerSpitGoldCD				= mod:NewCDCountTimer(10.9, 265773, nil, nil, nil, 3)
local timerLucreCallCD				= mod:NewCDTimer(41.2, 265923, nil, nil, nil, 3)
local timerSerpentineCD				= mod:NewCDTimer(21.9, 265781, nil, nil, nil, 2)

mod.vb.goldCast = 0

--mod:AddRangeFrameOption(5, 194966)

function mod:OnCombatStart(delay)
	self.vb.goldCast = 0
	timerSpitGoldCD:Start(8.3-delay, 1)
	timerSerpentineCD:Start(13.1-delay)
	timerTailThrashCD:Start(16.8-delay)
	timerLucreCallCD:Start(41.2-delay)
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 265773 then
		warnSpitGold:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnSpitGold:Show()
			specWarnSpitGold:Play("runout")
			yellSpitGold:Yell()
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 265773 then
		self.vb.goldCast = self.vb.goldCast + 1
		if self.vb.goldCast == 3 then
			self.vb.goldCast = 0
			timerSpitGoldCD:Start(14.6, self.vb.goldCast+1)
		else
			timerSpitGoldCD:Start(10.9, self.vb.goldCast+1)
		end
	elseif spellId == 265923 then
		if self:IsTank() then
			specWarnLucreCall:Show()
			specWarnLucreCall:Play("killmob")
		else
			specWarnLucreCallTank:Show()
			specWarnLucreCallTank:Play("moveboss")
		end
		timerLucreCallCD:Start()--Probably wrong, didn't get to log this far, but guessed similar to pull on 3x gold rule
	elseif spellId == 265781 then
		specWarnSerpentine:Show()
		specWarnSerpentine:Play("justrun")
		timerSerpentineCD:Start(21.9)
	elseif spellId == 265910 then
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTailThrash:Show()
			specWarnTailThrash:Play("defensive")
		end
		timerTailThrashCD:Start()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 265914 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show()
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 124396 then
		
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257939 then
	end
end
--]]
