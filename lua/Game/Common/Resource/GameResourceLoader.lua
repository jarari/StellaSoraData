local ResourceLoader = CS.ResourceLoader
local GameResourceLoader = {}
GameResourceLoader.ResType = (CS.GameResourceLoader).ResourceType
GameResourceLoader.RootPath = "Assets/AssetBundles/"
local tbCachedBundleGroup = {}
GameResourceLoader.LoadAssets = (CS.GameResourceLoader).LoadAssets
GameResourceLoader.LoadAssetsAsync = (CS.GameResourceLoader).LoadAssetsAsync
GameResourceLoader.LoadSubAsset = (CS.GameResourceLoader).LoadSubAsset
GameResourceLoader.LoadSubAssetAsync = (CS.GameResourceLoader).LoadSubAssetAsync
GameResourceLoader.LoadSubAssets = (CS.GameResourceLoader).LoadSubAssets
GameResourceLoader.LoadSubAssetsAsync = (CS.GameResourceLoader).LoadSubAssetsAsync
GameResourceLoader.LoadAllSubAssets = (CS.GameResourceLoader).LoadAllSubAssets
GameResourceLoader.LoadAllSubAssetsAsync = (CS.GameResourceLoader).LoadAllSubAssetsAsync
GameResourceLoader.LoadAssetBundle = (CS.GameResourceLoader).LoadAssetBundle
GameResourceLoader.Unload = (CS.GameResourceLoader).Unload
GameResourceLoader.LoadAsset = function(resourceType, path, type, bundleGroup, panelId)
  -- function num : 0_0 , upvalues : _ENV, GameResourceLoader
  local res = ((CS.GameResourceLoader).LoadAsset)(resourceType, path, type, (GameResourceLoader.MakeBundleGroup)(bundleGroup, panelId))
  if res ~= nil then
    return res
  else
    printError("load resource failed: " .. path)
    return nil
  end
end

GameResourceLoader.LoadAssetAsync = function(resourceType, path, type, bundleGroup, panelId, callBack)
  -- function num : 0_1 , upvalues : _ENV, GameResourceLoader
  ((CS.GameResourceLoader).LoadAssetAsync)(resourceType, path, type, callBack, (GameResourceLoader.MakeBundleGroup)(bundleGroup, panelId))
end

GameResourceLoader.UnloadAsset = function(nPanelId)
  -- function num : 0_2 , upvalues : tbCachedBundleGroup, _ENV, GameResourceLoader
  if tbCachedBundleGroup[nPanelId] ~= nil then
    if (PanelManager.CheckPanelOpen)(nPanelId) == true then
      return 
    end
    local _clonedBundleGroup = (tbCachedBundleGroup[nPanelId]).clonedBundleGroup
    ;
    (GameResourceLoader.Unload)(_clonedBundleGroup)
    _clonedBundleGroup = nil
    tbCachedBundleGroup[nPanelId] = nil
  end
end

GameResourceLoader.ExistsAsset = function(path)
  -- function num : 0_3 , upvalues : _ENV
  return ((CS.GameResourceLoader).ExistsAsset)(path)
end

GameResourceLoader.MakeBundleGroup = function(sGroupName, nPanelId)
  -- function num : 0_4 , upvalues : tbCachedBundleGroup, _ENV
  local _clonedBundleGroup = nil
  if sGroupName ~= nil and nPanelId ~= nil and nPanelId > 0 then
    if tbCachedBundleGroup[nPanelId] == nil then
      _clonedBundleGroup = ((CS.GameResourceLoader).CloneBundleGroup)(sGroupName)
      tbCachedBundleGroup[nPanelId] = {clonedBundleGroup = _clonedBundleGroup}
    else
      _clonedBundleGroup = (tbCachedBundleGroup[nPanelId]).clonedBundleGroup
    end
  end
  return _clonedBundleGroup
end

return GameResourceLoader

