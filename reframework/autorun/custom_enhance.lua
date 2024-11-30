local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')

local CJK_GLYPH_RANGES = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x3130, 0x318F, -- Hangul Compatibility Jamo
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0xFF00, 0xFFEF, -- Half-width characters
    0x4e00, 0x9FAF, -- CJK Ideograms
    0xA960, 0xA97F, -- Hangul Jamo Extended-A
    0xAC00, 0xD7A3, -- Hangul Syllables
    0xD7B0, 0xD7FF, -- Hangul Jamo Extended-B
    0,
}
local fontCN = imgui.load_font('SourceHanSansCN-Bold.otf', 18, CJK_GLYPH_RANGES)


local config = json.load_file('custom_enhance.json') or {}
config = utils.tbl_merge({
    Enable = true,
    InfStamina = true,
    InfWeight = true,
    PriceX10 = true,
}, config)

local stamina_manager_t = sdk.find_type_definition('app.StaminaManager')
sdk.hook(stamina_manager_t:get_method('add(System.Single, System.Boolean)'),
    function(args)
        if config.Enable and config.InfStamina then
            local v = sdk.to_float(args[3])
            if v < 0 then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
        return sdk.PreHookResult.CALL_ORIGINAL
    end,
    nil
)

local item_manager_t = sdk.find_type_definition('app.ItemManager')
sdk.hook(item_manager_t:get_method('getWeightRank(System.Single, System.Single)'),
    nil,
    function(retval)
        if config.Enable and config.InfWeight then
            return sdk.to_ptr(0)
        end
        return retval
    end
)

local item_common_param_t = sdk.find_type_definition('app.ItemCommonParam')
sdk.hook(item_common_param_t:get_method('get_SellPrice()'),
    nil,
    function(retval)
        if config.Enable and config.PriceX10 then
            return sdk.to_ptr((sdk.to_int64(retval) & 0xFFFFFFFF) * 10)
        end
        return retval
    end
)

local character_manager = sdk.get_managed_singleton('app.CharacterManager')
local item_manager = sdk.get_managed_singleton('app.ItemManager')

re.on_draw_ui(function()
    imgui.push_font(fontCN)
    if imgui.tree_node('Custom Enhance') then
        _, config.Enable = imgui.checkbox('Custom Enhance', config.Enable)
        _, config.InfStamina = imgui.checkbox('Inf Stamina', config.InfStamina)
        _, config.InfWeight = imgui.checkbox('Inf Weight', config.InfWeight)
        _, config.PriceX10 = imgui.checkbox('Price X10', config.PriceX10)
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
    end
    imgui.pop_font()
end)
re.on_config_save(function() json.dump_file('custom_enhance.json', config) end)
