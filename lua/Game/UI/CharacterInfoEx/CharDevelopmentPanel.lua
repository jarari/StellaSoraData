-- CharDevelopmentPanel Panel
local CharDevelopmentPanel = class("CharDevelopmentPanel", BasePanel)
-- Panel 定义
CharDevelopmentPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharDevelopmentPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharDevelopmentPanel"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CharDevelopmentPanel:Awake()
end
function CharDevelopmentPanel:OnEnable()
end
function CharDevelopmentPanel:OnDisable()
end
function CharDevelopmentPanel:OnDestroy()
end
-------------------- callback function --------------------
return CharDevelopmentPanel
