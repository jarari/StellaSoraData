-- Panel 模板

local CharacterInfoPanel = class("CharacterInfoPanel", BasePanel)

CharacterInfoPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharacterInfoPanel._nFadeInType = 0 -- 如果有初次入场动画需求，则配置0

CharacterInfoPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharacterInfoPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharacterInfoCtrl"},
}

return CharacterInfoPanel
