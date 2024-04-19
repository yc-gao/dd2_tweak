local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('inf_weight.json') or {}
config = utils.tbl_merge({ Enable = true }, config)

local item_manager_t = sdk.find_type_definition('app.ItemManager')
sdk.hook(item_manager_t:get_method('getWeightRank(System.Single, System.Single)'),
    nil,
    function(retval)
        if config.Enable then
            return sdk.to_ptr(0)
        end
        return retval
    end
)

re.on_draw_ui(function()
    if imgui.tree_node('Inf Weight') then
        _, config.Enable = imgui.checkbox('Enable Inf Weight', config.Enable)
    end
end)
re.on_config_save(function() json.dump_file('inf_weight.json', config) end)
