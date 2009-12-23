﻿if GetLocale() ~= "zhTW" then return end
DBM_CORE_LOAD_MOD_ERROR				= "載入%s模組時發生錯誤：%s"
DBM_CORE_LOAD_MOD_SUCCESS			= "成功載入%s模組!"
DBM_CORE_LOAD_GUI_ERROR				= "無法載入圖形介面：%s"

DBM_CORE_COMBAT_STARTED				= "%s開戰. 祝好運與盡興! :)";
DBM_CORE_BOSS_DOWN				= "%s 倒地, 經過 %s!"
DBM_CORE_BOSS_DOWN_LONG				= "%s倒地!本次經過%s，上次經過%s，最快紀錄%s。"
DBM_CORE_BOSS_DOWN_NEW_RECORD			= "%s倒地! 經過	%s，這是一個新記錄!（舊紀錄為%s）"
DBM_CORE_COMBAT_ENDED				= "%s 的戰鬥經過 %s 結束."

DBM_CORE_TIMER_FORMAT_SECS			= "%d秒"
DBM_CORE_TIMER_FORMAT_MINS			= "%d分鐘"
DBM_CORE_TIMER_FORMAT				= "%d分%d秒"

DBM_CORE_MIN					= "分"
DBM_CORE_MIN_FMT				= "%d 分"
DBM_CORE_SEC					= "秒"
DBM_CORE_SEC_FMT				= "%d 秒"
DBM_CORE_DEAD					= "死亡"
DBM_CORE_OK					= "確定"

DBM_CORE_GENERIC_WARNING_BERSERK		= "%s%s後狂暴"
DBM_CORE_GENERIC_TIMER_BERSERK			= "狂暴"
DBM_CORE_OPTION_TIMER_BERSERK			= "為$spell:26662顯示計時器"
DBM_CORE_OPTION_HEALTH_FRAME			= "顯示首領血量框架"

DBM_CORE_OPTION_CATEGORY_TIMERS			= "計時條"
DBM_CORE_OPTION_CATEGORY_WARNINGS		= "提示"
DBM_CORE_OPTION_CATEGORY_MISC			= "其它"

DBM_CORE_AUTO_RESPONDED				= "已自動回復密語。"
DBM_CORE_STATUS_WHISPER				= "%s：%s，%d/%d存活"
DBM_CORE_AUTO_RESPOND_WHISPER			= "%s正在與%s交戰，（當前%s，%d/%d存活）"
DBM_CORE_WHISPER_COMBAT_END_KILL		= "%s已經擊敗 %s!"
DBM_CORE_WHISPER_COMBAT_END_WIPE		= "%s在 %s 戰鬥中滅團。"

DBM_CORE_VERSIONCHECK_HEADER			= "Deadly Boss Mods - 版本檢測"
DBM_CORE_VERSIONCHECK_ENTRY			= "%s：%s(r%d)"
DBM_CORE_VERSIONCHECK_ENTRY_NO_DBM		= "%s：尚未安裝DBM"
DBM_CORE_VERSIONCHECK_FOOTER			= "團隊中有%d名成員正在使用Deadly Boss Mods"
DBM_CORE_YOUR_VERSION_OUTDATED      		= "你的 Deadly Boss Mod 已經過期! 請到 www.deadlybossmods.com 下載最新版本。"

DBM_CORE_UPDATEREMINDER_HEADER			= "你的 Deadly Boss Mod 已經過期! \n你可以在以下位址下載到新版本%s(r%d)："
DBM_CORE_UPDATEREMINDER_FOOTER			= "Ctrl-C：複製下載地址到剪貼簿。"
DBM_CORE_UPDATEREMINDER_NOTAGAIN		= "當有新版本時顯示彈出提示"

DBM_CORE_MOVABLE_BAR				= "拖動我!"

DBM_PIZZA_SYNC_INFO				= "|Hplayer:%1$s|h[%1$s]|h向你發送了一個倒計時：'%2$s'\n|HDBM:cancel:%2$s:nil|h|cff3588ff[取消該計時]|r|h  |HDBM:ignore:%2$s:%1$s|h|cff3588ff[忽略來自%1$s的計時]|r|h"
DBM_PIZZA_CONFIRM_IGNORE			= "是否要在該次遊戲連接中忽略來自%s的計時？"
DBM_PIZZA_ERROR_USAGE				= "命令：/dbm [broadcast] timer <時間（秒）> <文字>"

DBM_CORE_ERROR_DBMV3_LOADED			= "目前有2個版本的Deadly Boss Mods正在運行：DBMv3和DBMv4。\n按一下“確定”按鈕可將DBMv3關閉並重載使用者介面。\n我們建議將外掛程式目錄下的DBMv3刪除。"

DBM_CORE_MINIMAP_TOOLTIP_HEADER			= "Deadly Boss Mods"
DBM_CORE_MINIMAP_TOOLTIP_FOOTER			= "Shift+按一下或右鍵點擊即可移動"

DBM_CORE_RANGECHECK_HEADER			= "距離監視（%d碼）"
DBM_CORE_RANGECHECK_SETRANGE			= "設置距離"
DBM_CORE_RANGECHECK_SOUNDS			= "音效"
DBM_CORE_RANGECHECK_SOUND_OPTION_1		= "當一位玩家在範圍內時播放音效"
DBM_CORE_RANGECHECK_SOUND_OPTION_2		= "當多於一位玩家在範圍內時播放音效"
DBM_CORE_RANGECHECK_SOUND_0			= "沒有音效"
DBM_CORE_RANGECHECK_SOUND_1			= "預設音效"
DBM_CORE_RANGECHECK_SOUND_2			= "蜂鳴聲"
DBM_CORE_RANGECHECK_HIDE			= "隱藏"
DBM_CORE_RANGECHECK_SETRANGE_TO			= "%d碼"
DBM_CORE_RANGECHECK_LOCK			= "鎖定框架"

