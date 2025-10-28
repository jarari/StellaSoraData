local AvgPanel = class("AvgPanel", BasePanel)
local AvgData = PlayerData.Avg
local TimerManager = require "GameCore.Timer.TimerManager"
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local ModuleManager = require "GameCore.Module.ModuleManager"
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"
AvgPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
AvgPanel._bAddToBackHistory = false
AvgPanel._tbDefine = {
    {sPrefabPath = "Avg/Editor/Actor2DEditorAvgPanel.prefab"}, -- 立绘编辑器用的临时界面，正式游戏中不会使用它。
    {sPrefabPath = "Avg/Avg_0_Stage.prefab", sCtrlName = "Game.UI.Avg.Avg_0_Stage"},
    {sPrefabPath = "Avg/Avg_2_CHAR.prefab", sCtrlName = "Game.UI.Avg.Avg_2_CharCtrl"},
    {sPrefabPath = "Avg/Avg_2_L2D.prefab", sCtrlName = "Game.UI.Avg.Avg_2_L2DCtrl"},
    {sPrefabPath = "Avg/Avg_3_Transition.prefab", sCtrlName = "Game.UI.Avg.Avg_3_TransitionCtrl"},
    {sPrefabPath = "Avg/Avg_4_Talk.prefab", sCtrlName = "Game.UI.Avg.Avg_4_TalkCtrl"},
    {sPrefabPath = "Avg/Avg_5_Phone.prefab", sCtrlName = "Game.UI.Avg.Avg_5_PhoneCtrl"}, -- 手机对话层级低于常规对话
    {sPrefabPath = "Avg/Avg_6_Menu.prefab", sCtrlName = "Game.UI.Avg.Avg_6_MenuCtrl"},
    {sPrefabPath = "Avg/Avg_7_Choice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_ChoiceCtrl"},
    {sPrefabPath = "Avg/Avg_7_MajorChoice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_MajorChoiceCtrl"},
    {sPrefabPath = "Avg/Avg_7_PersonalityChoice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_PersonalityChoiceCtrl"},
    {sPrefabPath = "Avg/Avg_8_Log.prefab", sCtrlName = "Game.UI.Avg.Avg_8_LogCtrl"},
    {sPrefabPath = "Avg/Avg_9_Curtain.prefab", sCtrlName = "Game.UI.Avg.Avg_9_CurtainCtrl"},
}
if RUNNING_ACTOR2D_EDITOR ~= true then
    table.remove(AvgPanel._tbDefine, 1)
end
function AvgPanel:Awake()
    -- 注册手柄
    self:EnableGamepad()
    TimerManager.ForceFrameUpdate(true)
    --printLog("AvgPanel:Awake")
    --printTable(self._tbParam)
    -- 1.多语言处理
    self.sTxtLan = self._tbParam[2]
    self.nCurLanguageIdx = GetLanguageIndex(self.sTxtLan)
    self.sVoLan = self._tbParam[3]
    self.sVoResNameSurfix = ""
    for k, v in pairs(AllEnum.LanguageInfo) do
        if v[1] == self.sVoLan then
            self.sVoResNameSurfix = v[3]
            break
        end
    end
    self.bIsPlayerMale = PlayerData.Base:GetPlayerSex() == true
    self.sPlayerNickName = PlayerData.Base:GetPlayerNickName()
    -- 2.指令配置
    self.sAvgId = self._tbParam[1]
    self.sRootPath = GetAvgLuaRequireRoot(self.nCurLanguageIdx)
    self.sAvgCfgPath = self.sRootPath .. "Config/" .. self.sAvgId
    self.sAvgCharacterPath = self.sRootPath .. "Preset/AvgCharacter"
    self.sAvgPresetPath = "Game.UI.Avg.AvgPreset"
    self.sAvgContactsPath = self.sRootPath .. "Preset/AvgContacts"
    self.sAvgCfgHead = string.sub(self.sAvgId, 1, 2)
    if self.sAvgCfgHead == "BT" or self.sAvgCfgHead == "DP" or self.sAvgCfgHead == "GD" then self.AVG_NO_BG_MODE = true end
    self:RequireAndPreProcAvgConfig(self.sAvgCfgPath, self.sAvgCfgHead, self._tbParam[4])
    -- 3.AVG角色表（按当前语言取该角色对应的名字）
    local tbAvgChar = require(self.sAvgCharacterPath) -- Load Avg Character
    self.tbAvgCharacter = {}
    for i, v in ipairs(tbAvgChar) do
        self.tbAvgCharacter[v.id] = {name = v.name, reuse = v.reuse, color = v.name_bg_color, reuseL2DPose = v.reuseL2DPose}
    end
    -- 4.指令预设参数（背景抖动和立绘抖动）
    self.tbAvgPreset = require(self.sAvgPresetPath) -- Load Preset Parameters
    -- 5.执行指令前的一些准备。
    self.nCurIndex = 1 -- 配置索引从 1 开始
    local nStartIndex = self._tbParam[5]
    if type(nStartIndex) == "number" then
        if nStartIndex > 0 and nStartIndex < #self.tbAvgCfg then
            self.nCurIndex = nStartIndex
        end
    end
    self.nJumpTarget = nil
    self:SetSystemBgm(true) -- 暂停AVG外的系统BGM
    CS.AdventureModuleHelper.PauseLogic()
    -- 6.联系人信息
    local tbContacts = require(self.sAvgContactsPath)
    self.tbAvgContacts = {}
    for i, v in ipairs(tbContacts) do
        self.tbAvgContacts[v.id] = {name = v.name, signature = ProcAvgTextContent(v.signature), icon = v.icon}
    end
    -- 7.倍速
    self.nSpeedRate = 1
    EventManager.Add(EventId.AvgSpeedUp, self, self.OnEvent_AvgSpeedUp)
    self.sExecutingCMDName = nil
    -- 8.BE逻辑
    self.nBEIndex = 0
