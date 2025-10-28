-- ========== C# ==========
local Debug = CS.UnityEngine.Debug
Object = CS.UnityEngine.Object
Sprite = CS.UnityEngine.Sprite
Texture = CS.UnityEngine.Texture
Color = CS.UnityEngine.Color
ColorUtility = CS.UnityEngine.ColorUtility
Transform = CS.UnityEngine.Transform
RectTransform = CS.UnityEngine.RectTransform
GameObject = CS.UnityEngine.GameObject
Vector2 = CS.UnityEngine.Vector2
Vector3 = CS.UnityEngine.Vector3
Quaternion = CS.UnityEngine.Quaternion
NovaAPI = CS.NovaAPI
CSTimerManager = CS.TimerManager
DOTween = CS.DG.Tweening.DOTween
Sequence = CS.DG.Tweening.DOTween.Sequence
Ease = CS.DG.Tweening.Ease
RotateMode = CS.DG.Tweening.RotateMode
TweenExtensions = CS.TweenExtensions
GameUIUtils = CS.GameUIUtils
-- ========== Nova Lua ==========
local PB = require "pb"
require "functions"
local rapidjson = require "rapidjson"
GameEnum = require "Game.CodeGen.GAME_ENUM_DEFINE"
AllEnum = require "GameCore.Common.AllEnum"
Settings = require "GameCore.Common.Settings"
EventId = require "GameCore.Event.EventId"
EventManager = require "GameCore.Event.EventManager"
PlayerData = require "GameCore.Data.PlayerData"
NetMsgId = require "GameCore.Network.NetMsgId"
HttpNetHandler = require "GameCore.Network.HttpNetHandler"
PanelId = require "GameCore.UI.PanelId"
PanelManager = require "GameCore.UI.PanelManager"
BasePanel = require "GameCore.UI.BasePanel"
BaseCtrl = require "GameCore.UI.BaseCtrl"
RedDotDefine = require "GameCore.RedDot.RedDotDefine"
RedDotManager = require "GameCore.RedDot.RedDotManager"
PopUpManager = require "GameCore.Data.PopUpManager"
-- ========== XLua ==========
local util = require "xlua.util"
async_to_sync = util.async_to_sync
coroutine_call = util.coroutine_call
cs_generator = util.cs_generator
loadpackage = util.loadpackage
auto_id_map = util.auto_id_map
hotfix_ex = util.hotfix_ex
bind = util.bind
createdelegate = util.createdelegate
state = util.state
print_func_ref_by_csharp = util.print_func_ref_by_csharp
cs_coroutine = require "xlua.cs_coroutine"
-- ========== Log ========== 
local serpent = require "serpent"
function printLog(str)
    Debug.Log(str);
end
function printWarn(str) 
	Debug.LogWarning(str);
end
function printError(str) 
	Debug.LogError(str);
end
function printTable(tb)
    if type(tb) == "table" then
        print(serpent.block(tb))
    end
end
function traceback(str)
    Debug.LogError(debug.traceback(str));
end

-- ========== Time ==========
-- 以 分钟:秒 形式格式化时间(秒)
function timeFormat_MS(value)
	local min = math.floor(value / 60)
	local sec = value - min * 60
	if min < 10 then min = "0" .. min end
	if sec < 10 then sec = "0" .. sec end
	return min .. ":" .. sec
end
-- 以 小时:分钟:秒 形式格式化时间(秒)
function timeFormat_HMS(value)
	local hor = math.floor(value / 60 / 60)
	local min = math.floor((value - hor * 60 * 60) / 60)
	local sec = value - hor * 60 * 60 - min * 60

	if hor < 10 then hor = "0" .. hor end
	if min < 10 then min = "0" .. min end
	if sec < 10 then sec = "0" .. sec end
	return hor .. ":" .. min .. ":" .. sec
end
-- 以 天d 小时:分钟:秒 形式格式化时间(秒)
function timeFormat_DHMS(value)
	local day = math.floor(value / 60 / 60 / 24)

	value = value % (24 * 3600)

	local hor = math.floor(value / 60 / 60)
	local min = math.floor((value - hor * 60 * 60) / 60)
	local sec = value - hor * 60 * 60 - min*60

	if hor < 10 then hor = "0" .. hor end
	if min < 10 then min = "0" .. min end
	if sec < 10 then sec = "0" .. sec end
	
	if day > 0 then
		return string.format("%dd %s", day, hor .. ":" .. min .. ":" .. sec)
	else
		return hor .. ":" .. min .. ":" .. sec
	end
end
function timeFormat_Table(value)
    local tbTime = {}
    local day = math.floor(value / 60 / 60 / 24)
    value = value % (24 * 3600)
    local hour = math.floor(value / 60 / 60)
    local min = math.floor((value - hour * 60 * 60) / 60)
    local sec = value - hour * 60 * 60 - min*60
    tbTime.day = day
    tbTime.hour = hour
    tbTime.min = min
    tbTime.sec = sec
    return tbTime
end
--获取下一个周刷新时间（周一凌晨五点）
function GetNextWeekRefreshTime()
    local nCurTimeWithTimeZone = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local nCurTime = CS.ClientManager.Instance.serverTimeStamp
    
    local tbCurDate = os.date("!*t", nCurTimeWithTimeZone)
    local nCurWeekday = tbCurDate.wday
    nCurWeekday = (nCurWeekday == 1) and 7 or nCurWeekday - 1
    local nDays = 7 - nCurWeekday
    local nDailyRefreshOffsetHour = ConfigTable.GetConfigNumber("DailyRefreshOffsetHour")
    if tbCurDate.hour < nDailyRefreshOffsetHour then
        if nCurWeekday == 1 then
            nDays = 0
        else
            nDays = nDays + 1
        end
    end

    local nNextOpenTime = CS.ClientManager.Instance:GetNextRefreshTime(nCurTime)
    if nDays > 0 then
        for i = 1, nDays do
            nCurTime = nNextOpenTime
            nNextOpenTime = CS.ClientManager.Instance:GetNextRefreshTime(nCurTime)
        end
    end
    return nNextOpenTime
end
function FormatNum(num)
	if num <= 0 then
		return 0
	else
		local t1, t2 = math.modf(num)
		---小数如果为0，则去掉
		if t2 > 0 then
			return num
		else
			return t1
		end
	end
end
function FormatEffectValue(nValue,bPercent,nFormat)
    if bPercent then
        nValue = nValue * 100
    end
    if nValue == 0 and bPercent then
        return "0%"
    end
    local sValue
    if nFormat == GameEnum.ValueFormat.Int then
        nValue = math.floor(nValue)
        sValue = string.format("%d", nValue)
    elseif nFormat == GameEnum.ValueFormat.ODP then
        sValue = string.format("%.1f", nValue)
        sValue = sValue:gsub("0+$", "")
    elseif nFormat == GameEnum.ValueFormat.TDP then
        sValue = string.format("%.2f", nValue)
        sValue = sValue:gsub("0+$", "")
    end
    sValue = sValue:gsub("%.$", "")
    if bPercent then
        sValue = sValue .."%"
    end
    return sValue
end

function FormatWithCommas(nValue)
    local s, integer, decimal = tostring(nValue), "", ""
    local dot = string.find(s, "%.")

    if dot then
        integer = string.sub(s, 1, dot - 1)
        decimal = string.sub(s, dot + 1)
    else
        integer = s
    end

    integer = string.reverse(integer)
    integer = string.gsub(integer, "(%d%d%d)", "%1,")
    integer = string.reverse(integer)

    if string.sub(integer, 1, 1) == "," then
        integer = string.sub(integer, 2)
    end

    if decimal ~= "" then
        return integer .. "." .. decimal
    else
        return integer
    end
end
-- ========== Actor2D ==========
function indexOfPose(sPose)
    local tbCharPose = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
    "aa","ab","ac","ad","ae","af","ag","ah","ai","aj","ak","al","am","an","ao","ap","aq","ar","as","at","au","av","aw","ax","ay","az"}
    local nIdx = table.indexof(tbCharPose, sPose)
    if nIdx < 0 then nIdx = 0 end
    return nIdx
end
-- ========== Unity - Object ==========
function instantiate(...)
    return GameObject.Instantiate(...)
end
function destroy(obj)
    if not obj:IsNull() then
        GameObject.Destroy(obj)
    end
end
function destroyImmediate(obj)
    if not obj:IsNull() then
        GameObject.DestroyImmediate(obj)
    end
end
-- ========== Unity - Coroutine ==========
function luaCoroutineStart(runner, ...)
    return runner:StartCoroutine(util.cs_generator(...))
end
function luaCoroutineStop(runner, coroutine)
    runner:StopCoroutine(coroutine)
end
--function timerCoroutineStart(...)
--    return CSTimerManager.Instance:StartCoroutine(util.cs_generator(...))
--end
--function timerCoroutineStop(coroutine)
--    CSTimerManager.Instance:StopCoroutine(coroutine)
--end
-- ========== Unity - Transform ==========
-- 删除对象的child
function delChildren(go)
    if go.transform.childCount > 0 then
        for i=go.transform.childCount, 1, -1 do
            -- 这里需要减去1  因为下标获取的差异
            local obj = go.transform:GetChild(i - 1).gameObject
            destroy(obj)
        end
    end
end
-- ========== 名词表 ==========
function ProcContentWord(sContentWord, bUsePresetColor)
    if bUsePresetColor == nil then bUsePresetColor = false end
    local tbContent = string.split(sContentWord, "$")
    local sRetContent = tbContent[1]
    for i, v in ipairs(tbContent) do
        if i > 1 then
            local sHeadFourChar = string.sub(v, 1, 4) -- 固定长度为4位数的 id
            local nWordId = tonumber(sHeadFourChar)
            local sWord = nil
            if type(nWordId) == "number" then
                local data = ConfigTable.GetData("ContentWord", nWordId)
                if data ~= nil then sWord = data.Word end
            end
            if sWord == nil then
                sWord = "$" .. v
            else
                if bUsePresetColor == true then
                    local sColor = ConfigTable.GetData("ContentWord", nWordId).PresetColor or ""
                    if sColor ~= "" then sWord = string.format("<color=%s>%s</color>", sColor, sWord) end
                end
                sWord = string.gsub(v, sHeadFourChar, sWord)
            end
            sRetContent = sRetContent .. sWord
        end
    end
    return sRetContent
end
-- ========== 多语言 ==========
function GetLanguageIndex(sLan)
    for i, v in ipairs(AllEnum.LanguageInfo) do
        if v[1] == sLan then
            return i
        end
    end
    return 1
end
function GetLanguageByIndex(nIndex)
    local tbLanInfo = AllEnum.LanguageInfo[nIndex]
    if tbLanInfo ~= nil then
        return tbLanInfo[1]
    else
        return AllEnum.Language.CN
    end
end
function GetLanguageSurfixByIndex(nIndex)
    local tbLanInfo = AllEnum.LanguageInfo[nIndex]
    if tbLanInfo ~= nil then
        return tbLanInfo[3]
    else
        return "_cn"
    end
end
function GetAvgLuaRequireRoot(nIndex)
    local sFolderSurfix = GetLanguageSurfixByIndex(nIndex) .. "/"
    local sRootPath = "Game/UI/Avg/" .. sFolderSurfix -- Game/UI/Avg/_cn/
    if AVG_EDITOR == true and NovaAPI.IsRuntimeWindowsPlayer() == true then -- 在运行 AvgEditor.exe 时
        sRootPath = "/../../../../" .. sFolderSurfix -- /../../../../_cn/
    end
    return sRootPath
