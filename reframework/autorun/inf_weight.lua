local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local config = json.load_file('inf_weight.json') or {}
if config.EnableInfWeight == nil then
    config.EnableInfWeight = true
end

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

re.on_draw_ui(function()
    if imgui.tree_node('Inf Weight') then
        _, config.EnableInfWeight = imgui.checkbox('Enable Inf Weight', config.EnableInfWeight)
    end
end)
re.on_config_save(function() json.dump_file('inf_weight.json', config) end)
