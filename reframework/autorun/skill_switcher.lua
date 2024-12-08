local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local utils = require('utils')
local hotkeys = require("Hotkeys/Hotkeys")

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

local config = json.load_file('skill_switcher.json') or {}
config = utils.tbl_merge({
    Enable = true,
    Hotkeys = {
        ["NextKey"] = "Right",
        ["PrevKey"] = "Left"
    },
    CurrentPreset = 0,
    Presets = {},
    JobNames = {},
    SkillNames = {},
}, config)

local Job2Skills = {
    [1] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 100 },
    [2] = { 0, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 100 },
    [3] = { 0, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 100 },
    [4] = { 0, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 101, 100 },
    [5] = { 0, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 100 },
    [6] = { 0, 24, 25, 26, 27, 62, 63, 64, 65, 66, 67, 68, 69, 100 },
    [7] = { 0, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 100 },
    [8] = { 0, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 100 },
    [9] = { 0, 92, 93, 94, 95, 96, 97, 98, 99, 100 },
    [10] = { 0 }
}


local character_manager = sdk.get_managed_singleton('app.CharacterManager')
local gui_manager = sdk.get_managed_singleton("app.GuiManager")

local function GetCurrentJob()
    local player = character_manager:call("get_ManualPlayer()")
    local human = player:call("get_Human")
    local job_context = human:call("get_JobContext")

    local current_job = job_context:call("get_Job")
    return current_job
end

-- left, up, down, right
local function SetCurrentJobSkills(skills)
    local player = character_manager:call("get_ManualPlayer()")
    local human = player:call("get_Human")
    local skill_context = human:call("get_SkillContext")

    local current_job = GetCurrentJob()
    for i = 1, 4 do skill_context:setSkill(current_job, skills[i], i - 1) end
    gui_manager:call("setupKeyGuideCustomSkill()")
end
local function GetCurrentJobSkills()
    local player = character_manager:call("get_ManualPlayer()")
    local human = player:call("get_Human")
    local skill_context = human:call("get_SkillContext")

    local current_job = GetCurrentJob()
    local skills = {}
    for i = 1, 4 do
        skills[i] = skill_context:getSkillID(current_job, i - 1)
    end
    return skills
end

local function GetCurrentJobSkillsAvailable()
    local current_job = GetCurrentJob()
    local skills = {}
    for _, skill in ipairs(Job2Skills[current_job]) do
        local skill_str = tostring(skill)
        skills[skill_str] = config.SkillNames[skill_str]
    end
    return skills
end

local function UpdateSkills()
    local skills = config.Presets[config.CurrentPreset]
    if skills ~= nil then
        SetCurrentJobSkills(skills)
    end
end

hotkeys.setup_hotkeys(config.Hotkeys)

re.on_draw_ui(function()
    imgui.push_font(fontCN)
    if imgui.tree_node('Skill Switcher') then
        if imgui.button('save as preset') then
            config.Presets[#config.Presets + 1] = GetCurrentJobSkills()
            if #config.Presets == 1 then
                config.CurrentPreset = 1
            end
        end
        imgui.same_line()
        if imgui.button('delete last preset') then
            if config.CurrentPreset ~= #config.Presets then
                table.remove(config.Presets, #config.Presets)
            end
        end
        imgui.same_line()
        imgui.text('current job: ' .. config.JobNames[tostring(GetCurrentJob())])
        imgui.text('total presets: ' .. #config.Presets)
        imgui.text('current preset: ' .. config.CurrentPreset)
        for pidx, preset in ipairs(config.Presets) do
            if imgui.tree_node('preset ' .. pidx) then
                for sidx, skill in ipairs(preset) do
                    local changed, value = imgui.combo(({ 'left', 'up', 'down', 'right' })[sidx], tostring(skill),
                        GetCurrentJobSkillsAvailable())
                    if changed then
                        config.Presets[pidx][sidx] = tonumber(value)
                        if config.CurrentPreset == pidx then
                            UpdateSkills()
                        end
                    end
                end
                imgui.tree_pop()
            end
        end
        imgui.tree_pop()
    end
    imgui.pop_font()
end)

re.on_frame(function()
    if hotkeys.check_hotkey('NextKey') then
        if #config.Presets > 0 then
            config.CurrentPreset = config.CurrentPreset % #config.Presets + 1
            UpdateSkills()
        else
            config.CurrentPreset = 0
        end
    end
    if hotkeys.check_hotkey('PrevKey') then
        if #config.Presets > 0 then
            config.CurrentPreset = (config.CurrentPreset - 2) % #config.Presets + 1
            UpdateSkills()
        else
            config.CurrentPreset = 0
        end
    end
end)

re.on_config_save(function() json.dump_file('skill_switcher.json', config) end)
