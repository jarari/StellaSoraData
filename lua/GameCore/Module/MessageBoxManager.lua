local MessageBoxManager = {}
local objMessageBoxPanel, objPopupTipsPanel, objSideBannerPanel, objOrderWaitPanel = nil, nil, nil, nil
local OnEvent_Open = function(_, mapMsg, sLanguageId)
  -- function num : 0_0 , upvalues : _ENV, objPopupTipsPanel, objMessageBoxPanel
  if type(mapMsg) == "string" then
    mapMsg = {nType = (AllEnum.MessageBox).Tips, bPositive = false, sContent = mapMsg}
  else
    if mapMsg == true then
      mapMsg = {nType = (AllEnum.MessageBox).Tips, bPositive = true, sContent = (ConfigTable.GetUIText)(sLanguageId)}
    end
  end
  if mapMsg.nType == (AllEnum.MessageBox).Tips then
    if objPopupTipsPanel == nil then
      local PopupTipsPanel = require("Game.UI.MessageBoxEx.PopupTipsPanel")
      objPopupTipsPanel = (PopupTipsPanel.new)((AllEnum.UI_SORTING_ORDER).MessageBoxOverlay, 0, mapMsg)
      objPopupTipsPanel:_PreEnter()
      objPopupTipsPanel:_Enter()
    else
      do
        ;
        (EventManager.Hit)("ContinuePopupTips", mapMsg)
        if objMessageBoxPanel == nil then
          local MessageBoxPanel = require("Game.UI.MessageBoxEx.MessageBoxPanel")
          objMessageBoxPanel = (MessageBoxPanel.new)((AllEnum.UI_SORTING_ORDER).MessageBox, 0, mapMsg)
          objMessageBoxPanel:_PreEnter()
          objMessageBoxPanel:_Enter()
        else
          do
            ;
            (EventManager.Hit)("ContinueMessageBox", mapMsg)
          end
        end
      end
    end
  end
end

local OnEvent_ClosePopupTips = function(_)
  -- function num : 0_1 , upvalues : objPopupTipsPanel
  if objPopupTipsPanel then
    objPopupTipsPanel:_PreExit()
    objPopupTipsPanel:_Exit()
    objPopupTipsPanel:_Destroy()
    objPopupTipsPanel = nil
  end
end

local OnEvent_CloseMessageBox = function(_)
  -- function num : 0_2 , upvalues : objMessageBoxPanel
  if objMessageBoxPanel then
    objMessageBoxPanel:_PreExit()
    objMessageBoxPanel:_Exit()
    objMessageBoxPanel:_Destroy()
    objMessageBoxPanel = nil
  end
end

local OpenSideBannerPanel = function(mapMsg)
  -- function num : 0_3 , upvalues : _ENV, objSideBannerPanel
  local SideBannerPanel = require("Game.UI.SideBanner.SideBannerPanel")
  objSideBannerPanel = (SideBannerPanel.new)((AllEnum.UI_SORTING_ORDER).MessageBoxOverlay, 0, mapMsg)
  objSideBannerPanel:_PreEnter()
  objSideBannerPanel:_Enter()
end

local OnEvent_CloseSideBanner = function(_)
  -- function num : 0_4 , upvalues : objSideBannerPanel
  if objSideBannerPanel then
    objSideBannerPanel:_PreExit()
    objSideBannerPanel:_Exit()
    objSideBannerPanel:_Destroy()
    objSideBannerPanel = nil
  end
end

local OnEvent_OpenSideBanner = function(_, mapMsg)
  -- function num : 0_5 , upvalues : objSideBannerPanel, OpenSideBannerPanel, OnEvent_CloseSideBanner
  if objSideBannerPanel == nil then
    OpenSideBannerPanel(mapMsg)
  else
    OnEvent_CloseSideBanner()
    OpenSideBannerPanel(mapMsg)
  end
end