end
-- ========== AVG文本处理及性别矫正 ==========
function ProcAvgTextContent(sContent, nLanguageIndex)
    local nIndex = PlayerData.Base:GetPlayerSex() == true and 2 or 1 -- 1女 2男
    if nLanguageIndex == nil then
        nLanguageIndex = GetLanguageIndex(Settings.sCurrentTxtLanguage)
    end
    if nLanguageIndex < 1 or nLanguageIndex > #AllEnum.LanguageInfo then nLanguageIndex = 1 end
    -- a.替换名词，格式：$id$，其中 id 详见名词表 ContentWord.xlsx 。
    sContent = ProcContentWord(sContent, true)
    -- b.替换换行符
    sContent = string.gsub(sContent, "==RT==", "\n")
    -- c.替换玩家名
    sContent = string.gsub(sContent, "==PLAYER_NAME==", PlayerData.Base:GetPlayerNickName())
    -- d.替换性别称呼
    local AvgUIText = require (GetAvgLuaRequireRoot(nLanguageIndex) .. "Preset/AvgUIText")
    local mapSex = AvgUIText.SEX
    for k, v in pairs(mapSex) do
        sContent = string.gsub(sContent, k, v[nIndex])
    end
    -- e.替换忽略的内容（忽略翻译的文本中携带的标注内容）-- 2025.04.29弃用此临时处理方式，这是几百年前临时本地化需要的功能，现已完全不用了。
    -- sContent = string.gsub(sContent, "【.-】", "")
    return sContent
end
function ProcAvgTextContentFallback(sTextLan, sVoLan, bIsMale, sCN_F, sCN_M, sJP_F, sJP_M)
    --[[--五服定的对话文本 fallback 规则：
        (sCN_F中配女 sCN_M中配男 sJP_F日配女 sJP_M日配男)
        CN：日配男→日配女→中配男→中配女（默认）
        JP：日配男→日配女（默认）
        TW：中配男→中配女→日配男→日配女（默认）
        EN：中配男→中配女→日配男→日配女（默认）
        KR：中配男→中配女→日配男→日配女（默认）
    ]]
    if sCN_F == nil then sCN_F = "" end
    if sCN_M == nil then sCN_M = "" end
    if sJP_F == nil then sJP_F = "" end
    if sJP_M == nil then sJP_M = "" end
    local sContent = ""
    local tbFallback
    if sTextLan == AllEnum.Language.CN then
        tbFallback = {sCN_F}
        if bIsMale == true then table.insert(tbFallback, sCN_M) end -- 简中不会有男女差异文本。
        if sVoLan == AllEnum.Language.JP then
            table.insert(tbFallback, sJP_F)
            if bIsMale == true then table.insert(tbFallback, sJP_M) end -- 简中会有“日配”差异文本，但不会有“日配”男女差异文本。
        end
    elseif sTextLan == AllEnum.Language.JP then
        tbFallback = {sJP_F}
        if MULTI_LANGUAGE_GENDER_TEXT_COMPATIBLE == true and sJP_F == "" then table.insert(tbFallback, sCN_F) end -- 能兼容老数据，但容易让本地化同学晕头，最好将所有文本重新导入一下。
        if bIsMale == true then
            table.insert(tbFallback, sJP_M)
            if MULTI_LANGUAGE_GENDER_TEXT_COMPATIBLE == true and sJP_M == "" then table.insert(tbFallback, sCN_M) end -- 能兼容老数据，但容易让本地化同学晕头，最好将所有文本重新导入一下。
        end
    elseif sTextLan == AllEnum.Language.TW or sTextLan == AllEnum.Language.EN or sTextLan == AllEnum.Language.KR then
        tbFallback = {sJP_F}
        if bIsMale == true then table.insert(tbFallback, sJP_M) end
        if sVoLan == AllEnum.Language.CN then
            table.insert(tbFallback, sCN_F)
            if bIsMale == true then table.insert(tbFallback, sCN_M) end
        end
        if MULTI_LANGUAGE_GENDER_TEXT_COMPATIBLE == true and sVoLan == AllEnum.Language.JP and sJP_F == "" and sJP_M == "" then -- 能兼容老数据，但容易让本地化同学晕头，最好将所有文本重新导入一下。
            table.insert(tbFallback, sCN_F)
            if bIsMale == true then table.insert(tbFallback, sCN_M) end
        end
    end
    if type(tbFallback) == "table" then
        local n = #tbFallback
        for i = n, 1, -1 do
            local s = tbFallback[i]
            if type(s) == "string" and s ~= "" then
                sContent = s
                break
            end
        end
    end
    return sContent
end
function AdjustMainRoleAvgCharId(sAvgCharId)
    if sAvgCharId == nil then sAvgCharId = "avg3_100" end
    local tbMainRoleAvgCharId = {"avg3_100", "avg3_101"}
    local nIdx = table.indexof(tbMainRoleAvgCharId, sAvgCharId)
    if nIdx > 0 then -- 按性别矫正一下主角id
        local nIndex = PlayerData.Base:GetPlayerSex() == true and 2 or 1 -- 1女 2男
        return tbMainRoleAvgCharId[nIndex]
    else
        return sAvgCharId
    end
end
function CalcTextAnimDuration(sContent, nLanguageIndex, bIsBB)
    local tbInterval = { 0.03, 0.03, 0.03, 0.01, 0.03 } -- CN TW JP EN 对话内容逐字显示时，前后两字间隔时长（秒）。
    local tbIntervalForBB = { 0.25, 0.25, 0.25, 0.083, 0.25 } -- CN TW JP EN 对话内容逐字显示时，前后两字间隔时长（秒）。
    local nInterval = bIsBB == true and tbIntervalForBB[nLanguageIndex] or tbInterval[nLanguageIndex]
    if nInterval == nil then nInterval = bIsBB == true and tbIntervalForBB[1] or tbInterval[1] end
    local sPureContent = string.gsub(sContent, "<.->", "")
    sPureContent = string.gsub(sPureContent, "\n", "")
    local nDuration = string.utf8len(sPureContent) * nInterval
    return nDuration
end
function Avg_ProcRes_M_F(sName)
    local nLen = string.len(sName)
    local surfix = string.sub(sName, nLen - 2, nLen)
    if surfix == "_MP" or surfix == "_FP" then
        if PlayerData.Base:GetPlayerSex() == true then
            surfix = "_MP" -- 男
        else
            surfix = "_FP" -- 女
        end
        sName = string.sub(sName, 1, nLen - 3) .. surfix
        return sName
    else
        return sName
    end
end
function Avg_ProcEnquotes(s)
    s = string.gsub(s, "\\", "")
    s = string.gsub(s, "'", "\\'")
    s = string.gsub(s, '"', '\\"')
    return s
end
-- ========== json ==========
function decodeJson(sJson)
    local tbData = {}
    if type(sJson) == "string" and sJson ~= "" then
        tbData = rapidjson.decode(sJson)
        if tbData == nil then
            tbData = {}
            printError("json文本配置格式有误，该文本为：" .. sJson)
        end
    end
    return tbData
end

---判断string是否以start开头 startwith
function IsStartsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

--将utf8字符转换为unicode编码格式对应的十进制数值
function UFT8ToUnicode(convertStr)
    if type(convertStr) ~= "string" then
        return convertStr
    end
    local resultDec = 0
    local i = 1
    local num1 = string.byte(convertStr, i)
    if num1 ~= nil then
        local tempVar1, tempVar2 = 0, 0
        if num1 >= 0x00 and num1 <= 0x7f then
            tempVar1 = num1
            tempVar2 = 0
        elseif num1 & 0xe0 == 0xc0 then
            local t1 = 0
            local t2 = 0
            t1 = num1 & 0xff >> 3
            i = i + 1
            num1 = string.byte(convertStr, i)
            t2 = num1 & 0xff >> 2
            tempVar1 = t2 | ((t1 & (0xff >> 6)) << 6)
            tempVar2 = t1 >> 2
        elseif num1 & 0xf0 == 0xe0 then
            local t1 = 0
            local t2 = 0
            local t3 = 0
            t1 = num1 & (0xff >> 3)
            i = i + 1
            num1 = string.byte(convertStr, i)
            t2 = num1 & (0xff >> 2)
            i = i + 1
            num1 = string.byte(convertStr, i)
            t3 = num1 & (0xff >> 2)
            tempVar1 = ((t2 & (0xff >> 6)) << 6) | t3
            tempVar2 = (t1 << 4) | (t2 >> 2)
        end
        resultDec = tempVar2 * 256 + tempVar1
    end
    return resultDec
end
-- ========== decode change info ==========
local function DecodeChangeInfo(mapChangeInfo)
    local mapDecodedChangeInfo = {}
    if type(mapChangeInfo) ~= "table" then
        return mapDecodedChangeInfo
    end
    if mapChangeInfo.Props == nil then
        return mapDecodedChangeInfo
    end
    for nIndex, mapGoogleProtobufAny in ipairs(mapChangeInfo.Props) do
        if mapGoogleProtobufAny.type_url == "" or mapGoogleProtobufAny.type_url == nil then
            printError("ChangeInfo 格式错误")
            return mapDecodedChangeInfo
        end
        local tbSubUrl = string.split(mapGoogleProtobufAny.type_url, "/")
        local sProtoMsgName = tbSubUrl[2]
        local mapDecodedData = PB.decode(sProtoMsgName, mapGoogleProtobufAny.value)
        if mapDecodedChangeInfo[sProtoMsgName] == nil then
            mapDecodedChangeInfo[sProtoMsgName] = {}
        end
        table.insert(mapDecodedChangeInfo[sProtoMsgName], mapDecodedData)
    end
    return mapDecodedChangeInfo
end

-- 根据ChangeInfo解析的获得展示流程
local function OpenReceiveByChangeInfo(mapChangeInfo, callback, sTip)
    local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapChangeInfo)
    UTILS.OpenReceiveByReward(mapReward, callback, sTip)
end

-- 根据服务器下发的展示字段或表内奖励字段解析的获得展示流程
local function OpenReceiveByDisplayItem(tbItem, mapChangeInfo, callback, sTip, nTitleType)
    local mapTrans = PlayerData.Item:ProcessTransChangeInfo(mapChangeInfo)
    local tbReward, tbSpReward = PlayerData.Item:ProcessRewardDisplayItem(tbItem, mapTrans)
    local mapReward = {
        tbReward = tbReward,
        tbSpReward = tbSpReward,
        tbSrc = mapTrans.tbSrc,
        tbDst = mapTrans.tbDst
    }
    UTILS.OpenReceiveByReward(mapReward, callback, sTip, nTitleType)
end

