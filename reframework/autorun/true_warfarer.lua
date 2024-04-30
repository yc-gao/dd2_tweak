local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

local HotKeys = require('Hotkeys.Hotkeys')
local utils = require('utils')

local config = json.load_file('true_warfarer.json') or {}
config = utils.tbl_merge({
    currentPreset = 0,
    presetSet = {
        [1] = {},  -- 战士
        [2] = {},  -- 弓箭手
        [3] = {},  -- 法师
        [4] = {},  -- 盗贼
        [5] = {},  -- 斗士
        [6] = {},  -- 巫师
        [7] = {},  -- 魔剑士
        [8] = {},  -- 魔弓手
        [9] = {},  -- 幻术师
        [10] = {}, -- 龙选者
    },
    Hotkeys = {
        ["Switch Preset"] = "Space",
    }
}, config)

HotKeys.setup_hotkeys(config.Hotkeys)

local GetGuiManager = utils.func_cache(function() return sdk.get_managed_singleton("app.GuiManager") end)
local GetCharacterManager = utils.func_cache(function() return sdk.get_managed_singleton("app.CharacterManager") end)
local GetPlayerHuman = utils.func_cache(function() return GetCharacterManager():call('get_ManualPlayerHuman()') end)
local GetJobContext = utils.func_cache(function() return GetPlayerHuman():call('get_JobContext()') end)
local GetSkillContext = utils.func_cache(function() return GetPlayerHuman():call('get_SkillContext()') end)

local ApplyPreset = function()
    local currentJob = GetJobContext():get_field('CurrentJob')
    local skills = config.presetSet[currentJob][config.currentPreset]
    if skills == nil then
        config.currentPreset = 0
        return false
    end
    for k, v in ipairs(skills) do
        GetSkillContext():setSkill(GetJobContext():get_field('CurrentJob'), v, k - 1)
    end
    GetGuiManager():call("setupKeyGuideCustomSkill()")
    return true
end

local NextPreset = function()
    config.currentPreset = config.currentPreset + 1
    if not ApplyPreset() then
        config.currentPreset = config.currentPreset + 1
        return ApplyPreset()
    end
    return true
end

local DelPreset = function(idx)
    if config.currentPreset == idx then
        config.currentPreset = 0
    elseif config.currentPreset > idx then
        config.currentPreset = config.currentPreset - 1
    end
    table.remove(config.presetSet, idx)
    ApplyPreset()
end

local savePreset = function()
    local currentJob = GetJobContext():get_field('CurrentJob')
    local skills = {}
    for i = 0, 3 do
        skills[i + 1] = GetSkillContext():getSkillID(currentJob, i)
    end
    table.insert(config.presetSet[currentJob], skills)
end

re.on_frame(function()
    if HotKeys.check_hotkey("Switch Preset", false, true) then
        NextPreset()
    end
end)

re.on_draw_ui(function()
    if imgui.tree_node('True Warfarer') then
        if HotKeys.hotkey_setter("Switch Preset", false, 'Switch Preset') then
            HotKeys.update_hotkey_table(config.Hotkeys)
        end
        if imgui.button('Save Preset') then
            savePreset()
        end
        imgui.text('current job: ' .. GetJobContext():get_field('CurrentJob'))
        local presetSet = config.presetSet[GetJobContext():get_field('CurrentJob')] or {}
        for i, v in ipairs(presetSet) do
            imgui.push_id('checkbox item ' .. i)
            local changed, selected = imgui.checkbox(
                'left: ' .. v[1] .. ' top: ' .. v[2] .. ' down: ' .. v[3] .. ' right: ' .. v[4],
                config.currentPreset == i)
            imgui.pop_id()
            if changed then
                if selected then
                    config.currentPreset = i
                else
                    config.currentPreset = 0
                end
            end
            imgui.same_line()
            imgui.push_id('preset del ' .. i)
            if imgui.button('del') then
                DelPreset(i)
            end
            imgui.pop_id()
        end
    end
end)
re.on_config_save(function() json.dump_file('true_warfarer.json', config) end)
