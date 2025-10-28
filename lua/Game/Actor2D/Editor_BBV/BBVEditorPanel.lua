local BBVEditorPanel = class("BBVEditorPanel", BasePanel)
--[[ Panel 定义
    BBVEditorPanel._nFADEINTYPE = 1
    BBVEditorPanel._nFadeInType = 1
    BBVEditorPanel._bIsMainPanel = true
    BBVEditorPanel._bAddToBackHistory = true
    BBVEditorPanel._nSnapshotPrePanel = 0
    BBVEditorPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
BBVEditorPanel._tbDefine = {
    {sPrefabPath = "BubbleVoiceEditor/BubbleVoiceEditorPanel.prefab", sCtrlName = "Game.Actor2D.Editor_BBV.BBVEditorCtrl"}
}
return BBVEditorPanel
