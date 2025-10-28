
local ProloguePanel = class("ProloguePanel", BasePanel)
ProloguePanel.OpenMinMap = false
ProloguePanel._bAddToBackHistory = false
ProloguePanel._tbDefine =
{
    {
      --sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab",sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl",
      sPrefabPath = "Battle/ProloguePanel.prefab",sCtrlName = "Game.UI.Battle.PrologueCtrl" 
    },
    { sPrefabPath = "Battle/SkillHintIndicators.prefab",sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators" },
}

-------------------- base function --------------------

-------------------- callback function --------------------
function ProloguePanel:OnEnable()
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        --开启
        --EventManager.Hit(EventId.OpenPanel, PanelId.Hud)
    end
    cs_coroutine.start(wait)
end
return ProloguePanel