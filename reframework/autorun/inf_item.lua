local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local CN_FONT_NAME = 'SourceHanSansCN-Bold.otf'
local CN_FONT_SIZE = 18
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
local fontCN = imgui.load_font(CN_FONT_NAME, CN_FONT_SIZE, CJK_GLYPH_RANGES)

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
