if GetLocale() ~= "koKR" then return end
local L

------------------------
--  Conclave of Wind  --
------------------------
L = DBM:GetModLocalization("Conclave")

L:SetGeneralLocalization({
	name = "바람의 비밀의회"
})

L:SetWarningLocalization({
	warnSpecial				= "Hurricane/Zephyr/Sleet Storm Active",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial			= "Special Abilities Active!"
})

L:SetTimerLocalization({
	timerSpecial			= "Special Abilities CD",
	timerSpecialActive		= "Special Abilities Active"
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
	warnSpecial				= "Show warning when Hurricane/Zephyr/Sleet Storm are cast",--Special abilities hurricane, sleet storm, zephyr(which are on shared cast/CD)
	specWarnSpecial			= "Show special warning when special abilities are cast",
	timerSpecial			= "Show timer for special abilities cooldown",
	timerSpecialActive		= "Show timer for special abilities duration"
})

---------------
--  Al'Akir  --
---------------
L = DBM:GetModLocalization("AlAkir")

L:SetGeneralLocalization({
	name = "알아키르"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetMiscLocalization({
})

L:SetOptionLocalization({
})
