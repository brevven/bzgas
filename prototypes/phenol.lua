local util = require("data-util");

if util.me.use_phenol() then

data:extend({
  {
    type = "item",
    name = "phenol",
    icon = "__bzgas__/graphics/icons/phenol.png",
    icon_size = 128,
    subgroup = "raw-material",
    order = "g[phenol]",
    stack_size = util.get_stack_size(100),
  },
})

if data.raw.item["coke"] then
  local er = mods.Krastorio2 and 10 or 6.4
  local cat
  if mods.Krastorio2 then
    cat  = "smelting"
    util.add_effect("steel-processing", {type="recipe-unlock", name="phenol"})
  elseif data.raw.item["foundry"] then
    cat = "founding"
    util.add_effect("foundry", {type="recipe-unlock", name="phenol"})
  else
    cat = "advanced-crafting"
    util.add_effect("automation", {type="recipe-unlock", name="phenol"})
  end

  data:extend({
    {
      type = "recipe",
      name = "phenol",
      category = cat,
      main_product = "phenol",
      enabled = "false",
      ingredients = {{"coal", 4}},
      energy_required = er,
      results = {
        {type="item", name="phenol", amount = 2},
        {type="item", name="coke", amount = 1},
      },
    }
  })
else
  data:extend({
    {
      type = "recipe",
      name = "phenol",
      category = "advanced-crafting",
      main_product = "phenol",
      enabled = "false",
      energy_required = 1,
      ingredients = {{"coal", 1}},
      results = {
        {type="item", name="phenol", amount = 1},
      },
    }
  })
  util.add_effect("automation", {type="recipe-unlock", name="phenol"})
end
end
