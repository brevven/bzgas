local util = require("data-util");

if mods["248k"] then
  data:extend({
    {
      type = "recipe",
      name = "acid-gas-breakdown",
      icons = {
        {icon = "__bzgas__/graphics/icons/gas.png", icon_size = 128},
        {icon = "__248k__/ressources/fluids/fi_acid_gas.png", icon_size = 64, scale=0.25, shift={-8,-8}},
      },
      category = "chemistry",
      subgroup = "fi_item_subgroup_f",
      enabled = "false",
      energy_required = 3,
      ingredients = {
        {type="fluid", name="fi_acid_gas", amount=10},
        {type="fluid", name="water", amount=10},
      },
      results = {
        {type="fluid", name="gas", amount=10},
        {type="fluid", name="sulfuric-acid", amount=10},
      },
    }
  })
  util.add_unlock("fi_refery_2_tech", "acid-gas-breakdown")
end
