local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local config = json.load_file('inf_stamina.json') or {}
if config.EnableInfStamina == nil then
    config.EnableInfStamina = true
end

local stamina_manager_t = sdk.find_type_definition('app.StaminaManager')
local battle_manager = sdk.get_managed_singleton('app.BattleManager')
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
    if imgui.tree_node('Inf Stamina') then
        _, config.EnableInfStamina = imgui.checkbox('Enable Inf Stamina', config.EnableInfStamina)
    end
end)
re.on_config_save(function() json.dump_file('inf_stamina.json', config) end)
