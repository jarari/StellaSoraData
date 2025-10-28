-- BaseCtrl
local ConfigData = require "GameCore.Data.ConfigData"
local TimerManager = require "GameCore.Timer.TimerManager"
local GameResourceLoader = require "Game.Common.Resource.GameResourceLoader"
local ResType = GameResourceLoader.ResType
local AdventureModuleHelper = CS.AdventureModuleHelper
local BaseCtrl = class("BaseCtrl")
local sRootPath = Settings.AB_ROOT_PATH
local bDebugLog = false
local typeof = typeof
--[[
    NodeConfig 说明

    Key 为代码中使用的变量名，一般就用节点名。
    Value 为 config table，5个字段名及作用：

    (1)sNodeName 选填(string)，默认与 Key 一样。

    (2)sComponentName 选填(string)，默认 GameObject 类型。

    (3)callback 选填(string)，若填了 sComponent 必填，
    目前只支持 Button ButtonEx Toggle ScrollRect 组件类型的callback绑定，
    如需要增加组件类型，在 BaseCtrl 中相应添加，
    callback 参数1：self，参数2：组件对象，参数3：由组件类型决定，
    如 Toggle 会带 bool isOn 表明该组件当前 on/off 状态。

    (4)sCtrlName 选填(string)，子 ctrl 概念，同 ctrl 一样，填 Lua 路径，
    若填了，则该节点的子、孙节点不再解析，不在当前 ctrl 中缓存，
    而缓存在子 ctrl 中，当前 ctrl 中只缓存子 ctrl 实例，
    同时 sComponentName 和 callback 失效。

    (5)nCount 选填(number)，会按 sNodeName + n 的 string 去匹配节点，
    在 ctrl 中以数组形式缓存节点组件，组件类型由 sComponent 决定，
    组件回调由 callback 决定，
    callback 参数1：self，参数2：组件对象，参数3：数组索引，参数4：由组件类型决定，
    如：Toggle 会带 bool isOn 表明该组件当前 on/off 状态。
]]
---------- 界面切换流程 ---------- begin

---@diagnostic disable-next-line: duplicate-set-field
function BaseCtrl:ctor(goPrefabInstance, objPanel)
    self._panel = objPanel
    self._tbTimer = {} -- timer array
    self._mapPrefab = {} -- 管理该 ctrl 中其余的 Prefab 实例。
    self._mapLoadAssets = {} -- 管理该 ctrl 中其余的 Prefab 实例。
    self._mapHandler = {} -- key:node name, value: callback ui_handler function
    self._mapNode = {} -- 根据 ctrl 实例中填写的节点配置，解析并缓存预设体实例中的组件。
    self:ParsePrefab(goPrefabInstance)
    if type(self.Awake) == "function" then
        self:Awake()
    end
    self._autoRemoveUnusedTimer = nil
end
function BaseCtrl:ParsePrefab(goPrefabInstance)
    if goPrefabInstance ~= nil and goPrefabInstance:IsNull() == false then
        self.gameObject = goPrefabInstance
    end
    self:_ParseNode(self._mapNodeConfig)
end
function BaseCtrl:_PreExit(callback, bPlayFadeOut)
    self:_UnbindComponentCallback(self._mapNodeConfig)
    self:_UnbindEventCallback(self._mapEventConfig)
    self:_RemoveAllTimer()
    if type(self.OnPreExit) == "function" then
        self:OnPreExit()
    end
    local func_DoCallback = function()
        if type(callback) == "function" then
            callback()
        end
    end
    if bPlayFadeOut == true and type(self.FadeOut) == "function" then
        local nDelayTime = self:FadeOut()
        if type(nDelayTime) == "number" and nDelayTime > 0 then
            local func_timer = function(timer)
                func_DoCallback()
            end
            TimerManager.Add(1, nDelayTime, self, func_timer, true, true)
        else
            func_DoCallback()
        end
    else
        func_DoCallback()
    end
end
function BaseCtrl:_Exit()
    if type(self.OnDisable) == "function" then
        self:OnDisable()
    end
    if type(self._mapNode) == "table" then
        for sKey, obj in pairs(self._mapNode) do
            if type(obj) ~= "table" then -- 是一个 unity object
                self._mapNode[sKey] = 0 -- 占位接引用
            else
                if type(obj.__cname) == "string" then -- 是一个 lua class obj 暂先不动
                else -- 是一个普通的 lua table
                    for i, _obj in ipairs(obj) do
                        if type(_obj) ~= "table" then -- 是一个 unity object
                            self._mapNode[sKey][i] = 0 -- 占位接引用
                        else -- 是一个 lua class obj 暂先不动，在 base panel 里会统一处理。
                        end
                    end
                end
            end
        end
    end
    self:_DebugLogDataCount("OnDisable")
end
function BaseCtrl:_Enter(bPlayFadeIn)
    self:_BindComponentCallback(self._mapNodeConfig)
    self:_BindEventCallback(self._mapEventConfig)
    self:_RegisterRedDot()
    if type(self.OnEnable) == "function" then
        self:OnEnable()
    end
    if type(self.FadeIn) == "function" then
        self:FadeIn(bPlayFadeIn)
        self._panel._nFadeInType = self._panel._nFADEINTYPE -- 重置当前界面初始进入动画状态
    end
    self:_DebugLogDataCount("OnEnable")
