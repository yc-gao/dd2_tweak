local log = log
local json = json
local sdk = sdk
local re = re
local imgui = imgui

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
    }
}, config)


local gui_manager = sdk.get_managed_singleton("app.GuiManager")
local character_manager = sdk.get_managed_singleton('app.CharacterManager')
local human = character_manager:call('get_ManualPlayerHuman()')
local job_context = human:call('get_JobContext()')
local skill_context = human:call('get_SkillContext()')

local SetSkills = function(job_context, skill_context, gui_manager, skills)
    for k, v in ipairs(skills) do
        skill_context:setSkill(job_context:get_field('CurrentJob'), v, k - 1)
    end
    gui_manager:call("setupKeyGuideCustomSkill()")
end

re.on_draw_ui(function()
    -- TODO: impl
    if imgui.tree_node('True Warfarer') then
    end
end)
re.on_config_save(function() json.dump_file('true_warfarer.json', config) end)
