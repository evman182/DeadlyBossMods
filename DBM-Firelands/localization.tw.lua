﻿if GetLocale() ~= "zhTW" then return end
local L

-----------------
-- Beth'tilac --
-----------------
L= DBM:GetModLocalization(192)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerSpinners 		= "下一次 燼網紡織者",
	TimerSpiderlings	= "下一次 燼網小蜘蛛",
	TimerDrone			= "下一次 燼網雄蛛"
})

L:SetOptionLocalization({
	TimerSpinners		= "為下一次$journal:2770出現顯示計時器",
	TimerSpiderlings	= "為下一次$journal:2778出現顯示計時器",
	TimerDrone			= "為下一次$journal:2773出現顯示計時器",
	RangeFrame			= "顯示距離框(10碼)"
})

L:SetMiscLocalization({
	EmoteSpiderlings 	= "小蜘蛛從牠們的巢穴中被驚動了!"
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
	yellPhase2			= "數萬年來我平靜地睡著...現在居然這樣...血肉之軀，你們給我燒吧!"
})

---------------
-- Alysrazor --
---------------
L= DBM:GetModLocalization(194)

L:SetWarningLocalization({
	WarnPhase			= "階段 %d",
	WarnNewInitiate		= "熾炎猛禽學徒 (%s)"
})

L:SetTimerLocalization({
	TimerPhaseChange	= "階段 %d",
	TimerHatchEggs		= "下次熔岩蛋",
	timerNextInitiate	= "下次熾炎爪擊啟動",
	TimerCombatStart	= "戰鬥開始"
})

L:SetOptionLocalization({
	TimerCombatStart	= "為戰鬥開始顯示時間",
	WarnPhase			= "為每次轉換階段顯示警告",
	WarnNewInitiate		= "為新的熾炎猛禽學徒顯示警告",
	timerNextInitiate	= "為下一次熾炎猛禽學徒顯示計時器",
	TimerPhaseChange	= "為下次階段轉換顯示計時器",
	TimerHatchEggs		= "為下次熔岩蛋孵化顯示計時器",
	InfoFrame			= "在資訊框架顯示熔岩之力"
})

L:SetMiscLocalization({
	YellPull		= "我現在有新的主人了，凡人!",
	Initiate		= "熾炎猛禽學徒",--http://www.wowhead.com/npc=53896
	YellPhase2		= "這片天空屬於我。",
	FullPower		= "spell:99925",--This is in the emote, shouldn't need localizing, just msg:find
	LavaWorms		= "熾炎熔岩蟲從地上鑽了出來!",--Might use this one day if i feel it needs a warning for something. Or maybe pre warning for something else (like transition soon)
	PowerLevel		= "熔岩之力",
	East			= "東邊",
	West			= "西邊",
	Both			= "兩側"
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
	Riplimb		= "裂軀",
	Rageface	= "怒面"
})

-------------
-- Baleroc --
-------------
L= DBM:GetModLocalization(196)

L:SetWarningLocalization({
	warnStrike	= "%s (%d)"
})

L:SetTimerLocalization({
	timerStrike			= "下一次 %s",
	TimerBladeActive	= "%s",
	TimerBladeNext		= "下一次 巴勒羅克之刃"
})

L:SetOptionLocalization({
	ResetShardsinThrees	= "每3秒（25人）/2秒（10人）重置$spell:99259的倒數計時",
	warnStrike			= "為虐殺/煉獄之刃顯示警告",
	timerStrike			= "為下一次虐殺/煉獄之刃顯示計時器",
	TimerBladeActive	= "為目前虐殺/煉獄之刃顯示持續時間",
	TimerBladeNext		= "為下一次巴勒羅克之刃顯示計時器",
	SetIconOnCountdown	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(99516),
	SetIconOnTorment	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100232),
	ArrowOnCountdown	= "當你中了$spell:99516時顯示DBM箭頭",
	InfoFrame			= "為活力火花堆疊顯示訊息框",
	RangeFrame			= "為$spell:99404顯示距離框(5碼)"
})

L:SetMiscLocalization({
	VitalSpark		= GetSpellInfo(99262).." 堆疊"
})

--------------------------------
-- Majordomo Fandral Staghelm --
--------------------------------
L= DBM:GetModLocalization(197)

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	timerNextSpecial	= "下一次 %s (%d)"
})