end
function BaseCtrl:_Destroy()
    if type(self.OnDestroy) == "function" then
        self:OnDestroy()
    end
    for k,v in pairs(self._mapPrefab) do
        self:DestroyPrefabInstance(k)
    end
    for k,v in pairs(self._mapLoadAssets) do
        self:UnLoadAsset(k)
    end
    self._panel = nil
    self._tbTimer = nil
    self._mapPrefab = nil
    self._mapLoadAssets = nil
    self._mapHandler = nil
    self._mapNode = nil
end
function BaseCtrl:_Release()
    if self.gameObject ~= nil and self.gameObject:IsNull() == false then
        if type(self.OnRelease) == "function" then
            self:OnRelease()
        end
    end
end
---------- 界面切换流程 ---------- end
function BaseCtrl:_ParseNode(mapNodeConfig)
    if self.gameObject ~= nil and type(mapNodeConfig) == "table" then
        local trPrefabRoot = self.gameObject.transform
        local mapNode = {}
        local function func_MarkAllNode(trRoot)
            local nChildCount = trRoot.childCount - 1
            for i = 0, nChildCount, 1 do
                local trChild = trRoot:GetChild(i)
                mapNode[trChild.name] = trChild.gameObject
                if trChild.childCount > 0 then
                    func_MarkAllNode(trChild)
                end
            end
        end
        func_MarkAllNode(trPrefabRoot)
        for sKey, mapConfig in pairs(mapNodeConfig) do
            local sNodeName = mapConfig.sNodeName
            local nCount = mapConfig.nCount
            local sComponentName = mapConfig.sComponentName
            local sCtrlName = mapConfig.sCtrlName
            local sLanguageId = mapConfig.sLanguageId
            if type(sNodeName) ~= "string" then sNodeName = tostring(sKey) end
            local tbNodeName = {}
            if type(nCount) == "number" then
                if type(self._mapNode[sKey]) ~= "table" then
                    self._mapNode[sKey] = {}
                end
                for i = 1, nCount, 1 do
                    table.insert(tbNodeName, sNodeName .. tostring(i))
                end
            else
                table.insert(tbNodeName, sNodeName)
            end
            for nIndex, sName in ipairs(tbNodeName) do
                local bComponentFound = true
                local objNode = nil
                local goNode = mapNode[sName]
                if goNode ~= nil then
                    if type(sCtrlName) == "string" then
                        local objCtrl = nil
                        local nGoInstanceId = goNode:GetInstanceID()
                        for _nObjCtrlIdx, _objCtrl in ipairs(self._panel._tbObjChildCtrl) do
                            if _objCtrl._nGoInstanceId == nGoInstanceId then
                                objCtrl = _objCtrl
                                break
                            end
                        end
                        if objCtrl == nil then
                            local luaClass = require(sCtrlName)
                            objCtrl = luaClass.new(goNode, self._panel)
                            objCtrl._nGoInstanceId = nGoInstanceId
                            table.insert(self._panel._tbObjChildCtrl, objCtrl)
                        end
                        objCtrl:ParsePrefab(goNode)
                        objNode = objCtrl
                    else
                        if sComponentName == nil then sComponentName = "GameObject" end
                        if sComponentName == "GameObject" then
                            objNode = goNode
                        elseif sComponentName == "Transform" then
                            objNode = goNode.transform
                        else
                            local _sComponentName = sComponentName
                            if sComponentName == "InputField_onEndEdit" then _sComponentName = "InputField" end
                            bComponentFound, objNode = goNode:GetNodeComponent(_sComponentName) -- objNode = goNode:GetComponent(sComponentName)
                            if objNode ~= nil and type(sLanguageId) == "string" then
                                if _sComponentName == "Text" then
                                    if ConfigTable.GetUIText(sLanguageId) then
                                        NovaAPI.SetText(objNode, ConfigTable.GetUIText(sLanguageId))
                                    else
                                        printError("UIText缺失配置:" .. sLanguageId)
                                    end
                                elseif _sComponentName == "TMP_Text" then
                                    if ConfigTable.GetUIText(sLanguageId) then
                                        NovaAPI.SetTMPText(objNode, ConfigTable.GetUIText(sLanguageId))
                                    else
                                        printError("UIText缺失配置:" .. sLanguageId)
                                    end
                                end
                            end
                        end
                    end
                    if bComponentFound == true and objNode ~= nil then
                        if type(nCount) == "number" then
                            self._mapNode[sKey][nIndex] = objNode
                        else
                            self._mapNode[sKey] = objNode
                        end
                    else
                        printError("节点找到了但组件没找到，节点名：" .. sName .. "，组件名：".. sComponentName .. "，panel id：" .. tostring(table.keyof(PanelId, self._panel._nPanelId)))
                    end
                else
                    printError("界面预设体中配置的节点没找到，预设体名字：" .. trPrefabRoot.name .. "，节点名字：" .. sName)
                end
            end
        end
    end
