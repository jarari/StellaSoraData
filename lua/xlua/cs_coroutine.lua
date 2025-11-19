local util = require("xlua/util")
local cs_coroutine_runner = (CS.LuaManager).Instance
return {start = function(...)
  -- function num : 0_0 , upvalues : cs_coroutine_runner, util
  return cs_coroutine_runner:StartCoroutine((util.cs_generator)(...))
end
, stop = function(coroutine)
  -- function num : 0_1 , upvalues : cs_coroutine_runner
  cs_coroutine_runner:StopCoroutine(coroutine)
end
}