L:SetOptionLocalization({
	timerNextSpecial			= "為下一次特殊技能顯示計時器",
	RangeFrameSeeds				= "為$spell:98450顯示距離框(12碼)",
	RangeFrameCat				= "為$spell:98374顯示距離框(10碼)",
	LeapArrow					= "當$spell:98476在附近時顯示DBM箭頭",
	IconOnLeapingFlames			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100208)
})

L:SetMiscLocalization({
})

--------------
-- Ragnaros --
--------------
L= DBM:GetModLocalization(198)

L:SetWarningLocalization({
	warnRageRagnarosSoon	= "%s在%s在5秒後",--Spellname on targetname
	warnSplittingBlow		= "%s在%s",--Spellname in Location
	warnEngulfingFlame		= "%s在%s",--Spellname in Location
	WarnRemainingAdds		= "剩下 %d 個烈焰之子",
	warnAggro				= "你為熔岩煉獄的目標!",
	warnNoAggro				= "你沒有熔岩煉獄的仇恨",
	warnEmpoweredSulf		= "%s 在5秒後施放"--The spell has a 5 second channel, but tooltip doesn't reflect it so cannot auto localize
})

L:SetTimerLocalization({
	timerRageRagnaros		= "%s在%s",--Spellname on targetname
	TimerPhaseSons			= "烈焰之子階段結束"
})

L:SetOptionLocalization({
	warnRageRagnarosSoon		= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.prewarn:format(101109, GetSpellInfo(101109)),
	warnSplittingBlow			= "為$spell:100877的位置顯示警告",
	warnEngulfingFlame			= "為$spell:99171的位置顯示警告",
	WarnEngulfingFlameHeroic	= "為$spell:99171的位置顯示警告(英雄模式)",
	WarnRemainingAdds			= "為剩餘烈焰之子的顯示警告",
	warnSeedsLand				= "顯示$spell:98520落地時警告/計時器而非熔岩晶粒施放時警告/計時器",
	ElementalAggroWarn			= "無論是否為熔岩煉獄的目標都顯示警告",
	warnEmpoweredSulf			= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.cast:format(100997, GetSpellInfo(100997)),
	timerRageRagnaros			= DBM_CORE_AUTO_TIMER_OPTIONS.cast:format(101109, GetSpellInfo(101109)),
	TimerPhaseSons				= "顯示烈焰之子階段的持續時間計時器",
	RangeFrame					= "顯示距離框",
	P4IconRangeFilter			= "讓距離框在P4時只有顯示團隊圖示的團員\n(需要開啟顯示距離框)",
	InfoHealthFrame				= "顯示生命值框架 (低於十萬生命值)",
	MeteorFrame					= "顯示$spell:99849的目標的訊息框",
	AggroFrame					= "顯示沒有熔岩煉獄的仇恨的團員的訊息框",
	BlazingHeatIcons			= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(100983)
})

L:SetMiscLocalization({
	East				= "東邊",
	West				= "西邊",
	Middle				= "中間",
	North				= "近戰區",
	South				= "後方",
	HealthInfo			= "低於十萬生命值",
	HasNoAggro			= "無目標",
	MeteorTargets		= "我的天 隕石!",--Keep rollin' rollin' rollin' rollin'.
	TransitionEnded1	= "夠了!我將結束這一切。",--More reliable then adds method.
	TransitionEnded2	= "薩弗拉斯將終結你。",
	TransitionEnded3	= "跪下吧，凡人們!一切都將結束。",
	Defeat				= "太早了!...你們來的太早了...",
	Phase4				= "太早了..."
})

-----------------------
--  Firelands Trash  --
-----------------------
L = DBM:GetModLocalization("FirelandsTrash")

L:SetGeneralLocalization({
	name = "火源之界小怪"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	TrashRangeFrame	= "為$spell:100012顯示距離框(10碼)"
})

L:SetMiscLocalization({
})

----------------
--  Volcanus  --
----------------
L = DBM:GetModLocalization("Volcanus")

L:SetGeneralLocalization({
	name = "沃坎努斯"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	timerStaffTransition	= "轉換階段結束"
})

L:SetOptionLocalization({
	timerStaffTransition	= "為轉換階段顯示時間"
})

L:SetMiscLocalization({
	StaffEvent			= "諾達希爾木枝對於%S+的觸碰產生了激烈的反應!",--Reg expression pull match
	StaffTrees			= "燃燒的樹人從地面冒出來協助保衛者!",--Might add a spec warning for this later.
	StaffTransition		= "受折磨的保衛者身上的火焰熄滅了!"
})