-- 根据处理之后普通道具和特殊道具，获得展示流程
local function OpenReceiveByReward(mapReward, callback, sTip, nTitleType)
    local bOverflow = PlayerData.State:GetMailOverflow()

    local function open_mail()
        if bOverflow then
            EventManager.Hit(EventId.OpenMessageBox, {
                nType = AllEnum.MessageBox.Alert,
                sContent = ConfigTable.GetUIText("Mail_Overflow_Tip"),
                callbackConfirm = callback
            })
            PlayerData.State:SetMailOverflow(false)
        else
            if callback then callback() end
        end
    end

    local function open_trans()
        local tbSrc, tbDst = {}, {}

        local mapOverTrans = PlayerData.Item:GetFragmentsOverflow()
        if mapOverTrans and mapOverTrans.tbSrc and #mapOverTrans.tbSrc > 0 then
            for _, v in ipairs(mapOverTrans.tbSrc) do
                table.insert(tbSrc, v)
            end
            for _, v in ipairs(mapOverTrans.tbDst) do
                table.insert(tbDst, v)
            end
        end

        if mapReward and mapReward.tbSrc and #mapReward.tbSrc > 0 then
            for _, v in ipairs(mapReward.tbSrc) do
                table.insert(tbSrc, v)
            end
            for _, v in ipairs(mapReward.tbDst) do
                table.insert(tbDst, v)
            end
        end

        if #tbDst > 0 and #tbSrc > 0 then
            EventManager.Hit(EventId.OpenPanel, PanelId.ReceiveAutoTrans, tbSrc, tbDst, open_mail)
        else
            open_mail()
        end
    end

    local function open_normal()
        if mapReward and mapReward.tbReward and #mapReward.tbReward > 0 then
            EventManager.Hit(EventId.OpenPanel, PanelId.ReceivePropsTips, mapReward.tbReward, open_trans, sTip, nTitleType)
        else
            open_trans()
        end
    end

    if mapReward and mapReward.tbSpReward and #mapReward.tbSpReward > 0 then
        EventManager.Hit(EventId.OpenPanel, PanelId.ReceiveSpecialReward, mapReward.tbSpReward, open_normal)
    else
        open_normal()
    end
end
-- ========== Debugger ==========
local debuggee = nil
function startDebugger (ip, port)
    if Settings.ENABLE_DEBUGGER then
        local config = {}
        config.controllerHost = ip
        config.controllerPort = port
        local startResult, breakerType = debuggee.start(rapidjson, config)
        print('debuggee start ->', startResult, breakerType)
        if startResult then
            --luaCoroutineStart(NovaAPI.GetLuaObject(), function()
            --    while true do
            --        debuggee.poll()
            --        coroutine.yield(nil)
            --    end
            --end)
        end
        return startResult
    else
        return false
    end
end
if Settings.ENABLE_DEBUGGER then
    debuggee = require "vscode-debuggee"
    startDebugger("localhost", 56789)
end

-- ========== String ==========
local strLengthConfig = {
    {tbRange = {{0x2E80, 0x2FDF}, {0x3400, 0x4dbf}, {0x4E00, 0x9FFF}}, sType = "中文", nCount = 2},
    {tbRange = {{0x1100, 0x11FF}, {0x3130, 0x318F}, {0xAC00, 0xD7AF}}, sType = "韩文", nCount = 2},
    {tbRange = {{0x3040, 0x30FF}, {0x31F0, 0x31FF}}, sType = "日文", nCount = 2},
    {tbRange = {{0xFF00, 0xFFEF}}, sType = "全角符号", nCount = 2},
}


local function GetParamStrLen(sParam)
    --去掉富文本标签
    sParam = string.gsub(sParam, "</?[^>]+>", "")
    local nLength = 0
    local nIndex = 1
    while true do
        local curByte = string.byte(sParam, nIndex)
        local byteCount = 1
        if curByte > 239 then
            byteCount = 4  -- 4字节字符
        elseif curByte > 223 then
            byteCount = 3  -- 汉字
        elseif curByte > 128 then
            byteCount = 2  -- 双字节字符
        elseif curByte == 10 then
            byteCount = 1  -- 单字节字符
        else
            byteCount = 1  -- 单字节字符
        end

        local subStr = string.sub(sParam, nIndex, nIndex + byteCount - 1)
        local charUnicodeNum = UFT8ToUnicode(subStr)
        local bContains = false
        local nAddCount = 1
        for _, v in ipairs(strLengthConfig) do
            local tbRange = v.tbRange
            for _, range in ipairs(tbRange) do
                if charUnicodeNum >= range[1] and charUnicodeNum <= range[2] then
                    bContains = true
                    nAddCount = v.nCount
                    break
                end
            end
            if bContains then
                break
            end
        end

        nLength = nLength + nAddCount
        nIndex = nIndex + byteCount
        if nIndex > #sParam then
            break
        end
    end
    return nLength
end

-- 处理服务器下发的存Byte的字符串
local function ParseByteString(sByte)
    return {string.byte(sByte, 1, -1)}
end
-- 求某索引nIndex在处理后的Byte数组中是否被设置
local function IsBitSet(tbByte, nIndex)
    local nGroup64 = math.ceil(nIndex / 64) - 1
    local nIndexInGroup64 = nIndex - nGroup64 * 64
    local nGroup8 = math.ceil(nIndexInGroup64 / 8) - 1
    local nIndexInGroup8 = nIndexInGroup64 - nGroup8 * 8
    local nByteTableIndex = 8 - nGroup8 + nGroup64 * 8

    if not tbByte[nByteTableIndex] then
        return false
    end
    return ((1 << (nIndexInGroup8 - 1)) & tbByte[nByteTableIndex]) > 0
end

local function GetBuildAttributeId(nGroupId,nLevel)
    return nGroupId * 100000 + nLevel
end
---获取角色attribute表id--
local function GetCharacterAttributeId(nCharId,nAdvance,nLevel)
    return nCharId * 100000 + nAdvance * 1000 + nLevel
end
---获取星盘attribute表id--
local function GetDiscAttributeId(nGroupId,nPhase,nLevel)
    return nGroupId * 1000 + nPhase * 100 + nLevel
end
local function GetDiscExtraAttributeId(nGroupId,nStar)
    return nGroupId * 10 + nStar
end

local function GetPotentialId(nCharId, nIndex)
    return 500000 + nCharId * 100 + nIndex
end

local function ParseNoBrokenDesc(sDesc)
    if Settings.sCurrentTxtLanguage == AllEnum.Language.EN or Settings.sCurrentTxtLanguage == AllEnum.Language.KR then
        return sDesc -- 英文和韩文句子内有空格，不需要整句
    else
        return "<nobr>" .. sDesc .. "</nobr>"
    end
end