DBM_CORE_SLASHCMD_HELP				= {
	"可用命令：",
	"/dbm version：進行團隊範圍內的版本檢測（也可使用：ver）",
	"/dbm unlock：顯示一個可移動的計時條，可通過對它來移動所有DBM計時條的位置（也可使用：move）",
	"/dbm timer <x> <文本>：開始一個以<文本>為名稱的時間為<x>秒的倒計時",
	"/dbm broadcast timer <x> <文本>：向團隊廣播一個以<文本>為名稱的時間為<x>秒的倒計時（需要團隊隊長或助理權限）",
	"/dbm break <分鐘>: 開始休息<min>分鐘。向所有團隊成員發送一個DBM休息計時條。",
	"/dbm help：顯示可用命令描述",
}

DBM_ERROR_NO_PERMISSION				= "無權進行該操作。"

DBM_CORE_BOSSHEALTH_HIDE_FRAME			= "關閉血量框架"

DBM_CORE_ALLIANCE				= "聯盟"
DBM_CORE_HORDE					= "部落"

DBM_CORE_UNKNOWN				= "未知"

DBM_CORE_BREAK_START				= "現在開始休息-你有%s分鐘!"
DBM_CORE_BREAK_MIN				= "%s分鐘後休息時間結束!"
DBM_CORE_BREAK_SEC				= "%s秒後休息時間結束!"
DBM_CORE_BREAK_TIME				= "休息時間!"
DBM_CORE_BREAK_OVER				= "休息時間已經結束"

DBM_CORE_TIMER_PULL				= "戰鬥準備"
DBM_CORE_ANNOUNCE_PULL				= "%d秒後拉怪"
DBM_CORE_ANNOUNCE_PULL_NOW			= "拉怪囉!"

DBM_CORE_ACHIEVEMENT_TIMER_SPEED_KILL 		= "快速擊殺"

-- Auto-generated Timer Localizations
DBM_CORE_AUTO_TIMER_TEXTS = {
	target 					= "%s: %%s",
	cast 					= "%s",
	active 					= "%s",
	cd 					= "%s 冷卻",
	next 					= "下一次 %s",
	achievement 				= "%s",
}

DBM_CORE_AUTO_TIMER_OPTIONS = {
	target 					= "為|cff71d5ff|Hspell:%d|h%s|h|r顯示減益計時器",
	cast 					= "為|cff71d5ff|Hspell:%d|h%s|h|r顯示施法計時器",
	active 					= "為|cff71d5ff|Hspell:%d|h%s|h|r顯示持續時間計時器",
	cd 					= "為|cff71d5ff|Hspell:%d|h%s|h|r顯示冷卻計時器",
	next 					= "為下一次 |cff71d5ff|Hspell:%d|h%s|h|r顯示計時器",
	achievement 				= "為成就:%s顯示計時器",
}

-- Auto-generated Warning Localizations
DBM_CORE_AUTO_ANNOUNCE_TEXTS = {
	target 					= "%s: >%%s<",
	spell 					= "%s",
	cast 					= "施放 %s: %.1f 秒",
	soon 					= "%s 即將到來",
	prewarn 				= "%s 在 %s",
	phase 					= "第%d階段",
}

local prewarnOption 				= "為|cff71d5ff|Hspell:%d|h%s|h|r顯示預先警告"
DBM_CORE_AUTO_ANNOUNCE_OPTIONS = {
	target 					= "提示|cff71d5ff|Hspell:%d|h%s|h|r的目標",
	spell 					= "為|cff71d5ff|Hspell:%d|h%s|h|r顯示警告",
	cast 					= "當|cff71d5ff|Hspell:%d|h%s|h|r施放時顯示警告",
	soon 					= prewarnOption,
	prewarn 				= prewarnOption,
	phase 					= "提示第%d階段",
}

-- Auto-generated Special Warning Localizations
DBM_CORE_AUTO_SPEC_WARN_OPTIONS = {
	spell 					= "為$spell:%d顯示特別警告",
	dispel 					= "Show special warning to dispel/spellsteal \n $spell:%d",
	you 					= "當你中了$spell:%d時顯示特別警告",
	target 					= "為中了$spell:%d的人顯示特別警告",
	close 					= "當中了$spell:%d的人在你附近時顯示特別警告",
	move 					= "當你中了$spell:%d時顯示特別警告",
	run 					= "為$spell:%d顯示特別警告",
	cast 					= "當$spell:%d施放時顯示特別警告",
	stack 					= "當你中了$spell:%d(>=%d層)時顯示特別警告"
}

DBM_CORE_AUTO_SPEC_WARN_TEXTS = {
	spell 					= "%s",
	dispel 					= "%%s中了%s - 現在驅散",
	you 					= "你中了%s",
	target 					= "%%s中了%s",
	close 					= "你附近的%%s中了%s",
	move 					= "%s - 快離開",
	run 					= "%s - 快跑開",
	cast 					= "%s - 停止施法",
	stack 					= "%s (%%d)"
}

DBM_CORE_AUTO_ICONS_OPTION_TEXT			= "為$spell:%d的目標設置標記"
DBM_CORE_AUTO_SOUND_OPTION_TEXT			= "為$spell:%d播放音效"

-- New special warnings
DBM_CORE_MOVE_SPECIAL_WARNING_BAR		= "可拖動的特別警告"
DBM_CORE_MOVE_SPECIAL_WARNING_TEXT		= "特別警告"