end
function BaseCtrl:_BindComponentCallback(mapNodeConfig)
    if type(mapNodeConfig) ~= "table" then
        return
    end
    local function func_DoBind(objComp, sCompName, cb, sNodeKey, nIndex)
        local sHandlerKey = sNodeKey
        if type(nIndex) == "number" then
            sHandlerKey = sNodeKey .. tostring(nIndex)
        end
        local func_Handler = function(...)
            local ui_func = ui_handler(self, cb, objComp, nIndex)
            ui_func(...)
            EventManager.Hit(EventId.UIOperate)
        end
        --local func_Handler = ui_handler(self, cb, objComp, nIndex)
        if sCompName == "Button" then
            objComp.onClick:AddListener(func_Handler)
            --NovaAPI.AddButtonListener(objComp, func_Handler)
        elseif sCompName == "ButtonEx" then
            objComp.onClick:AddListener(func_Handler)
        elseif sCompName == "UIButton" then
            objComp.onClick:AddListener(func_Handler)
            --NovaAPI.AddUIButtonListener(objComp, func_Handler)
        elseif sCompName == "NaviButton" then
            objComp.onClick:AddListener(func_Handler)
        elseif sCompName == "TMPHyperLink" then
            objComp.onClick:AddListener(func_Handler)
        elseif sCompName == "Toggle" then
            NovaAPI.AddToggleListener(objComp, func_Handler)
        elseif sCompName == "UIToggle" then
            NovaAPI.AddUIToggleListener(objComp, func_Handler)
        elseif sCompName == "ScrollRect" then
            NovaAPI.AddScrollRectListener(objComp, func_Handler)
        elseif sCompName == "Slider" then
            NovaAPI.AddSliderListener(objComp, func_Handler)
        elseif sCompName == "LoopScrollView" then
            objComp.onValueChanged:AddListener(func_Handler)
        elseif sCompName == "InputField" then
            NovaAPI.AddIPValueChangedListener(objComp, func_Handler)
        elseif sCompName == "InputField_onEndEdit" then
            objComp.onEndEdit:AddListener(func_Handler)
        elseif sCompName == "TMP_Dropdown" then
            objComp.onValueChanged:AddListener(func_Handler)
        elseif sCompName == "Dropdown" then
            NovaAPI.AddDropDownListener(objComp, func_Handler)
        elseif sCompName == "TMP_InputField" then
            objComp.onValueChanged:AddListener(func_Handler)
        elseif sCompName == "LoopScrollSnap" then
            objComp.onGridSelect:AddListener(func_Handler)
 	    elseif sCompName == "UIDrag" then
            objComp.onDragEvent:AddListener(func_Handler)
        elseif sCompName == "UIZoom" then
            objComp.onZoom:AddListener(func_Handler)
        else
        end
        if type(func_Handler) == "function" then
            self._mapHandler[sHandlerKey] = func_Handler
        end
    end
    for sKey, mapConfig in pairs(mapNodeConfig) do
        local sCallback = mapConfig.callback
        local sComponentName = mapConfig.sComponentName
        local nCount = mapConfig.nCount
        if type(sCallback) == "string" and type(sComponentName) == "string" then
            local funcCallback = self[sCallback]
            if type(funcCallback) == "function" then
                if type(self._mapNode[sKey]) == "table" and type(nCount) == "number" then
                    for i = 1, nCount, 1 do
                        func_DoBind(self._mapNode[sKey][i], sComponentName, funcCallback, sKey, i)
                    end
                else
                    func_DoBind(self._mapNode[sKey], sComponentName, funcCallback, sKey)
                end
            else
                printError("没有找到组件的回调函数，节点名字：" .. sKey .. "，回调函数名字：" .. sCallback)
            end
        end
    end
