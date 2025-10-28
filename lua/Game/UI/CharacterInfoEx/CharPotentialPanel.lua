-- CharPotentialPanel Panel

local CharPotentialPanel = class("CharPotentialPanel", BasePanel)
-- Panel 定义
CharPotentialPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharPotentialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharPotentialCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CharPotentialPanel:Awake()
end
function CharPotentialPanel:OnEnable()
end
function CharPotentialPanel:OnDisable()
end
function CharPotentialPanel:OnDestroy()
end
-------------------- callback function --------------------
return CharPotentialPanel