local OpenOrderWaitPanel = function(mapMsg)
  -- function num : 0_6 , upvalues : _ENV, objOrderWaitPanel
  local OrderWaitPanel = require("Game.UI.Mall.OrderWaitPanel")
  objOrderWaitPanel = (OrderWaitPanel.new)((AllEnum.UI_SORTING_ORDER).MessageBox, 0, mapMsg)
  objOrderWaitPanel:_PreEnter()
  objOrderWaitPanel:_Enter()
end

local OnEvent_CloseOrderWait = function(_)
  -- function num : 0_7 , upvalues : objOrderWaitPanel
  if objOrderWaitPanel then
    objOrderWaitPanel:_PreExit()
    objOrderWaitPanel:_Exit()
    objOrderWaitPanel:_Destroy()
    objOrderWaitPanel = nil
  end
end

local OnEvent_OpenOrderWait = function(_, mapMsg)
  -- function num : 0_8 , upvalues : objOrderWaitPanel, OpenOrderWaitPanel, OnEvent_CloseOrderWait
  if objOrderWaitPanel == nil then
    OpenOrderWaitPanel(mapMsg)
  else
    OnEvent_CloseOrderWait()
    OpenOrderWaitPanel(mapMsg)
  end
end

local Uninit = function(_)
  -- function num : 0_9 , upvalues : _ENV, MessageBoxManager, OnEvent_Open, OnEvent_CloseMessageBox, OnEvent_OpenSideBanner, OnEvent_CloseSideBanner, OnEvent_OpenOrderWait, OnEvent_CloseOrderWait, Uninit
  (EventManager.Remove)(EventId.OpenMessageBox, MessageBoxManager, OnEvent_Open)
  ;
  (EventManager.Remove)(EventId.CloseMessageBox, MessageBoxManager, OnEvent_CloseMessageBox)
  ;
  (EventManager.Remove)("OpenSideBanner", MessageBoxManager, OnEvent_OpenSideBanner)
  ;
  (EventManager.Remove)("CloseSideBanner", MessageBoxManager, OnEvent_CloseSideBanner)
  ;
  (EventManager.Remove)("OpenOrderWait", MessageBoxManager, OnEvent_OpenOrderWait)
  ;
  (EventManager.Remove)("CloseOrderWait", MessageBoxManager, OnEvent_CloseOrderWait)
  ;
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, MessageBoxManager, Uninit)
end

MessageBoxManager.CheckOrderWaitOpen = function()
  -- function num : 0_10 , upvalues : objOrderWaitPanel
  do return objOrderWaitPanel ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

MessageBoxManager.Init = function()
  -- function num : 0_11 , upvalues : _ENV, MessageBoxManager, OnEvent_Open, OnEvent_CloseMessageBox, OnEvent_ClosePopupTips, OnEvent_OpenSideBanner, OnEvent_CloseSideBanner, OnEvent_OpenOrderWait, OnEvent_CloseOrderWait, Uninit
  (EventManager.Add)(EventId.OpenMessageBox, MessageBoxManager, OnEvent_Open)
  ;
  (EventManager.Add)(EventId.CloseMessageBox, MessageBoxManager, OnEvent_CloseMessageBox)
  ;
  (EventManager.Add)(EventId.ClosePopupTips, MessageBoxManager, OnEvent_ClosePopupTips)
  ;
  (EventManager.Add)("OpenSideBanner", MessageBoxManager, OnEvent_OpenSideBanner)
  ;
  (EventManager.Add)("CloseSideBanner", MessageBoxManager, OnEvent_CloseSideBanner)
  ;
  (EventManager.Add)("OpenOrderWait", MessageBoxManager, OnEvent_OpenOrderWait)
  ;
  (EventManager.Add)("CloseOrderWait", MessageBoxManager, OnEvent_CloseOrderWait)
  ;
  (EventManager.Add)(EventId.CSLuaManagerShutdown, MessageBoxManager, Uninit)
end

return MessageBoxManager

