local CharBgPanel = class("CharBgPanel", BasePanel)
CharBgPanel._tbDefine = {
{sPrefabPath = "CharacterInfoEx/CharBgPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharBgCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharacterInfoPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharacterInfoCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharDevelopmentPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharDevelopmentCtrl"}
, 
{sPrefabPath = "CharSkill/CharSkillPanel.prefab", sCtrlName = "Game.UI.CharSkill.CharSkillCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharPotentialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharPotentialCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharTalentPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharTalentCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharEquipmentPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharEquipmentCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharFgPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharFgCtrl"}
, 
{sPrefabPath = "CharacterInfoEx/CharacterRelationPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharacterRelationCtrl"}
}
CharBgPanel._mapEventConfig = {[EventId.CharRelatePanelOpen] = "OnEvent_CharRelatePanelOpen", [EventId.CharRelatePanelClose] = "OnEvent_CharRelatePanelClose"}
local char_panel_show_cfg = {
[PanelId.CharInfo] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = 0, L2DPosX = 0, weaponPosX = 28}
, 
[PanelId.CharUpPanel] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = 0, L2DPosX = -0.92, weaponPosX = 28}
, 
[PanelId.CharSkill] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -26.8, L2DPosX = -0.62, weaponPosX = 28}
, 
[PanelId.CharEquipment] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -29.1, L2DPosX = -4, weaponPosX = 28}
, 
[PanelId.CharPotential] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -31.4, L2DPosX = -6.8, weaponPosX = 28}
, 
[PanelId.CharTalent] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).None, bgPosX = -33.8, L2DPosX = -26, weaponPosX = 28}
, 
[PanelId.CharacterRelation] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -60, L2DPosX = -3, weaponPosX = 28}
, 
[PanelId.CharFavourGift] = {bShowTopBar = true, type = (AllEnum.CharBgPanelShowType).L2D, bgPosX = -60, L2DPosX = -3, weaponPosX = 28}
}
local char_sub_panel = {[PanelId.CharUpPanel] = true, [PanelId.CharFavourGift] = true}
local panel_switch_anim_cfg = {
[PanelId.CharUpPanel] = {
[PanelId.CharInfo] = {nL2dTime = 0.3, nBgTime = 0}
}
, 
[PanelId.CharInfo] = {
[PanelId.CharUpPanel] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharSkill] = {nL2dTime = 0.2, nBgTime = 0}
, 
[PanelId.CharEquipment] = {nL2dTime = 0.4, nBgTime = 0, uiEaseType = Ease.InOutSine, bgEaseType = Ease.InOutCubic}
, 
[PanelId.CharacterRelation] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharPotential] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharTalent] = {nL2dTime = 0, nBgTime = 0}
}
, 
[PanelId.CharSkill] = {
[PanelId.CharInfo] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharEquipment] = {nL2dTime = 0.25, nBgTime = 0.25}
, 
[PanelId.CharacterRelation] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharPotential] = {nL2dTime = 0.3, nBgTime = 0.3}
, 
[PanelId.CharTalent] = {nL2dTime = 0.3, nBgTime = 0.3}
}
, 
[PanelId.CharEquipment] = {
[PanelId.CharInfo] = {nL2dTime = 0.4, nBgTime = 0, uiEaseType = Ease.InOutSine, bgEaseType = Ease.InOutCubic}
, 
[PanelId.CharSkill] = {nL2dTime = 0.25, nBgTime = 0.25}
, 
[PanelId.CharacterRelation] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharPotential] = {nL2dTime = 0.3, nBgTime = 0.3}
, 
[PanelId.CharTalent] = {nL2dTime = 0.3, nBgTime = 0.3}
}
, 
[PanelId.CharacterRelation] = {
[PanelId.CharInfo] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharEquipment] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharSkill] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharPotential] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharTalent] = {nL2dTime = 0, nBgTime = 0}
}
, 
[PanelId.CharPotential] = {
[PanelId.CharInfo] = {nL2dTime = 0.3, nBgTime = 0}
, 
[PanelId.CharEquipment] = {nL2dTime = 0.3, nBgTime = 0.3}
, 
[PanelId.CharSkill] = {nL2dTime = 0.3, nBgTime = 0.3}
, 
[PanelId.CharacterRelation] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharTalent] = {nL2dTime = 0.3, nBgTime = 0.3}
}
, 
[PanelId.CharTalent] = {
[PanelId.CharInfo] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharEquipment] = {nL2dTime = 0, nBgTime = 0.3}
, 
[PanelId.CharSkill] = {nL2dTime = 0, nBgTime = 0.3}
, 
[PanelId.CharacterRelation] = {nL2dTime = 0, nBgTime = 0}
, 
[PanelId.CharPotential] = {nL2dTime = 0, nBgTime = 0.3}
}
}
CharBgPanel.Close = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (EventManager.Hit)(EventId.ClosePanel, PanelId.CharBgPanel)
end

