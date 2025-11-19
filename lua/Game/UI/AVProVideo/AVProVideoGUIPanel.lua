local AVProVideoGUIPanel = class("AVProVideoGUIPanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
AVProVideoGUIPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
AVProVideoGUIPanel._bIsMainPanel = false
AVProVideoGUIPanel._tbDefine = {
{sPrefabPath = "AVProVideo/AVProVideoGUI.prefab", sCtrlName = "Game.UI.AVProVideo.AVProVideoGUICtrl"}
}
AVProVideoGUIPanel.OnEnable = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager
  if (GamepadUIManager.GetInputState)() then
    (GamepadUIManager.EnableGamepadUI)("AVProVideoGUICtrl", ((self._tbObjCtrl)[1]).tbGamepadUINode)
  end
end

AVProVideoGUIPanel.OnDisable = function(self)
  -- function num : 0_1 , upvalues : GamepadUIManager
  if (GamepadUIManager.GetInputState)() then
    (GamepadUIManager.DisableGamepadUI)("AVProVideoGUICtrl")
  end
end

return AVProVideoGUIPanel

