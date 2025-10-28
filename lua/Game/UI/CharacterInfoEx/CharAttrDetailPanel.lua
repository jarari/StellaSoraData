
local CharAttrDetailPanel = class("CharAttrDetailPanel", BasePanel)

CharAttrDetailPanel._bIsMainPanel = false

CharAttrDetailPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharAttrDetailPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharAttrDetailCtrl"},
}

return CharAttrDetailPanel