end
function AvgPanel:OnEnable()
    -- 6.关联处理指令的方法。（需在 AvgPanel 的所有 Ctrl 都 Awake 后再关联）
    self:BindCmdProcFunc()
    -- 7.开始执行指令。
    EventManager.Add(EventId.AvgSkipCheck, self, self.OnEvent_AvgSkipCheck)
    EventManager.Add(EventId.AvgSkip, self, self.OnEvent_AvgSkip) -- 不能放到 Awake 中，因为 Avg_4_TalkCtrl 里也监听了，跳 AvgId 后首条是对话类指令时会有BUG的。
    EventManager.Add(EventId.AvgTryResume, self, self.OnEvent_AvgTryResume)
    EventManager.Add(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration) -- 通过音效指令单播角色语音时，取语音时长。
    if AVG_EDITOR == true then -- Avg编辑器体验相关的小优化
        self:AddTimer(1, 1, "DelayRunInAvgEditor", true, true, true)
    else
        if self.sAvgCfgHead == "DP" then
            WwiseAudioMgr:PlaySound("ui_dispatch_dialogue_enter")
        end
        self:RUN()
    end
end
function AvgPanel:BindCmdProcFunc()
    self.mapProcFunc = {}
    -- 背景图类、分镜类指令
    self.mapProcFunc["SetBg"] = self:FindCmdProcFunc("Avg_0_Stage", "SetBg")
    self.mapProcFunc["CtrlBg"] = self:FindCmdProcFunc("Avg_0_Stage", "CtrlBg")
    self.mapProcFunc["SetStage"] = self:FindCmdProcFunc("Avg_0_Stage", "SetStage")
    self.mapProcFunc["CtrlStage"] = self:FindCmdProcFunc("Avg_0_Stage", "CtrlStage")
    -- 前、后景特效类指令
    self.mapProcFunc["SetFx"] = self:FindCmdProcFunc("Avg_0_Stage", "SetFx")
    self.mapProcFunc["SetFrontObj"] = self:FindCmdProcFunc("Avg_0_Stage", "SetFrontObj")
    self.mapProcFunc["SetHeartBeat"] = self:FindCmdProcFunc("Avg_0_Stage", "SetHeartBeat")
    self.mapProcFunc["SetPP"] = self:FindCmdProcFunc("Avg_0_Stage", "SetPP")
    self.mapProcFunc["SetPPGlobal"] = self:FindCmdProcFunc("Avg_0_Stage", "SetPPGlobal")
    -- 角色类指令
    self.mapProcFunc["SetChar"] = self:FindCmdProcFunc("Avg_2_CharCtrl", "SetChar")
    self.mapProcFunc["CtrlChar"] = self:FindCmdProcFunc("Avg_2_CharCtrl", "CtrlChar")
    self.mapProcFunc["PlayCharAnim"] = self:FindCmdProcFunc("Avg_2_CharCtrl", "PlayCharAnim")
    self.mapProcFunc["SetCharHead"] = self:FindCmdProcFunc("Avg_2_CharCtrl", "SetCharHead")
    self.mapProcFunc["CtrlCharHead"] = self:FindCmdProcFunc("Avg_2_CharCtrl", "CtrlCharHead")
    self.mapProcFunc["SetL2D"] = self:FindCmdProcFunc("Avg_2_L2DCtrl", "SetL2D")
    self.mapProcFunc["CtrlL2D"] = self:FindCmdProcFunc("Avg_2_L2DCtrl", "CtrlL2D")
    self.mapProcFunc["SetCharL2D"] = self:FindCmdProcFunc("Avg_2_L2DCtrl", "SetCharL2D")
    -- 转场、影幕
    self.mapProcFunc["SetFilm"] = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "SetFilm")
    self.mapProcFunc["SetTrans"] = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "SetTrans")
    self.mapProcFunc["SetWordTrans"] = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "SetWordTrans")
    -- 对话类指令
    self.mapProcFunc["SetTalk"] = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetTalk")
    self.mapProcFunc["SetTalkShake"] = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetTalkShake")
    self.mapProcFunc["SetGoOn"] = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetGoOn")
    self.mapProcFunc["SetMainRoleTalk"] = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetMainRoleTalk")
    -- 手机
    self.mapProcFunc["SetPhone"] = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhone")
    self.mapProcFunc["SetPhoneMsg"] = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsg")
    self.mapProcFunc["SetPhoneThinking"] = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneThinking")
    self.mapProcFunc["SetPhoneMsgChoiceBegin"] = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsgChoiceBegin")
    self.mapProcFunc["SetPhoneMsgChoiceJumpTo"] = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsgChoiceJumpTo")
    self.mapProcFunc["SetPhoneMsgChoiceEnd"] = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsgChoiceEnd")
    -- 选项类指令
    self.mapProcFunc["SetChoiceBegin"] = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceBegin")
    self.mapProcFunc["SetChoiceJumpTo"] = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceJumpTo")
    self.mapProcFunc["SetChoiceRollback"] = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceRollback")
    self.mapProcFunc["SetChoiceRollover"] = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceRollover")
    self.mapProcFunc["SetChoiceEnd"] = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceEnd")
    self.mapProcFunc["SetMajorChoice"] = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoice")
    self.mapProcFunc["SetMajorChoiceJumpTo"] = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoiceJumpTo")
    self.mapProcFunc["SetMajorChoiceRollover"] = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoiceRollover")
    self.mapProcFunc["SetMajorChoiceEnd"] = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoiceEnd")
    self.mapProcFunc["SetPersonalityChoice"] = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoice")
    self.mapProcFunc["SetPersonalityChoiceJumpTo"] = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoiceJumpTo")
    self.mapProcFunc["SetPersonalityChoiceRollover"] = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoiceRollover")
    self.mapProcFunc["SetPersonalityChoiceEnd"] = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoiceEnd")
    self.mapProcFunc["IfTrue"] = {ctrl = self, func = self.IfTrue}
    self.mapProcFunc["EndIf"] = {ctrl = self, func = self.EndIf}
    self.mapProcFunc["GetEvidence"] = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "GetEvidence")
    -- 音效类指令
    self.mapProcFunc["SetAudio"] = {ctrl = self, func = self.SetAudio}
    self.mapProcFunc["SetBGM"] = {ctrl = self, func = self.SetBGM}
    -- 特殊
    self.mapProcFunc["SetSceneHeading"] = self:FindCmdProcFunc("Avg_6_MenuCtrl", "SetSceneHeading")
    self.mapProcFunc["SetIntro"] = self:FindCmdProcFunc("Avg_6_MenuCtrl", "SetIntro")
    self.mapProcFunc["NewCharIntro"] = self:FindCmdProcFunc("Avg_6_MenuCtrl", "NewCharIntro")
    -- 控制类指令
    self.mapProcFunc["Wait"] = {ctrl = self, func = self.Wait}
    self.mapProcFunc["Jump"] = {ctrl = self, func = self.Jump}
    self.mapProcFunc["Clear"] = {ctrl = self, func = self.Clear}
    self.mapProcFunc["End"] = {ctrl = self, func = self.End}
    self.mapProcFunc["SetGroupId"] = {ctrl = self, func = self.SetGroupId}
    -- 备注指令
    self.mapProcFunc["Comment"] = {ctrl = self, func = self.Comment}
    -- 跨演出配置跳转
    self.mapProcFunc["BadEnding_Check"] = {ctrl = self, func = self.BadEnding_Check}
    self.mapProcFunc["BadEnding_Mark"] = {ctrl = self, func = self.BadEnding_Mark}
    self.mapProcFunc["JUMP_AVG_ID"] = {ctrl = self, func = self.JUMP_AVG_ID}
