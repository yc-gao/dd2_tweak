local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('price_x10.json') or {}
config = utils.tbl_merge({
    Enable = true,
}, config)

local item_common_param_t = sdk.find_type_definition('app.ItemCommonParam')
sdk.hook(item_common_param_t:get_method('get_SellPrice()'),
    nil,
    function(retval)
        if config.Enable then
            return sdk.to_ptr((sdk.to_int64(retval) & 0xFFFFFFFF) * 10)
        end
        return retval
    end
)

re.on_draw_ui(function()
    if imgui.tree_node('Price X10') then
        _, config.Enable = imgui.checkbox('price x10', config.Enable)
        imgui.tree_pop()
    end
end)

re.on_config_save(function() json.dump_file('price_x10.json', config) end)
