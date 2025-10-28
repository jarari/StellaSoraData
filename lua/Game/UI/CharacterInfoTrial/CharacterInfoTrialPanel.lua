-- Panel 模板

local CharacterInfoTrialPanel = class("CharacterInfoTrialPanel", BasePanel)

CharacterInfoTrialPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharacterInfoTrialPanel._nFadeInType = 0 -- 如果有初次入场动画需求，则配置0

CharacterInfoTrialPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoTrial/CharacterInfoTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharacterInfoTrialCtrl"},
}

return CharacterInfoTrialPanel