end
function AvgPanel:DelayRunInAvgEditor()
    WwiseAudioMgr.MusicVolume = 10
    if self.sAvgCfgHead == "DP" then
        WwiseAudioMgr:PlaySound("ui_dispatch_dialogue_enter")
    end
    self:RUN()
end
function AvgPanel:OnDisable()
    self.mapProcFunc = nil
    -- 1.Unload Avg Config
    if self.tbAvgCfg ~= nil then self.tbAvgCfg = nil end
    package.loaded[self.sAvgCfgPath] = nil
    self.sAvgCfgPath = nil
    -- 2.Unload Avg Character
    if self.tbAvgCharacter ~= nil then self.tbAvgCharacter = nil end
    package.loaded[self.sAvgCharacterPath] = nil
    self.sAvgCharacterPath = nil
    -- 3.Unload Preset Paramters
    if self.tbAvgPreset ~= nil then self.tbAvgPreset = nil end
    package.loaded[self.sAvgPresetPath] = nil
    self.sAvgPresetPath = nil
    -- 4.Unload Contacts Paramters
    if self.tbAvgContacts ~= nil then self.tbAvgContacts = nil end
    package.loaded[self.sAvgContactsPath] = nil
    self.sAvgContactsPath = nil
    CS.AdventureModuleHelper.ResumeLogic()
    TimerManager.ForceFrameUpdate(false)
    -- 注销手柄
    self:DisableGamepad()
