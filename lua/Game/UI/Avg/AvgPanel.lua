local AvgPanel = class("AvgPanel", BasePanel)
local AvgData = PlayerData.Avg
local TimerManager = require("GameCore.Timer.TimerManager")
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local ModuleManager = require("GameCore.Module.ModuleManager")
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
AvgPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
AvgPanel._bAddToBackHistory = false
AvgPanel._tbDefine = {
{sPrefabPath = "Avg/Editor/Actor2DEditorAvgPanel.prefab"}
, 
{sPrefabPath = "Avg/Avg_0_Stage.prefab", sCtrlName = "Game.UI.Avg.Avg_0_Stage"}
, 
{sPrefabPath = "Avg/Avg_2_CHAR.prefab", sCtrlName = "Game.UI.Avg.Avg_2_CharCtrl"}
, 
{sPrefabPath = "Avg/Avg_2_L2D.prefab", sCtrlName = "Game.UI.Avg.Avg_2_L2DCtrl"}
, 
{sPrefabPath = "Avg/Avg_3_Transition.prefab", sCtrlName = "Game.UI.Avg.Avg_3_TransitionCtrl"}
, 
{sPrefabPath = "Avg/Avg_4_Talk.prefab", sCtrlName = "Game.UI.Avg.Avg_4_TalkCtrl"}
, 
{sPrefabPath = "Avg/Avg_5_Phone.prefab", sCtrlName = "Game.UI.Avg.Avg_5_PhoneCtrl"}
, 
{sPrefabPath = "Avg/Avg_6_Menu.prefab", sCtrlName = "Game.UI.Avg.Avg_6_MenuCtrl"}
, 
{sPrefabPath = "Avg/Avg_7_Choice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_ChoiceCtrl"}
, 
{sPrefabPath = "Avg/Avg_7_MajorChoice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_MajorChoiceCtrl"}
, 
{sPrefabPath = "Avg/Avg_7_PersonalityChoice.prefab", sCtrlName = "Game.UI.Avg.Avg_7_PersonalityChoiceCtrl"}
, 
{sPrefabPath = "Avg/Avg_8_Log.prefab", sCtrlName = "Game.UI.Avg.Avg_8_LogCtrl"}
, 
{sPrefabPath = "Avg/Avg_9_Curtain.prefab", sCtrlName = "Game.UI.Avg.Avg_9_CurtainCtrl"}
}
if RUNNING_ACTOR2D_EDITOR ~= true then
  (table.remove)(AvgPanel._tbDefine, 1)
end
AvgPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : TimerManager, _ENV
  self:EnableGamepad()
  ;
  (TimerManager.ForceFrameUpdate)(true)
  self.sTxtLan = (self._tbParam)[2]
  self.nCurLanguageIdx = GetLanguageIndex(self.sTxtLan)
  self.sVoLan = (self._tbParam)[3]
  self.sVoResNameSurfix = ""
  for k,v in pairs(AllEnum.LanguageInfo) do
    if v[1] == self.sVoLan then
      self.sVoResNameSurfix = v[3]
      break
    end
  end
  do
    self.bIsPlayerMale = (PlayerData.Base):GetPlayerSex() == true
    self.sPlayerNickName = (PlayerData.Base):GetPlayerNickName()
    self.sAvgId = (self._tbParam)[1]
    self.sRootPath = GetAvgLuaRequireRoot(self.nCurLanguageIdx)
    self.sAvgCfgPath = self.sRootPath .. "Config/" .. self.sAvgId
    self.sAvgCharacterPath = self.sRootPath .. "Preset/AvgCharacter"
    self.sAvgPresetPath = "Game.UI.Avg.AvgPreset"
    self.sAvgContactsPath = self.sRootPath .. "Preset/AvgContacts"
    self.sAvgCfgHead = (string.sub)(self.sAvgId, 1, 2)
    if self.sAvgCfgHead == "BT" or self.sAvgCfgHead == "DP" or self.sAvgCfgHead == "GD" then
      self.AVG_NO_BG_MODE = true
    end
    self:RequireAndPreProcAvgConfig(self.sAvgCfgPath, self.sAvgCfgHead, (self._tbParam)[4])
    local tbAvgChar = require(self.sAvgCharacterPath)
    self.tbAvgCharacter = {}
    for i,v in ipairs(tbAvgChar) do
      -- DECOMPILER ERROR at PC108: Confused about usage of register: R7 in 'UnsetPending'

      (self.tbAvgCharacter)[v.id] = {name = v.name, reuse = v.reuse, color = v.name_bg_color, reuseL2DPose = v.reuseL2DPose}
    end
    self.tbAvgPreset = require(self.sAvgPresetPath)
    self.nCurIndex = 1
    local nStartIndex = (self._tbParam)[5]
    if type(nStartIndex) == "number" and nStartIndex > 0 and nStartIndex < #self.tbAvgCfg then
      self.nCurIndex = nStartIndex
    end
    self.nJumpTarget = nil
    self:SetSystemBgm(true)
    ;
    ((CS.AdventureModuleHelper).PauseLogic)()
    local tbContacts = require(self.sAvgContactsPath)
    self.tbAvgContacts = {}
    for i,v in ipairs(tbContacts) do
      -- DECOMPILER ERROR at PC158: Confused about usage of register: R9 in 'UnsetPending'

      (self.tbAvgContacts)[v.id] = {name = v.name, signature = ProcAvgTextContent(v.signature), icon = v.icon}
    end
    self.nSpeedRate = 1
    ;
    (EventManager.Add)(EventId.AvgSpeedUp, self, self.OnEvent_AvgSpeedUp)
    self.sExecutingCMDName = nil
    self.nBEIndex = 0
    -- DECOMPILER ERROR: 6 unprocessed JMP targets
  end
end