end
function BaseCtrl:_UnbindComponentCallback(mapNodeConfig)
    if type(mapNodeConfig) ~= "table" then
        return
    end
    local function func_DoUnbind(objComp, sCompName, sNodeKey, nIndex)
        local sHandlerKey = sNodeKey
        if type(nIndex) == "number" then
            sHandlerKey = sNodeKey .. tostring(nIndex)
        end
        local func_Handler = self._mapHandler[sHandlerKey]
        if objComp ~= nil and func_Handler ~= nil then
            if sCompName == "Button" then
                objComp.onClick:RemoveListener(func_Handler)
                --NovaAPI.RemoveButtonListener(objComp, func_Handler)
            elseif sCompName == "ButtonEx" then
                objComp.onClick:RemoveListener(func_Handler)
            elseif sCompName == "UIButton" then
                objComp.onClick:RemoveListener(func_Handler)
                --NovaAPI.RemoveUIButtonListener(objComp, func_Handler)
            elseif sCompName == "NaviButton" then
                objComp.onClick:RemoveListener(func_Handler)
            elseif sCompName == "TMPHyperLink" then
                objComp.onClick:RemoveListener(func_Handler)
            elseif sCompName == "Toggle" then
                NovaAPI.RemoveToggleListener(objComp, func_Handler)
            elseif sCompName == "UIToggle" then
                NovaAPI.RemoveUIToggleListener(objComp, func_Handler)
            elseif sCompName == "ScrollRect" then
                NovaAPI.RemoveScrollRectListener(objComp, func_Handler)
            elseif sCompName == "Slider" then
                NovaAPI.RemoveSliderListener(objComp, func_Handler)
            elseif sCompName == "LoopScrollView" then
                objComp.onValueChanged:RemoveListener(func_Handler)
            elseif sCompName == "InputField" then
                NovaAPI.RemoveIPValueChangedListener(objComp, func_Handler)
            elseif sCompName == "InputField_onEndEdit" then
                objComp.onEndEdit:RemoveListener(func_Handler)
            elseif sCompName == "TMP_Dropdown" then
                objComp.onValueChanged:RemoveListener(func_Handler)
            elseif sCompName == "Dropdown" then
                NovaAPI.RemoveDropDownListener(objComp, func_Handler)
            elseif sCompName == "TMP_InputField" then
                objComp.onValueChanged:RemoveListener(func_Handler)
            elseif sCompName == "LoopScrollSnap" then
                objComp.onGridSelect:RemoveListener(func_Handler)
	        elseif sCompName == "UIDrag" then
                objComp.onDragEvent:RemoveListener(func_Handler)
            elseif sCompName == "UIZoom" then
                objComp.onZoom:RemoveListener(func_Handler)
            end
        end
        self._mapHandler[sHandlerKey] = nil
        func_Handler = nil
    end
    for sKey, mapConfig in pairs(mapNodeConfig) do
        local sCallback = mapConfig.callback
        local sComponentName = mapConfig.sComponentName
        local nCount = mapConfig.nCount
        if type(sCallback) == "string" and type(sComponentName) == "string" then
            local funcCallback = self[sCallback]
            if type(funcCallback) == "function" then
                if type(self._mapNode[sKey]) == "table" and type(nCount) == "number" then
                    for i = 1, nCount, 1 do
                        func_DoUnbind(self._mapNode[sKey][i], sComponentName, sKey, i)
                    end
                else
                    func_DoUnbind(self._mapNode[sKey], sComponentName, sKey)
                end
            else
                printError("没有找到组件的回调函数，节点名字：" .. sKey .. "，回调函数名字：" .. sCallback)
            end
        end
    end
end
function BaseCtrl:_BindEventCallback(mapEventConfig)
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Add(nEventId, self, callback)
        end
    end
end
function BaseCtrl:_UnbindEventCallback(mapEventConfig)
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Remove(nEventId, self, callback)
        end
    end
end
function BaseCtrl:_RemoveAllTimer()
    local n = #self._tbTimer
    for i = n, 1, -1 do
        TimerManager.Remove(self._tbTimer[i], false)
        table.remove(self._tbTimer, i)
    end
    if table.nums(self._tbTimer) > 0 then self._tbTimer = {} end
    if self._autoRemoveUnusedTimer ~= nil then
        self._autoRemoveUnusedTimer:Cancel()
        self._autoRemoveUnusedTimer = nil
    end
end
function BaseCtrl:_DebugLogDataCount(sTitle)
    if bDebugLog == false then
        return
    end
    local sCtrlName = self.__cname
    local sGoName = self.gameObject.name
    local nTimerCnt = table.nums(self._tbTimer)
    local nPrefabInsCnt = table.nums(self._mapPrefab)
    local nHandlerCnt = table.nums(self._mapHandler)
    local nNodeCnt = table.nums(self._mapNode)
    local sDebugLog = string.format(
        "[%s.%s] 预设体：%s，计时器数量：%d，自理预设体实例数量：%d，回调数量：%d，节点数量：%d。", 
        sCtrlName, sTitle, sGoName, nTimerCnt, nPrefabInsCnt, nHandlerCnt, nNodeCnt)
    printLog(sDebugLog)
    -- printTable(self._mapNode)
end

--注册红点
function BaseCtrl:_RegisterRedDot()
    if nil ~= self._mapRedDotConfig then
        for key, cfg in pairs(self._mapRedDotConfig) do
            local sNodeName = cfg.sNodeName
            local nNodeIndex = cfg.nNodeIndex
            local objNode
            if nil == nNodeIndex then
                objNode = self._mapNode[sNodeName]
            else
                if nil ~= self._mapNode[sNodeName] then
                    objNode = self._mapNode[sNodeName][nNodeIndex]
                end
            end
            
            if nil == objNode then
                printError(string.format("绑定红点失败！！！ 找不到红点节点.key = %s, nodeName = %s", key, sNodeName))
            else
                RedDotManager.RegisterNode(key, cfg.param, objNode.gameObject)
            end
        end
    end
end
-------------------- public function --------------------
function BaseCtrl:GetPanelId()
    return self._panel._nPanelId
end
function BaseCtrl:GetPanelParam()
    return self._panel:GetPanelParam()
end

-- sprite begin
function BaseCtrl:GetAtlasSprite(sAtlasPath, sSpriteName)
    -- 参数如：(12_rare, rare_build_1)
    -- sAtlasPath 图集路径参考 05_number ，sSpriteName 为 sAtlasPath 目录中的 png 名字。
    if string.find(sAtlasPath, "/CommonEx/") ~= nil or string.find(sAtlasPath, "/Common/") ~= nil then
        printError("新版UI在换过图集做法后，从图集中取Sprite时不应出现/CommonEx/目录 或 /Common/ 目录。" .. sAtlasPath .. "," .. sSpriteName)
        printError("panel id:" .. self._panel._nPanelId .. "，ctrl name:" .. self.__cname)
        return nil
    end
    local sFullPath = string.format("%sUI/CommonEx/atlas_png/%s/%s.png", sRootPath, sAtlasPath, sSpriteName)
    return GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(Sprite))
