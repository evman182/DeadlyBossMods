﻿if GetLocale() ~= "koKR" then return end
local L

------------------------
--  Conclave of Wind  --
------------------------
--L = DBM:GetModLocalization(154)
L = DBM:GetModLocalization("Conclave")

L:SetGeneralLocalization({
	name = "바람의 비밀의회"
})

L:SetWarningLocalization({
	warnSpecial				= "궁극의 힘!", --Hurricane/Zephyr/Sleet Storm Active",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial			= "궁극의 힘 시전!!",
	warnSpecialSoon			= "10초 후 궁극의 힘"
})

L:SetTimerLocalization({
	timerSpecial			= "다음 궁극의 힘",
	timerSpecialActive		= "궁극의 힘"
})

L:SetOptionLocalization({
	warnSpecial				= "궁극의 힘 시전 경고 보기", -- Show warning when Hurricane/Zephyr/Sleet Storm are cast",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial			= "궁극의 힘 시전을 할 경우 특수 경고 보기",
	timerSpecial			= "다음 궁극의 힘 타이머 보기",
	timerSpecialActive		= "궁극의 힘 유지 타이머 보기",
	warnSpecialSoon			= "궁국의 힘 사전 경고 보기(~10초 전)",	
	OnlyWarnforMyTarget		= "대상/주시대상으로 선택한 보스에 관련된 타이머/경고만 보기\n(풀링 포함. 선택한 보스 외에 다른 보스는 숨김)"
})

L:SetMiscLocalization({
--	gatherstrength			= "%s에게서 힘을 모으기 시작합니다!"
	gatherstrength			= "힘을 모으기 시작합니다!",
	Anshal					= "안샬",
	Nezir					= "네지르",
	Rohash					= "로하시"
})
---------------
--  Al'Akir  --
---------------
--L = DBM:GetModLocalization(155)
L = DBM:GetModLocalization("AlAkir")

L:SetGeneralLocalization({
	name = "알아키르"
})


L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerFeedback 		= "역순환 (%d)"
})

L:SetOptionLocalization({
	LightningRodIcon	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(89668),
	TimerFeedback		= "$spell:87904 유지 타이머 보기",
	RangeFrame			= "$spell:89668의 영향을 받을 경우 거리 프레임 보기(20 m)"
})

L:SetMiscLocalization({
})