AvgPanel.OnEnable = function(self)
  -- function num : 0_1 , upvalues : _ENV, WwiseAudioMgr
  self:BindCmdProcFunc()
  ;
  (EventManager.Add)(EventId.AvgSkipCheck, self, self.OnEvent_AvgSkipCheck)
  ;
  (EventManager.Add)(EventId.AvgSkip, self, self.OnEvent_AvgSkip)
  ;
  (EventManager.Add)(EventId.AvgTryResume, self, self.OnEvent_AvgTryResume)
  ;
  (EventManager.Add)(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
  if AVG_EDITOR == true then
    self:AddTimer(1, 1, "DelayRunInAvgEditor", true, true, true)
  else
    if self.sAvgCfgHead == "DP" then
      WwiseAudioMgr:PlaySound("ui_dispatch_dialogue_enter")
    end
    self:RUN()
  end
end

AvgPanel.BindCmdProcFunc = function(self)
  -- function num : 0_2
  self.mapProcFunc = {}
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetBg = self:FindCmdProcFunc("Avg_0_Stage", "SetBg")
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).CtrlBg = self:FindCmdProcFunc("Avg_0_Stage", "CtrlBg")
  -- DECOMPILER ERROR at PC19: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetStage = self:FindCmdProcFunc("Avg_0_Stage", "SetStage")
  -- DECOMPILER ERROR at PC25: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).CtrlStage = self:FindCmdProcFunc("Avg_0_Stage", "CtrlStage")
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetFx = self:FindCmdProcFunc("Avg_0_Stage", "SetFx")
  -- DECOMPILER ERROR at PC37: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetFrontObj = self:FindCmdProcFunc("Avg_0_Stage", "SetFrontObj")
  -- DECOMPILER ERROR at PC43: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetHeartBeat = self:FindCmdProcFunc("Avg_0_Stage", "SetHeartBeat")
  -- DECOMPILER ERROR at PC49: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPP = self:FindCmdProcFunc("Avg_0_Stage", "SetPP")
  -- DECOMPILER ERROR at PC55: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPPGlobal = self:FindCmdProcFunc("Avg_0_Stage", "SetPPGlobal")
  -- DECOMPILER ERROR at PC61: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetChar = self:FindCmdProcFunc("Avg_2_CharCtrl", "SetChar")
  -- DECOMPILER ERROR at PC67: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).CtrlChar = self:FindCmdProcFunc("Avg_2_CharCtrl", "CtrlChar")
  -- DECOMPILER ERROR at PC73: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).PlayCharAnim = self:FindCmdProcFunc("Avg_2_CharCtrl", "PlayCharAnim")
  -- DECOMPILER ERROR at PC79: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetCharHead = self:FindCmdProcFunc("Avg_2_CharCtrl", "SetCharHead")
  -- DECOMPILER ERROR at PC85: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).CtrlCharHead = self:FindCmdProcFunc("Avg_2_CharCtrl", "CtrlCharHead")
  -- DECOMPILER ERROR at PC91: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetL2D = self:FindCmdProcFunc("Avg_2_L2DCtrl", "SetL2D")
  -- DECOMPILER ERROR at PC97: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).CtrlL2D = self:FindCmdProcFunc("Avg_2_L2DCtrl", "CtrlL2D")
  -- DECOMPILER ERROR at PC103: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetCharL2D = self:FindCmdProcFunc("Avg_2_L2DCtrl", "SetCharL2D")
  -- DECOMPILER ERROR at PC109: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetFilm = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "SetFilm")
  -- DECOMPILER ERROR at PC115: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetTrans = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "SetTrans")
  -- DECOMPILER ERROR at PC121: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetWordTrans = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "SetWordTrans")
  -- DECOMPILER ERROR at PC127: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).PlayVideo = self:FindCmdProcFunc("Avg_3_TransitionCtrl", "PlayVideo")
  -- DECOMPILER ERROR at PC133: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetTalk = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetTalk")
  -- DECOMPILER ERROR at PC139: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetTalkShake = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetTalkShake")
  -- DECOMPILER ERROR at PC145: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetGoOn = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetGoOn")
  -- DECOMPILER ERROR at PC151: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetMainRoleTalk = self:FindCmdProcFunc("Avg_4_TalkCtrl", "SetMainRoleTalk")
  -- DECOMPILER ERROR at PC157: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPhone = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhone")
  -- DECOMPILER ERROR at PC163: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPhoneMsg = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsg")
  -- DECOMPILER ERROR at PC169: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPhoneThinking = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneThinking")
  -- DECOMPILER ERROR at PC175: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPhoneMsgChoiceBegin = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsgChoiceBegin")
  -- DECOMPILER ERROR at PC181: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPhoneMsgChoiceJumpTo = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsgChoiceJumpTo")
  -- DECOMPILER ERROR at PC187: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPhoneMsgChoiceEnd = self:FindCmdProcFunc("Avg_5_PhoneCtrl", "SetPhoneMsgChoiceEnd")
  -- DECOMPILER ERROR at PC193: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetChoiceBegin = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceBegin")
  -- DECOMPILER ERROR at PC199: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetChoiceJumpTo = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceJumpTo")
  -- DECOMPILER ERROR at PC205: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetChoiceRollback = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceRollback")
  -- DECOMPILER ERROR at PC211: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetChoiceRollover = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceRollover")
  -- DECOMPILER ERROR at PC217: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetChoiceEnd = self:FindCmdProcFunc("Avg_7_ChoiceCtrl", "SetChoiceEnd")
  -- DECOMPILER ERROR at PC223: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetMajorChoice = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoice")
  -- DECOMPILER ERROR at PC229: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetMajorChoiceJumpTo = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoiceJumpTo")
  -- DECOMPILER ERROR at PC235: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetMajorChoiceRollover = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoiceRollover")
  -- DECOMPILER ERROR at PC241: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetMajorChoiceEnd = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "SetMajorChoiceEnd")
  -- DECOMPILER ERROR at PC247: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPersonalityChoice = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoice")
  -- DECOMPILER ERROR at PC253: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPersonalityChoiceJumpTo = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoiceJumpTo")
  -- DECOMPILER ERROR at PC259: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPersonalityChoiceRollover = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoiceRollover")
  -- DECOMPILER ERROR at PC265: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetPersonalityChoiceEnd = self:FindCmdProcFunc("Avg_7_PersonalityChoiceCtrl", "SetPersonalityChoiceEnd")
  -- DECOMPILER ERROR at PC271: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).IfTrue = {ctrl = self, func = self.IfTrue}
  -- DECOMPILER ERROR at PC277: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).EndIf = {ctrl = self, func = self.EndIf}
  -- DECOMPILER ERROR at PC283: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).GetEvidence = self:FindCmdProcFunc("Avg_7_MajorChoiceCtrl", "GetEvidence")
  -- DECOMPILER ERROR at PC289: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).IfUnlock = {ctrl = self, func = self.IfUnlock}
  -- DECOMPILER ERROR at PC295: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).IfUnlockElse = {ctrl = self, func = self.IfUnlockElse}
  -- DECOMPILER ERROR at PC301: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).IfUnlockEnd = {ctrl = self, func = self.IfUnlockEnd}
  -- DECOMPILER ERROR at PC307: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetAudio = {ctrl = self, func = self.SetAudio}
  -- DECOMPILER ERROR at PC313: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetBGM = {ctrl = self, func = self.SetBGM}
  -- DECOMPILER ERROR at PC319: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetSceneHeading = self:FindCmdProcFunc("Avg_6_MenuCtrl", "SetSceneHeading")
  -- DECOMPILER ERROR at PC325: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetIntro = self:FindCmdProcFunc("Avg_6_MenuCtrl", "SetIntro")
  -- DECOMPILER ERROR at PC331: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).NewCharIntro = self:FindCmdProcFunc("Avg_6_MenuCtrl", "NewCharIntro")
  -- DECOMPILER ERROR at PC337: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).Wait = {ctrl = self, func = self.Wait}
  -- DECOMPILER ERROR at PC343: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).Jump = {ctrl = self, func = self.Jump}
  -- DECOMPILER ERROR at PC349: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).Clear = {ctrl = self, func = self.Clear}
  -- DECOMPILER ERROR at PC355: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).End = {ctrl = self, func = self.End}
  -- DECOMPILER ERROR at PC361: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).SetGroupId = {ctrl = self, func = self.SetGroupId}
  -- DECOMPILER ERROR at PC367: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).Comment = {ctrl = self, func = self.Comment}
  -- DECOMPILER ERROR at PC373: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).BadEnding_Check = {ctrl = self, func = self.BadEnding_Check}
  -- DECOMPILER ERROR at PC379: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).BadEnding_Mark = {ctrl = self, func = self.BadEnding_Mark}
  -- DECOMPILER ERROR at PC385: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (self.mapProcFunc).JUMP_AVG_ID = {ctrl = self, func = self.JUMP_AVG_ID}
