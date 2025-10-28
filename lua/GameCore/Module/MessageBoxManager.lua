local MessageBoxManager = {}
local objMessageBoxPanel = nil
local objPopupTipsPanel = nil
local objSideBannerPanel = nil
local objOrderWaitPanel = nil

local function OnEvent_Open(_, mapMsg, sLanguageId)
    if type(mapMsg) == "string" then -- lua用的飘字内容简化输入
        mapMsg = {
            nType = AllEnum.MessageBox.Tips,
            bPositive = false,
            sContent = mapMsg,
        }
    elseif mapMsg == true then -- 场景触发的飘字提示事件特殊处理
        mapMsg = {
            nType = AllEnum.MessageBox.Tips,
            bPositive = true,
            sContent = ConfigTable.GetUIText(sLanguageId),
        }
    end

    if mapMsg.nType == AllEnum.MessageBox.Tips then
        if objPopupTipsPanel == nil then
            local PopupTipsPanel = require "Game.UI.MessageBoxEx.PopupTipsPanel"
            objPopupTipsPanel = PopupTipsPanel.new(AllEnum.UI_SORTING_ORDER.MessageBoxOverlay, 0, mapMsg)
            objPopupTipsPanel:_PreEnter()
            objPopupTipsPanel:_Enter()
        else
            EventManager.Hit("ContinuePopupTips", mapMsg)
        end
    else
        if objMessageBoxPanel == nil then
            local MessageBoxPanel = require "Game.UI.MessageBoxEx.MessageBoxPanel"
            objMessageBoxPanel = MessageBoxPanel.new(AllEnum.UI_SORTING_ORDER.MessageBox, 0, mapMsg)
            objMessageBoxPanel:_PreEnter()
            objMessageBoxPanel:_Enter()
        else
            EventManager.Hit("ContinueMessageBox", mapMsg)
        end
    end
end
local function OnEvent_ClosePopupTips(_)
    if objPopupTipsPanel then
        objPopupTipsPanel:_PreExit()
        objPopupTipsPanel:_Exit()
        objPopupTipsPanel:_Destroy()
        objPopupTipsPanel = nil
    end
end
local function OnEvent_CloseMessageBox(_)
    if objMessageBoxPanel then
        objMessageBoxPanel:_PreExit()
        objMessageBoxPanel:_Exit()
        objMessageBoxPanel:_Destroy()
        objMessageBoxPanel = nil
    end
end

------ 侧边栏 ------
local function OpenSideBannerPanel(mapMsg)
    local SideBannerPanel = require "Game.UI.SideBanner.SideBannerPanel"
    objSideBannerPanel = SideBannerPanel.new(AllEnum.UI_SORTING_ORDER.MessageBoxOverlay, 0, mapMsg)
    objSideBannerPanel:_PreEnter()
    objSideBannerPanel:_Enter()
end

local function OnEvent_CloseSideBanner(_)
    if objSideBannerPanel then
        objSideBannerPanel:_PreExit()
        objSideBannerPanel:_Exit()
        objSideBannerPanel:_Destroy()
        objSideBannerPanel = nil
    end
end

local function OnEvent_OpenSideBanner(_, mapMsg)
    if objSideBannerPanel == nil then
        OpenSideBannerPanel(mapMsg)
    else
        OnEvent_CloseSideBanner()
        OpenSideBannerPanel(mapMsg)
    end
end

------ 订单处理中提示 ------
local function OpenOrderWaitPanel(mapMsg)
    local OrderWaitPanel = require "Game.UI.Mall.OrderWaitPanel"
    objOrderWaitPanel = OrderWaitPanel.new(AllEnum.UI_SORTING_ORDER.MessageBox, 0, mapMsg)
    objOrderWaitPanel:_PreEnter()
    objOrderWaitPanel:_Enter()
end

local function OnEvent_CloseOrderWait(_)
    if objOrderWaitPanel then
        objOrderWaitPanel:_PreExit()
        objOrderWaitPanel:_Exit()
        objOrderWaitPanel:_Destroy()
        objOrderWaitPanel = nil
    end
end

local function OnEvent_OpenOrderWait(_, mapMsg)
    if objOrderWaitPanel == nil then
        OpenOrderWaitPanel(mapMsg)
    else
        OnEvent_CloseOrderWait()
        OpenOrderWaitPanel(mapMsg)
    end
end

local function Uninit(_)
    EventManager.Remove(EventId.OpenMessageBox, MessageBoxManager, OnEvent_Open)
    EventManager.Remove(EventId.CloseMessageBox, MessageBoxManager, OnEvent_CloseMessageBox)
    EventManager.Remove("OpenSideBanner", MessageBoxManager, OnEvent_OpenSideBanner)
    EventManager.Remove("CloseSideBanner", MessageBoxManager, OnEvent_CloseSideBanner)
    EventManager.Remove("OpenOrderWait", MessageBoxManager, OnEvent_OpenOrderWait)
    EventManager.Remove("CloseOrderWait", MessageBoxManager, OnEvent_CloseOrderWait)
    -- 游戏app关闭
    EventManager.Remove(EventId.CSLuaManagerShutdown, MessageBoxManager, Uninit)
end

function MessageBoxManager.CheckOrderWaitOpen()
    return objOrderWaitPanel ~= nil
