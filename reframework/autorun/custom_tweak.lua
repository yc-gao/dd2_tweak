local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local config = json.load_file('custom_tweak.json') or {}
if config.EnableInfWeight == nil then
    config.EnableInfWeight = true
end
if config.EnableInfStamina == nil then
    config.EnableInfStamina = true
end

-- 无限负重
local item_manager_t = sdk.find_type_definition('app.ItemManager')
sdk.hook(item_manager_t:get_method('getWeightRank(System.Single, System.Single)'),
    nil,
    function(retval)
        if config.EnableInfWeight then
            return sdk.to_ptr(0)
        end
        return retval
    end
)

-- 非战斗不消耗耐力
local battle_manager = sdk.get_managed_singleton('app.BattleManager')
local stamina_manager_t = sdk.find_type_definition('app.StaminaManager')
sdk.hook(stamina_manager_t:get_method('add(System.Single, System.Boolean)'),
    function(args)
        if config.EnableInfStamina then
            local v = sdk.to_float(args[3])
            if v < 0 and not battle_manager:call('get_IsBattleMode()') then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
        return sdk.PreHookResult.CALL_ORIGINAL
    end,
    nil
)

re.on_draw_ui(function()
    if imgui.tree_node('Custom Tweak') then
        _, config.EnableInfWeight = imgui.checkbox('Enable Inf Weight', config.EnableInfWeight)
        _, config.EnableInfStamina = imgui.checkbox('Enable Inf Stamina', config.EnableInfStamina)
    end
end)
re.on_config_save(function() json.dump_file('custom_tweak.json', config) end)
