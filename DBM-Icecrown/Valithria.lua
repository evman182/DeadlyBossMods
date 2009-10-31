local mod = DBM:NewMod("Valithria", "DBM-Icecrown")
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 1799 $"):sub(12, -3))
mod:SetCreatureID(36789, 37868, 36791, 37863, 37886)--All the add creatureids for now drycoded from mmo database. (37950 phased bossid?)
--mod:SetUsedIcons(3, 4, 5, 6, 7, 8)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START"
)