end

AvgPanel.DelayRunInAvgEditor = function(self)
  -- function num : 0_3 , upvalues : WwiseAudioMgr
  WwiseAudioMgr.MusicVolume = 10
  if self.sAvgCfgHead == "DP" then
    WwiseAudioMgr:PlaySound("ui_dispatch_dialogue_enter")
  end
  self:RUN()
end

AvgPanel.OnDisable = function(self)
  -- function num : 0_4 , upvalues : _ENV, TimerManager
  self.mapProcFunc = nil
  if self.tbAvgCfg ~= nil then
    self.tbAvgCfg = nil
  end
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (package.loaded)[self.sAvgCfgPath] = nil
  self.sAvgCfgPath = nil
  if self.tbAvgCharacter ~= nil then
    self.tbAvgCharacter = nil
  end
  -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (package.loaded)[self.sAvgCharacterPath] = nil
  self.sAvgCharacterPath = nil
  if self.tbAvgPreset ~= nil then
    self.tbAvgPreset = nil
  end
  -- DECOMPILER ERROR at PC26: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (package.loaded)[self.sAvgPresetPath] = nil
  self.sAvgPresetPath = nil
  if self.tbAvgContacts ~= nil then
    self.tbAvgContacts = nil
  end
  -- DECOMPILER ERROR at PC35: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (package.loaded)[self.sAvgContactsPath] = nil
  self.sAvgContactsPath = nil
  ;
  ((CS.AdventureModuleHelper).ResumeLogic)()
  ;
  (TimerManager.ForceFrameUpdate)(false)
  self:DisableGamepad()
end

