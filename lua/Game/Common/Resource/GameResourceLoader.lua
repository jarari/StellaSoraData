local ResourceLoader = CS.ResourceLoader

--[[
    游戏资源加载卸载实用方法
    具体实现与参数说明详见CS侧的GameResourceLoader类实现，Lua侧是API映射
]]--
local GameResourceLoader = {}

GameResourceLoader.ResType = CS.GameResourceLoader.ResourceType

--- AssetBundle资源根目录
GameResourceLoader.RootPath = "Assets/AssetBundles/"
local tbCachedBundleGroup = {} -- 缓存已加载的bundlegroup

------------------------------------- Load Asset --------------------------------------------

--GameResourceLoader.LoadAsset = CS.GameResourceLoader.LoadAsset
--GameResourceLoader.LoadAssetAsync = CS.GameResourceLoader.LoadAssetAsync
GameResourceLoader.LoadAssets = CS.GameResourceLoader.LoadAssets
GameResourceLoader.LoadAssetsAsync = CS.GameResourceLoader.LoadAssetsAsync

----------------------------------- Load Sub Asset ------------------------------------------

GameResourceLoader.LoadSubAsset = CS.GameResourceLoader.LoadSubAsset
GameResourceLoader.LoadSubAssetAsync = CS.GameResourceLoader.LoadSubAssetAsync
GameResourceLoader.LoadSubAssets = CS.GameResourceLoader.LoadSubAssets
GameResourceLoader.LoadSubAssetsAsync = CS.GameResourceLoader.LoadSubAssetsAsync
GameResourceLoader.LoadAllSubAssets = CS.GameResourceLoader.LoadAllSubAssets
GameResourceLoader.LoadAllSubAssetsAsync = CS.GameResourceLoader.LoadAllSubAssetsAsync

---------------------------------- Load Asset Bundle ----------------------------------------

GameResourceLoader.LoadAssetBundle = CS.GameResourceLoader.LoadAssetBundle

--------------------------------------- Unload ----------------------------------------------

GameResourceLoader.Unload = CS.GameResourceLoader.Unload

---------------------function-------------------------------------------------
---界面中load资源请不要直接调用该接口
function GameResourceLoader.LoadAsset(resourceType, path, type, bundleGroup, panelId)-- any, "Assets/****", Sprite, "UI", n
    local res = CS.GameResourceLoader.LoadAsset(  resourceType, path, type, GameResourceLoader.MakeBundleGroup(bundleGroup, panelId)  )
    if res ~= nil then
        return res
    else
        printError("load resource failed: " .. path)
        return nil
    end
end

function GameResourceLoader.LoadAssetAsync(resourceType, path, type, bundleGroup, panelId, callBack)
    CS.GameResourceLoader.LoadAssetAsync(  resourceType, path, type, callBack, GameResourceLoader.MakeBundleGroup(bundleGroup, panelId)  )
end

function GameResourceLoader.UnloadAsset(nPanelId)
    if tbCachedBundleGroup[nPanelId] ~= nil then
        if PanelManager.CheckPanelOpen(nPanelId) == true then return end
        local _clonedBundleGroup = tbCachedBundleGroup[nPanelId].clonedBundleGroup
        GameResourceLoader.Unload(_clonedBundleGroup)
        _clonedBundleGroup = nil
        tbCachedBundleGroup[nPanelId] = nil   
    end
end

function GameResourceLoader.ExistsAsset(path)
    return CS.GameResourceLoader.ExistsAsset(path)
end

function GameResourceLoader.MakeBundleGroup(sGroupName, nPanelId)
    local _clonedBundleGroup = nil
    if sGroupName ~= nil and nPanelId ~= nil and nPanelId > 0 then
        if tbCachedBundleGroup[nPanelId] == nil then
            _clonedBundleGroup = CS.GameResourceLoader.CloneBundleGroup(sGroupName)
            tbCachedBundleGroup[nPanelId] = {--[[ referenceCount = 1, ]] clonedBundleGroup = _clonedBundleGroup} -- referenceCount 暂时屏蔽，今后需要时再打开。
        else
            _clonedBundleGroup = tbCachedBundleGroup[nPanelId].clonedBundleGroup
            --[[ tbCachedBundleGroup[nPanelId].referenceCount = tbCachedBundleGroup[nPanelId].referenceCount + 1 ]]
        end   
    end
    return _clonedBundleGroup
end
return GameResourceLoader
