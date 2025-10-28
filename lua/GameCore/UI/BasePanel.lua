-- BasePanel
local GameResourceLoader = require "Game.Common.Resource.GameResourceLoader"
local ResType = GameResourceLoader.ResType
local GameCameraStackManager = CS.GameCameraStackManager
local BasePanel = class("BasePanel")
-- local sUIResRootPath = Settings.AB_ROOT_PATH .. "UI/"
local sTopBarCtrlLua = "Game.UI.TopBarEx.TopBarCtrl"
local sSafeAreaRoot = "----SafeAreaRoot----"
local bDebugLog = false
local typeof = typeof
---------- 界面切换流程 ---------- begin

---@diagnostic disable-next-line: duplicate-set-field
function BasePanel:ctor(nIndex, nPanelId, tbParam)
    self._nIndex = nIndex
    self._nPanelId = nPanelId -- Panel 编号
    self._bIsActive = false
    self._tbParam = tbParam -- 自定义 Panel 参数
    if self._nFADEINTYPE == nil then
        self._nFADEINTYPE = 1 -- 是否初始播放入场动画，当前界面的默认值(0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
    end
    if self._nFadeInType == nil then
        self._nFadeInType = 1 -- 是否初始播放入场动画，多出来的动画具体情况自己界面定义(0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
    end
    if self._bIsMainPanel == nil then
        self._bIsMainPanel = true -- 非主 panel 没有历史回退功能 应附属于某个主 Panel 且自行控制开关
    end
    if self._bAddToBackHistory == nil then -- 是否加入回退历史
        self._bAddToBackHistory = true
    end
    if self._nSnapshotPrePanel == nil then -- 是否保持上个 Panel 可见
        self._nSnapshotPrePanel = 0 -- 当前界面需要看上上一界面截屏时，设置1或2，1模糊截屏，2普通截屏。
    end
    if self._sSortingLayerName == nil then -- 指定 UI Layer
        self._sSortingLayerName = AllEnum.SortingLayerName.UI --决定当前 Panel 的所有 UI 预设体实例将挂在哪个根节点下
    end
    if self._tbDefine == nil then -- Panel 定义
        self._tbDefine = {}
    end
    if self._sUIResRootPath ~= nil then -- 有的UI资源现在不在UI目录下，用自己定义的目录
        self.sUIResRootPath = Settings.AB_ROOT_PATH .. self._sUIResRootPath
    else
        self.sUIResRootPath = Settings.AB_ROOT_PATH .. "UI/"
    end
    self._tbObjCtrl = {} -- 管理 panel 静态配置的 ctrl 实例数组
    self._tbObjChildCtrl = {} -- 管理 ctrl 静态配置嵌套的子 ctrl 实例数组
    self._tbObjDyncChildCtrl = {} -- 管理 ctrl 中动态创建的子 ctrl 实例数组
    if type(self.Awake) == "function" then
        self:Awake()
    end
    self.bIsTipsPanel = UTILS.CheckIsTipsPanel(self._nPanelId)
end
function BasePanel:_PreExit(callback, bPlayFadeOut)
    if self._bIsActive == false then
        return
    end
    self:_UnbindEventCallback()
    for sName, objChildCtrl in ipairs(self._tbObjChildCtrl) do
        objChildCtrl:_PreExit()
    end
    for i, objDyncChildCtrl in ipairs(self._tbObjDyncChildCtrl) do
        objDyncChildCtrl:_PreExit()
    end
    local nCount = #self._tbObjCtrl
    local function func_PreExitDone()
        nCount = nCount - 1
        if nCount == 0 and type(callback) == "function" then
            callback()
        end
    end
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        objCtrl:_PreExit(func_PreExitDone, bPlayFadeOut)
    end
end
function BasePanel:_PreEnter(callback, goSnapshot)
    local _trParent = PanelManager.GetUIRoot(self._sSortingLayerName)
    local nCount = #self._tbDefine
    local function func_DoInstantiate(nIndex)
        local function func_ProcNext()
            nIndex = nIndex + 1
            if nIndex > nCount then
                if type(callback) == "function" then callback() end
            else
                func_DoInstantiate(nIndex)
            end
        end
        local objCtrl = self._tbObjCtrl[nIndex]
        if objCtrl ~= nil and objCtrl.gameObject ~= nil then
            objCtrl:ParsePrefab()
            func_ProcNext()
        else
            local tbDefine = self._tbDefine[nIndex]
            local sPrefabFullPath = self.sUIResRootPath .. tbDefine.sPrefabPath
            local sLuaClassName = tbDefine.sCtrlName
            local function func_PrefabLoaded(uiPrefab)
                local luaClassName = require(sLuaClassName)
                local trParent = _trParent
                if sLuaClassName == sTopBarCtrlLua and self._trTopBarParent ~= nil then
                    trParent = self._trTopBarParent
                end
                local goPrefabInstance = instantiate(uiPrefab, trParent)
                goPrefabInstance.name = uiPrefab.name
                goPrefabInstance.transform:SetAsLastSibling()
                if nIndex == 1 then
                    self._trTopBarParent = goPrefabInstance.transform:Find(sSafeAreaRoot)
                    if self._trTopBarParent == nil then
                        self._trTopBarParent = goPrefabInstance.transform
                    end
                    if goSnapshot ~= nil and goSnapshot:IsNull() == false then
                        goSnapshot.transform:SetParent(goPrefabInstance.transform)
                        goSnapshot.transform.localScale = Vector3.one
                        goSnapshot.transform:SetAsFirstSibling()
                        local rt = goSnapshot:GetComponent("RectTransform")
                        rt.anchorMax = Vector2.one
                        rt.anchorMin = Vector2.zero
                        rt.anchoredPosition = Vector2.zero
                    end
                end
                NovaAPI.ProcResPathNote(  goPrefabInstance, GameResourceLoader.MakeBundleGroup("UI", self._nPanelId)  ) -- 自动还原sprite引用（ResPathNote组件在解引用时记录AssetPath）
                if objCtrl == nil then
                    objCtrl = luaClassName.new(goPrefabInstance, self)
                    table.insert(self._tbObjCtrl, objCtrl)
                else
                    objCtrl:ParsePrefab(goPrefabInstance)
                    --[[ 很早之前由于有些界面的初始化全都写在了 Awake 中，当低内存模式时，
                    返回上一个界面时只会执行 OnEnable 不会执行 Awake，当时粗糙的就再执行了一下 Awake 处理，但不符合设计初衷。]]
                    -- 不过影响有点多，很多界面原先只需要一次赋值的东西都放在了awake，实例删了后造成原先赋值的组件IsNull()，还是得走一遍awake
                    if type(objCtrl.Awake) == "function" then
                        objCtrl:Awake()
                    end
                end
                func_ProcNext()
            end
            -- GameResourceLoader.LoadAssetAsync(ResType.Any, sPrefabFullPath, typeof(Object), func_PrefabLoaded)
            local prefab = GameResourceLoader.LoadAsset(ResType.Any, sPrefabFullPath, typeof(Object), "UI", self._nPanelId)
            if prefab == nil or prefab:IsNull() == true then
                printError(sPrefabFullPath .. " can not found!!!")
            end
            func_PrefabLoaded(prefab)
        end
    end
    func_DoInstantiate(1) -- 按 _tbDefine 配置的顺序逐个加载并实例化
    self._bIsActive = true
end
function BasePanel:_Exit()
    if self._bIsActive == false then
        return
    end
    if type(self.OnDisable) == "function" then
        self:OnDisable()
    end
    for sName, objChildCtrl in ipairs(self._tbObjChildCtrl) do
        objChildCtrl:_Exit()
    end
    for i, objDyncChildCtrl in ipairs(self._tbObjDyncChildCtrl) do
        objDyncChildCtrl:_Exit()
    end
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        objCtrl:_Exit()
    end
    self:_DebugLogDataCount("OnDisable")
    self._bIsActive = false
end
function BasePanel:_Enter(bPlayFadeIn)
    self:_BindEventCallback()
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        local canvas = objCtrl.gameObject:GetComponent("Canvas")
        if canvas ~= nil and canvas:IsNull() == false then
            NovaAPI.SetCanvasWorldCamera(canvas, GameCameraStackManager.Instance.uiCamera)
            NovaAPI.SetCanvasSortingName(canvas, self._sSortingLayerName)
            local nSortingOrder = 0
            if self._nIndex >= AllEnum.UI_SORTING_ORDER.Guide then -- 一些固定的特殊层级。
                nSortingOrder = self._nIndex
            elseif self.bIsTipsPanel == true then
                nSortingOrder = AllEnum.UI_SORTING_ORDER.Tips -- Tips类专用
                if self._bIsExtraTips == true then
                    nSortingOrder = AllEnum.UI_SORTING_ORDER.TipsEx
                end
            else
                nSortingOrder = self._nIndex * 100 + i
            end
            NovaAPI.SetCanvasSortingOrder(canvas, nSortingOrder)
            objCtrl._nSortingOrder = nSortingOrder
            NovaAPI.SetCanvasPlaneDistance(canvas, 101)
        end
        objCtrl.gameObject:SetActive(true)
        objCtrl:_Enter(bPlayFadeIn)
    end
    for sName, objChildCtrl in ipairs(self._tbObjChildCtrl) do
        objChildCtrl:_Enter()
    end
    if type(self.OnEnable) == "function" then
        self:OnEnable(bPlayFadeIn)
    end
    EventManager.Hit("OnEvent_PanelOnEnableById", self._nPanelId) --放在这里因为有的panel中没有OnEnable方法
    self:_DebugLogDataCount("OnEnable")
end
function BasePanel:_AfterEnter()
    if type(self.OnAfterEnter) == "function" then
        self:OnAfterEnter()
    end
end
function BasePanel:_SetPrefabInstance(bDel)
    local nCount = #self._tbObjDyncChildCtrl
    for i = nCount, 1, -1 do
        local objDyncChildCtrl = self._tbObjDyncChildCtrl[i]
        objDyncChildCtrl:_Destroy()
        objDyncChildCtrl.gameObject = nil
        table.remove(self._tbObjDyncChildCtrl, i)
    end
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        if bDel == true then
            if objCtrl.__cname == "TopBarCtrl" then
                objCtrl.gameObject = nil
            else
                if objCtrl.gameObject ~= nil and objCtrl.gameObject:IsNull() == false then
                    destroy(objCtrl.gameObject)
                    objCtrl.gameObject = nil
                end
            end
            self._trTopBarParent = nil
        else
            if objCtrl.gameObject ~= nil and objCtrl.gameObject:IsNull() == false then
                objCtrl.gameObject:SetActive(false)
            end
        end
    end
    if bDel == true then
        nCount = #self._tbObjChildCtrl
        for i = nCount, 1, -1 do
            local o = self._tbObjChildCtrl[i]
            o._nGoInstanceId = nil
            o.gameObject = nil
            table.remove(self._tbObjChildCtrl, i)
        end
    end
    self:_DebugLogDataCount("Before OnDestroy")
end
function BasePanel:_Destroy()
    if type(self.OnDestroy) == "function" then
        self:OnDestroy()
    end
    for i, objCtrl in ipairs(self._tbObjCtrl) do
        GameResourceLoader.UnloadAsset(objCtrl._panel._nPanelId)
        objCtrl:_Destroy()
    end
    for sName, objChildCtrl in ipairs(self._tbObjChildCtrl) do
        objChildCtrl:_Destroy()
    end
    self:_SetPrefabInstance(true)
    self._tbParam = nil
    self._tbObjCtrl = nil
    self._tbObjChildCtrl = nil
    self._tbObjDyncChildCtrl = nil
end
function BasePanel:_Release()
    if type(self.OnRelease) == "function" then
        self:OnRelease()
    end
    if type(self._tbObjCtrl) == "table" then
        for i, objCtrl in ipairs(self._tbObjCtrl) do
            objCtrl:_Release()
        end
    end
    if type(self._tbObjChildCtrl) == "table" then
        for sName, objChildCtrl in ipairs(self._tbObjChildCtrl) do
            objChildCtrl:_Release()
        end
    end
end
---------- 界面切换流程 ---------- end
function BasePanel:_BindEventCallback()
    if type(self._mapEventConfig) == "table" then
        for nEventId, sCallbackName in pairs(self._mapEventConfig) do
            local callback = self[sCallbackName]
            if type(callback) == "function" then
                EventManager.Add(nEventId, self, callback)
            end
        end
    end
end
function BasePanel:_UnbindEventCallback()
    if type(self._mapEventConfig) == "table" then
        for nEventId, sCallbackName in pairs(self._mapEventConfig) do
            local callback = self[sCallbackName]
            if type(callback) == "function" then
                EventManager.Remove(nEventId, self, callback)
            end
        end
    end
end
function BasePanel:_DebugLogDataCount(sTitle)
    if bDebugLog == false then
        return
    end
    local sPanelName = self.__cname
    local nObjCtrlCnt = table.nums(self._tbObjCtrl)
    local nObjChildCtrlCnt = table.nums(self._tbObjChildCtrl)
    local nObjDyncChildCtrlCnt = table.nums(self._tbObjDyncChildCtrl)
    local sDebugLog = string.format(
        "[%s.%s] ctrl实例数量：%d，子ctrl实例数量：%d，动态子ctrl实例数量：%d。", 
        sPanelName, sTitle, nObjCtrlCnt, nObjChildCtrlCnt, nObjDyncChildCtrlCnt)
    printLog(sDebugLog)
end
-------------------- public function --------------------
function BasePanel:GetPanelParam()
    if type(self._tbParam) == "table" then
        return self._tbParam
    else
        return nil
    end
end
return BasePanel
