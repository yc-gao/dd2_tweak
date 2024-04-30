local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('inf_stamina.json') or {}
config = utils.tbl_merge({ Enable = true }, config)

local GetBattleManager = utils.func_cache(function() return sdk.get_managed_singleton('app.BattleManager') end)
local stamina_manager_t = sdk.find_type_definition('app.StaminaManager')

sdk.hook(stamina_manager_t:get_method('add(System.Single, System.Boolean)'),
    function(args)
        if config.Enable then
            local v = sdk.to_float(args[3])
            if v < 0 and not GetBattleManager():call('get_IsBattleMode()') then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
        return sdk.PreHookResult.CALL_ORIGINAL
    end,
    nil
)

re.on_draw_ui(function()
    if imgui.tree_node('Inf Stamina') then
        _, config.Enable = imgui.checkbox('Enable Inf Stamina', config.Enable)
    end
end)
re.on_config_save(function() json.dump_file('inf_stamina.json', config) end)
