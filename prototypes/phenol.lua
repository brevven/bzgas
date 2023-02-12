local util = require("data-util");

if util.me.use_phenol() then

data:extend({
  {
    type = "item",
    name = "phenol",
    icon = "__bzgas__/graphics/icons/phenol.png", icon_size = 128,
    pictures = {
      {filename = "__bzgas__/graphics/icons/phenol.png",   size = 128, scale = 0.125},
      {filename = "__bzgas__/graphics/icons/phenol-2.png", size = 128, scale = 0.125},
      {filename = "__bzgas__/graphics/icons/phenol-3.png", size = 128, scale = 0.125},
      {filename = "__bzgas__/graphics/icons/phenol-4.png", size = 128, scale = 0.125},
    },
    subgroup = "raw-material",
    order = "g[phenol]",
    stack_size = util.get_stack_size(100),
  },
})

if data.raw.item["coke"] then
  local cat
  if mods.Krastorio2 then
    cat  = "smelting"
  elseif data.raw.item["foundry"] then
    cat = "founding"
  else
    cat = "advanced-crafting"
  end

  if mods.Krastorio2 then
    data:extend({
      {
        type = "recipe",
        name = "phenol",
        category = cat,
        main_product = "phenol",
        enabled = "false",
        icon = "__bzgas__/graphics/icons/phenol.png", icon_size = 128,
        ingredients = {{"coal", 6}, {"wood", 6}},
        energy_required = 16,
        subgroup = "raw-material",
        results = {
          {type="item", name="phenol", amount = 6},
          {type="item", name="coke", amount = 3},
        },
      }
    })
  else
    data:extend({
      {
        type = "recipe",
        name = "phenol",
        category = cat,
        main_product = "phenol",
        enabled = "false",
		     icon = "__bzgas__/graphics/icons/phenol.png", icon_size = 128,
        ingredients = {{"coal", 4}},
        energy_required = 6.4,
		     subgroup = "raw-material",
        results = {
          {type="item", name="phenol", amount = 2},
          {type="item", name="coke", amount = 1},
        },
      }
    })
  end
  if mods.Krastorio2 then
    util.add_effect("steel-processing", {type="unlock-recipe", recipe="phenol"})
  elseif data.raw.item["foundry"] then
    util.add_effect("foundry", {type="unlock-recipe", recipe="phenol"})
  else
    util.add_effect("basic-chemistry", {type="unlock-recipe", recipe="phenol"})
  end
  data:extend({
    {
      type = "recipe",
      name = "phenol-from-oil",
      main_product = "phenol",
      category = "chemistry",
      enabled = "false",
      icons = {
        {icon = "__bzgas__/graphics/icons/phenol.png", icon_size = 128},
        {icon = "__base__/graphics/icons/fluid/light-oil.png", icon_size = 64, icon_mipmaps = 4, scale=0.25, shift={-8,-8}},
      },
      ingredients = {
        {type="fluid", name="light-oil", amount=20}
      },
      energy_required = 12,
      results = {
        {type="item", name="phenol", amount=3},
      },
    }
  })
  util.add_unlock("advanced-oil-processing", "phenol-from-oil")
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
        {type="item", name="phenol", amount=1},
      },
    }
  })
  util.add_effect("automation", {type="unlock-recipe", recipe="phenol"})
end
end