end
function AvgPanel:RequireAndPreProcAvgConfig(sAvgConfigPath, sHead, _sGroupId)
    local ok, aaa =  pcall(require, sAvgConfigPath)
    if not ok then
        printError("AVG 指令配置文件未找到，路径:" .. sAvgConfigPath .. ". error: " .. aaa)
        EventManager.Hit(EventId.OpenMessageBox, "AVG 指令配置文件未找到，路径:" .. sAvgConfigPath)
        EventManager.Hit("StoryDialog_DialogEnd")
        return
    else
        self.tbAvgCfg = aaa

        -- 处理PM、DP分组
        if type(_sGroupId) == "string" and _sGroupId ~= "" then self.tbAvgCfg = self:ParseGroup(aaa, sHead, _sGroupId) end
        self.tbPhoneMsgChoiceTarget = {}

        -- 处理选项目标
        if self.tbChoiceTarget == nil then self.tbChoiceTarget = {} end
        if self.tbChoiceTarget[self.sAvgId] == nil then self.tbChoiceTarget[self.sAvgId] = {} end
        local tb = self.tbChoiceTarget[self.sAvgId]

        -- 处理路线选项跳转目标
        if self.tbMajorChoiceTarget == nil then self.tbMajorChoiceTarget = {} end
        if self.tbMajorChoiceTarget[self.sAvgId] == nil then self.tbMajorChoiceTarget[self.sAvgId] = {} end
        local tbMajor = self.tbMajorChoiceTarget[self.sAvgId]

        -- 处理性格选项跳转目标
        if self.tbPersonalityChoiceTarget == nil then self.tbPersonalityChoiceTarget = {} end
        if self.tbPersonalityChoiceTarget[self.sAvgId] == nil then self.tbPersonalityChoiceTarget[self.sAvgId] = {} end
        local tbPersonality = self.tbPersonalityChoiceTarget[self.sAvgId]

        -- 处理条件判断跳转目标
        if self.tbIfTrueTarget == nil then self.tbIfTrueTarget = {} end
        if self.tbIfTrueTarget[self.sAvgId] == nil then self.tbIfTrueTarget[self.sAvgId] = {} end
        local tbIfTrue = self.tbIfTrueTarget[self.sAvgId]

        -- 结束指令的Id
        self.END_CMD_ID = nil

        -- BadEnding Mark指令的Id
        self.BadEndingMarkId = nil

        for i, v in ipairs(self.tbAvgCfg) do
            if v.cmd == "SetChoiceBegin" then
                local sGroupId = v.param[1]
                if tb[sGroupId] == nil then tb[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} end
                tb[sGroupId].nBeginCmdId = i
            elseif v.cmd == "SetChoiceJumpTo" then
                local sGroupId = v.param[1]
                local nIndex = v.param[2]
                if tb[sGroupId] == nil then tb[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} end
                tb[sGroupId].tbTargetCmdId[nIndex] = i
            elseif v.cmd == "SetChoiceEnd" then
                local sGroupId = v.param[1]
                if tb[sGroupId] == nil then tb[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} end
                tb[sGroupId].nEndCmdId = i
            elseif v.cmd == "SetPhoneMsgChoiceBegin" then
                local sGroupId = v.param[1]
                if self.tbPhoneMsgChoiceTarget[sGroupId] == nil then self.tbPhoneMsgChoiceTarget[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} end
                self.tbPhoneMsgChoiceTarget[sGroupId].nBeginCmdId = i
            elseif v.cmd == "SetPhoneMsgChoiceJumpTo" then
                local sGroupId = v.param[1]
                local nIndex = v.param[2]
                if self.tbPhoneMsgChoiceTarget[sGroupId] == nil then self.tbPhoneMsgChoiceTarget[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} end
                self.tbPhoneMsgChoiceTarget[sGroupId].tbTargetCmdId[nIndex] = i
            elseif v.cmd == "SetPhoneMsgChoiceEnd" then
                local sGroupId = v.param[1]
                if self.tbPhoneMsgChoiceTarget[sGroupId] == nil then self.tbPhoneMsgChoiceTarget[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} end
                self.tbPhoneMsgChoiceTarget[sGroupId].nEndCmdId = i
            elseif v.cmd == "End" then
                if self.END_CMD_ID == nil then
                    self.END_CMD_ID = i
                    break -- END 指令只应配一条，END之后的指令将被忽略。
                end
            elseif v.cmd == "SetMajorChoice" then
                local nGroupId = v.param[1]
                if tbMajor[nGroupId] == nil then tbMajor[nGroupId] = {nEndCmdId = 0, tbTargetCmdId = {}} end
            elseif v.cmd == "SetMajorChoiceJumpTo" then
                local nGroupId = v.param[1]
                local nIndex = v.param[2]
                if tbMajor[nGroupId] == nil then tbMajor[nGroupId] = {nEndCmdId = 0, tbTargetCmdId = {}} end
                tbMajor[nGroupId].tbTargetCmdId[nIndex] = i
            elseif v.cmd == "SetMajorChoiceEnd" then
                local nGroupId = v.param[1]
                if tbMajor[nGroupId] == nil then tbMajor[nGroupId] = {nEndCmdId = 0, tbTargetCmdId = {}} end
                tbMajor[nGroupId].nEndCmdId = i
            elseif v.cmd == "SetPersonalityChoice" then
                local nGroupId = v.param[1]
                if tbPersonality[nGroupId] == nil then tbPersonality[nGroupId] = {nEndCmdId = 0, tbTargetCmdId = {}} end
            elseif v.cmd == "SetPersonalityChoiceJumpTo" then
                local nGroupId = v.param[1]
                local nIndex = v.param[2]
                if tbPersonality[nGroupId] == nil then tbPersonality[nGroupId] = {nEndCmdId = 0, tbTargetCmdId = {}} end
                tbPersonality[nGroupId].tbTargetCmdId[nIndex] = i
            elseif v.cmd == "SetPersonalityChoiceEnd" then
                local nGroupId = v.param[1]
                if tbPersonality[nGroupId] == nil then tbPersonality[nGroupId] = {nEndCmdId = 0, tbTargetCmdId = {}} end
                tbPersonality[nGroupId].nEndCmdId = i
            elseif v.cmd == "IfTrue" or v.cmd == "EndIf" then
                local sGroupId = v.param[1]
                if tbIfTrue[sGroupId] == nil then tbIfTrue[sGroupId] = {cmdids = {}, played = {}} end
                if table.indexof(tbIfTrue[sGroupId].cmdids, i) <= 0 then
                    table.insert(tbIfTrue[sGroupId].cmdids, i)
                    table.insert(tbIfTrue[sGroupId].played, false)
                end
            elseif v.cmd == "BadEnding_Mark" then
                self.BadEndingMarkId = i
            end
        end
        -- printTable(self.tbChoiceTarget)
        AvgData:MarkStoryId(self.sAvgId)
    end
end
function AvgPanel:ParseGroup(data, sHead, sGroupId)
    local bMatch = false
    local tbGroupData = {}
    for i, v in ipairs(data) do
        if v.cmd == "SetGroupId" then
            if sHead == "DP" and sGroupId == "PLAY_ALL_PLAY_ALL" then
                bMatch = true
            else
                bMatch = v.param[1] == sGroupId
            end
            if bMatch and sHead == "PM" then
                table.insert(tbGroupData, {cmd="SetPhone",param={0,1,1}})
            end
        else
            if bMatch or v.cmd == "End" then
                table.insert(tbGroupData, v)
            end
        end
    end
    return tbGroupData
end

-- 功能性接口
function AvgPanel:FindCmdProcFunc(sCtrlName, sCmd)
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        if objCtrl.__cname == sCtrlName then
            return { ctrl = objCtrl, func = objCtrl[sCmd] }
        end
    end
end
function AvgPanel:GetAvgCharName(sAvgCharId)
    local tbChar = self.tbAvgCharacter[sAvgCharId]
    if tbChar == nil then
        return sAvgCharId, "#0ABEC5"
    else
        return (tbChar.name or sAvgCharId), (tbChar.color or "#0ABEC5")
    end
end
function AvgPanel:GetAvgCharReuseRes(sAvgCharId)
    local tbChar = self.tbAvgCharacter[sAvgCharId]
    if tbChar == nil then
        return sAvgCharId
    else
        if tbChar.reuse == nil then
            return sAvgCharId
        else
            return tbChar.reuse
        end
    end
