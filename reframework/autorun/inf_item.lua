local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local config = json.load_file('inf_item.json') or {}
config = utils.tbl_merge({}, config)

local fontCN = imgui.load_font('SourceHanSansCN-Bold.otf', 18)

local character_manager = sdk.get_managed_singleton('app.CharacterManager')
local item_manager = sdk.get_managed_singleton('app.ItemManager')

re.on_draw_ui(function()
    imgui.push_font(fontCN)
    if imgui.tree_node('Inf Item') then
        if imgui.button('飞石') then
            item_manager:call('getItem', 80, 1,
                item_manager:call('getCharaId(app.Character)', character_manager:call('get_Chara()')),
                true, false, false, 2)
        end

        if imgui.button('基石') then
            item_manager:call('getItem', 81, 1,
                item_manager:call('getCharaId(app.Character)', character_manager:call('get_Chara()')),
                true, false, false, 2)
        end
    end
    imgui.pop_font()
end)
re.on_config_save(function() json.dump_file('inf_stamina.json', config) end)
