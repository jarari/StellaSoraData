local ExeEditorPanel = class("ExeEditorPanel", BasePanel)
--[[ Panel 定义
    ExeEditorPanel._nFADEINTYPE = 1
    ExeEditorPanel._nFadeInType = 1
    ExeEditorPanel._bIsMainPanel = true
    ExeEditorPanel._bAddToBackHistory = true
    ExeEditorPanel._nSnapshotPrePanel = 0
    ExeEditorPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
ExeEditorPanel._tbDefine = {
    {sPrefabPath = "BubbleVoiceEditor/ExeEditorPanel.prefab", sCtrlName = "Game.Actor2D.Editor_BBV.ExeEditorCtrl"}
}
return ExeEditorPanel
