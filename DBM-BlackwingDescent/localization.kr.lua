if GetLocale() ~= "koKR" then return end

local L

--------------
--  Magmaw  --
--------------
L = DBM:GetModLocalization("Magmaw")

L:SetGeneralLocalization({
	name = "용암아귀"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
})

-------------------------------
--  Dark Iron Golem Council  --
-------------------------------
L = DBM:GetModLocalization("DarkIronGolemCouncil")

L:SetGeneralLocalization({
	name = "검은무쇠단 사절"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
	Magmatron	= "Magmatron",
	Electron	= "Electron",
	Toxitron	= "Toxitron",
	Arcanotron	= "Arcanotron",
	SayBomb		= "Poison Bomb on me!"
})

L:SetOptionLocalization({
	SayBombTarget	= "$spell:80157 외치기"
})

----------------
--  Maloriak  --
----------------
L = DBM:GetModLocalization("Maloriak")

L:SetGeneralLocalization({
	name = "말로리악"
})

L:SetWarningLocalization({
	WarnPhase			= "%s 단계",
	WarnRemainingAdds	= "%d 돌연변이 남음"
})

L:SetTimerLocalization({
	TimerPhase		= "다음 단계"
})

L:SetMiscLocalization({
	YellRed			= "섞고 흔들어서, 열을 가한다...",
	YellBlue		= "급격한 온도 변화에 필멸의 육신",
	YellGreen		= "T이건 좀 불안정하지만",
	YellDark		= "혼합물이 너무 약하구나, 말로리악!",
	Red				= "붉은",
	Blue			= "푸른",
	Green			= "초록",
	Dark			= "암흑"
})

L:SetOptionLocalization({
	WarnPhase			= "다음 단계 전환 경고 보기",
	WarnRemainingAdds	= "돌연변이가 얼마나 남았는지 경고 보기",
	TimerPhase			= "다음 단계 타이머 보기"
})

-----------------
--  Chimaeron  --
-----------------
L = DBM:GetModLocalization("Chimaeron")

L:SetGeneralLocalization({
	name = "카미이론"
})

L:SetWarningLocalization({
	WarnPhase2Soon	= "곧 2 단계",
	WarnBreak	= "%s : >%s< (%d)"
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
	WarnPhase2Soon	= "2 단계 사전 경고 보기",
	WarnBreak	= DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(82881, GetSpellInfo(82881) or "알 수 없음")
})

-----------------
--  Atramedes  --
-----------------
L = DBM:GetModLocalization("Atramedes")

L:SetGeneralLocalization({
	name = "아트라메데스"
})

L:SetWarningLocalization({
	WarnAirphase		= "공중 단계",
	WarnGroundphase		= "지상 단계",
	WarnShieldsLeft		= "고대 드워프 보호막 - %d -남음"
})

L:SetTimerLocalization({
	TimerAirphase		= "공중 단계",
	TimerGroundphase	= "지상 단계"
})

L:SetMiscLocalization({
	AncientDwarvenShield	= "고대 드워프 보호막",
	Airphase				= "Yes, run! With every step your heart quickens. The beating, loud and thunderous... Almost deafening. You cannot escape!"
})

L:SetOptionLocalization({
	WarnAirphase		= "공중단계 경고 보기",
	WarnGroundphase		= "지상단계 경고 보기",
	WarnShieldsLeft		= "고대 드워프 보호막 남은 개수 경고 보기",
	TimerAirphase		= "다음 공중 단계 경고 보기",
	TimerGroundphase	= "다음 지상 단계 경고 보기"
})

----------------
--  Nefarian  --
----------------
L = DBM:GetModLocalization("Nefarian-BD")	-- No conflict with BWL version :)

L:SetGeneralLocalization({
	name = "네파리안"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
	YellPhase2			= "저주받을 필멸자들!",
	ChromaticPrototype	= "오색 실험체"
})

L:SetOptionLocalization({
})