end

function MessageBoxManager.Init()
    EventManager.Add(EventId.OpenMessageBox, MessageBoxManager, OnEvent_Open)
    EventManager.Add(EventId.CloseMessageBox, MessageBoxManager, OnEvent_CloseMessageBox)
    EventManager.Add(EventId.ClosePopupTips, MessageBoxManager, OnEvent_ClosePopupTips)
    EventManager.Add("OpenSideBanner", MessageBoxManager, OnEvent_OpenSideBanner)
    EventManager.Add("CloseSideBanner", MessageBoxManager, OnEvent_CloseSideBanner)
    EventManager.Add("OpenOrderWait", MessageBoxManager, OnEvent_OpenOrderWait)
    EventManager.Add("CloseOrderWait", MessageBoxManager, OnEvent_CloseOrderWait)
    -- 游戏app关闭
    EventManager.Add(EventId.CSLuaManagerShutdown, MessageBoxManager, Uninit)
end
return MessageBoxManager

-- 弹窗-两个按钮
-- local msg = {
--     nType = AllEnum.MessageBox.Confirm,
--     sContent = "1",
--     sContentSub = "2",
--     sTitle = "", -- 不填默认"提示"
--     sConfirm = "", -- 不填默认"确认"
--     sCancel = "", -- 不填默认"取消"
--     callbackConfirm = function () -- 不填默认直接关闭
--     end,
--     callbackCancel = function () -- 不填默认直接关闭
--     end,
--     bDisableSnap = true, -- 不填默认背景可点击
--     bCloseNoHandler = true, -- 点击右上关闭按钮是否执行取消回调
--     bBlur = true, -- 不填默认开启背景模糊
--     bRedCancel = true, -- 使用红色的取消
--     bGrayConfirm = true, -- 不可点击确认
-- }
-- EventManager.Hit(EventId.OpenMessageBox, msg)

-- 弹窗-一个按钮
-- local msg = {
--     nType = AllEnum.MessageBox.Alert,
--     sContent = "1",
--     sContentSub = "2",
--     sTitle = "", -- 不填默认"提示"
--     sConfirm = "", -- 不填默认"确认"
--     callbackConfirm = function () -- 不填默认直接关闭
--     end,
--     bDisableSnap = true, -- 不填默认背景可点击
--     bCloseNoHandler = true, -- 点击右上关闭按钮是否执行取消回调
--     bBlur = true, -- 不填默认开启背景模糊
-- }
-- EventManager.Hit(EventId.OpenMessageBox, msg)

-- 飘字提示
-- EventManager.Hit(EventId.OpenMessageBox, sTips)

-- 弹窗-说明
-- local msg = {
--     nType = AllEnum.MessageBox.Desc,
--     sContent = "1",
--     sTitle = "", -- 不填默认"说明"
--     sConfirm = "", -- 不填默认"确认"
--     callbackConfirm = function () -- 不填默认直接关闭
--     end,
--     bDisableSnap = true, -- 不填默认背景可点击
--     bCloseNoHandler = true, -- 点击右上关闭按钮是否执行取消回调（不填默认执行）
--     bBlur = true, -- 不填默认开启背景模糊
-- }
-- EventManager.Hit(EventId.OpenMessageBox, msg)

-- 弹窗-两个按钮带道具格子
-- local msg = {
--     nType = AllEnum.MessageBox.Item,
--     sContent = "1",
--     sContentSub = "2",
--     tbItem = {
--         [1] = {nTid = 0, nCount = 1},
--     },
--     sTitle = "", -- 不填默认"提示"
--     sConfirm = "", -- 不填默认"确认"
--     sCancel = "", -- 不填默认"取消"
--     callbackConfirm = function () -- 不填默认直接关闭
--     end,
--     callbackCancel = function () -- 不填默认直接关闭
--     end,
--     bDisableSnap = true, -- 不填默认背景可点击
--     bCloseNoHandler = true, -- 点击右上关闭按钮是否执行取消回调（不填默认执行）
--     bBlur = true, -- 不填默认开启背景模糊
-- }
-- EventManager.Hit(EventId.OpenMessageBox, msg)

-- 弹窗-道具格子
-- local msg = {
--     nType = AllEnum.MessageBox.ItemList,
--     tbItem = {
--         [1] = {nId = 0, nCount = 1},
--     },
--     sTitle = "", -- 不填默认"奖励预览"
--     bDisableSnap = true, -- 不填默认背景可点击
--     bCloseNoHandler = true, -- 点击右上关闭按钮是否执行取消回调（不填默认执行）
--     bBlur = true, -- 不填默认开启背景模糊
-- }
-- EventManager.Hit(EventId.OpenMessageBox, msg)

-- 弹窗-不带确认取消按钮的说明文本
-- local msg = {
--     nType = AllEnum.MessageBox.PlainText,
--     sContent = "1",
--     sTitle = "", -- 不填默认"提示"
--     bDisableSnap = true, -- 不填默认背景可点击
--     bCloseNoHandler = true, -- 点击右上关闭按钮是否执行取消回调（不填默认执行）
--     bBlur = true, -- 不填默认开启背景模糊
-- }
-- EventManager.Hit(EventId.OpenMessageBox, msg)