end
function BaseCtrl:GetPngSprite(sPath) -- 参数如：Icon/Item/item_1
    if type(sPath) == "number" then
        printError("调用接口处需更新，panel id:" .. self._panel._nPanelId .. "，ctrl name:" .. self.__cname)
        return nil -- 显示白图
    end
    -- 从各配置表的相关字段中取得路径，应以以下目录名之一开头，末尾不需要填 .png。
    if string.find(sPath, "Icon/") == nil and 
        string.find(sPath, "Image/") == nil and 
        string.find(sPath, "ImageAvg/") == nil and 
        string.find(sPath, "big_sprites/") == nil then
        printError("配置表中 Icon 资源字段内容填写错误，应填路径，如：Icon/Item/item_1，panel id:" .. self._panel._nPanelId .. "，ctrl name:" .. self.__cname)
        return nil -- 显示白图
    else
        local sp = GameResourceLoader.LoadAsset(ResType.Any, sRootPath .. sPath .. ".png", typeof(Sprite))
        if sp == nil then
            printError(string.format("未找到 icon 资源：%s，panel id：%s，ctrl name：%s",sPath,tostring(self._panel._nPanelId),tostring(self.__cname)))
        end
        return sp
    end
end
function BaseCtrl:GetSprite_FrameColor(nRarity, sFrameType, bBigSprites)
    local sPngName = sFrameType .. AllEnum.FrameColor_New[nRarity]
    if bBigSprites then
        return self:GetPngSprite("UI/big_sprites/" .. sPngName)
    else
        return self:GetAtlasSprite("12_rare", sPngName)
    end
end
function BaseCtrl:GetSprite_Coin(nCoinItemId) -- 参数如：AllEnum.CoinItemId.Gold
    local mapItem = ConfigTable.GetData_Item(nCoinItemId)
    if mapItem == nil then return nil
    else
        if mapItem.Icon2 == nil or mapItem.Icon2 == "" then return nil
        else return self:GetPngSprite(mapItem.Icon2) end
    end
end
function BaseCtrl:GetAvgCharHeadIcon(sSpeakerId, sFace)
    -- Icon/AvgHead/avg1_103/avg1_103_002
    if sFace == nil then sFace = "002" end
    if sSpeakerId == nil or sSpeakerId == "" or sSpeakerId == "avg0_1" or sSpeakerId == "0" then -- 主角头像
        sSpeakerId = AdjustMainRoleAvgCharId()
    end
    local sIconPath = string.format("Icon/AvgHead/%s/%s_%s", sSpeakerId, sSpeakerId, sFace)
    return self:GetPngSprite(sIconPath)
end
-- sprite end

-- new set sprite begin
function BaseCtrl:SetSprite(imgObj, sPath) -- 这里不再检查path路径
    local sFullPath = sRootPath .. sPath .. ".png"
    local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
    if not bSuc then
        traceback(string.format("Sprite设置失败：%s，panel id：%s，ctrl name：%s", sFullPath,
                tostring(self._panel._nPanelId),tostring(self.__cname)))
    end
    return bSuc
end
function BaseCtrl:SetAtlasSprite(imgObj, sAtlasPath, sSpriteName)
    -- 参数如：(12_rare, rare_build_1)
    -- sAtlasPath 图集路径参考 05_number ，sSpriteName 为 sAtlasPath 目录中的 png 名字。
    if string.find(sAtlasPath, "/CommonEx/") ~= nil or string.find(sAtlasPath, "/Common/") ~= nil then
        printError("新版UI在换过图集做法后，从图集中取Sprite时不应出现/CommonEx/目录 或 /Common/ 目录。" .. sAtlasPath .. "," .. sSpriteName)
        printError("panel id:" .. self._panel._nPanelId .. "，ctrl name:" .. self.__cname)
        return false
    end
    local sFullPath = string.format("%sUI/CommonEx/atlas_png/%s/%s.png", sRootPath, sAtlasPath, sSpriteName)
    local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
    if not bSuc then
        traceback(string.format("icon设置失败：%s，panel id：%s，ctrl name：%s",sFullPath,tostring(self._panel._nPanelId),tostring(self.__cname)))
    end
    return bSuc
end
function BaseCtrl:SetActivityAtlasSprite(imgObj, sActivityPath, sSpriteName)
    -- 参数如：(Swim, rare_build_1)
    -- sActivityPath 图集路径参考 Swim ，sSpriteName 为 sActivityPath 目录中的 png 名字。
    local sFullPath = string.format("%sUI_Activity/%s/SpriteAtlas/%s.png", sRootPath, sActivityPath, sSpriteName)
    local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
    if not bSuc then
        traceback(string.format("icon设置失败：%s，panel id：%s，ctrl name：%s",sFullPath,tostring(self._panel._nPanelId),tostring(self.__cname)))
    end
    return bSuc
