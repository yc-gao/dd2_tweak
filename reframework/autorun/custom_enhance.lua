local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('basic_enhance.json') or {}
config = utils.tbl_merge({
    InfStamina = true,
    InfWeight = true,
}, config)

local stamina_manager_t = sdk.find_type_definition('app.StaminaManager')
local item_manager_t = sdk.find_type_definition('app.ItemManager')

sdk.hook(stamina_manager_t:get_method('add(System.Single, System.Boolean)'),
    function(args)
        if config.InfStamina then
            local v = sdk.to_float(args[3])
            if v < 0 then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
        return sdk.PreHookResult.CALL_ORIGINAL
    end,
    nil
)
sdk.hook(item_manager_t:get_method('getWeightRank(System.Single, System.Single)'),
    nil,
    function(retval)
        if config.InfWeight then
            return sdk.to_ptr(0)
        end
        return retval
    end
)

re.on_draw_ui(function()
    if imgui.tree_node('Basic Enhance') then
        _, config.InfStamina = imgui.checkbox('Inf Stamina', config.InfStamina)
        _, config.InfWeight = imgui.checkbox('Inf Weight', config.InfWeight)
        imgui.tree_pop()
    end
end)
re.on_config_save(function() json.dump_file('basic_enhance.json', config) end)