end
function AvgPanel:AddTimer(nTargetCount, nInterval, sCallbackName, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
    -- nTargetCount 计时器将触发几次回调，若为无限循环计时器填0，必填。
    -- nInterval 计时器触发两次回调的间隔时间，单位秒，必填。
    -- sCallbackName 回调函数名，string 类型，必填。
    -- bAutoRun 是否创建计时器后就开始运行，选填，默认true，若想手动控制启动，填false创建后将处于暂停状态，在需要处通过timer:Pause(false)来启动。
    -- bDestroyWhenComplete 是否完成后销毁，选填，默认false，为方便计时器可反复使用，若在完成后想再次使用，通过timer:Reset()来再次使用。
    -- nScaleType 默认传 nil = TimerScaleType.None，true = TimerScaleType.Unscaled, false = TimerScaleType.RealTime
    -- tbParam 自定义参数，选填写，类型任意，需要传多个参数，或复杂类型的，建议组一个 lua table 再传入。
    local callback = self[sCallbackName]
    if type(callback) == "function" then
        local timer = TimerManager.Add(nTargetCount, nInterval, self, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
        return timer
    else
        return nil
    end
end
function AvgPanel:GetBgCgFgResFullPath(sName)
    if sName == "BG_Black" then
        return "ImageAvg/AvgBg/BG_Black"
    elseif table.indexof(self.tbAvgPreset.BgResName, sName) > 0 then
        return "ImageAvg/AvgBg/"..sName
    elseif table.indexof(self.tbAvgPreset.CgResName, sName) > 0 then
        return "ImageAvg/AvgCG/"..sName
    elseif table.indexof(self.tbAvgPreset.FgResName, sName) > 0 then
        return "ImageAvg/AvgFg/"..sName
    elseif table.indexof(self.tbAvgPreset.DiscResName, sName) > 0 then
        local sFolderName = string.gsub(sName, "_B", "")
        return "Disc/"..sFolderName.."/"..sName
    else
        return nil
    end
end
function AvgPanel:GetAvgContactsData(sContactsId)
    local tbContacts = self.tbAvgContacts[sContactsId]
    if tbContacts == nil then
        return sContactsId
    else
        return tbContacts
    end
end
function AvgPanel:GetNextProcFunc(nextIndex)
    if self.nCurIndex ~= nil then
        if nextIndex == nil then
            nextIndex = 1
        end
        return self.tbAvgCfg[self.nCurIndex + nextIndex]
    end
end

-- 事件
function AvgPanel:OnEvent_AvgSkipCheck()
    if self.timerWaiting ~= nil then
        self.timerWaiting:Pause(true) -- 先暂停不销毁，取消梗概弹窗后可以续播，但如果是跳转至路线或执行连播逻辑则再销毁。
    end
    local sCmdName, nJumpTo = nil, nil
    -- a00.检查下文是否有：BadEnding_Check 指令
    for i = self.nCurIndex, self.END_CMD_ID, 1 do
        sCmdName = self.tbAvgCfg[i].cmd
        if sCmdName == "BadEnding_Check" then
            self:BadEnding_Check()
            break
        end
    end
    -- a01.检查下文是否有：SetIntro 指令
    for i = self.nCurIndex, self.END_CMD_ID, 1 do
        sCmdName = self.tbAvgCfg[i].cmd
        if sCmdName == "SetIntro" then
            local param = self.tbAvgCfg[i].param
            local objCtrl = self.mapProcFunc[sCmdName].ctrl -- 处理指令的实例
            local ProcFunc = self.mapProcFunc[sCmdName].func -- 处理指令的方法
            ProcFunc(objCtrl, param)
            break
        end
    end
    -- a.检查下文是否有：路线选项指令、创角指令
    for i = self.nCurIndex, self.END_CMD_ID, 1 do
        sCmdName = self.tbAvgCfg[i].cmd
        if sCmdName == "SetMajorChoice" then
            nJumpTo = i
            break
        end
    end
    -- b.检查是否弹梗概小窗
    if nJumpTo == nil then
        EventManager.Hit(EventId.AvgSkipCheckIntro)
    else
        if self.timerWaiting ~= nil then
            self.timerWaiting:Cancel()
            self.timerWaiting = nil
        end
        self.nJumpTarget = nJumpTo
        self:RUN()
    end
end
function AvgPanel:OnEvent_AvgSkip()
    local nJumpTo = nil
    local mapConfig = self.tbAvgCfg[self.END_CMD_ID - 1]
    if mapConfig ~= nil and mapConfig.cmd == "JUMP_AVG_ID" then
        nJumpTo = self.END_CMD_ID - 1
    end
    if nJumpTo ~= nil then
        self.nJumpTarget = nJumpTo
    else
        self.nJumpTarget = self.END_CMD_ID
    end
    self:RUN()
end
function AvgPanel:OnEvent_AvgTryResume()
    if self.timerWaiting ~= nil then
        self.timerWaiting:Pause(false)
    end
end
function AvgPanel:OnEvent_AvgSpeedUp(nRate)
    printLog("Avg加速 AvgPanel " .. nRate)
    self.nSpeedRate = nRate
    DOTween.unscaledTimeScale = nRate
    if self.timerWaiting ~= nil then
        self.timerWaiting:SetSpeed(nRate)
    end
    --[[ DOTween.KillAll(true)
    if self.timerWaiting ~= nil then
        self.timerWaiting:Cancel()
        self:_onWaitComplete()
    end ]]
end

-- 执行指令主逻辑
function AvgPanel:RUN()
    if type(self.sExecutingCMDName) == "string" then
        printError(string.format("当前指令 %s 尚未执行完成，在一帧里又调用了一次 AvgPanel:RUN() 接口，必须排查此严重错误！！", self.sExecutingCMDName))
        return
    end
    if self.timerWaiting ~= nil then
        self.timerWaiting:Cancel()
        self.timerWaiting = nil
    end
    if self.nCurIndex == nil then return end
    if self.nJumpTarget ~= nil then
        self.nCurIndex = self.nJumpTarget
        self.nJumpTarget = nil
    end
    local mapConfig = self.tbAvgCfg[self.nCurIndex]
    local sCmd = mapConfig.cmd -- 指令名
    local tbParam = mapConfig.param -- 指令参数
    if self.mapProcFunc[sCmd] == nil then -- 临时容错处理
        printError("未找到该指令：" .. sCmd)
        return
    end
    local objCtrl = self.mapProcFunc[sCmd].ctrl -- 处理指令的实例
    local ProcFunc = self.mapProcFunc[sCmd].func -- 处理指令的方法
    local nWaitTime = 0
    self.sExecutingCMDName = sCmd
    nWaitTime = ProcFunc(objCtrl, tbParam)
    self.sExecutingCMDName = nil
    printLog(string.format("索引:%s指令:%s耗时:%f", self.nCurIndex or "nil", sCmd, nWaitTime))
    if type(self.nCurIndex) == "number" then
        self.nCurIndex = self.nCurIndex + 1
    end
    if nWaitTime < 0 then -- 暂停执行下文指令。
        return
    elseif nWaitTime > 0 then -- 等待后继续执行下文指令。
        self:Wait({nWaitTime})
    else -- 直接继续执行下文指令。
        self:RUN()
    end
end
function AvgPanel:End()
    EventManager.Remove(EventId.AvgSkipCheck, self, self.OnEvent_AvgSkipCheck)
    EventManager.Remove(EventId.AvgSkip, self, self.OnEvent_AvgSkip)
    EventManager.Remove(EventId.AvgTryResume, self, self.OnEvent_AvgTryResume)
    EventManager.Remove(EventId.AvgSpeedUp, self, self.OnEvent_AvgSpeedUp)
    EventManager.Remove(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
    EventManager.Hit(EventId.BlockInput, true)
    self.nCurIndex = nil
    local _objCtrl
    local _ProcFunc
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        if objCtrl.__cname == "Avg_9_CurtainCtrl" then -- 通过遍历找它是因为它没做进指令集（非必要）
            _objCtrl = objCtrl
            _ProcFunc = _objCtrl["SetEnd"]
            break
        end
    end
    if self.AVG_NO_BG_MODE == true then
        self:onEnd() -- 不需要落幕，直接结束。
    else
        local nTime = _ProcFunc(_objCtrl, false) -- 完成落幕后再结束。
        self:AddTimer(1, nTime, "onEnd", true, true, true)
    end
    return -1
end
function AvgPanel:onEnd()
    if self.nCurIndex == 1 then
        return
    end
    AVG_EDITOR_PLAYING = nil
    self:SetSystemBgm(false) -- 恢复（续播）AVG外的系统BGM
    self:OnEvent_AvgSpeedUp(1)
    EventManager.Hit(EventId.BlockInput, false)
    EventManager.Hit("StoryDialog_DialogEnd")
end
function AvgPanel:Jump(tbParam)
    local nIndex = tbParam[1]
    self.nJumpTarget = nIndex
    return 0
end
function AvgPanel:Wait(tbParam) -- nTime 等待一段时长后再执行下文指令，单位：秒。
    local nTime = tbParam[1]
    if nTime > 0 then
        self.timerWaiting = self:AddTimer(1, nTime, "_onWaitComplete", true, true, true)
        self.timerWaiting:SetSpeed(self.nSpeedRate)
    end
    return -1
end
function AvgPanel:_onWaitComplete() -- 等待完成继续执行下文指令。
    self.timerWaiting = nil
    self:RUN()
end
function AvgPanel:SetGroupId()
    return 0
end

-- 备注指令（无实际演出效果）
function AvgPanel:Comment(tbParam)
    return 0
end

-- 选项类跳转
function AvgPanel:SetChoiceJumpTo(nGroupId, nIndex)
    local tb = self.tbChoiceTarget[self.sAvgId]
    local tbData = tb[nGroupId] -- 按 组id + 索引 找到跳转目标指令 id
    if tbData ~= nil then
        self.nCurIndex = tbData.tbTargetCmdId[tostring(nIndex)]
        self:RUN()
    end
end
function AvgPanel:SetChoiceRollback(nGroupId)
    local tb = self.tbChoiceTarget[self.sAvgId]
    local tbData = tb[nGroupId]
    if tbData ~= nil then
        self.nJumpTarget = tbData.nBeginCmdId
    end
end
function AvgPanel:SetChoiceRollover(nGroupId)
    local tb = self.tbChoiceTarget[self.sAvgId]
    local tbData = tb[nGroupId]
    if tbData ~= nil then
        self.nJumpTarget = tbData.nEndCmdId
    end
end

-- 手机选项类跳转
function AvgPanel:SetPhoneMsgChoiceJumpTo(nGroupId, nIndex)
    local tbData = self.tbPhoneMsgChoiceTarget[nGroupId] -- 按 组id + 索引 找到跳转目标指令 id
    if tbData ~= nil then
        self.nCurIndex = tbData.tbTargetCmdId[tostring(nIndex)]
        self:RUN()
    end
end
function AvgPanel:SetPhoneMsgChoiceEnd(nGroupId)
    local tbData = self.tbPhoneMsgChoiceTarget[tostring(nGroupId)] -- 按 组id + 索引 找到跳转目标指令 id
    if tbData ~= nil then
        self.nJumpTarget = tbData.nEndCmdId
    end
end

-- 重要选项指令：路线选项 跳转相关
function AvgPanel:SetMajorChoiceJumpTo(nGroupId, nIndex)
    local tbMajor = self.tbMajorChoiceTarget[self.sAvgId]
    local tbMajorData = tbMajor[nGroupId]
    if tbMajorData ~= nil then
        self.nCurIndex = tbMajorData.tbTargetCmdId[nIndex]
        self:RUN()
    end
end
function AvgPanel:SetMajorChoiceRollover(nGroupId)
    local tbMajor = self.tbMajorChoiceTarget[self.sAvgId]
    local tbMajorData = tbMajor[nGroupId]
    if tbMajorData ~= nil then
        self.nJumpTarget = tbMajorData.nEndCmdId
    end
end

-- 重要选项指令：性格选项 跳转相关
function AvgPanel:SetPersonalityChoiceJumpTo(nGroupId, nIndex)
    local tbPersonality = self.tbPersonalityChoiceTarget[self.sAvgId]
    local tbPersonalityData = tbPersonality[nGroupId]
    if tbPersonalityData ~= nil then
        self.nCurIndex = tbPersonalityData.tbTargetCmdId[nIndex]
        self:RUN()
    end
end
function AvgPanel:SetPersonalityChoiceRollover(nGroupId)
    local tbPersonality = self.tbPersonalityChoiceTarget[self.sAvgId]
    local tbPersonalityData = tbPersonality[nGroupId]
    if tbPersonalityData ~= nil then
        self.nJumpTarget = tbPersonalityData.nEndCmdId
    end
end

-- 条件判断跳转
local tbChoiceABC = {"a","b","c"}
function AvgPanel:IfTrue(tbParam)
    local sIfTrueGroupId = tbParam[1] -- IfTrue 指令自己的组id（string）
    local bIsMajorChoice = tbParam[2] == 0 -- 0路径选项指令，1性格选项指令
    local sAvgId = tbParam[3] -- 演出配置文件名 AAA.lua （只需填 AAA 即可）
    local nChoiceGroupId = tbParam[4] -- 选项指令的组id（number）
    local tbParamData = string.split(tbParam[5], "|") -- 范例：b2|c2|b1+c1，意思是：选过2次b时，或选过2次c时，或（选过1次b并且选过1次c）时，判断成功。
    local bResult, nParamLen, sABC, nCount
    for i, v in ipairs(tbParamData) do
        -- v 与 v 之间是逻辑“或”关系，因此只要判断到一个 true 即可 break 掉 for 循环。
        local tbParamGroupData = string.split(v, "+")
        for ii, vv in ipairs(tbParamGroupData) do
            -- 如果还含有逻辑“与”，则数组长度>1，并且只要判断到一个 false 即可 break 掉。
            nParamLen = string.len(vv)
            sABC = string.sub(vv, 1, 1)
            sABC = string.lower(sABC) -- 强转小写 abc，得出判断的是选A/B/C
            if nParamLen > 1 then
                nCount = tonumber(string.sub(vv, 2)) or 1 -- 得出判断的是选过的次数（若>=则判断成功）
            else
                nCount = 1
            end
            bResult = AvgData:CheckIfTrue(bIsMajorChoice, sAvgId, nChoiceGroupId, table.indexof(tbChoiceABC, sABC), nCount)
            if bResult ~= true then
                break -- 记库数据和临时数据都判断失败，则此块 含逻辑“与” 的参数，整体立即判断为 false 失败。
            end
        end
        if bResult == true then
            break -- 若某块参数判断成功，则本次 if true 指令立即判断为 true 成功。
        end
    end
    local tbIfTrueCmdIds = self.tbIfTrueTarget[self.sAvgId][sIfTrueGroupId].cmdids
    local tbPlayed = self.tbIfTrueTarget[self.sAvgId][sIfTrueGroupId].played
    local nIdx = table.indexof(tbIfTrueCmdIds, self.nCurIndex)
    if nIdx > 1 then
        if tbPlayed[nIdx - 1] == true then
            local nNum = #tbIfTrueCmdIds
            self.nJumpTarget = tbIfTrueCmdIds[nNum]
            return 0
        end
    end
    if bResult == true then
        tbPlayed[nIdx] = true
    else
        self.nJumpTarget = tbIfTrueCmdIds[nIdx + 1]
    end
    return 0 -- 立即往下执行（可能是播彩蛋的演出，也可能是跳去下一处 if true 或 end if 处）
end
function AvgPanel:EndIf(tbParam)
    return 0
end

-- 音效类指令
function AvgPanel:SetBGM(tbParam)
    local nType = tbParam[1] -- 0播放，1停止，2暂停，3恢复，4音量。
    local sVolume = tbParam[2] -- 详见 AvgPreset.BgmVol
    local nTrackIndex = tbParam[3] + 1 -- BGM音轨索引，目前就2条BGM音轨。
    local sBgmName = tbParam[4] -- 仅在 nType = 0 时有效。
    local sFadeTime = tbParam[5] -- 为 none 时即表示无 fade 效果。
    local nDuration = tbParam[6]
    local bWait = tbParam[7]
    if nType == 4 then -- 调BGM音量，会同时影响2个音轨
        WwiseAudioMgr:PostEvent(sVolume)
    else
        local sBaseName = "avg_track" .. tostring(nTrackIndex)
        local sWwiseEventName = sBaseName
        if nType == 0 then
            WwiseAudioMgr:SetState(sBaseName, sBgmName)
            if sFadeTime ~= "none" then
                sWwiseEventName = sWwiseEventName .. "_fadeIn_" .. sFadeTime -- 例：avg_track1_fadeIn_500ms
            end
        elseif nType == 1 then
            sWwiseEventName = sWwiseEventName .. "_stop"
            if sFadeTime ~= "none" then
                sWwiseEventName = sWwiseEventName .. "_fadeOut_" .. sFadeTime -- 例：avg_track1_stop_fadeOut_500ms
            end
        elseif nType == 2 then
            sWwiseEventName = sWwiseEventName .. "_pause"
            if sFadeTime ~= "none" then
                sWwiseEventName = sWwiseEventName .. "_fadeOut_" .. sFadeTime -- 例：avg_track1_pause_fadeOut_500ms
            end
        elseif nType == 3 then
            sWwiseEventName = sWwiseEventName .. "_resume"
            if sFadeTime ~= "none" then
                sWwiseEventName = sWwiseEventName .. "_fadeIn_" .. sFadeTime -- 例：avg_track1_resume_fadeIn_500ms
            end
        end
        WwiseAudioMgr:PostEvent(sWwiseEventName)
        if nType == 0 then WwiseAudioMgr:PostEvent(sVolume) end
    end
    if bWait == true and nDuration > 0 then
        return nDuration
    else
        return 0
    end
end
function AvgPanel:SetAudio(tbParam) -- 暂时不支持控制音效的音量。
    local nType = tbParam[1] -- 0音效环境音，1播角色语音，2关角色语音
    local sName = tbParam[2]
    local nDuration = tbParam[3]
    local bWait = tbParam[4]
    if sName ~= "" then
        if nType == 0 then
            WwiseAudioMgr:PlaySound(sName) -- 音效、环境音，如果是想停止循环的，配置的 name 后缀接 _stop 即可。
        elseif nType == 1 then
            WwiseAudioMgr:WwiseVoice_PlayInAVG(sName)
        elseif nType == 2 then
            self.bProcVoiceCallbackEvent = false
            WwiseAudioMgr:WwiseVoice_StopInAVG()
        end
    end
    if bWait == true then
        if nDuration > 0 then
            return nDuration
        elseif nDuration < 0 and nType == 1 then
            self.bProcVoiceCallbackEvent = true
            return -1 -- 因为播语音的接口不是同步返回语音时长，接下去播指令详见OnEvent_AvgVoiceDuration接口。
        else
            return 0
        end
    else
        return 0
    end
end
function AvgPanel:SetSystemBgm(bPause) -- 控制AVG外的系统BGM，暂停或续播。
    if bPause == true then
        if ModuleManager.GetIsAdventure() == true then
            WwiseAudioMgr:PostEvent("avg_combat_enter")
        else
            if self.sAvgCfgHead ~= "DP" then
                WwiseAudioMgr:PostEvent("avg_enter")
            end
        end
    else
        if ModuleManager.GetIsAdventure() == true then
            WwiseAudioMgr:PostEvent("avg_combat_exit")
        else
            if self.sAvgCfgHead ~= "DP" then
                WwiseAudioMgr:PostEvent("avg_exit")
            end
        end
        -- 无脑卸载AVG相关的BNK，BNK的名字是由音效组提供的，并约定不会变（不会新增或删除）。
        NovaAPI.UnloadWwiseSoundBank("AVG")
        NovaAPI.UnloadWwiseSoundBank("Music_AVG")
    end
end
function AvgPanel:PlayCharEmojiSound(sEmojiName)
    for i, v in ipairs(self.tbAvgPreset.CharEmoji) do
        if v[3] == sEmojiName then
            local sEmojiSound = v[4]
            if type(sEmojiSound) == "string" and sEmojiSound ~= "" then self:SetAudio({0, sEmojiSound}) end
            break
        end
    end
end
function AvgPanel:PlayFxSound(sFxName, bPlay)
    for _, v in ipairs(self.tbAvgPreset.FxResName) do
        if v[1] == sFxName then
            local sFxSound = v[2]
            if type(sFxSound) == "string" and sFxSound ~= "" then
                if bPlay ~= true then
                    sFxSound = sFxSound .. "_stop"
                end
                self:SetAudio({0, sFxSound})
            end
            break
        end
    end
end
function AvgPanel:OnEvent_AvgVoiceDuration(nDuration)
    if self.bProcVoiceCallbackEvent == true then
        self.bProcVoiceCallbackEvent = false
        if nDuration > 0 then
            self:Wait({nDuration})
        end
    else
        --printLog("单播角色语音回调" .. nDuration)
    end
end

-- 组合封装指令
function AvgPanel:Clear(tbParam)
    local bClearChar = tbParam[1]
    local nDuration = tbParam[2]
    local bWait = tbParam[3]
    local bClearTalk = tbParam[4]
    if bClearChar == true then EventManager.Hit(EventId.AvgClearAllChar, nDuration) end
    if bClearTalk == true then EventManager.Hit(EventId.AvgClearTalk) end
    if bWait == true and type(nDuration) == "number" and nDuration > 0 then
        return nDuration
    else
        return 0
    end
end

function AvgPanel:GetCharEmojiIndex(sEmoji)
    if self.tbAvgPreset ~= nil then
        for i, v in ipairs(self.tbAvgPreset.CharEmoji) do
            if v[3] == sEmoji then
                return v[1]
            end
        end
    end
    return 0
end

-- 跨演出配置跳转
function AvgPanel:BadEnding_Check(tbParam)
    -- 单播 BE 时需确保一定会执行，将末尾“还原舞台并跳回”的演出给移除掉。
    if type(self.BadEndingMarkId) == "number" then
        if self.BadEndingMarkId > self.nCurIndex and self.BadEndingMarkId < self.END_CMD_ID then
            local nRemoveBegin = self.END_CMD_ID - 1
            local nRemoveEnd = self.BadEndingMarkId
            for i = (self.END_CMD_ID - 1), self.BadEndingMarkId, -1 do
                table.remove(self.tbAvgCfg, i)
                self.END_CMD_ID = self.END_CMD_ID - 1
            end
            -- 处理 BE 的 “再来一点” 的需求：把配在 END 之后的演出往前移。
            if #self.tbAvgCfg > self.END_CMD_ID then
                table.remove(self.tbAvgCfg, self.END_CMD_ID)
                table.insert(self.tbAvgCfg, {cmd="End"})
                self.END_CMD_ID = #self.tbAvgCfg
            end 
        end
    end
    return 0
end
function AvgPanel:BadEnding_Mark(tbParam)
    return 0
end
function AvgPanel:JUMP_AVG_ID(tbParam)
    local sAvgId = tbParam[1]
    local nCmdId = tbParam[2]
    local sBE = tbParam[3] or ""
    if sBE == "A" then self.nBEIndex = 1
    elseif sBE == "B" then self.nBEIndex = 2
    elseif sBE == "C" then self.nBEIndex = 3
    end
    if sAvgId == nil then return -1 end
    if nCmdId == nil then nCmdId = 1 end
    EventManager.Hit(EventId.TemporaryBlockInput, 1)
    if self.sAvgCfgPath ~= nil then
        package.loaded[self.sAvgCfgPath] = nil
        self.sAvgCfgPath = nil
    end
    self.sAvgId = sAvgId
    self.sAvgCfgPath = self.sRootPath .. "Config/" .. self.sAvgId
    self:RequireAndPreProcAvgConfig(self.sAvgCfgPath)
    printLog("Jump to AvgId:" .. sAvgId)
    self.nJumpTarget = nCmdId
    return 0
end

-- 手柄启用和退出
function AvgPanel:EnableGamepad()
    -- avg会穿插在战斗界面内或单独打开，要分这两种处理
    self.bHasOtherGamepadUI = GamepadUIManager.GetInputState()
    if not self.bHasOtherGamepadUI then
        GamepadUIManager.EnterAdventure(true)
    end
    GamepadUIManager.EnableGamepadUI("AVG", {}) -- 子ctrl在OnEnable的时候会添加节点
    self.sCurGamepadUI = nil
end

function AvgPanel:DisableGamepad()
    self.sCurGamepadUI = nil
    GamepadUIManager.DisableGamepadUI("AVG")
    if not self.bHasOtherGamepadUI then
        GamepadUIManager.QuitAdventure()
    end
end

return AvgPanel