end
function BaseCtrl:SetPngSprite(imgObj, sPath) -- 参数如：Icon/Item/item_1
    if type(sPath) == "number" then
        traceback("调用接口处需更新，panel id:" .. self._panel._nPanelId .. "，ctrl name:" .. self.__cname)
        NovaAPI.SetImageSpriteAsset(imgObj, nil)
        return false -- 显示白图
    end
    -- 从各配置表的相关字段中取得路径，应以以下目录名之一开头，末尾不需要填 .png。
    if string.find(sPath, "Icon/") == nil and
            string.find(sPath, "Image/") == nil and
            string.find(sPath, "ImageAvg/") == nil and
            string.find(sPath, "big_sprites/") == nil and
            string.find(sPath, "Disc/") == nil and
            string.find(sPath, "Play_") == nil    then
        traceback("配置表中 Icon 资源字段内容填写错误，应填路径，如：Icon/Item/item_1，panel id:" .. self._panel._nPanelId .. "，ctrl name:" .. self.__cname)
        NovaAPI.SetImageSpriteAsset(imgObj, nil)
        return false -- 显示白图
    else
        local sFullPath = sRootPath .. sPath .. ".png"
        local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
        if not bSuc then
            traceback(string.format("icon设置失败：%s，panel id：%s，ctrl name：%s", sFullPath,
                    tostring(self._panel._nPanelId),tostring(self.__cname)))
        end
        return bSuc
    end
end
function BaseCtrl:SetSprite_FrameColor(imgObj, nRarity, sFrameType, bBigSprites)
    local sPngName = sFrameType .. AllEnum.FrameColor_New[nRarity]
    if bBigSprites then
        return self:SetPngSprite(imgObj, "UI/big_sprites/" .. sPngName)
    else
        return self:SetAtlasSprite(imgObj, "12_rare", sPngName)
    end
end
function BaseCtrl:SetSprite_Coin(imgObj, nCoinItemId) -- 参数如：AllEnum.CoinItemId.Gold
    local mapItem = ConfigTable.GetData_Item(nCoinItemId)
    if mapItem == nil then return false
    else
        if mapItem.Icon2 == nil or mapItem.Icon2 == "" then return false
        else return self:SetPngSprite(imgObj, mapItem.Icon2) end
    end
end
function BaseCtrl:SetAvgCharHeadIcon(imgObj, sSpeakerId, sFace)
    -- Icon/AvgHead/avg1_103/avg1_103_002
    if sFace == nil then sFace = "002" end
    if sSpeakerId == nil or sSpeakerId == "" or sSpeakerId == "avg0_1" or sSpeakerId == "0" then -- 主角头像
        sSpeakerId = AdjustMainRoleAvgCharId()
    end
    local sIconPath = string.format("Icon/AvgHead/%s/%s_%s", sSpeakerId, sSpeakerId, sFace)
    return self:SetPngSprite(imgObj, sIconPath)
end
-- new set sprite end

-- AVG start
function BaseCtrl:GetAvgStageEffect(sName, sType)
    -- 不是取 sprite 是取 texture
    if sName == nil then return nil end
    local sFullPath = string.format("%sImageAvg/AvgStageEffect/%s.png", sRootPath, sName)
    return GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(Texture))
