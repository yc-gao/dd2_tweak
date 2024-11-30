local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('boss_refresh_faster.json') or {}
config = utils.tbl_merge({
    Enable = true,
}, config)

if config.Enable then
    local generate_default_parameter_t = sdk.find_type_definition('app.GenerateDefaultParameter')
    sdk.hook(generate_default_parameter_t:get_method('getDeadCharaRepopTime(System.Boolean, System.Boolean)'),
        function(args)
            if (sdk.to_int64(args[3]) & 1) == 1 then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
            return sdk.PreHookResult.CALL_ORIGINAL
        end,
        function(retval)
            local tm = sdk.to_int64(retval)
            if tm == nil then
                return sdk.to_ptr(0)
            end
            return retval
        end
    )
end

re.on_draw_ui(function()
    if imgui.tree_node('Boss Refresh Faster') then
        _, config.Enable = imgui.checkbox('boss refresh faster', config.Enable)
        imgui.tree_pop()
    end
end)

re.on_config_save(function() json.dump_file('boss_refresh_faster.json', config) end)
