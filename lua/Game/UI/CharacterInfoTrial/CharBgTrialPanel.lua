local CharBgTrialPanel = class("CharBgTrialPanel", BasePanel)
CharBgTrialPanel._bIsMainPanel = false
CharBgTrialPanel._tbDefine = {
{sPrefabPath = "CharacterInfoTrial/CharBgTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharBgTrialCtrl"}
, 
{sPrefabPath = "CharacterInfoTrial/CharacterInfoTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharacterInfoTrialCtrl"}
, 
{sPrefabPath = "CharacterInfoTrial/CharSkillTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharSkillTrialCtrl"}
, 
{sPrefabPath = "CharacterInfoTrial/CharPotentialTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharPotentialTrialCtrl"}
, 
{sPrefabPath = "CharacterInfoTrial/CharTalentTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharTalentTrialCtrl"}
, 
{sPrefabPath = "CharacterInfoTrial/CharFgTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharFgTrialCtrl"}
}
CharBgTrialPanel._mapEventConfig = {[EventId.CharRelatePanelOpen] = "OnEvent_CharRelatePanelOpen", [EventId.CharRelatePanelClose] = "OnEvent_CharRelatePanelClose"}
local char_panel_show_cfg = {
[PanelId.CharInfoTrial] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = 0, L2DPosX = 0, weaponPosX = 28}
, 
[PanelId.CharSkillTrial] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -26.8, L2DPosX = -0.62, weaponPosX = 28}
, 
[PanelId.CharPotentialTrial] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -31.4, L2DPosX = -6.8, weaponPosX = 28}
, 
[PanelId.CharTalentTrial] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).None, bgPosX = -33.8, L2DPosX = -26, weaponPosX = 28}
}
local char_sub_panel = {[PanelId.CharUpPanel] = true, [PanelId.CharFavourGift] = true}
local panel_switch_anim_cfg = {
[PanelId.CharInfoTrial] = {
[PanelId.CharSkillTrial] = {nL2dTime = 0.2, nBgTime = 0}
, 
[PanelId.CharPotentialTrial] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharTalentTrial] = {nL2dTime = 0, nBgTime = 0}
}
, 
[PanelId.CharSkillTrial] = {
[PanelId.CharInfoTrial] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharPotentialTrial] = {nL2dTime = 0.3, nBgTime = 0.3}
, 
[PanelId.CharTalentTrial] = {nL2dTime = 0.3, nBgTime = 0.3}
}
, 
[PanelId.CharPotentialTrial] = {
[PanelId.CharInfoTrial] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharSkillTrial] = {nL2dTime = 0.3, nBgTime = 0.3}
, 
[PanelId.CharTalentTrial] = {nL2dTime = 0.3, nBgTime = 0.3}
}
, 
[PanelId.CharTalentTrial] = {
[PanelId.CharInfoTrial] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharSkillTrial] = {nL2dTime = 0, nBgTime = 0.3}
, 
[PanelId.CharPotentialTrial] = {nL2dTime = 0, nBgTime = 0.3}
}
}
CharBgTrialPanel.Close = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (EventManager.Hit)(EventId.ClosePanel, PanelId.CharBgPanel)
end

CharBgTrialPanel.GetPanelAnimCfg = function(self, nClosePanelId, nOpenPanelId)
  -- function num : 0_1 , upvalues : panel_switch_anim_cfg
  if panel_switch_anim_cfg[nClosePanelId] == nil then
    return 
  end
  if (panel_switch_anim_cfg[nClosePanelId])[nOpenPanelId] == nil then
    return 
  end
  return (panel_switch_anim_cfg[nClosePanelId])[nOpenPanelId]
end

CharBgTrialPanel.GetPanelAnimTime = function(self, nClosePanelId, nOpenPanelId)
  -- function num : 0_2
  local tbCfg = self:GetPanelAnimCfg(nClosePanelId, nOpenPanelId)
  if tbCfg ~= nil then
    return tbCfg.nBgTime, tbCfg.nL2dTime
  end
end

CharBgTrialPanel.PlayPanelSwitchAnim = function(self, trContent, nWidth, nTime)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Hit)(EventId.TemporaryBlockInput, nTime)
  local tweener = (trContent:DOAnchorPosX(nWidth, nTime)):SetUpdate(true)
  local tbCfg = self:GetPanelAnimCfg(self.nClosePanelId, self.nPanelId)
  if tbCfg ~= nil and tbCfg.uiEaseType ~= nil then
    tweener:SetEase(tbCfg.uiEaseType)
  end
  return tweener
end

CharBgTrialPanel.GetPanelShowCfg = function(self)
  -- function num : 0_4 , upvalues : char_panel_show_cfg
  return char_panel_show_cfg
end

CharBgTrialPanel.GetSubPanel = function(self)
  -- function num : 0_5 , upvalues : char_sub_panel
  return char_sub_panel
end

CharBgTrialPanel.Awake = function(self)
  -- function num : 0_6 , upvalues : _ENV
  self.nPanelId = 0
  self.nCharId = 0
  self.tbCharList = {}
  self.panelStack = {}
  self.bSecondPanel = false
  local tbParam = self._tbParam
  if type(tbParam) == "table" then
    self.nPanelId = tbParam[1]
    if tbParam[2] ~= nil then
      self.configData = (ConfigTable.GetData_Character)(tbParam[2])
      self.mapCharTrialInfo = ((PlayerData.Char):CreateTrialChar({(self.configData).ViewId}))[(self.configData).ViewId]
      self.nCharId = (self.mapCharTrialInfo).nId
    end
  end
  ;
  (table.insert)(self.panelStack, self.nPanelId)
end

CharBgTrialPanel.OnEnable = function(self)
  -- function num : 0_7
end

CharBgTrialPanel.OnDisable = function(self)
  -- function num : 0_8
end

CharBgTrialPanel.OnEvent_CharRelatePanelOpen = function(self, nPanelId, ncharId, tbCharList, param1)
  -- function num : 0_9 , upvalues : char_sub_panel, _ENV
  self.nClosePanelId = self.nPanelId
  self.nPanelId = nPanelId
  self.bSecondPanel = false
  if ncharId ~= nil then
    self.nCharId = ncharId
  end
  if tbCharList ~= nil then
    self.tbCharList = tbCharList
  end
  if param1 ~= nil then
    self.param1 = param1
  end
  if char_sub_panel[nPanelId] then
    (table.insert)(self.panelStack, nPanelId)
  end
  ;
  (EventManager.Hit)(EventId.CharRelatePanelAdvance, self.nClosePanelId, nPanelId)
end

CharBgTrialPanel.OnEvent_CharRelatePanelClose = function(self, bForceClose)
  -- function num : 0_10 , upvalues : _ENV, char_panel_show_cfg
  if #self.panelStack <= 1 or bForceClose then
    self:Close()
    return 
  end
  self.nClosePanelId = self.nPanelId
  local nLastPanelId = (self.panelStack)[#self.panelStack]
  if self.nClosePanelId ~= nLastPanelId then
    self:Close()
    return 
  end
  local nOpenPanelId = (self.panelStack)[#self.panelStack - 1]
  ;
  (table.remove)(self.panelStack, #self.panelStack)
  self.nPanelId = nOpenPanelId
  self.bSecondPanel = false
  local panelCfg = char_panel_show_cfg[self.nClosePanelId]
  if panelCfg ~= nil then
    (EventManager.Hit)(EventId.CharRelatePanelBack, self.nClosePanelId, nOpenPanelId)
  end
end

return CharBgTrialPanel