end
function BaseCtrl:GetAvgPortrait(sAvgCharId, sPose, sFace)
    local sPathBody = string.format("%sActor2D/CharacterAvg/%s/atlas_png/%s/%s_%s_001.png", sRootPath, sAvgCharId, sPose, sAvgCharId, sPose)
    local sPathFace = string.format("%sActor2D/CharacterAvg/%s/atlas_png/%s/%s_%s_%s.png", sRootPath, sAvgCharId, sPose, sAvgCharId, sPose, sFace)
    local sPathBlackBody = string.format("%sActor2D/CharacterAvg/%s/%s_%s_001x.png", sRootPath, sAvgCharId, sAvgCharId, sPose)
    local spBody = GameResourceLoader.LoadAsset(ResType.Any, sPathBody, typeof(Sprite))
    local spFace = nil
    if GameResourceLoader.ExistsAsset(sPathFace) == true then
        spFace = GameResourceLoader.LoadAsset(ResType.Any, sPathFace, typeof(Sprite))
    end
    local spBlackBody = spBody
    if GameResourceLoader.ExistsAsset(sPathBlackBody) == true then
        spBlackBody = GameResourceLoader.LoadAsset(ResType.Any, sPathBlackBody, typeof(Sprite))
    end
    local sFullPath = string.format("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
    local objOffset = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
    local nX, nY = 0,0
    if objOffset == nil then printError(sFullPath) return end
    local s, x, y = objOffset:GetOffsetData(PanelId.AvgST, indexOfPose(sPose), true, nX, nY) -- Avg 只用半身像数据
    local v3OffsetPos = Vector3(x, y, 0)
    local v3OffsetScale = Vector3(s, s, 1)
    return spBody, spFace, v3OffsetPos, v3OffsetScale, spBlackBody
end
function BaseCtrl:GetAvgPortraitEmojiOffsetData(sAvgCharId, sPose, nEmojiIndex)
    local sFullPath = string.format("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
    local objOffset = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
    local nX, nY = 0,0
    local s, x, y = objOffset:GetEmojiData(PanelId.AvgST, indexOfPose(sPose), nEmojiIndex, nX, nY)
    local v3OffsetPos = Vector3(x, y, 0)
    local v3OffsetScale = Vector3(s, math.abs(s), 1)
    return v3OffsetPos, v3OffsetScale
end
function BaseCtrl:GetAvgHeadFrameOffsetData(sAvgCharId, sPose, nFrameIndex)
    local sFullPath = string.format("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
    local objOffset = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
    if nFrameIndex == 2 then nFrameIndex = 3 end -- Avg头像框微调数据复用
    local nX, nY = 0,0
    local s, x, y = objOffset:Get_AvgCharHeadFrameData(PanelId.AvgST, indexOfPose(sPose), nFrameIndex, nX, nY)
    return x, y, s
end
function BaseCtrl:OnEvent_AvgSpeedUp_Timer(nRate)
    local n = #self._tbTimer
    -- printLog("Avg加速 BaseCtrl " .. self.__cname .. ", rate:" .. nRate .. ", count:" .. n)
    for i = n, 1, -1 do
        local timer = self._tbTimer[i]
        if timer ~= nil then
            --[[ timer:Cancel(true)
            table.remove(self._tbTimer, i) ]]
            timer:SetSpeed(nRate)
        end
    end
end
function BaseCtrl:SetAvgCharHeadIconByPrefab(img, sPrefabPath)
    local sFullPath = sRootPath .. sPrefabPath
    local prefab = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(GameObject), "UI", self._panel._nPanelId)
    NovaAPI.SetImageSpriteWithPrefab(img, prefab)
end
-- AVG end

function BaseCtrl:AddTimer(nTargetCount, nInterval, sCallbackName, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
    -- nTargetCount 计时器将触发几次回调，若为无限循环计时器填0，必填。
    -- nInterval 计时器触发两次回调的间隔时间，单位秒，必填。
    -- sCallbackName 回调函数名，string 类型，必填。
    -- bAutoRun 是否创建计时器后就开始运行，选填，默认true，若想手动控制启动，填false创建后将处于暂停状态，在需要处通过timer:Pause(false)来启动。
    -- bDestroyWhenComplete 是否完成后销毁，选填，默认false，为方便计时器可反复使用，若在完成后想再次使用，通过timer:Reset()来再次使用。
    -- nScaleType 默认传 nil = TimerScaleType.None，true = TimerScaleType.Unscaled, false = TimerScaleType.RealTime
    -- tbParam 自定义参数，选填写，类型任意，需要传多个参数，或复杂类型的，建议组一个 lua table 再传入。
    local callback
    if type(sCallbackName) == "function" then
        callback = sCallbackName
    else
        callback = self[sCallbackName]
    end
    if type(callback) == "function" then
        local timer = TimerManager.Add(nTargetCount, nInterval, self, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
        if timer ~= nil then
            if self:GetPanelId() == PanelId.AvgST and type(self._panel.nSpeedRate) == "number" then
                timer:SetSpeed(self._panel.nSpeedRate)
            end
            table.insert(self._tbTimer, timer)
            --[[ if self._autoRemoveUnusedTimer == nil then
                self._autoRemoveUnusedTimer = TimerManager.Add(0, 5, self, self._autoRemoveTimer, true, false, false, nil)
            end ]]
        end
        return timer
    else
        return nil
    end
end
function BaseCtrl:_autoRemoveTimer(timer)
    local n = #self._tbTimer
    for i = n, 1, -1 do
        local timer = self._tbTimer[i]
        if timer ~= nil and timer:IsUnused() == true then
            table.remove(self._tbTimer, i)
        end
    end
end
function BaseCtrl:CreatePrefabInstance(sPrefabPath, trParent)
    -- sPrefabPath 为一个预设体路径，如：Assets/AssetBundles/UI/Login/LoginBg.prefab
    -- 只需填 UI/Login/LoginBg.prefab 即可。
    local sFullPath = sRootPath .. sPrefabPath
    local prefab = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(Object), "UI", self._panel._nPanelId)
    if trParent == nil then
        trParent = self.gameObject.transform
    end
    local goPrefabIns = instantiate(prefab, trParent)
    goPrefabIns.name = sPrefabPath
    self._mapPrefab[sPrefabPath] = goPrefabIns
    return goPrefabIns
end
function BaseCtrl:DestroyPrefabInstance(sPrefabPath)
    local goIns = self._mapPrefab[sPrefabPath]
    if goIns ~= nil then
        destroy(goIns)
        self._mapPrefab[sPrefabPath] = nil
    end
end
function BaseCtrl:LoadAsset(sPrefabPath, assetType)
    -- sPrefabPath 为一个预设体路径，如：Assets/AssetBundles/UI/Login/LoginBg.prefab
    -- 只需填 UI/Login/LoginBg.prefab 即可。
    local sFullPath = sRootPath .. sPrefabPath
    if assetType == nil then
        assetType = typeof(Object)
    end
    local prefab =  GameResourceLoader.LoadAsset(ResType.Any, sFullPath, assetType, "UI", self._panel._nPanelId)
    if prefab ~= nil then
        self._mapLoadAssets[sPrefabPath] = prefab
    end
    return prefab
end
function BaseCtrl:LoadAssetAsync(sPrefabPath, assetType, callback)
    -- sPrefabPath 为一个预设体路径，如：Assets/AssetBundles/UI/Login/LoginBg.prefab
    -- 只需填 UI/Login/LoginBg.prefab 即可。
    local sFullPath = sRootPath .. sPrefabPath
    if assetType == nil then
        assetType = typeof(Object)
    end
    local function callBack(obj)
        if obj ~= nil then
            if obj ~= nil then
                self._mapLoadAssets[sPrefabPath] = obj
            end
            if callback ~= nil then
                callback(obj)
            end
        end
    end
    GameResourceLoader.LoadAssetAsync(ResType.Any, sFullPath, assetType, "UI", self._panel._nPanelId, callBack)
end
function BaseCtrl:UnLoadAsset(sPrefabPath)
    local prefab = self._mapLoadAssets[sPrefabPath]
    if prefab ~= nil then
        prefab = nil
        self._mapLoadAssets[sPrefabPath] = nil
    end
end
function BaseCtrl:SpawnPrefabInstance(prefab, sLuaClassName, sPoolName, parent)

    local goPrefabIns = AdventureModuleHelper.SpawnPrefabInstance(prefab, sPoolName, parent)
    local luaClassName = require(sLuaClassName)
    local objCtrl = luaClassName.new(goPrefabIns, self._panel)
    objCtrl:_Enter()
    return objCtrl
end
function BaseCtrl:DespawnPrefabInstance(objCtrl, sPoolName)
    if objCtrl ~= nil then
        objCtrl:_PreExit()
        objCtrl:_Exit()
        objCtrl:_Destroy()
        AdventureModuleHelper.DespawnPrefabInstance(objCtrl.gameObject, sPoolName)
    end
end
function BaseCtrl:BindCtrlByNode(goNode,sCtrlName)
    local objCtrl
    local luaClass = require(sCtrlName)
    if luaClass == nil then
        printError("Ctrl Lua not found, path:" .. sCtrlName)
    else
        objCtrl = luaClass.new(goNode, self._panel)
        table.insert(self._panel._tbObjDyncChildCtrl, objCtrl)
        objCtrl:_Enter()
    end
    return objCtrl
end
function BaseCtrl:UnbindCtrlByNode(objCtrl)
    objCtrl:_PreExit()
    objCtrl:_Exit()
    objCtrl:_Destroy()
    objCtrl.gameObject = nil
    table.remove(self._panel._tbObjDyncChildCtrl, table.indexof(self._panel._tbObjDyncChildCtrl, objCtrl))
end
function BaseCtrl:SetAnimationCallback(animatior, sCallbackName)
    -- 动画结束回调方法
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        local time = animatior:GetCurrentAnimatorStateInfo(0).length
        self:AddTimer(1, time, sCallbackName, true, true, true)
    end
    cs_coroutine.start(wait)
end
function BaseCtrl:ParseHitDamageDesc(nHitDamageId, nLevel)
    local sDesc = ""
    local mapDamage = ConfigTable.GetData_HitDamage(nHitDamageId)
    if not mapDamage then
        printError("该 hit damage id 找不到数据:" .. nHitDamageId)
        sDesc = string.format("<color=#FF0000>%d</color>", nHitDamageId) -- 红色：此 id 找不到数据
        return sDesc
    end

    local nPercent = mapDamage.SkillPercentAmend[nLevel]
    local nAbs = mapDamage.SkillAbsAmend[nLevel]
    if not nPercent or not nAbs then
        printError(string.format("该技能等级在 HitDamage 表中找不到数据, hit damage id:%d, level:%d", nHitDamageId, nLevel))
        sDesc = string.format("<color=#FF0000>%d</color>", nHitDamageId) -- 红色：此 id 找不到数据
        return sDesc
    end

    nPercent = nPercent * ConfigData.IntFloatPrecision
    nPercent = FormatNum(nPercent)
    nAbs = FormatNum(nAbs)
    local sPercent = nPercent == 0 and "" or tostring(nPercent) .. "%%"
    local sAbs = nAbs == 0 and "" or tostring(nAbs)

    if nPercent ~= 0 and nAbs ~= 0 then
        sDesc = sPercent .. "+" .. sAbs
    else
        sDesc = sPercent .. sAbs
    end
    return sDesc -- 例：15%+100 或 15% 或 100
end

function BaseCtrl:ThousandsNumber(number) -- 千分位格式化
    local formatted = tostring(number)
    local k
    while true do
        formatted,  k = string.gsub(formatted, "^(.*-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function BaseCtrl:GetGamepadUINode()
    local tbNode = {}
    if self.gameObject == nil or type(self._mapNodeConfig) ~= "table" then
        return tbNode
    end

    local function add(sKey, mapConfig, sComponentName)
        if mapConfig.sComponentName == sComponentName then
            local nCount = mapConfig.nCount
            if type(nCount) == "number" then
                for i = 1, nCount do
                    local mapNode = self._mapNode[sKey][i]
                    if mapNode then
                        table.insert(tbNode, {mapNode = mapNode, sComponentName = sComponentName, sAction = mapConfig.sAction})
                    end
                end
            else
                local mapNode = self._mapNode[sKey]
                if mapNode then
                    table.insert(tbNode, {mapNode = mapNode, sComponentName = sComponentName, sAction = mapConfig.sAction})
                end
            end
        end
    end
    for sKey, mapConfig in pairs(self._mapNodeConfig) do
        add(sKey, mapConfig, "NaviButton")
        add(sKey, mapConfig, "GamepadScroll")
    end
    return tbNode
end

return BaseCtrl