AvgPanel.RequireAndPreProcAvgConfig = function(self, sAvgConfigPath, sHead, _sGroupId)
  -- function num : 0_5 , upvalues : _ENV, AvgData
  local ok, aaa = pcall(require, sAvgConfigPath)
  if not ok then
    printError("AVG 指令配置文件未找到，路径:" .. sAvgConfigPath .. ". error: " .. aaa)
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, "AVG 指令配置文件未找到，路径:" .. sAvgConfigPath)
    ;
    (EventManager.Hit)("StoryDialog_DialogEnd")
    return 
  else
    self.tbAvgCfg = aaa
    if type(_sGroupId) == "string" and _sGroupId ~= "" then
      self.tbAvgCfg = self:ParseGroup(aaa, sHead, _sGroupId)
    end
    self.tbPhoneMsgChoiceTarget = {}
    if self.tbChoiceTarget == nil then
      self.tbChoiceTarget = {}
    end
    -- DECOMPILER ERROR at PC56: Confused about usage of register: R6 in 'UnsetPending'

    if (self.tbChoiceTarget)[self.sAvgId] == nil then
      (self.tbChoiceTarget)[self.sAvgId] = {}
    end
    local tb = (self.tbChoiceTarget)[self.sAvgId]
    if self.tbMajorChoiceTarget == nil then
      self.tbMajorChoiceTarget = {}
    end
    -- DECOMPILER ERROR at PC73: Confused about usage of register: R7 in 'UnsetPending'

    if (self.tbMajorChoiceTarget)[self.sAvgId] == nil then
      (self.tbMajorChoiceTarget)[self.sAvgId] = {}
    end
    local tbMajor = (self.tbMajorChoiceTarget)[self.sAvgId]
    if self.tbPersonalityChoiceTarget == nil then
      self.tbPersonalityChoiceTarget = {}
    end
    -- DECOMPILER ERROR at PC90: Confused about usage of register: R8 in 'UnsetPending'

    if (self.tbPersonalityChoiceTarget)[self.sAvgId] == nil then
      (self.tbPersonalityChoiceTarget)[self.sAvgId] = {}
    end
    local tbPersonality = (self.tbPersonalityChoiceTarget)[self.sAvgId]
    if self.tbIfTrueTarget == nil then
      self.tbIfTrueTarget = {}
    end
    -- DECOMPILER ERROR at PC107: Confused about usage of register: R9 in 'UnsetPending'

    if (self.tbIfTrueTarget)[self.sAvgId] == nil then
      (self.tbIfTrueTarget)[self.sAvgId] = {}
    end
    local tbIfTrue = (self.tbIfTrueTarget)[self.sAvgId]
    if self.tbIfUnlockTarget == nil then
      self.tbIfUnlockTarget = {}
    end
    -- DECOMPILER ERROR at PC124: Confused about usage of register: R10 in 'UnsetPending'

    if (self.tbIfUnlockTarget)[self.sAvgId] == nil then
      (self.tbIfUnlockTarget)[self.sAvgId] = {}
    end
    local tbIfUnlock = (self.tbIfUnlockTarget)[self.sAvgId]
    self.END_CMD_ID = nil
    self.BadEndingMarkId = nil
    for i,v in ipairs(self.tbAvgCfg) do
      if v.cmd == "SetChoiceBegin" then
        local sGroupId = (v.param)[1]
        if tb[sGroupId] == nil then
          tb[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
        end
        -- DECOMPILER ERROR at PC149: Confused about usage of register: R17 in 'UnsetPending'

        ;
        (tb[sGroupId]).nBeginCmdId = i
      else
        do
          if v.cmd == "SetChoiceJumpTo" then
            local sGroupId = (v.param)[1]
            local nIndex = (v.param)[2]
            if tb[sGroupId] == nil then
              tb[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
            end
            -- DECOMPILER ERROR at PC169: Confused about usage of register: R18 in 'UnsetPending'

            ;
            ((tb[sGroupId]).tbTargetCmdId)[nIndex] = i
          else
            do
              if v.cmd == "SetChoiceEnd" then
                local sGroupId = (v.param)[1]
                if tb[sGroupId] == nil then
                  tb[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                end
                -- DECOMPILER ERROR at PC186: Confused about usage of register: R17 in 'UnsetPending'

                ;
                (tb[sGroupId]).nEndCmdId = i
              else
                do
                  if v.cmd == "SetPhoneMsgChoiceBegin" then
                    local sGroupId = (v.param)[1]
                    -- DECOMPILER ERROR at PC203: Confused about usage of register: R17 in 'UnsetPending'

                    if (self.tbPhoneMsgChoiceTarget)[sGroupId] == nil then
                      (self.tbPhoneMsgChoiceTarget)[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                    end
                    -- DECOMPILER ERROR at PC206: Confused about usage of register: R17 in 'UnsetPending'

                    ;
                    ((self.tbPhoneMsgChoiceTarget)[sGroupId]).nBeginCmdId = i
                  else
                    do
                      if v.cmd == "SetPhoneMsgChoiceJumpTo" then
                        local sGroupId = (v.param)[1]
                        local nIndex = (v.param)[2]
                        -- DECOMPILER ERROR at PC225: Confused about usage of register: R18 in 'UnsetPending'

                        if (self.tbPhoneMsgChoiceTarget)[sGroupId] == nil then
                          (self.tbPhoneMsgChoiceTarget)[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                        end
                        -- DECOMPILER ERROR at PC229: Confused about usage of register: R18 in 'UnsetPending'

                        ;
                        (((self.tbPhoneMsgChoiceTarget)[sGroupId]).tbTargetCmdId)[nIndex] = i
                      else
                        do
                          if v.cmd == "SetPhoneMsgChoiceEnd" then
                            local sGroupId = (v.param)[1]
                            -- DECOMPILER ERROR at PC246: Confused about usage of register: R17 in 'UnsetPending'

                            if (self.tbPhoneMsgChoiceTarget)[sGroupId] == nil then
                              (self.tbPhoneMsgChoiceTarget)[sGroupId] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                            end
                            -- DECOMPILER ERROR at PC249: Confused about usage of register: R17 in 'UnsetPending'

                            ;
                            ((self.tbPhoneMsgChoiceTarget)[sGroupId]).nEndCmdId = i
                          else
                            do
                              -- DECOMPILER ERROR at PC257: Unhandled construct in 'MakeBoolean' P1

                              if v.cmd == "End" and self.END_CMD_ID == nil then
                                self.END_CMD_ID = i
                                break
                              end
                              if v.cmd == "SetMajorChoice" then
                                local nGroupId = (v.param)[1]
                                if tbMajor[nGroupId] == nil then
                                  tbMajor[nGroupId] = {nEndCmdId = 0, 
tbTargetCmdId = {}
}
                                end
                              else
                                do
                                  if v.cmd == "SetMajorChoiceJumpTo" then
                                    local nGroupId = (v.param)[1]
                                    local nIndex = (v.param)[2]
                                    if tbMajor[nGroupId] == nil then
                                      tbMajor[nGroupId] = {nEndCmdId = 0, 
tbTargetCmdId = {}
}
                                    end
                                    -- DECOMPILER ERROR at PC291: Confused about usage of register: R18 in 'UnsetPending'

                                    ;
                                    ((tbMajor[nGroupId]).tbTargetCmdId)[nIndex] = i
                                  else
                                    do
                                      if v.cmd == "SetMajorChoiceEnd" then
                                        local nGroupId = (v.param)[1]
                                        if tbMajor[nGroupId] == nil then
                                          tbMajor[nGroupId] = {nEndCmdId = 0, 
tbTargetCmdId = {}
}
                                        end
                                        -- DECOMPILER ERROR at PC307: Confused about usage of register: R17 in 'UnsetPending'

                                        ;
                                        (tbMajor[nGroupId]).nEndCmdId = i
                                      else
                                        do
                                          if v.cmd == "SetPersonalityChoice" then
                                            local nGroupId = (v.param)[1]
                                            if tbPersonality[nGroupId] == nil then
                                              tbPersonality[nGroupId] = {nEndCmdId = 0, 
tbTargetCmdId = {}
}
                                            end
                                          else
                                            do
                                              if v.cmd == "SetPersonalityChoiceJumpTo" then
                                                local nGroupId = (v.param)[1]
                                                local nIndex = (v.param)[2]
                                                if tbPersonality[nGroupId] == nil then
                                                  tbPersonality[nGroupId] = {nEndCmdId = 0, 
tbTargetCmdId = {}
}
                                                end
                                                -- DECOMPILER ERROR at PC340: Confused about usage of register: R18 in 'UnsetPending'

                                                ;
                                                ((tbPersonality[nGroupId]).tbTargetCmdId)[nIndex] = i
                                              else
                                                do
                                                  if v.cmd == "SetPersonalityChoiceEnd" then
                                                    local nGroupId = (v.param)[1]
                                                    if tbPersonality[nGroupId] == nil then
                                                      tbPersonality[nGroupId] = {nEndCmdId = 0, 
tbTargetCmdId = {}
}
                                                    end
                                                    -- DECOMPILER ERROR at PC356: Confused about usage of register: R17 in 'UnsetPending'

                                                    ;
                                                    (tbPersonality[nGroupId]).nEndCmdId = i
                                                  else
                                                    do
                                                      if v.cmd == "IfTrue" or v.cmd == "EndIf" then
                                                        local sGroupId = (v.param)[1]
                                                        if tbIfTrue[sGroupId] == nil then
                                                          tbIfTrue[sGroupId] = {
cmdids = {}
, 
played = {}
}
                                                        end
                                                        if (table.indexof)((tbIfTrue[sGroupId]).cmdids, i) <= 0 then
                                                          (table.insert)((tbIfTrue[sGroupId]).cmdids, i)
                                                          ;
                                                          (table.insert)((tbIfTrue[sGroupId]).played, false)
                                                        end
                                                      else
                                                        do
                                                          if v.cmd == "IfUnlock" then
                                                            local sGroupId = (v.param)[1]
                                                            if tbIfUnlock[sGroupId] == nil then
                                                              tbIfUnlock[sGroupId] = {nEndCmdId = 0, nElseCmdId = 0, bSucc = false}
                                                            end
                                                          else
                                                            do
                                                              if v.cmd == "IfUnlockElse" then
                                                                local sGroupId = (v.param)[1]
                                                                if tbIfUnlock[sGroupId] == nil then
                                                                  tbIfUnlock[sGroupId] = {nEndCmdId = 0, nElseCmdId = 0, bSucc = false}
                                                                end
                                                                -- DECOMPILER ERROR at PC424: Confused about usage of register: R17 in 'UnsetPending'

                                                                ;
                                                                (tbIfUnlock[sGroupId]).nElseCmdId = i
                                                              else
                                                                do
                                                                  if v.cmd == "IfUnlockEnd" then
                                                                    local sGroupId = (v.param)[1]
                                                                    if tbIfUnlock[sGroupId] == nil then
                                                                      tbIfUnlock[sGroupId] = {nEndCmdId = 0, nElseCmdId = 0, bSucc = false}
                                                                    end
                                                                    -- DECOMPILER ERROR at PC440: Confused about usage of register: R17 in 'UnsetPending'

                                                                    ;
                                                                    (tbIfUnlock[sGroupId]).nEndCmdId = i
                                                                  else
                                                                    do
                                                                      do
                                                                        if v.cmd == "BadEnding_Mark" then
                                                                          self.BadEndingMarkId = i
                                                                        end
                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out DO_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                                        -- DECOMPILER ERROR at PC446: LeaveBlock: unexpected jumping out IF_STMT

                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    AvgData:MarkStoryId(self.sAvgId)
  end
end

AvgPanel.ParseGroup = function(self, data, sHead, sGroupId)
  -- function num : 0_6 , upvalues : _ENV
  local bMatch = false
  local tbGroupData = {}
  for i,v in ipairs(data) do
    if v.cmd == "SetGroupId" then
      if sHead == "DP" and sGroupId == "PLAY_ALL_PLAY_ALL" then
        bMatch = true
      else
        bMatch = (v.param)[1] == sGroupId
      end
      if bMatch and sHead == "PM" then
        (table.insert)(tbGroupData, {cmd = "SetPhone", 
param = {0, 1, 1}
})
      end
    elseif bMatch or v.cmd == "End" then
      (table.insert)(tbGroupData, v)
    end
  end
  do return tbGroupData end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

AvgPanel.FindCmdProcFunc = function(self, sCtrlName, sCmd)
  -- function num : 0_7 , upvalues : _ENV
  for i,objCtrl in ipairs(self._tbObjCtrl) do
    if objCtrl.__cname == sCtrlName then
      return {ctrl = objCtrl, func = objCtrl[sCmd]}
    end
  end
end

AvgPanel.GetAvgCharName = function(self, sAvgCharId)
  -- function num : 0_8
  local tbChar = (self.tbAvgCharacter)[sAvgCharId]
  if tbChar == nil then
    return sAvgCharId, "#0ABEC5"
  else
    return tbChar.name or sAvgCharId, tbChar.color or "#0ABEC5"
  end
end

AvgPanel.GetAvgCharReuseRes = function(self, sAvgCharId)
  -- function num : 0_9
  local tbChar = (self.tbAvgCharacter)[sAvgCharId]
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

AvgPanel.AddTimer = function(self, nTargetCount, nInterval, sCallbackName, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
  -- function num : 0_10 , upvalues : _ENV, TimerManager
  local callback = self[sCallbackName]
  if type(callback) == "function" then
    local timer = (TimerManager.Add)(nTargetCount, nInterval, self, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
    return timer
  else
    do
      do return nil end
    end
  end
end

AvgPanel.GetBgCgFgResFullPath = function(self, sName)
  -- function num : 0_11 , upvalues : _ENV
  if sName == "BG_Black" then
    return "ImageAvg/AvgBg/BG_Black"
  else
    if (table.indexof)((self.tbAvgPreset).BgResName, sName) > 0 then
      return "ImageAvg/AvgBg/" .. sName
    else
      if (table.indexof)((self.tbAvgPreset).CgResName, sName) > 0 then
        return "ImageAvg/AvgCG/" .. sName
      else
        if (table.indexof)((self.tbAvgPreset).FgResName, sName) > 0 then
          return "ImageAvg/AvgFg/" .. sName
        else
          if (table.indexof)((self.tbAvgPreset).DiscResName, sName) > 0 then
            local sFolderName = (string.gsub)(sName, "_B", "")
            return "Disc/" .. sFolderName .. "/" .. sName
          else
            do
              do return nil end
            end
          end
        end
      end
    end
  end
end

AvgPanel.GetAvgContactsData = function(self, sContactsId)
  -- function num : 0_12
  local tbContacts = (self.tbAvgContacts)[sContactsId]
  if tbContacts == nil then
    return sContactsId
  else
    return tbContacts
  end
end

AvgPanel.GetNextProcFunc = function(self, nextIndex)
  -- function num : 0_13
  if self.nCurIndex ~= nil then
    if nextIndex == nil then
      nextIndex = 1
    end
    return (self.tbAvgCfg)[self.nCurIndex + nextIndex]
  end
end

AvgPanel.OnEvent_AvgSkipCheck = function(self)
  -- function num : 0_14 , upvalues : _ENV, WwiseAudioMgr
  if self.timerWaiting ~= nil then
    (self.timerWaiting):Pause(true)
  end
  local sCmdName, nJumpTo = nil, nil
  for i = self.nCurIndex, self.END_CMD_ID do
    sCmdName = ((self.tbAvgCfg)[i]).cmd
    if sCmdName == "BadEnding_Check" then
      self:BadEnding_Check()
      break
    end
  end
  do
    for i = self.nCurIndex, self.END_CMD_ID do
      sCmdName = ((self.tbAvgCfg)[i]).cmd
      if sCmdName == "SetIntro" then
        local param = ((self.tbAvgCfg)[i]).param
        local objCtrl = ((self.mapProcFunc)[sCmdName]).ctrl
        local ProcFunc = ((self.mapProcFunc)[sCmdName]).func
        ProcFunc(objCtrl, param)
        break
      end
    end
    do
      for i = self.nCurIndex, self.END_CMD_ID do
        sCmdName = ((self.tbAvgCfg)[i]).cmd
        if sCmdName == "SetMajorChoice" then
          nJumpTo = i
          break
        else
          if sCmdName == "PlayVideo" then
            nJumpTo = i
            break
          end
        end
      end
      do
        if nJumpTo == nil then
          (EventManager.Hit)(EventId.AvgSkipCheckIntro)
        else
          WwiseAudioMgr:PostEvent("avg_track1_stop")
          WwiseAudioMgr:PostEvent("avg_track2_stop")
          WwiseAudioMgr:PostEvent("avg_sfx_all_stop")
          if self.timerWaiting ~= nil then
            (self.timerWaiting):Cancel()
            self.timerWaiting = nil
          end
          self.nJumpTarget = nJumpTo
          self:RUN()
        end
      end
    end
  end
end

AvgPanel.OnEvent_AvgSkip = function(self)
  -- function num : 0_15
  local nJumpTo = nil
  local mapConfig = (self.tbAvgCfg)[self.END_CMD_ID - 1]
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

AvgPanel.OnEvent_AvgTryResume = function(self)
  -- function num : 0_16
  if self.timerWaiting ~= nil then
    (self.timerWaiting):Pause(false)
  end
end

AvgPanel.OnEvent_AvgSpeedUp = function(self, nRate)
  -- function num : 0_17 , upvalues : _ENV
  printLog("Avg加速 AvgPanel " .. nRate)
  self.nSpeedRate = nRate
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

  DOTween.unscaledTimeScale = nRate
  if self.timerWaiting ~= nil then
    (self.timerWaiting):SetSpeed(nRate)
  end
end

AvgPanel.RUN = function(self)
  -- function num : 0_18 , upvalues : _ENV
  if type(self.sExecutingCMDName) == "string" then
    printError((string.format)("当前指令 %s 尚未执行完成，在一帧里又调用了一次 AvgPanel:RUN() 接口，必须排查此严重错误！！", self.sExecutingCMDName))
    return 
  end
  if self.timerWaiting ~= nil then
    (self.timerWaiting):Cancel()
    self.timerWaiting = nil
  end
  if self.nCurIndex == nil then
    return 
  end
  if self.nJumpTarget ~= nil then
    self.nCurIndex = self.nJumpTarget
    self.nJumpTarget = nil
  end
  local mapConfig = (self.tbAvgCfg)[self.nCurIndex]
  local sCmd = mapConfig.cmd
  local tbParam = mapConfig.param
  if (self.mapProcFunc)[sCmd] == nil then
    printError("未找到该指令：" .. sCmd)
    return 
  end
  local objCtrl = ((self.mapProcFunc)[sCmd]).ctrl
  local ProcFunc = ((self.mapProcFunc)[sCmd]).func
  local nWaitTime = 0
  self.sExecutingCMDName = sCmd
  nWaitTime = ProcFunc(objCtrl, tbParam)
  self.sExecutingCMDName = nil
  printLog((string.format)("索引:%s指令:%s耗时:%f", self.nCurIndex or "nil", sCmd, nWaitTime))
  if type(self.nCurIndex) == "number" then
    self.nCurIndex = self.nCurIndex + 1
  end
  if nWaitTime < 0 then
    return 
  else
    if nWaitTime > 0 then
      self:Wait({nWaitTime})
    else
      self:RUN()
    end
  end
end

AvgPanel.End = function(self)
  -- function num : 0_19 , upvalues : _ENV
  (EventManager.Remove)(EventId.AvgSkipCheck, self, self.OnEvent_AvgSkipCheck)
  ;
  (EventManager.Remove)(EventId.AvgSkip, self, self.OnEvent_AvgSkip)
  ;
  (EventManager.Remove)(EventId.AvgTryResume, self, self.OnEvent_AvgTryResume)
  ;
  (EventManager.Remove)(EventId.AvgSpeedUp, self, self.OnEvent_AvgSpeedUp)
  ;
  (EventManager.Remove)(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
  ;
  (EventManager.Hit)(EventId.BlockInput, true)
  self.nCurIndex = nil
  local _objCtrl, _ProcFunc = nil, nil
  for i,objCtrl in ipairs(self._tbObjCtrl) do
    if objCtrl.__cname == "Avg_9_CurtainCtrl" then
      _objCtrl = objCtrl
      _ProcFunc = _objCtrl.SetEnd
      break
    end
  end
  do
    if self.AVG_NO_BG_MODE == true then
      self:onEnd()
    else
      local nTime = _ProcFunc(_objCtrl, false)
      self:AddTimer(1, nTime, "onEnd", true, true, true)
    end
    do
      return -1
    end
  end
end

AvgPanel.onEnd = function(self)
  -- function num : 0_20 , upvalues : _ENV
  if self.nCurIndex == 1 then
    return 
  end
  AVG_EDITOR_PLAYING = nil
  self:SetSystemBgm(false)
  self:OnEvent_AvgSpeedUp(1)
  ;
  (EventManager.Hit)(EventId.BlockInput, false)
  ;
  (EventManager.Hit)("StoryDialog_DialogEnd")
end

AvgPanel.Jump = function(self, tbParam)
  -- function num : 0_21
  local nIndex = tbParam[1]
  self.nJumpTarget = nIndex
  return 0
end

AvgPanel.Wait = function(self, tbParam)
  -- function num : 0_22
  local nTime = tbParam[1]
  if nTime > 0 then
    self.timerWaiting = self:AddTimer(1, nTime, "_onWaitComplete", true, true, true)
    ;
    (self.timerWaiting):SetSpeed(self.nSpeedRate)
  end
  return -1
end

AvgPanel._onWaitComplete = function(self)
  -- function num : 0_23
  self.timerWaiting = nil
  self:RUN()
end

AvgPanel.SetGroupId = function(self)
  -- function num : 0_24
  return 0
end

AvgPanel.Comment = function(self, tbParam)
  -- function num : 0_25
  return 0
end

AvgPanel.SetChoiceJumpTo = function(self, nGroupId, nIndex)
  -- function num : 0_26 , upvalues : _ENV
  local tb = (self.tbChoiceTarget)[self.sAvgId]
  local tbData = tb[nGroupId]
  if tbData ~= nil then
    self.nCurIndex = (tbData.tbTargetCmdId)[tostring(nIndex)]
    self:RUN()
  end
end

AvgPanel.SetChoiceRollback = function(self, nGroupId)
  -- function num : 0_27
  local tb = (self.tbChoiceTarget)[self.sAvgId]
  local tbData = tb[nGroupId]
  if tbData ~= nil then
    self.nJumpTarget = tbData.nBeginCmdId
  end
end

AvgPanel.SetChoiceRollover = function(self, nGroupId)
  -- function num : 0_28
  local tb = (self.tbChoiceTarget)[self.sAvgId]
  local tbData = tb[nGroupId]
  if tbData ~= nil then
    self.nJumpTarget = tbData.nEndCmdId
  end
end

AvgPanel.SetPhoneMsgChoiceJumpTo = function(self, nGroupId, nIndex)
  -- function num : 0_29 , upvalues : _ENV
  local tbData = (self.tbPhoneMsgChoiceTarget)[nGroupId]
  if tbData ~= nil then
    self.nCurIndex = (tbData.tbTargetCmdId)[tostring(nIndex)]
    self:RUN()
  end
end

AvgPanel.SetPhoneMsgChoiceEnd = function(self, nGroupId)
  -- function num : 0_30 , upvalues : _ENV
  local tbData = (self.tbPhoneMsgChoiceTarget)[tostring(nGroupId)]
  if tbData ~= nil then
    self.nJumpTarget = tbData.nEndCmdId
  end
end

AvgPanel.SetMajorChoiceJumpTo = function(self, nGroupId, nIndex)
  -- function num : 0_31
  local tbMajor = (self.tbMajorChoiceTarget)[self.sAvgId]
  local tbMajorData = tbMajor[nGroupId]
  if tbMajorData ~= nil then
    self.nCurIndex = (tbMajorData.tbTargetCmdId)[nIndex]
    self:RUN()
  end
end

AvgPanel.SetMajorChoiceRollover = function(self, nGroupId)
  -- function num : 0_32
  local tbMajor = (self.tbMajorChoiceTarget)[self.sAvgId]
  local tbMajorData = tbMajor[nGroupId]
  if tbMajorData ~= nil then
    self.nJumpTarget = tbMajorData.nEndCmdId
  end
end

AvgPanel.SetPersonalityChoiceJumpTo = function(self, nGroupId, nIndex)
  -- function num : 0_33
  local tbPersonality = (self.tbPersonalityChoiceTarget)[self.sAvgId]
  local tbPersonalityData = tbPersonality[nGroupId]
  if tbPersonalityData ~= nil then
    self.nCurIndex = (tbPersonalityData.tbTargetCmdId)[nIndex]
    self:RUN()
  end
end

AvgPanel.SetPersonalityChoiceRollover = function(self, nGroupId)
  -- function num : 0_34
  local tbPersonality = (self.tbPersonalityChoiceTarget)[self.sAvgId]
  local tbPersonalityData = tbPersonality[nGroupId]
  if tbPersonalityData ~= nil then
    self.nJumpTarget = tbPersonalityData.nEndCmdId
  end
end

local tbChoiceABC = {"a", "b", "c"}
AvgPanel.IfTrue = function(self, tbParam)
  -- function num : 0_35 , upvalues : _ENV, AvgData, tbChoiceABC
  local sIfTrueGroupId = tbParam[1]
  local bIsMajorChoice = tbParam[2] == 0
  local sAvgId = tbParam[3]
  local nChoiceGroupId = tbParam[4]
  local tbParamData = ((string.split)(tbParam[5], "|"))
  local bResult, nParamLen, sABC, nCount = nil, nil, nil, nil
  for i,v in ipairs(tbParamData) do
    local tbParamGroupData = (string.split)(v, "+")
    for ii,vv in ipairs(tbParamGroupData) do
      nParamLen = (string.len)(vv)
      sABC = (string.sub)(vv, 1, 1)
      sABC = (string.lower)(sABC)
      if not tonumber((string.sub)(vv, 2)) then
        do
          nCount = nParamLen <= 1 or 1
          nCount = 1
          bResult = AvgData:CheckIfTrue(bIsMajorChoice, sAvgId, nChoiceGroupId, (table.indexof)(tbChoiceABC, sABC), nCount)
          -- DECOMPILER ERROR at PC73: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC73: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  if bResult ~= true or bResult ~= true then
    local tbIfTrueCmdIds = (((self.tbIfTrueTarget)[self.sAvgId])[sIfTrueGroupId]).cmdids
    local tbPlayed = (((self.tbIfTrueTarget)[self.sAvgId])[sIfTrueGroupId]).played
    local nIdx = (table.indexof)(tbIfTrueCmdIds, self.nCurIndex)
    do
      if nIdx > 1 and tbPlayed[nIdx - 1] == true then
        local nNum = #tbIfTrueCmdIds
        self.nJumpTarget = tbIfTrueCmdIds[nNum]
        return 0
      end
      if bResult == true then
        tbPlayed[nIdx] = true
      else
        self.nJumpTarget = tbIfTrueCmdIds[nIdx + 1]
      end
      do return 0 end
      -- DECOMPILER ERROR: 11 unprocessed JMP targets
    end
  end
end

AvgPanel.EndIf = function(self, tbParam)
  -- function num : 0_36
  return 0
end

AvgPanel.IfUnlock = function(self, tbParam)
  -- function num : 0_37 , upvalues : AvgData
  local sGroupId = tbParam[1]
  local sConditionId = tbParam[2]
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R4 in 'UnsetPending'

  if AvgData:IsUnlock(sConditionId) == true then
    (((self.tbIfUnlockTarget)[self.sAvgId])[sGroupId]).bSUcc = true
    return 0
  else
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (((self.tbIfUnlockTarget)[self.sAvgId])[sGroupId]).bSUcc = false
    self.nJumpTarget = (((self.tbIfUnlockTarget)[self.sAvgId])[sGroupId]).nElseCmdId
    return 0
  end
end

AvgPanel.IfUnlockElse = function(self, tbParam)
  -- function num : 0_38
  local sGroupId = tbParam[1]
  if (((self.tbIfUnlockTarget)[self.sAvgId])[sGroupId]).bSUcc == true then
    self.nJumpTarget = (((self.tbIfUnlockTarget)[self.sAvgId])[sGroupId]).nEndCmdId
    return 0
  else
    return 0
  end
end

AvgPanel.IfUnlockEnd = function(self, tbParam)
  -- function num : 0_39
  return 0
end

AvgPanel.SetBGM = function(self, tbParam)
  -- function num : 0_40 , upvalues : WwiseAudioMgr, _ENV
  local nType = tbParam[1]
  local sVolume = tbParam[2]
  local nTrackIndex = tbParam[3] + 1
  local sBgmName = tbParam[4]
  local sFadeTime = tbParam[5]
  local nDuration = tbParam[6]
  local bWait = tbParam[7]
  if nType == 4 then
    WwiseAudioMgr:PostEvent(sVolume)
  else
    local sBaseName = "avg_track" .. tostring(nTrackIndex)
    local sWwiseEventName = sBaseName
    if nType == 0 then
      WwiseAudioMgr:SetState(sBaseName, sBgmName)
      if sFadeTime ~= "none" then
        sWwiseEventName = sWwiseEventName .. "_fadeIn_" .. sFadeTime
      end
    else
      if nType == 1 then
        sWwiseEventName = sWwiseEventName .. "_stop"
        if sFadeTime ~= "none" then
          sWwiseEventName = sWwiseEventName .. "_fadeOut_" .. sFadeTime
        end
      else
        if nType == 2 then
          sWwiseEventName = sWwiseEventName .. "_pause"
          if sFadeTime ~= "none" then
            sWwiseEventName = sWwiseEventName .. "_fadeOut_" .. sFadeTime
          end
        else
          if nType == 3 then
            sWwiseEventName = sWwiseEventName .. "_resume"
            if sFadeTime ~= "none" then
              sWwiseEventName = sWwiseEventName .. "_fadeIn_" .. sFadeTime
            end
          end
        end
      end
    end
    WwiseAudioMgr:PostEvent(sWwiseEventName)
    if nType == 0 then
      WwiseAudioMgr:PostEvent(sVolume)
    end
  end
  do
    if bWait == true and nDuration > 0 then
      return nDuration
    else
      return 0
    end
  end
end

AvgPanel.SetAudio = function(self, tbParam)
  -- function num : 0_41 , upvalues : WwiseAudioMgr
  local nType = tbParam[1]
  local sName = tbParam[2]
  local nDuration = tbParam[3]
  local bWait = tbParam[4]
  if sName ~= "" then
    if nType == 0 then
      WwiseAudioMgr:PlaySound(sName)
    else
      if nType == 1 then
        WwiseAudioMgr:WwiseVoice_PlayInAVG(sName)
      else
        if nType == 2 then
          self.bProcVoiceCallbackEvent = false
          WwiseAudioMgr:WwiseVoice_StopInAVG()
        end
      end
    end
  end
  if bWait == true then
    if nDuration > 0 then
      return nDuration
    else
      if nDuration < 0 and nType == 1 then
        self.bProcVoiceCallbackEvent = true
        return -1
      else
        return 0
      end
    end
  else
    return 0
  end
end

AvgPanel.SetSystemBgm = function(self, bPause)
  -- function num : 0_42 , upvalues : ModuleManager, WwiseAudioMgr, _ENV
  if bPause == true then
    if (ModuleManager.GetIsAdventure)() == true then
      WwiseAudioMgr:PostEvent("avg_combat_enter")
    else
      if self.sAvgCfgHead ~= "DP" then
        WwiseAudioMgr:PostEvent("avg_enter")
      end
    end
  else
    if (ModuleManager.GetIsAdventure)() == true then
      WwiseAudioMgr:PostEvent("avg_combat_exit")
    else
      if self.sAvgCfgHead ~= "DP" then
        WwiseAudioMgr:PostEvent("avg_exit")
      end
    end
    ;
    (NovaAPI.UnloadWwiseSoundBank)("AVG")
    ;
    (NovaAPI.UnloadWwiseSoundBank)("Music_AVG")
  end
end

AvgPanel.PlayCharEmojiSound = function(self, sEmojiName)
  -- function num : 0_43 , upvalues : _ENV
  for i,v in ipairs((self.tbAvgPreset).CharEmoji) do
    if v[3] == sEmojiName then
      local sEmojiSound = v[4]
      if type(sEmojiSound) == "string" and sEmojiSound ~= "" then
        self:SetAudio({0, sEmojiSound})
      end
      break
    end
  end
end

AvgPanel.PlayFxSound = function(self, sFxName, bPlay)
  -- function num : 0_44 , upvalues : _ENV
  for _,v in ipairs((self.tbAvgPreset).FxResName) do
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

AvgPanel.OnEvent_AvgVoiceDuration = function(self, nDuration)
  -- function num : 0_45
  if self.bProcVoiceCallbackEvent == true then
    self.bProcVoiceCallbackEvent = false
    if nDuration > 0 then
      self:Wait({nDuration})
    end
  end
end

AvgPanel.Clear = function(self, tbParam)
  -- function num : 0_46 , upvalues : _ENV
  local bClearChar = tbParam[1]
  local nDuration = tbParam[2]
  local bWait = tbParam[3]
  local bClearTalk = tbParam[4]
  if bClearChar == true then
    (EventManager.Hit)(EventId.AvgClearAllChar, nDuration)
  end
  if bClearTalk == true then
    (EventManager.Hit)(EventId.AvgClearTalk)
  end
  if bWait == true and type(nDuration) == "number" and nDuration > 0 then
    return nDuration
  else
    return 0
  end
end

AvgPanel.GetCharEmojiIndex = function(self, sEmoji)
  -- function num : 0_47 , upvalues : _ENV
  if self.tbAvgPreset ~= nil then
    for i,v in ipairs((self.tbAvgPreset).CharEmoji) do
      if v[3] == sEmoji then
        return v[1]
      end
    end
  end
  do
    return 0
  end
end

AvgPanel.BadEnding_Check = function(self, tbParam)
  -- function num : 0_48 , upvalues : _ENV
  if type(self.BadEndingMarkId) == "number" and self.nCurIndex < self.BadEndingMarkId and self.BadEndingMarkId < self.END_CMD_ID then
    local nRemoveBegin = self.END_CMD_ID - 1
    local nRemoveEnd = self.BadEndingMarkId
    for i = self.END_CMD_ID - 1, self.BadEndingMarkId, -1 do
      (table.remove)(self.tbAvgCfg, i)
      self.END_CMD_ID = self.END_CMD_ID - 1
    end
    if self.END_CMD_ID < #self.tbAvgCfg then
      (table.remove)(self.tbAvgCfg, self.END_CMD_ID)
      ;
      (table.insert)(self.tbAvgCfg, {cmd = "End"})
      self.END_CMD_ID = #self.tbAvgCfg
    end
  end
  do
    return 0
  end
end

AvgPanel.BadEnding_Mark = function(self, tbParam)
  -- function num : 0_49
  return 0
end

AvgPanel.JUMP_AVG_ID = function(self, tbParam)
  -- function num : 0_50 , upvalues : _ENV
  local sAvgId = tbParam[1]
  local nCmdId = tbParam[2]
  local sBE = tbParam[3] or ""
  if sBE == "A" then
    self.nBEIndex = 1
  else
    if sBE == "B" then
      self.nBEIndex = 2
    else
      if sBE == "C" then
        self.nBEIndex = 3
      end
    end
  end
  if sAvgId == nil then
    return -1
  end
  if nCmdId == nil then
    nCmdId = 1
  end
  ;
  (EventManager.Hit)(EventId.TemporaryBlockInput, 1)
  -- DECOMPILER ERROR at PC36: Confused about usage of register: R5 in 'UnsetPending'

  if self.sAvgCfgPath ~= nil then
    (package.loaded)[self.sAvgCfgPath] = nil
    self.sAvgCfgPath = nil
  end
  self.sAvgId = sAvgId
  self.sAvgCfgPath = self.sRootPath .. "Config/" .. self.sAvgId
  self:RequireAndPreProcAvgConfig(self.sAvgCfgPath)
  printLog("Jump to AvgId:" .. sAvgId)
  self.nJumpTarget = nCmdId
  return 0
end

AvgPanel.EnableGamepad = function(self)
  -- function num : 0_51 , upvalues : GamepadUIManager
  self.bHasOtherGamepadUI = (GamepadUIManager.GetInputState)()
  if not self.bHasOtherGamepadUI then
    (GamepadUIManager.EnterAdventure)(true)
  end
  ;
  (GamepadUIManager.EnableGamepadUI)("AVG", {})
  self.sCurGamepadUI = nil
end

AvgPanel.DisableGamepad = function(self)
  -- function num : 0_52 , upvalues : GamepadUIManager
  self.sCurGamepadUI = nil
  ;
  (GamepadUIManager.DisableGamepadUI)("AVG")
  if not self.bHasOtherGamepadUI then
    (GamepadUIManager.QuitAdventure)()
  end
end

return AvgPanel