CharBgPanel.GetPanelAnimCfg = function(self, nClosePanelId, nOpenPanelId)
  -- function num : 0_1 , upvalues : panel_switch_anim_cfg
  if panel_switch_anim_cfg[nClosePanelId] == nil then
    return 
  end
  if (panel_switch_anim_cfg[nClosePanelId])[nOpenPanelId] == nil then
    return 
  end
  return (panel_switch_anim_cfg[nClosePanelId])[nOpenPanelId]
end

CharBgPanel.GetPanelAnimTime = function(self, nClosePanelId, nOpenPanelId)
  -- function num : 0_2
  local tbCfg = self:GetPanelAnimCfg(nClosePanelId, nOpenPanelId)
  if tbCfg ~= nil then
    return tbCfg.nBgTime, tbCfg.nL2dTime
  end
end

CharBgPanel.PlayPanelSwitchAnim = function(self, trContent, nWidth, nTime)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Hit)(EventId.TemporaryBlockInput, nTime)
  local tweener = (trContent:DOAnchorPosX(nWidth, nTime)):SetUpdate(true)
  local tbCfg = self:GetPanelAnimCfg(self.nClosePanelId, self.nPanelId)
  if tbCfg ~= nil and tbCfg.uiEaseType ~= nil then
    tweener:SetEase(tbCfg.uiEaseType)
  end
  return tweener
end

CharBgPanel.GetPanelShowCfg = function(self)
  -- function num : 0_4 , upvalues : char_panel_show_cfg
  return char_panel_show_cfg
end

CharBgPanel.GetSubPanel = function(self)
  -- function num : 0_5 , upvalues : char_sub_panel
  return char_sub_panel
end

CharBgPanel.Awake = function(self)
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
      self.nCharId = tbParam[2]
    end
    if tbParam[3] ~= nil then
      self.tbCharList = tbParam[3]
    end
    if tbParam[4] ~= nil then
      self.param1 = tbParam[4]
    end
  end
  ;
  (table.insert)(self.panelStack, self.nPanelId)
end

CharBgPanel.OnEnable = function(self)
  -- function num : 0_7
end

CharBgPanel.OnDisable = function(self)
  -- function num : 0_8
end

CharBgPanel.OnEvent_CharRelatePanelOpen = function(self, nPanelId, ncharId, tbCharList, param1)
  -- function num : 0_9 , upvalues : char_sub_panel, _ENV
  self.nClosePanelId = self.nPanelId
  self.nPanelId = nPanelId
  self.bSecondPanel = false
  if ncharId ~= nil then
    self.ncharId = ncharId
  end
  if tbCharList ~= nil then
    self.tbCharList = tbCharList
  end
  if param1 ~= nil then
    self.param1 = param1
  end
  if char_sub_panel[nPanelId] then
    (table.insert)(self.panelStack, nPanelId)
  else
    if (self.panelStack)[#self.panelStack] == self.nClosePanelId then
      (table.remove)(self.panelStack, #self.panelStack)
      ;
      (table.insert)(self.panelStack, nPanelId)
    end
  end
  ;
  (EventManager.Hit)(EventId.CharRelatePanelAdvance, self.nClosePanelId, nPanelId)
end

CharBgPanel.OnEvent_CharRelatePanelClose = function(self, bForceClose)
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

return CharBgPanel