--处理描述文字 等级为当前描述类别等级 比如角色技能就传角色技能等级 已和策划确认不会出现不同等级来源
local function SubDesc(str,nLevel,nCompareLevel,mapLinkParam)
    local ConfigData = require "GameCore.Data.ConfigData"
    local function SubDescLink(originStr,mapParam) -- 处理：词条超链
        if originStr == nil or originStr == "" then return "" end
        local mapWord = {}
        for word in string.gmatch(originStr, "##.-#%d%d%d%d#") do
            if mapWord[word] == nil then
                local sWordId = string.match(word,"%d%d%d%d")
                local nWordId = tonumber(sWordId)
                if nWordId == nil then
                    printError("词条 id 错误:" .. sWordId)
                    mapWord[word] = sWordId
                else
                    local mapWordData = ConfigTable.GetData("Word", nWordId)
                    if mapWordData == nil or mapWordData.Icon == "" then
                        printError("该词条 id 找不到数据:" .. sWordId)
                        if mapWordData and mapWordData.Icon == "" then
                            printError("该词条 id 找不到Icon:" .. sWordId)
                        end
                        mapWord[word] = string.format("<color=#FF0000>%s</color>", sWordId)
                    else
                        if mapWordData.Type == GameEnum.wordLinkType.Word then
                            --mapWord[word] = string.format("<color=#%s><link=\"%d\"><sprite=%d>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Icon, mapWordData.Title)
                            mapWord[word] = string.format("<color=#%s><link=\"%d\"><u>%s</u>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Title,mapWordData.TitleIcon)
                        elseif mapWordData.Type == GameEnum.wordLinkType.Potential then
                            if mapParam == nil or mapParam.nCharId == nil then
                                printError("该<潜能>词条 id 找不到角色:" .. sWordId)
                                mapWord[word] = string.format("<color=#FF0000>%s</color>", sWordId)
                            else
                                local nPotentialId = GetPotentialId(mapParam.nCharId, tonumber(mapWordData.Param1))
                                local mapItemCfg = ConfigTable.GetData_Item(nPotentialId)
                                local sTitle = mapItemCfg and mapItemCfg.Title or mapWordData.Title
                                --mapWord[word] = string.format("<color=#%s><link=\"%d\"><sprite=%d>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Icon, sTitle)
                                mapWord[word] = string.format("<color=#%s><link=\"%d\"><u>%s</u></link></color>", mapWordData.Color, mapWordData.Id, sTitle)
                            end
                        end
                    end
                end
            end
        end
        for word, finalStr in pairs(mapWord) do
            originStr = string.gsub(originStr, word, finalStr)
        end
        return originStr
    end
    local function ParseHitDamageDesc(nHitDamageId, nHitDamageLevel)
        local mapDamage = ConfigTable.GetData_HitDamage(nHitDamageId)
        if not mapDamage then
            return string.format("<color=#BD3059>该 hit damage id 找不到数据:%s</color>", nHitDamageId) -- 红色：此 id 找不到数据
        end
        local nPercent = mapDamage.SkillPercentAmend[nHitDamageLevel]
        local nAbs = mapDamage.SkillAbsAmend[nHitDamageLevel]
        if not nPercent or not nAbs then
            return string.format("<color=#BD3059>该技能等级在 HitDamage 表中找不到数据, hit damage id:%d, level:%d</color>", nHitDamageId, nHitDamageLevel)
        end

        nPercent = nPercent * ConfigData.IntFloatPrecision
        nPercent = FormatNum(nPercent)
        nAbs = FormatNum(nAbs)
        local sPercent = nPercent == 0 and "" or tostring(nPercent) .. "%%"
        local sAbs = nAbs == 0 and "" or tostring(nAbs)
        if nPercent ~= 0 and nAbs ~= 0 then
            return sPercent .. "+" .. sAbs
        else
            return sPercent .. sAbs
        end
    end
    local function GetValueKey(nDataId, nType, nValueLevel)
        local ret = nDataId
        if nType == GameEnum.levelTypeData.Exclusive or nType == GameEnum.levelTypeData.SkillSlot then
            ret = nDataId + nValueLevel * 10
        elseif nType == GameEnum.levelTypeData.OutfitPromote then
        elseif nType == GameEnum.levelTypeData.OutfifBreak then
        else
        end
        return ret
    end
    local function ParseEffectDesc(nEffectId, nEffectLevel,nShowType)
        local mapEffectCfgData = ConfigTable.GetData_Effect(nEffectId)
        if mapEffectCfgData == nil then
            return string.format("<color=#BD3059>该EffectId找不到数据:%s</color>", nEffectId) -- 红色：此 id 找不到数据
        end
        local nValueKey = GetValueKey(nEffectId,mapEffectCfgData.levelTypeData,nEffectLevel)
        local mapEffectValueData = ConfigTable.GetData("EffectValue", nValueKey)
        if mapEffectValueData == nil then
            return string.format("<color=#BD3059>该EffectId和等级找不到Value数据:%s，%s</color>", nEffectId,nEffectLevel) -- 红色：此 id 找不到数据
        end
        local sValue = mapEffectValueData.EffectTypeParam1
        local nValue = tonumber(sValue)
        if nValue == nil then
            return string.format("<color=#BD3059>该EffectValueId配置的数据不支持显示:%s</color>", nValueKey)
        end
        nValue = math.abs(nValue)
        if nShowType == 1 then
            nValue = nValue * 100
            return nValue .. "%%"
        end
        return tostring(nValue)
    end
    local function ParseOnceDesc(nOnceId, nOnceLevel,nShowType)
        local mapCfgData = ConfigTable.GetData("OnceAdditionalAttribute", nOnceId)
        if mapCfgData == nil then
            return string.format("<color=#BD3059>该OnceAdditionalAttributeId找不到数据:%s</color>", nOnceId) -- 红色：此 id 找不到数据
        end
        local nValueKey = GetValueKey(nOnceId,mapCfgData.levelTypeData,nOnceLevel)
        local mapValueData = ConfigTable.GetData("OnceAdditionalAttributeValue", nValueKey)
        if mapValueData == nil then
            return string.format("<color=#BD3059>该OnceAdditionalAttributeId和等级找不到Value数据:%s，%s，%s</color>", nOnceId,nOnceLevel,nValueKey) -- 红色：此 id 找不到数据
        end
        local nValue = mapValueData.Value1 * ConfigData.IntFloatPrecision
        nValue = math.abs(nValue)
        if nShowType == 1 then
            nValue = nValue * 100
            return nValue .. "%%"
        end
        return tostring(nValue)
    end
    local function ParseShieldDesc(nShieldId, nShieldLevel,nShowType)
        local mapCfgData = ConfigTable.GetData("Shield", nShieldId)
        if mapCfgData == nil then
            return string.format("<color=#BD3059>该ShieldId找不到数据:%s</color>", nShieldId) -- 红色：此 id 找不到数据
        end
        local nValueKey = GetValueKey(nShieldId,mapCfgData.levelTypeData,nShieldLevel)
        local mapValueData = ConfigTable.GetData("ShieldValue", nValueKey)
        if mapValueData == nil then
            return string.format("<color=#BD3059>该ShieldId和等级找不到Value数据:%s，%s</color>", nShieldId,nShieldLevel) -- 红色：此 id 找不到数据
        end
        local nValue = mapValueData.ReferenceScale
        nValue = nValue * ConfigData.IntFloatPrecision
        nValue = math.abs(nValue)
        if nShowType == 1 then
            nValue = nValue * 100
            return nValue .. "%%"
        end
        return tostring(nValue)
    end
    local function ParseSriptDesc(nSriptId, nSriptLevel,nShowType)
        local mapCfgData = ConfigTable.GetData("ScriptParameter", nSriptId)
        if mapCfgData == nil then
            return string.format("<color=#BD3059>该SriptId找不到数据:%s</color>", nSriptId) -- 红色：此 id 找不到数据
        end
        local nValueKey = GetValueKey(nSriptId,mapCfgData.levelTypeData,nSriptLevel)
        local mapValueData = ConfigTable.GetData("ScriptParameterValue", nValueKey)
        if mapValueData == nil then
            return string.format("<color=#BD3059>该SriptId和等级找不到Value数据:%s，%s</color>", nSriptId,nSriptLevel) -- 红色：此 id 找不到数据
        end
        local nValue = mapValueData.CommonData
        nValue = nValue * ConfigData.IntFloatPrecision
        nValue = math.abs(nValue)
        if nShowType == 1 then
            nValue = nValue * 100
            return nValue .. "%%"
        end
        return tostring(nValue)
    end
    local linkStr = SubDescLink(str, mapLinkParam)
    if nLevel == nil then
        return linkStr
    end
    local mapWord = {}
    for word in string.gmatch(linkStr, "&.-&") do
        local paramStr = string.gsub(word,"&","")
        print(paramStr)
        local tbParam = string.split(paramStr,",")
        local sTable    = tbParam[1]
        local sKey      = tbParam[2]
        local sShowType = tbParam[3]
        local nShowType = tonumber(sShowType)
        if nShowType == nil then
            nShowType = 0
        end
        if sTable == nil or sKey == nil then
            mapWord[word] = string.format("<color=#BD3059>配置错误，无法读取对应表名和ID：%s</color>",word)
        else
            local nKey = tonumber(sKey)
            if nKey == nil then
                mapWord[word] = string.format("<color=#BD3059>表ID配置错误，无法转为number：%s</color>",word)
            else
                if sTable == "HitDamage" then
                    local subStr = ParseHitDamageDesc(nKey, nLevel)
                    if nCompareLevel ~= nil then
                        local sCompareStr = ParseHitDamageDesc(nKey, nCompareLevel)
                        subStr = string.format( "%s<color=#8cac59>(%s↑)</color>",subStr,sCompareStr)
                    end
                    mapWord[word] = subStr
                elseif sTable == "Effect" then
                    local subStr = ParseEffectDesc(nKey, nLevel,nShowType)
                    if nCompareLevel ~= nil then
                        local sCompareStr = ParseEffectDesc(nKey, nCompareLevel,nShowType)
                        subStr = string.format( "%s<color=#8cac59>(%s↑)</color>",subStr,sCompareStr)
                    end
                    mapWord[word] = subStr
                elseif sTable == "Once" then
                    local subStr = ParseOnceDesc(nKey, nLevel,nShowType)
                    if nCompareLevel ~= nil then
                        local sCompareStr = ParseOnceDesc(nKey, nCompareLevel,nShowType)
                        subStr = string.format( "%s<color=#8cac59>(%s↑)</color>",subStr,sCompareStr)
                    end
                    mapWord[word] = subStr
                elseif sTable == "Shield" then
                    local subStr = ParseShieldDesc(nKey, nLevel,nShowType)
                    if nCompareLevel ~= nil then
                        local sCompareStr = ParseShieldDesc(nKey, nCompareLevel,nShowType)
                        subStr = string.format( "%s<color=#8cac59>(%s↑)</color>",subStr,sCompareStr)
                    end
                    mapWord[word] = subStr
                elseif sTable == "Script" then
                    local subStr = ParseSriptDesc(nKey, nLevel,nShowType)
                    if nCompareLevel ~= nil then
                        local sCompareStr = ParseSriptDesc(nKey, nCompareLevel,nShowType)
                        subStr = string.format( "%s<color=#8cac59>(%s↑)</color>",subStr,sCompareStr)
                    end
                    mapWord[word] = subStr
                else
                    mapWord[word] = string.format("<color=#BD3059>未支持的表名：%s</color>",word)
                end
            end
        end
    end
    for word, finalStr in pairs(mapWord) do
        linkStr = string.gsub(linkStr, word, finalStr)
    end
    return ParseNoBrokenDesc(linkStr)
end

--nOverrideLevel 仅对潜能和音符等级生效   2025.5.10 否则会覆盖所有等级导致显示错误
--bSimple  简略描述（目前只有潜能卡会有这个配置）
local function ParseDesc(mapDescConfig, nCompareLevelType, nCompareLevel, bSimple, nOverrideLevel, mapLinkParam)
    if mapDescConfig == nil then
        printError("解析描述失败!")
        return ""
    end
    local ConfigData = require "GameCore.Data.ConfigData"
    local str = bSimple and mapDescConfig.BriefDesc or mapDescConfig.Desc
    local function SubDescLink(originStr, mapParam) -- 处理：词条超链
        if originStr == nil or originStr == "" then return "" end
        local mapWord = {}
        for word in string.gmatch(originStr, "##.-#%d%d%d%d#") do
            if mapWord[word] == nil then
                local sWordId = string.match(word,"%d%d%d%d")
                local nWordId = tonumber(sWordId)
                if nWordId == nil then
                    printError("词条 id 错误:" .. sWordId)
                    mapWord[word] = sWordId
                else
                    local mapWordData = ConfigTable.GetData("Word", nWordId)
                    if mapWordData == nil or mapWordData.Icon == "" then
                        printError("该词条 id 找不到数据:" .. sWordId)
                        if mapWordData and mapWordData.Icon == "" then
                            printError("该词条 id 找不到Icon:" .. sWordId)
                        end
                        mapWord[word] = string.format("<color=#FF0000>%s</color>", sWordId)
                    else
                        if mapWordData.Type == GameEnum.wordLinkType.Word then
                            --mapWord[word] = string.format("<color=#%s><link=\"%d\"><sprite=%d>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Icon, mapWordData.Title)
                            mapWord[word] = string.format("<color=#%s><link=\"%d\"><u>%s</u>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Title,mapWordData.TitleIcon)
                        elseif mapWordData.Type == GameEnum.wordLinkType.Potential then
                            if mapParam == nil or mapParam.nCharId == nil then
                                printError("该<潜能>词条 id 找不到角色:" .. sWordId)
                                mapWord[word] = string.format("<color=#FF0000>%s</color>", sWordId)
                            else
                                local nPotentialId = GetPotentialId(mapParam.nCharId, tonumber(mapWordData.Param1))
                                local mapItemCfg = ConfigTable.GetData_Item(nPotentialId)
                                local sTitle = mapItemCfg and mapItemCfg.Title or mapWordData.Title
                                --mapWord[word] = string.format("<color=#%s><link=\"%d\"><sprite=%d>%s</link></color>", mapWordData.Color, mapWordData.Id, mapWordData.Icon, sTitle)
                                mapWord[word] = string.format("<color=#%s><link=\"%d\"><u>%s</u></link></color>", mapWordData.Color, mapWordData.Id, sTitle)
                            end
                        end
                    end
                end
            end
        end
        for word, finalStr in pairs(mapWord) do
            originStr = string.gsub(originStr, word, finalStr)
        end
        return originStr
    end
    local linkStr = SubDescLink(str, mapLinkParam)
    local function ParseHitDamageDesc(nHitDamageId, nHitDamageLevel)
        local sDesc = ""
        local mapDamage = ConfigTable.GetData_HitDamage(nHitDamageId)
        if not mapDamage then
            sDesc = string.format("<color=#BD3059>该 hit damage id 找不到数据:%s</color>", nHitDamageId) -- 红色：此 id 找不到数据
            return sDesc
        end
        local levelType = mapDamage.levelTypeData
        if levelType == GameEnum.levelTypeData.BreakCount then
            nHitDamageLevel = nHitDamageLevel < 1 and 1 or nHitDamageLevel -- 原为 nHitDamageLevel + 1 现修改为最小为1
        elseif levelType == GameEnum.levelTypeData.None then
            nHitDamageLevel = 1
        end
        local nPercent = mapDamage.SkillPercentAmend[nHitDamageLevel]
        local nAbs = mapDamage.SkillAbsAmend[nHitDamageLevel]
        if not nPercent or not nAbs then
            sDesc = string.format("<color=#BD3059>该技能等级在 HitDamage 表中找不到数据, hit damage id:%d, level:%d</color>", nHitDamageId, nHitDamageLevel)
            return sDesc
        end

        nPercent = nPercent * ConfigData.IntFloatPrecision
        nPercent = FormatNum(nPercent)
        nAbs = FormatNum(nAbs)
        local sPercent = nPercent == 0 and "" or tostring(nPercent) .. "%%"
        local sAbs = nAbs == 0 and "" or tostring(nAbs)
        if nPercent ~= 0 and nAbs ~= 0 then
            sDesc = sPercent .. "+" .. sAbs
        else
            sDesc = sPercent .. sAbs
        end
        return sDesc -- 例：15%+100 或 15% 或 100
    end
    local function FormatValueShow(sValue, sShowType, sEnumType)
        if sShowType == "Text" then
            return sValue
        elseif sShowType == "Enum" then
            sEnumType = tostring(sEnumType)
            if sEnumType ~= nil then
                local tbEnum = CacheTable.GetData("_EnumDesc", sEnumType)
                if tbEnum ~= nil then
                    local nEnumValue = tonumber(sValue)
                    if nEnumValue ~= nil then
                        if tbEnum[nEnumValue] then
                            return ConfigTable.GetUIText(tbEnum[nEnumValue])
                        else
                            printError(sEnumType .. "枚举未找到值:" .. nEnumValue)
                            return nil
                        end
                    else
                        printError("枚举值填写错误:" .. sValue)
                        return nil
                    end
                else
                    printError("枚举类型填写错误:" .. sEnumType)
                    return nil
                end
            else
                printError("枚举类型未填写")
                return nil
            end
        else
            local nValue = tonumber(sValue)
            if nValue ~= nil then
                local isIntFloat = sShowType == "10K" or sShowType == "10KPct" or sShowType == "10KHdPct" -- IntFloat类型
                local isPercent = sShowType == "Pct" or sShowType == "HdPct" or sShowType == "10KPct" or sShowType == "10KHdPct" -- 百分比类型添加百分号
                local multiHundred = sShowType == "HdPct" or sShowType == "10KHdPct" -- 乘100显示
                nValue = isIntFloat and nValue * ConfigData.IntFloatPrecision or nValue
                nValue = multiHundred and nValue * 100 or nValue
                nValue = math.abs(nValue)
                nValue = clearFloat(nValue)
                local integer, decimal = math.modf(nValue)
                sValue = decimal < 0.01 and tostring(integer) or tostring(nValue) -- 小数为0时不显示小数位(注:取小数时概率出现无限趋近于0但大于0的值,故此处小于0.01的小数忽略,视为整数)
                sValue = isPercent and sValue .. "%%" or sValue
                return sValue
            else
                return nil
            end
        end
    end
    local function ParseLevelUpDesc(sTable, nId, nLevel, sParameter, sShowType, sEnumType)
        local function GetValueKey(nDataId, nType, nValueLevel)
            return nDataId + nValueLevel * 10
        end
        local sDesc = nil
        local sErrorInfo = nil
        local mapCfgData = DataTable[sTable]
        if mapCfgData ~= nil then
            local sValueTable = sTable .. "Value" -- 配置表对应的Value表
            local mapValueCfgData = DataTable[sValueTable]
            if mapValueCfgData ~= nil then
                local mapData = mapCfgData[nId]
                if mapData ~= nil then
                    local nValueId = GetValueKey(nId, mapData.levelTypeData, nLevel)
                    local mapValueData = mapValueCfgData[nValueId]
                    if mapValueData ~= nil then
                        local sValue = mapValueData[sParameter]
                        if sValue ~= nil then
                            sDesc = FormatValueShow(sValue, sShowType, sEnumType)
                            if sDesc == nil then
                                sErrorInfo = string.format("<color=#BD3059>%s表中该ValueId配置的数据解析失败:%s</color>", sValueTable, nValueId)
                            end
                        else
                            sErrorInfo = string.format("<color=#BD3059>%s表中没有该字段:%s</color>", sValueTable, sParameter) -- 红色：没有该字段
                        end
                    else
                        sErrorInfo = string.format("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sValueTable, nValueId) -- 红色：此id找不到数据
                    end
                else
                    sErrorInfo = string.format("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sTable, nId) -- 红色：此id找不到数据
                end
            else
                sErrorInfo = string.format("<color=#BD3059>找不到该配置表:%s</color>", sValueTable) -- 红色：找不到配置表
            end
        else
            sErrorInfo = string.format("<color=#BD3059>找不到该配置表:%s</color>", sTable) -- 红色：找不到配置表
        end

        if sErrorInfo ~= nil and sErrorInfo ~= "" then
            printError(sErrorInfo)
            sDesc = sErrorInfo
        end

        if sDesc == nil then
            printError("描述解析失败")
            sDesc = ""
        end

        return sDesc
    end
    local function ParseNoLevelUpDesc(sTable, nId, sParameter, sShowType, sEnumType)
        local sDesc = nil
        local sErrorInfo = nil
        local mapCfgData = DataTable[sTable]
        if mapCfgData ~= nil then
            local mapData = mapCfgData[nId]
            if mapData ~= nil then
                local sValue = mapData[sParameter]
                if sValue ~= nil then
                    sDesc = FormatValueShow(sValue, sShowType, sEnumType)
                    if sDesc == nil then
                        sErrorInfo = string.format("<color=#BD3059>%s表中该Id配置的数据解析失败:%s</color>", sTable, nId)
                    end
                else
                    sErrorInfo = string.format("<color=#BD3059>%s表中没有该字段:%s</color>", sTable, sParameter) -- 红色：没有该字段
                end
            else
                sErrorInfo = string.format("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sTable, nId) -- 红色：此id找不到数据
            end
        else
            sErrorInfo = string.format("<color=#BD3059>找不到该配置表:%s</color>", sTable) -- 红色：找不到配置表
        end

        if sErrorInfo ~= nil and sErrorInfo ~= "" then
            printError(sErrorInfo)
            sDesc = sErrorInfo
        end

        if sDesc == nil then
            printError("描述解析失败")
            sDesc = ""
        end

        return sDesc
    end
    local mapWord = {}
    for word in string.gmatch(linkStr, "&.-&") do
        local sParameterKey = string.gsub(word,"&","")
        local paramStr = mapDescConfig[sParameterKey]
        local tbParam = string.split(paramStr,",")
        local sTable     = tbParam[1] -- 表名
        local sParseType = tbParam[2] -- 解析类型
        local sKey       = tbParam[3] -- Id
        local sParameter = tbParam[4] -- 参数名
        local sShowType  = tbParam[5] -- 显示类型
        local sEnumType  = tbParam[6] -- 枚举类型(显示类型为枚举时使用)
        if sTable == nil or sKey == nil then
            mapWord[word] = string.format("<color=#BD3059>配置错误，无法读取对应表名和ID：%s</color>", word)
        else
            local mapCfgData = DataTable[sTable]
            if mapCfgData ~= nil then
                local nKey = tonumber(sKey)
                if nKey == nil then
                    mapWord[word] = string.format("<color=#BD3059>表ID配置错误，无法转为number：%s</color>", word)
                else
                    local mapData = mapCfgData[nKey]
                    if mapData ~= nil then
                        local nLevel = 1
                        nOverrideLevel = tonumber(nOverrideLevel)
                        if mapData.levelTypeData == GameEnum.levelTypeData.Exclusive then -- 潜能等级通过潜能Id查询
                            nLevel = UTILS.QueryLevelInfo(mapData.LevelData, mapData.levelTypeData, mapData.LevelData)
                        else -- 非潜能等级通过角色Id及额外参数查询
                            local nCharId = tonumber(string.sub(sKey, 1, 3))
                            nLevel = UTILS.QueryLevelInfo(nCharId, mapData.levelTypeData, mapData.LevelData, mapData.MainOrSupport)
                        end
                        if mapData.levelTypeData == GameEnum.levelTypeData.Exclusive or mapData.levelTypeData == GameEnum.levelTypeData.Note then
                            if nOverrideLevel ~= nil then
                                nLevel = nOverrideLevel
                            end
                        end
                        if sParseType == "DamageNum" and sTable == "HitDamage" then
                            local subStr = ParseHitDamageDesc(nKey, nLevel)
                            if nCompareLevelType ~= nil and mapData.levelTypeData == nCompareLevelType and nCompareLevel ~= nil then
                                local sCompareStr = ParseHitDamageDesc(nKey, nCompareLevel)
                                if subStr ~= sCompareStr then
                                    subStr = string.format( "%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                                end
                            end
                            mapWord[word] = subStr
                        elseif sParseType == "LevelUp" then
                            local subStr = ParseLevelUpDesc(sTable, nKey, nLevel, sParameter, sShowType, sEnumType)
                            if nCompareLevelType ~= nil and mapData.levelTypeData == nCompareLevelType and nCompareLevel ~= nil then
                                local sCompareStr = ParseLevelUpDesc(sTable, nKey, nCompareLevel, sParameter, sShowType, sEnumType)
                                if subStr ~= sCompareStr then
                                    subStr = string.format( "%s<color=#8cac59>(%s↑)</color>", subStr, sCompareStr)
                                end
                            end
                            mapWord[word] = subStr
                        elseif sParseType == "NoLevel" then
                            mapWord[word] = ParseNoLevelUpDesc(sTable, nKey, sParameter, sShowType, sEnumType)
                        end
                    else
                        mapWord[word] = string.format("<color=#BD3059>%s表中该Id找不到数据:%s</color>", sTable, nKey) -- 红色：此id找不到数据
                    end        
                end
            else
                mapWord[word] = string.format("<color=#BD3059>找不到该配置表:%s</color>", sTable) -- 红色：找不到配置表
            end
        end
    end
    for word, finalStr in pairs(mapWord) do
        linkStr = string.gsub(linkStr, word, finalStr)
    end
    return ParseNoBrokenDesc(linkStr)
end

local function ParseDiscDesc(originStr, mapSkill, mapSkillNext, nLayer, mapLinkParam)
    originStr = UTILS.SubDesc(originStr, nil, nil, mapLinkParam)
    local mapWord = {}
    for word in string.gmatch(originStr, "{[0-9]*}") do
        if mapWord[word] == nil then
            local nCurLayer = nLayer
            local sWordId = string.sub(word,2,#word - 1)
            local nWordId = tonumber(sWordId)
            if nWordId == nil then
                printError("wordId error:"..sWordId)
                mapWord[word] = sWordId
                goto continue
            end
            local fieldName = "Param"..nWordId
            if nCurLayer then -- 泛用技能
                local nMaxStringCount = #mapSkill[fieldName]
                if nCurLayer > nMaxStringCount then
                    nCurLayer = nMaxStringCount
                end
                for k, v in ipairs(mapSkill[fieldName]) do
                    if nCurLayer == k then
                        mapWord[word] = v
                    end
                end
            else -- 核心技能
                if mapSkillNext and mapSkill[fieldName] ~= mapSkillNext[fieldName] then
                    mapWord[word] = mapSkill[fieldName] .. "<color=#8cac59>(" .. mapSkillNext[fieldName] .. "↑)</color>"
                else
                    mapWord[word] = mapSkill[fieldName]
                end
            end
        end
        if not mapWord[word] then
            mapWord[word] = "{未找到参数配置}"
        end
        mapWord[word] = string.gsub( mapWord[word],"%%","%%%%")
        ::continue::
    end
    for word, finalStr in pairs(mapWord) do
        originStr = string.gsub(originStr,word,finalStr)
    end
    return ParseNoBrokenDesc(originStr)
end

-- 只处理带参数的单行文本描述
local function ParseParamDesc(originStr, mapCfg, mapCfgNext, mapLinkParam, sColor)
    originStr = UTILS.SubDesc(originStr, nil, nil, mapLinkParam)
    local mapWord = {}
    for word in string.gmatch(originStr, "{[0-9]*}") do
        if mapWord[word] == nil then
            local sWordId = string.sub(word,2,#word - 1)
            local nWordId = tonumber(sWordId)
            if nWordId == nil then
                printError("wordId error:"..sWordId)
                mapWord[word] = sWordId
                goto continue
            end
            local fieldName = "Param"..nWordId
            if mapCfgNext and mapCfg[fieldName] ~= mapCfgNext[fieldName] then
                mapWord[word] = mapCfg[fieldName] .. "<color=#8cac59>(" .. mapCfgNext[fieldName] .. "↑)</color>"
            else
                if sColor then
                    mapWord[word] = "<color=" .. sColor .. ">" .. mapCfg[fieldName] .. "</color>"
                else
                    mapWord[word] = mapCfg[fieldName]
                end
            end
        end
        if not mapWord[word] then
            mapWord[word] = "{未找到参数配置}"
        end
        mapWord[word] = string.gsub(mapWord[word],"%%","%%%%")
        ::continue::
    end
    for word, finalStr in pairs(mapWord) do
        originStr = string.gsub(originStr,word,finalStr)
    end
    return ParseNoBrokenDesc(originStr)
end

-- 处理道具Icon显示数量的文本
local function ParseRewardItemCount(tbReward)
    -- 不显示数字时配置为-1
    if nil == tbReward then return -1 end
    if #tbReward < 3 then 
        printError("物品数量配置错误，应有至少3个参数")
        return -1
    end
    
    if #tbReward == 3 then
        return tbReward[2]
    elseif #tbReward > 3 then
        local countTxt = tbReward[2].."~"..tbReward[3]  
        return countTxt
    end
    return -1
end

local function QueryLevelInfo(nId,nType,nParam1,nParam2)
    local ret
    ret = PlayerData.StarTower:QueryLevelInfo(nId,nType,nParam1,nParam2)
    if ret == nil then
        ret = PlayerData.Char:QueryLevelInfo(nId,nType,nParam1,nParam2)
    end
    return ret
end

-- 处理关卡内任务目标文本
local function ParseLevelQuestTargetDesc(originStr, mapTarget)
    local mapSkillType = {
        [GameEnum.LevelQuestTargetType.CastSkill] = true,
        [GameEnum.LevelQuestTargetType.CastSkillEnd] = true,
    }
    local mapWord = {}
    for word in string.gmatch(originStr, "{Param" .. "[0-9]*}") do
        if mapWord[word] == nil then
            local fieldName = string.sub(word,2,#word - 1)
            local sParam = mapTarget[fieldName]
            if mapTarget.QuestType == GameEnum.LevelQuestTargetType.KillMonster and fieldName == "Param2" then
                local nMonsterId = tonumber(sParam)
                local sMonsterName = sParam
                if nMonsterId then
                    local monsterData = ConfigTable.GetData("Monster", nMonsterId)
                    if monsterData then
                        local monsterSkin = ConfigTable.GetData("MonsterSkin", monsterData.FAId)
                        if monsterSkin then
                            local monsterManual = ConfigTable.GetData("MonsterManual", monsterSkin.MonsterManual)
                            if monsterManual then
                                sMonsterName = monsterManual.Name
                            end
                        end
                    end
                end
                sParam = sMonsterName
            elseif mapSkillType[mapTarget.QuestType] and fieldName == "Param2" then
                local nSkillId = tonumber(sParam)
                local sSkillName = sParam
                if nSkillId then
                    local mapCfg = ConfigTable.GetData("Skill", nSkillId)
                    if mapCfg then
                        sSkillName = mapCfg.Title
                    end
                end
                sParam = sSkillName
            end
            mapWord[word] = "<color=#2be1f1>" .. sParam .. "</color>"
        end
        if not mapWord[word] then
            mapWord[word] = "{未找到参数配置}"
        end
        mapWord[word] = string.gsub(mapWord[word],"%%","%%%%")
    end

    for word, finalStr in pairs(mapWord) do
        originStr = string.gsub(originStr,word,finalStr)
    end
    return originStr
end

-- 处理关卡内任务目标文本
local function GetLevelQuestTargetProcess(mapTarget, nCur)
    local mapSkipProcess = {
        [GameEnum.LevelQuestTargetType.ReceiveTriggerOpId] = true,
        [GameEnum.LevelQuestTargetType.Null] = true,
        [GameEnum.LevelQuestTargetType.RecoverEnergy] = true,
        [GameEnum.LevelQuestTargetType.KillAllMonster] = true,
    }
    if mapSkipProcess[mapTarget.QuestType] then
        return ""
    end
    -- 其他情况默认上限参数为第一个
    if nCur then
        return "<color=#2be1f1>(" .. nCur .."/" .. mapTarget.Param1 .. ")</color>"
    else
        return "<color=#2be1f1>(0/" .. mapTarget.Param1 .. ")</color>"
    end
end

local function GetBezierPointByT(beginPos, handlePos, endPos, deltaTime)
    local pow = (1 - deltaTime) ^ 2

    local x = pow * beginPos.x + 2 * deltaTime * (1 - deltaTime) * handlePos.x + deltaTime * deltaTime * endPos.x;
    local y = pow * beginPos.y + 2 * deltaTime * (1 - deltaTime) * handlePos.y + deltaTime * deltaTime * endPos.y;
    local z = pow * beginPos.z + 2 * deltaTime * (1 - deltaTime) * handlePos.z + deltaTime * deltaTime * endPos.z;

    return x, y, z;
end
 -- ========== Color ==========
 local _
_, Red_Unable = ColorUtility.TryParseHtmlString("#BD3059")
_, Blue_Normal = ColorUtility.TryParseHtmlString("#264278")
_, Blue_Dark = ColorUtility.TryParseHtmlString("#3B62AE")
_, White_Normal = ColorUtility.TryParseHtmlString("#FAFAFA")
_, White_Dark = ColorUtility.TryParseHtmlString("#2d4257")
_, Gray_Dark = ColorUtility.TryParseHtmlString("#505c67")
--Battle
--添加效果
local function AddEffect(nCharId,nEffectId,nLevel,nUseCount)
    if nUseCount == nil then
        nUseCount = 0
    end
    local mapEftCfgData = ConfigTable.GetData_Effect(nEffectId)
    if mapEftCfgData == nil then
        printError("Effect Id missing".. nEffectId)
        return nil
    end
    local nEffectValueId = nEffectId
    if mapEftCfgData.levelTypeData ~= GameEnum.levelTypeData.None then
        nEffectValueId = nEffectValueId + nLevel * 10
    end
    local mapEftValueData = ConfigTable.GetData("EffectValue", nEffectValueId)
    if mapEftValueData == nil then
        printError("EffectValue Id missing".. nEffectValueId)
        return nil
    end
    local nEftRemainTimes = -1
    if mapEftValueData.TakeEffectLimit ~= 0 then
        nEftRemainTimes = mapEftValueData.TakeEffectLimit - nUseCount
        if nEftRemainTimes <= 0 then
            printLog("效果次数已用完:"..nEffectId)
            return nil
        end
    end
    local nEffectUid = safe_call_cs_func(CS.AdventureModuleHelper.SetActorEffect,nCharId, nEffectId, nEftRemainTimes, 0)
    return nEffectUid
end
local function AddFateCardEft(nCharId,nEffectId,nRemainCount)
    if nRemainCount == 0 then
        printLog("效果次数已用完:"..nEffectId)
        return nil
    end
    local nEffectUid = safe_call_cs_func(CS.AdventureModuleHelper.SetActorEffect,nCharId, nEffectId, nRemainCount, 0)
    return nEffectUid
end
local function AddBuildEffect(mapCharEffect,mapDiscEffect,mapNoteEffect)
    local retCharEffect = {}
    local retDiscEffect = {}
    local retNoteEffect = {}
    for nCharId, mapEffect in pairs(mapCharEffect) do
        if mapEffect[AllEnum.EffectType.Affinity] ~= nil then
            for _, nEffectId in ipairs(mapEffect[AllEnum.EffectType.Affinity]) do
                if retCharEffect[AllEnum.EffectType.Affinity] == nil then
                    retCharEffect[AllEnum.EffectType.Affinity] = {}
                end
                if retCharEffect[AllEnum.EffectType.Affinity][nEffectId] == nil then
                    retCharEffect[AllEnum.EffectType.Affinity][nEffectId] = {}
                end
                local nEftUid = UTILS.AddEffect(nCharId,nEffectId,0,0)
                table.insert(retCharEffect[AllEnum.EffectType.Affinity][nEffectId],nEftUid)
            end
        end
        if mapEffect[AllEnum.EffectType.Talent] ~= nil then
            for _, nEffectId in ipairs(mapEffect[AllEnum.EffectType.Talent]) do
                if retCharEffect[AllEnum.EffectType.Talent] == nil then
                    retCharEffect[AllEnum.EffectType.Talent] = {}
                end
                if retCharEffect[AllEnum.EffectType.Talent][nEffectId] == nil then
                    retCharEffect[AllEnum.EffectType.Talent][nEffectId] = {}
                end
                local nEftUid = UTILS.AddEffect(nCharId,nEffectId,0,0)
                table.insert(retCharEffect[AllEnum.EffectType.Talent][nEffectId],nEftUid)
            end
        end
        if mapEffect[AllEnum.EffectType.Potential] ~= nil then
            for nPotentialId, tbPotentialData in pairs(mapEffect[AllEnum.EffectType.Potential]) do
                for _, nEffectId in ipairs(tbPotentialData[1]) do
                    if retCharEffect[AllEnum.EffectType.Potential] == nil then
                        retCharEffect[AllEnum.EffectType.Potential] = {}
                    end
                    if retCharEffect[AllEnum.EffectType.Potential][nEffectId] == nil then
                        retCharEffect[AllEnum.EffectType.Potential][nEffectId] = {}
                    end
                    local nEftUid = UTILS.AddEffect(nCharId,nEffectId,tbPotentialData[2],0)
                    table.insert(retCharEffect[AllEnum.EffectType.Potential][nEffectId],nEftUid)
                end
            end
        end
        if mapEffect[AllEnum.EffectType.Equipment] ~= nil then
            for _, nEffectId in ipairs(mapEffect[AllEnum.EffectType.Equipment]) do
                if retCharEffect[AllEnum.EffectType.Equipment] == nil then
                    retCharEffect[AllEnum.EffectType.Equipment] = {}
                end
                if retCharEffect[AllEnum.EffectType.Equipment][nEffectId] == nil then
                    retCharEffect[AllEnum.EffectType.Equipment][nEffectId] = {}
                end
                local nEftUid = UTILS.AddEffect(nCharId,nEffectId,0,0)
                table.insert(retCharEffect[AllEnum.EffectType.Equipment][nEffectId],nEftUid)
            end
        end
        if mapDiscEffect ~= nil then
            for nDiscTid, tbDiscEffectId in pairs(mapDiscEffect) do
                if retDiscEffect[nDiscTid] == nil then
                    retDiscEffect[nDiscTid] = {}
                end
                for _, mapEft in ipairs(tbDiscEffectId) do
                    if retDiscEffect[nDiscTid][mapEft[1]] == nil  then
                        retDiscEffect[nDiscTid][mapEft[1]] = {}
                    end
                    local nEftUid = UTILS.AddEffect(nCharId,mapEft[1],mapEft[2],0)
                    table.insert(retDiscEffect[nDiscTid][mapEft[1]],nEftUid)
                end
            end
        end
        if mapNoteEffect  ~= nil then
            for nNoteId, tbNoteEffectId in pairs(mapNoteEffect) do
                if retNoteEffect[nNoteId] == nil then
                    retNoteEffect[nNoteId] = {}
                end
                for _, mapEft in ipairs(tbNoteEffectId) do
                    if retNoteEffect[nNoteId][mapEft[1]] == nil  then
                        retNoteEffect[nNoteId][mapEft[1]] = {}
                    end
                    local nEftUid = UTILS.AddEffect(nCharId,mapEft[1],mapEft[2],0)
                    table.insert(retNoteEffect[nNoteId][mapEft[1]],nEftUid)
                end
            end
        end
    end
    return retCharEffect,retDiscEffect,retNoteEffect
end
local function RemoveEffect(nEftUid,nCharId)
    safe_call_cs_func(CS.AdventureModuleHelper.RemoveActorEffect,nCharId, nEftUid)
end
--==================战斗验证数据========================
local function GetBattleSamples()
    local lstBattleSamples = CS.AdventureModuleHelper.GetBattleSamples()
    local tbSamples = {}
    if lstBattleSamples ~= nil then
        local nCount = lstBattleSamples.Count - 1
        local function csList2Table(list)
            if list == nil then
                return {}
            end
            local nLstCount = list.Count - 1
            local ret = {}
            for i = 0, nLstCount do
                table.insert(ret,list[i])
            end
            return ret
        end
        for i = 0, nCount, 1 do
            local mapSample = {}
            mapSample.FromSrcAtk = lstBattleSamples[i].fromSrcAtk
            mapSample.FromPerkIntensityRatio = lstBattleSamples[i].fromPerkIntensityRatio
            mapSample.FromSlotDmgRatio = lstBattleSamples[i].fromSlotDmgRatio
            mapSample.FromEE = lstBattleSamples[i].fromEE
            mapSample.FromGenDmgRatio = lstBattleSamples[i].fromGenDmgRatio
            mapSample.FromDmgPlus = lstBattleSamples[i].fromDmgPlus
            mapSample.FromCritRatio = lstBattleSamples[i].fromCritRatio
            mapSample.FromFinalDmgRatio = lstBattleSamples[i].fromFinalDmgRatio
            mapSample.FromFinalDmgPlus = lstBattleSamples[i].fromFinalDmgPlus
            mapSample.ToErAmend = lstBattleSamples[i].toErAmend
            mapSample.ToDefAmend = lstBattleSamples[i].toDefAmend
            mapSample.ToRcdSlotDmgRatio = lstBattleSamples[i].toRcdSlotDmgRatio
            mapSample.ToEERCD = lstBattleSamples[i].toEERCD
            mapSample.ToGenDmgRcdRatio = lstBattleSamples[i].toGenDmgRcdRatio
            mapSample.ToDmgPlusRcd = lstBattleSamples[i].toDmgPlusRcd
            mapSample.Dmg = lstBattleSamples[i].dmg
            mapSample.CritRate = lstBattleSamples[i].critRate
            mapSample.Hp = lstBattleSamples[i].maxHP
            mapSample.Log = {}
            -- mapSample.Log.Def = lstBattleSamples[i].log.toSrcDef
            -- mapSample.Log.CritResistance = lstBattleSamples[i].log.toCritResistance
            -- mapSample.Log.DefPierce = lstBattleSamples[i].log.fromDefPierce
            -- mapSample.Log.DefIgnore = lstBattleSamples[i].log.fromDefIgnore
            -- mapSample.Log.WEP = lstBattleSamples[i].log.fromWEP
            -- mapSample.Log.FEP = lstBattleSamples[i].log.fromFEP
            -- mapSample.Log.SEP = lstBattleSamples[i].log.fromSEP
            -- mapSample.Log.AEP = lstBattleSamples[i].log.fromAEP
            -- mapSample.Log.LEP = lstBattleSamples[i].log.fromLEP
            -- mapSample.Log.DEP = lstBattleSamples[i].log.fromDEP
            -- mapSample.Log.WEI = lstBattleSamples[i].log.fromWEI
            -- mapSample.Log.FEI = lstBattleSamples[i].log.fromFEI
            -- mapSample.Log.SEI = lstBattleSamples[i].log.fromSEI
            -- mapSample.Log.AEI = lstBattleSamples[i].log.fromAEI
            -- mapSample.Log.LEI = lstBattleSamples[i].log.fromLEI
            -- mapSample.Log.DEI = lstBattleSamples[i].log.fromDEI
            -- mapSample.Log.WER = lstBattleSamples[i].log.toWER
            -- mapSample.Log.FER = lstBattleSamples[i].log.toFER
            -- mapSample.Log.SER = lstBattleSamples[i].log.toSER
            -- mapSample.Log.AER = lstBattleSamples[i].log.toAER
            -- mapSample.Log.LER = lstBattleSamples[i].log.toLER
            -- mapSample.Log.DER = lstBattleSamples[i].log.toDER
            -- mapSample.Log.Suppress = lstBattleSamples[i].log.suppress
            -- mapSample.Log.AttakerID = lstBattleSamples[i].log.fromID
            -- mapSample.Log.DefenderID = lstBattleSamples[i].log.toID
            -- mapSample.Log.HitDamageID = lstBattleSamples[i].log.hitDamageID
    
            -- mapSample.Log.FromBuffID = csList2Table(lstBattleSamples[i].log.fromBuffIDs)
            -- mapSample.Log.FromOnceadditionID = csList2Table(lstBattleSamples[i].log.fromOnceAdditionIDs)
            -- mapSample.Log.FromEffectID = csList2Table(lstBattleSamples[i].log.fromEffectIDs)
            -- mapSample.Log.ToBuffID = csList2Table(lstBattleSamples[i].log.toBuffIDs)
            -- mapSample.Log.ToOnceadditionID = csList2Table(lstBattleSamples[i].log.toOnceAdditionIDs)
            -- mapSample.Log.ToEffectID = csList2Table(lstBattleSamples[i].log.toEffectIDs)
            table.insert(tbSamples,mapSample)
        end
    end
    return tbSamples
end

local function GetCharDamageResult(tbCharId)
    local tbResult = {}
    for i = 1, #tbCharId do
        local nCharId = tbCharId[i]
        local nDamage = CS.AdventureModuleHelper.GetCharacterDamage(nCharId, false)
        local actorInfo = {}
        actorInfo.nCharId = nCharId
        actorInfo.nDamage = nDamage
        table.insert(tbResult, actorInfo)
    end
    return tbResult
end

-- ========== Itemtips ==========
--[[
    点击道具格子弹出tips
    这个格子是item，通常是展示用的，比如说出现在关卡的奖励展示列表格子
    适用于鬼知道策划会在这里配出什么类型道具的地方，比如说角色、星盘，这时候的展示需求是不同的
    
    需求1：nHasCount：星塔内不进背包的道具需要显示持有数量，因此需要传入当前已拥有数量
]]
local function ClickItemGridWithTips(nTid, transform, bOnlyItemTips, bShowDepot, bShowJumpto, nHasCount)
    -- 道具Tid
    -- 需要高亮的区域transform
    -- 是否只使用itemtips显示
    local mapItemCfgData = ConfigTable.GetData_Item(nTid)
    if mapItemCfgData == nil then
        return
    end

    if mapItemCfgData.Type == GameEnum.itemType.Disc then -- 星盘只展示预览界面
        EventManager.Hit(EventId.OpenPanel, PanelId.DiscSample, nTid)
        return
    elseif mapItemCfgData.Type == GameEnum.itemType.Char then -- 角色只展示预览界面
        EventManager.Hit(EventId.OpenPanel, PanelId.CharBgTrialPanel, PanelId.CharInfoTrial, nTid, {nTid}, true)
        return
    end

    if bOnlyItemTips then
        local mapData = {
            nTid = nTid,
            bShowDepot = bShowDepot,
            bShowJumpto = bShowJumpto,
            nHasCount = nHasCount,
        }
        EventManager.Hit(EventId.OpenPanel, PanelId.ItemTips, transform, mapData)
    else
        local mapData = {
            nTid = nTid,
            bShowDepot = bShowDepot,
            bShowJumpto = bShowJumpto,
            nHasCount = nHasCount,
        }
        EventManager.Hit(EventId.OpenPanel, PanelId.ItemTips, transform, mapData)
    end
end
local function CheckIsTipsPanel(nPanelId)
    local tbAllTipsPanelId = {
        PanelId.ItemTips,
        PanelId.PerkTips,
        PanelId.SkillTips,
        PanelId.BtnTips,
        PanelId.MonsterTips,
        PanelId.EquipmentTips,
        PanelId.DiscSkillTips,
    }
    return table.indexof(tbAllTipsPanelId, nPanelId) > 0
end
local function ClickWordLink(link, sWordId, mapLinkParam)
    local nWordId = tonumber(sWordId)
    local mapWordData = ConfigTable.GetData("Word", nWordId)
    if mapWordData == nil then
        if sWordId == nil then
            printError("sWordId为空")
            return
        end
        printError("wordId error:"..sWordId)
        return
    end

    if mapWordData.Type == GameEnum.wordLinkType.Word then
        local mapData = {
            nPerkId = 0,
            nCount = 0,
            bWordTip = true,
            sWordId = sWordId,
        }
        EventManager.Hit(EventId.OpenPanel, PanelId.PerkTips, link, mapData)
    elseif mapWordData.Type == GameEnum.wordLinkType.Potential then
        if mapLinkParam == nil or mapLinkParam.nCharId == nil then
            printError("该<潜能>词条 id 找不到角色:" .. sWordId)
            return
        else
            local nPotentialId = GetPotentialId(mapLinkParam.nCharId, tonumber(mapWordData.Param1))
            EventManager.Hit(EventId.OpenPanel, PanelId.PotentialDetail, nPotentialId, mapLinkParam.nLevel, mapLinkParam.nAddLv)
        end
    end
end

-- 排序字段及默认优先级
--local default_priority = {"rarity", "level", "skill_level_sum", "favorability", "obtain_time"}
--local sort_orders = {
--    level = "desc",
--    rarity = "desc",
--    obtain_time = "asc",
--    skill_level_sum = "desc",
--    favorability = "desc",
--}

-- 构建优先级
local function build_priority(selected, default_priority)
    local priority = {}
    local selected_map = {}
    for _, field in ipairs(selected) do
        table.insert(priority, field)
        --选中排序字段会按照玩家置顶的顺序进行排序
        selected_map[field] = true
    end
    for _, field in ipairs(default_priority) do
        if not selected_map[field] then
            table.insert(priority, field)
        end
    end
    return priority
end

-- 通用比较器
local function compare_roles(a, b, sort_priority, bOrder)
    for i, field in ipairs(sort_priority) do
        local va, vb = a[field], b[field]
        if va ~= nil and vb ~= nil and va ~= vb then
            --反转了，稀有度是数字越小稀有度越高
            if field == "Rare" or field == "nRarity" then
                if i == 1 and bOrder then
                    return va > vb
                else
                    return va < vb
                end
            elseif (i == 1 and bOrder) or field == "EET" or field == "nEET" then
                return va < vb
            else
                return va > vb
            end
        end
    end
    return false
end

-- 排序接口
local function SortByPriority(items, selected_fields, default_priority, bOrder)
    local sort_priority = build_priority(selected_fields, default_priority)
    table.sort(items, function(a, b)
        return compare_roles(a, b, sort_priority, bOrder)
    end)
end
--客户端每日刷新时间偏移
local function GetDayRefreshTimeOffset()
    local nNewDayTime = ConfigTable.GetConfigNumber("DailyRefreshOffsetHour") or 5
    if nNewDayTime > 24 then
        nNewDayTime = nNewDayTime % 24
    end
    return nNewDayTime
end

-- 用法
-- sort_roles(roles, {"level"}) -- 只选等级
-- sort_roles(roles, {"level", "favorability"}) -- 多主排序字段

--==================== SDK ====================
local function SDK_Logout()
    local SDKManager = CS.SDKManager.Instance
    if SDKManager:IsSDKInit() ~= true then
        return
    end
    SDKManager:SwitchAccount()
end
local function SDK_ShowAgreement()
    local SDKManager = CS.SDKManager.Instance
    if SDKManager:IsSDKInit() ~= true then
        return
    end
    local agreements = {}
    local sChannel = NovaAPI.GetClientChannel()
    if sChannel == "CN_Bilibili" or sChannel == "CN" or sChannel == "KOL" then
        table.insert(agreements,"user_agreement")
        table.insert(agreements,"privacy_agreement")
        table.insert(agreements,"child_privacy_agreement")
    else
        table.insert(agreements,"user_agreement")
        table.insert(agreements,"privacy_agreement")
        table.insert(agreements,"minors_shop_agreement")
    end
    SDKManager.SDK:ShowAgreement(agreements)
end

--=====================五服差异和运营对齐渠道===============
-- 服务器的Channel
local ServerChannel_CN={[1]="cn_android_official",[2]="cn_ios_official",[4]="cn_android_bilibili",[8]="cn_harmony_official",[16]="cn_pc_official",[32]="cn_pc_bilibili"}

local ServerChannel_JP={[1]="jp_android_official",[2]="jp_ios_official",[4]="jp_android_onestore",[8]="jp_pc_official"}
local ServerChannel_US={[1]="us_android_official",[2]="us_ios_official",[4]="us_android_onestore",[8]="us_pc_official"}
local ServerChannel_KR={[1]="kr_android_official",[2]="kr_ios_official",[4]="kr_android_onestore",[8]="kr_pc_official"}
local ServerChannel_TW={[1]="tw_android_official",[2]="tw_ios_official",[4]="tw_android_onestore",[8]="tw_pc_official"}
---return 获取当前客户端 所在地区的 渠道字符串  （这个字符串存在 主要是为了和运营那边的 channelId对应起来）
local function GetChannelConfigList()
    local resultList=nil
    local clientPublishRegion=CS.ClientConfig.ClientPublishRegion
    if clientPublishRegion==CS.ClientPublishRegion.CN then
        resultList=ServerChannel_CN
    elseif clientPublishRegion==CS.ClientPublishRegion.JP then
        resultList=ServerChannel_JP
    elseif clientPublishRegion==CS.ClientPublishRegion.US then
        resultList=ServerChannel_US
    elseif clientPublishRegion==CS.ClientPublishRegion.KR then
        resultList=ServerChannel_KR
    elseif clientPublishRegion==CS.ClientPublishRegion.TW then
        resultList=ServerChannel_TW
    else
    end
    return resultList
end
---使用场景:公告  走马灯
--- 在公告和走马灯中 taptap 渠道算official 所以在判断的时候 会把taptap替换成official
local function CheckChannel(channel)
    local fullChannnel=CS.ClientConfig.FullClientPublishChannelName

    local channelList=GetChannelConfigList()
    if channelList==nil then
        return false
    end
    local strChannel=channelList[channel]
    if strChannel==nil then
        return false
    end
    local tbClient=string.split(fullChannnel,"_")
    local tbServer=string.split(strChannel,"_")

    --平台判断
    if tbClient[2]==nil or tbServer[2]==nil  or tbClient[2]~=tbServer[2] then
        return false
    end
    if tbClient[3] == "taptap" then
        tbClient[3]  =  "official"
    end
    --渠道判断
    if tbClient[3]==nil or tbServer[3]==nil  or tbClient[3]~=tbServer[3] then
        return false
    end
    return true
end
local function CheckChannelList(channelList)
    local sCurClientPublishRegion=CS.ClientConfig.ClientPublishRegion
    if sCurClientPublishRegion==CS.ClientPublishRegion.Other then
        return true
    end
    --test渠道
    local fullChannnel=CS.ClientConfig.FullClientPublishChannelName
    if string.match(fullChannnel,"test") then
        return true
    end
    for i = 0, channelList.Count-1,1 do
        if CheckChannel(channelList[i]) then
            return true
        end
    end
    return false
end
local function CheckChannelList_Notice(channelList)
    local sCurClientPublishRegion=CS.ClientConfig.ClientPublishRegion
    if sCurClientPublishRegion==CS.ClientPublishRegion.Other then
        return true
    end
    --test渠道
    local fullChannnel=CS.ClientConfig.FullClientPublishChannelName
    if string.match(fullChannnel,"test") then
        return true
    end
    for _, channel in ipairs(channelList) do
        if CheckChannel(channel) then
            return true
        end
    end
    return false
end
---版本号比较 (0：相等 1：大于 -1：小于)
---@param v1 any
---@param v2 any
---@param num any 比较位数
local function VersionCompare(v1,v2,num)
    local v1List=string.split(v1,".")
    local v2List=string.split(v2,".")
    for i = 1, num, 1 do
        if #v1List <i or #v2List<i then
            if #v1List<#v2List then
                return -1
            elseif #v1List>#v2List then
                return 1
            else 
                return 0
            end
        end
        local v1_num=tonumber(v1List[i]) or 0
        local v2_num=tonumber(v2List[i]) or 0
        if v1_num>v2_num then
            return 1
        elseif v1_num<v2_num then
            return -1
        end 
    end
    return 0
end
local function GetBBSUrl()
    local result=false
    local url=""
    local sChannel = NovaAPI.GetClientChannel()
    if sChannel == "CN" or sChannel=="CN_Taptap" then
        result=true
        url = "https://bbs-stellasora.yostar.net/"
    elseif sChannel == "CN_TEST_1" then
        result=true
        url = "https://staging-bbs.yostar.net/"
    end
    return result,url
end
local function GetToolBoxUrl()
    local result=false
    local url=""
    local sChannel = NovaAPI.GetClientChannel()
    local clientPublishRegion=CS.ClientConfig.ClientPublishRegion
    if clientPublishRegion==CS.ClientPublishRegion.CN then
        if sChannel == "CN" or sChannel == "CN_Bilibili" or sChannel =="CN_Taptap" then
            result=true 
            url = "https://toolbox-stellasora.yostar.cn"
        else
            result=true 
            url = "https://staging-web-toolbox-stellasora.yostar.cn"
        end
    elseif clientPublishRegion==CS.ClientPublishRegion.TW then
        if sChannel == "TW" then
            result=true 
            url = "https://toolbox-stellasora.stargazer-games.com"
        else
            result=true 
            url = "https://staging-web-toolbox-stellasora.stargazer-games.com"
        end
    elseif clientPublishRegion==CS.ClientPublishRegion.JP then
        if sChannel == "JP" then
            result=true 
            url = "https://toolbox.stellasora.jp"
        else
            result=true 
            url = "https://staging-web-toolbox.stellasora.jp"
        end
    elseif clientPublishRegion==CS.ClientPublishRegion.US then
        if sChannel == "EN" then
            result=true 
            url = "https://toolbox.stellasora.global"
        else
            result=true 
            url = "https://staging-web-toolbox.stellasora.global"
        end

    elseif clientPublishRegion==CS.ClientPublishRegion.KR then
        if sChannel == "KR" then
            result=true 
            url = "https://toolbox.stellasora.kr"
        else
            result=true 
            url = "https://staging-web-toolbox.stellasora.kr"
        end
    end
    return result,url
end
local function GetExchangeCodeUrl()
    local result=false
    local url=""
    local sChannel = NovaAPI.GetClientChannel()
    local clientPublishRegion=CS.ClientConfig.ClientPublishRegion
    if clientPublishRegion==CS.ClientPublishRegion.CN then
    elseif clientPublishRegion==CS.ClientPublishRegion.TW then
        if sChannel == "TW" then
            result=true 
            url = "https://stellasora.stargazer-games.com/redemption?type=webview"
        else
            result=true 
            url = "https://staging-web-stellasora.stargazer-games.com/redemption?type=webview"
        end
    elseif clientPublishRegion==CS.ClientPublishRegion.JP then
        if sChannel == "JP" then
            result=true 
            url = "https://stellasora.jp/serial_code?type=webview"
        else
            result=true 
            url = "https://staging-web.stellasora.jp/serial_code?type=webview"
        end
    elseif clientPublishRegion==CS.ClientPublishRegion.US then
        if sChannel == "EN" then
            result=true 
            url = "https://stellasora.global/gift?type=webview"
        else
            result=true 
            url = "https://staging-web.stellasora.global/gift?type=webview"
        end

    elseif clientPublishRegion==CS.ClientPublishRegion.KR then
        if sChannel == "KR" then
            result=true 
            url = "https://stellasora.kr/gift?type=webview"
        else
            result=true 
            url = "https://staging-web.stellasora.kr/gift?type=webview"
        end
    end
    return result,url
end
_G.UTILS = {
    DecodeChangeInfo = DecodeChangeInfo,
    OpenReceiveByChangeInfo = OpenReceiveByChangeInfo,
    OpenReceiveByDisplayItem = OpenReceiveByDisplayItem,
    OpenReceiveByReward = OpenReceiveByReward,
    GetParamStrLen = GetParamStrLen,
    ParseByteString = ParseByteString,
    IsBitSet = IsBitSet,
    GetBuildAttributeId = GetBuildAttributeId,
    GetCharacterAttributeId = GetCharacterAttributeId,
    GetDiscAttributeId = GetDiscAttributeId,
    GetDiscExtraAttributeId = GetDiscExtraAttributeId,
    GetPotentialId =  GetPotentialId,
    SubDesc = SubDesc,
    ParseDesc = ParseDesc,
    ParseDiscDesc = ParseDiscDesc,
    ParseParamDesc = ParseParamDesc,
    ParseLevelQuestTargetDesc = ParseLevelQuestTargetDesc,
    GetLevelQuestTargetProcess = GetLevelQuestTargetProcess,
    ParseRewardItemCount = ParseRewardItemCount,
    GetBezierPointByT = GetBezierPointByT,
    AddEffect = AddEffect,
    AddFateCardEft = AddFateCardEft,
    AddBuildEffect = AddBuildEffect,
    RemoveEffect = RemoveEffect,
    GetBattleSamples = GetBattleSamples,
    GetCharDamageResult = GetCharDamageResult,
    ClickItemGridWithTips = ClickItemGridWithTips,
    QueryLevelInfo = QueryLevelInfo,
    SDK_Logout = SDK_Logout,
    SDK_ShowAgreement = SDK_ShowAgreement,
    ParseNoBrokenDesc = ParseNoBrokenDesc,
    CheckIsTipsPanel = CheckIsTipsPanel,
    ClickWordLink = ClickWordLink,
    CheckChannelList=CheckChannelList,
    VersionCompare=VersionCompare,
    SortByPriority = SortByPriority,
    GetDayRefreshTimeOffset = GetDayRefreshTimeOffset,
    GetBBSUrl = GetBBSUrl,
    GetToolBoxUrl = GetToolBoxUrl,
    GetExchangeCodeUrl = GetExchangeCodeUrl,
    CheckChannelList_Notice = CheckChannelList_Notice,
}