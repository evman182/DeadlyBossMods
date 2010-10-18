local mod	= DBM:NewMod("Argaloth", "DBM-BaradinHold", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(47120)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START"
)

local warnConsuming		= mod:NewTargetAnnounce(88954, 3)
local warnMeteorSlash		= mod:NewSpellAnnounce(88942, 4)
local warnFirestorm		= mod:NewSpellAnnounce(88972, 4)

local timerConsuming		= mod:NewTargetTimer(15, 88954)
local timerConsumingCD		= mod:NewCDTimer(22, 88954)
local timerMeteorSlash		= mod:NewNextTimer(16.5, 88942)
local timerMeteorSlashCast	= mod:NewCastTimer(1.25, 88942)
local timerFirestorm		= mod:NewBuffActiveTimer(15, 88972)
local timerFirestormCast	= mod:NewCastTimer(3, 88972)

mod:AddBoolOption("SetIconOnConsuming", true)

local consumingTargets = {}
local consumingIcon = 8

local function showConsumingWarning()
	warnConsuming:Show(table.concat(consumingTargets, "<, >"))
	table.wipe(consumingTargets)
	consumingIcon = 8
end

function mod:OnCombatStart(delay)
	table.wipe(consumingTargets)
	consumingIcon = 8
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(88954, 95173) then
		timerConsuming:Start(args.destName)
		timerConsumingCD:Start()
		consumingTargets[#consumingTargets] = args.destName
		if self.Options.SetIconOnConsuming then
			self:SetIcon(args.destName, consumingIcon)
			consumingIcon = consumingIcon - 1
		end
		self:Unschedule(showConsumingWarning)
		if mod:IsDifficulty("normal10") and #consumingTargets >= 3 then
			showConsumingWarning()
		else
			self:Schedule(0.3, showConsumingWarning())
		end
	elseif args:IsSpellID(88972) then
		timerFirestorm:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(88954, 95173) then
		timerConsuming:Cancel(args.destName)
	elseif args:IsSpellID(88972) then
		timerMeteorSlash:Start(13)
		timerConsumingCD:Start(9)
	end
end
	
function mod:SPELL_CAST_START(args)
	if args:IsSpellID(88942, 95172) then
		warnMeteorSlash:Show()
		timerMeteorSlashCast:Start()
		timerMeteorSlash:Start()
	elseif args:IsSpellID(88972) then
		warnFirestorm:Show()
		timerMeteorSlash:Cancel()
		timerConsumingCD:Cancel()
	end
end