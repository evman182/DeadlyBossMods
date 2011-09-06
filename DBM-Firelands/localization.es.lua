﻿if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerSpinners 		= "Siguientes hiladoras",
	TimerSpiderlings	= "Siguientes arañitas",
	TimerDrone		= "Siguiente zángano"
})

L:SetOptionLocalization({
	TimerSpinners		= "Mostrar tiempo para siguientes $journal:2770",
	TimerSpiderlings	= "Mostrar tiempo para siguientes $journal:2778",
	TimerDrone		= "Mostrar tiempo para siguiente $journal:2773",
	RangeFrame				= "Mostrar distancia (10)",
})

L:SetMiscLocalization({
	EmoteSpiderlings 	= "¡Las arañitas emergen de su nido!"
})

-------------------
-- Lord Rhyolith --
-------------------
L= DBM:GetModLocalization(193)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yellPhase2			= "He dormido durante eones sin ser molestado... Y ahora... Seres de carne, ¡ARDERÉIS!"
})

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase		= "Fase %d",
	WarnNewInitiate		= "Iniciado de Garfas Llameantes (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "Fase %d",
	TimerHatchEggs		= "Siguientes huevos",
	timerNextInitiate	= "Siguiente Iniciado",
	TimerCombatStart	= "Empieza el combate"
})

L:SetOptionLocalization({
	TimerCombatStart	= "Mostrar tiempo para el inicio del combate",
	WarnPhase		= "Mostrar un aviso para cada cambio de fase",
	WarnNewInitiate		= "Mostrar aviso para nuevo Iniciado de Garfas Llameantes",
	timerNextInitiate	= "Mostrar tiempo para siguiente Iniciado de Garfas Llameantes",
	TimerPhaseChange	= "Mostrar tiempo para siguiente fase",
	TimerHatchEggs		= "Mostrar tiempo hasta que los huevos eclosionen",
	InfoFrame		= "Mostrar información para Pluma de arrabio"
})

L:SetMiscLocalization({
	YellPull		= "¡Mortales, ahora sirvo a un nuevo amo!",
	Initiate		= "Iniciado de Garfas Llameantes",--http://www.wowhead.com/npc=53896
	YellPhase2		= "¡Estos cielos son MÍOS!",
	FullPower		= "spell:99925",
	LavaWorms		= "¡Gusanos de lava ígneos surgen del suelo!",
	PowerLevel		= "Pluma de arrabio",
	East			= "Este",
	West			= "Oeste",
	Both			= "Ambos"
})

-------------
-- Shannox --
-------------
L= DBM:GetModLocalization(195)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	SetIconOnFaceRage	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(99945),
	SetIconOnRage		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100415)
})

L:SetMiscLocalization({
	Riplimb		= "Desmembrador",
	Rageface	= "Rostrofuria"
})

-------------
-- Baleroc --
-------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	timerStrike			= "Siguiente %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "Siguiente Hoja"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "Reiniciar contador de $spell:99259 en series de 3s(en 25)/2s(en 10)",
	warnStrike			= "Mostrar avisos para Hoja de Infierno/Exterminadora",
	timerStrike			= "Mostrar tiempo para la siguiente Hoja de Infierno/Exterminadora",
	TimerBladeActive	= "Mostrar tiempo de duración de la hoja activa",
	TimerBladeNext		= "Mostrar tiempo para la siguiente hoja",
	SetIconOnCountdown	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(99516),
	SetIconOnTorment	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100232),
	ArrowOnCountdown	= "Mostrar flecha cuando te afecte $spell:99516 ",
	InfoFrame		= "Mostrar información de las marcas de Chispa vital",
	RangeFrame			= "Mostrar distancia (5) para $spell:99404"
})

L:SetMiscLocalization({
	VitalSpark		= "Marcas de "..GetSpellInfo(99262)
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	timerNextSpecial	= "Siguiente %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "Mostrar tiempo para siguiente habilidad especial",
	RangeFrameSeeds				= "Mostrar distancia (12) para $spell:98450",
	RangeFrameCat				= "Mostrar distancia (10) para $spell:98374",
	LeapArrow					= "Mostrar flecha cuando $spell:98476 está cerca de ti",
	IconOnLeapingFlames			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100208)
})

L:SetMiscLocalization({
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnSplittingBlow		= "%s en %s",
	warnEngulfingFlame		= "%s en %s",
	WarnRemainingAdds		= "%d Hijos de la Llama restantes"
})

L:SetTimerLocalization({
	TimerPhaseSons		= "Transición termina"
})

L:SetOptionLocalization({
	warnSplittingBlow	= "Mostrar aviso para $spell:100877",
	warnEngulfingFlame	= "Mostrar aviso para $spell:99171",
	WarnRemainingAdds	= "Mostrar aviso para el número de Hijos de la Llama restantes",
	TimerPhaseSons		= "Mostrar tiempo de duración para la fase de \"Hijos de la Llama\"",
	RangeFrame		= "Mostrar distancia",
	InfoHealthFrame		= "Mostrar información de vida (<90k de vida)",
	InfoFrame			= "Mostrar información de los objetivos de $spell:99849",
	BlazingHeatIcons	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100983)
})

L:SetMiscLocalization({
	East				= "Este",
	West				= "Oeste",
	Middle				= "Medio",
	North				= "Melee",
	South				= "Atrás",
	HealthInfo			= "Menos de 90k de vida",
	MeteorTargets		= "HOYGA METEHORITOS!",
	TransitionEnded1	= "Enough! I will finish this.",--translate
	TransitionEnded2	= "Sulfuras will be your end.",--translate
	TransitionEnded3	= "Fall to your knees, mortals!  This ends now.",--translate
	Defeat				= "Too soon! ... You have come too soon...",--translate
	Phase4				= "Too soon..."
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "Trash de las Tierras del Fuego"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	TrashRangeFrame	= "Mostrar distancia (10) para $spell:100012",
})

L:SetMiscLocalization({
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "Volcanus"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	timerStaffTransition	= "Fase de transición termina"
})

L:SetOptionLocalization({
	timerStaffTransition	= "Mostrar tiempo para la fase de transición"
})

L:SetMiscLocalization({
	StaffEvent			= "La rama de Nordrassil reacciona de forma violenta",
	StaffTrees			= "¡Antárboles ardientes emergen del suelo para ayudar al protector!",
	StaffTransition		= "¡Las llamas que consumen al protector atormentado se extinguen!"
})