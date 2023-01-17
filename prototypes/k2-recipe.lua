local util = require("data-util");
if mods.Krastorio2 then
  data:extend({
    {
      type = "recipe",
      name = "gas-reforming",
      category = "chemistry",
      subgroup = "fluid-recipes",
      main_product = "hydrogen",
      icons = {
        {icon = kr_fluids_icons_path.."hydrogen.png", icon_size = 64, icon_mipmaps = 4},
        {icon =  "__bzgas__/graphics/icons/gas.png", icon_size = 128, scale = 0.125, shift={-8,-8}},
      },
      enabled = false,
      ingredients = {
        {type="fluid", name="gas", amount=25},
        {type="fluid", name="water", amount=50},
      },
      energy_required = 3,
      results = {
        {type="fluid", name="hydrogen", amount = 100},
      },
    },
    {
      type = "recipe",
      name = "formaldehyde-methanol",
      category = "chemistry",
      subgroup = "fluid-recipes",
      main_product = "formaldehyde",
      icons = {
        {icon =  "__bzgas__/graphics/icons/formaldehyde.png", icon_size = 128, scale = 0.125},
        {icon = kr_fluids_icons_path.."biomethanol.png", icon_size = 64, scale = 0.125, icon_mipmaps = 4, shift={-5,-5}},
      },
      enabled = false,
      ingredients = {
        {type="fluid", name="biomethanol", amount=50},
        {type="fluid", name="oxygen", amount=25},
      },
      energy_required = 7,
      results = {
        {type="fluid", name="formaldehyde", amount = 50},
        {type="fluid", name="water", amount = 50},
      },
    },
  })
  if util.se6() then
    data:extend({
    {
      type = "recipe",
      name = "methane-reforming",
      category = "chemistry",
      subgroup = "fluid-recipes",
      main_product = "hydrogen",
      icons = {
        {icon = kr_fluids_icons_path.."hydrogen.png", icon_size = 64, icon_mipmaps = 4},
        {icon =  "__space-exploration-graphics__/graphics/icons/fluid/methane-gas.png", icon_size = 64, scale = 0.25, shift={-8,-8}},
      },
      enabled = false,
      ingredients = {
        {type="fluid", name="se-methane-gas", amount=25},
        {type="fluid", name="water", amount=50},
      },
      energy_required = 2,
      results = {
        {type="fluid", name="hydrogen", amount = 100},
      },
    },
    })
  end
  util.add_unlock("kr-advanced-chemistry", "gas-reforming")
  util.add_unlock("se-space-biochemical-laboratory", "methane-reforming")
  util.add_unlock("kr-advanced-chemistry", "formaldehyde-methanol")
end
