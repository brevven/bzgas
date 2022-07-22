local util = require("data-util");
if mods.Krastorio2 then
  data:extend({
    {
      type = "recipe",
      name = "gas-reforming",
      category = "chemistry",
      main_product = "hydrogen",
      icons = {
        {icon = kr_fluids_icons_path.."hydrogen.png", icon_size = 64, icon_mipmaps = 4},
        {icon =  "__bzgas__/graphics/icons/gas.png", icon_size = 128, scale = 0.125, shift={-8,-8}},
      },
      enabled = "false",
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
      main_product = "formaldehyde",
      icons = {
        {icon =  "__bzgas__/graphics/icons/formaldehyde.png", icon_size = 128, scale = 0.125},
        {icon = kr_fluids_icons_path.."oxygen.png", icon_size = 64, scale = 0.125, icon_mipmaps = 4, shift={-8,-8}},
      },
      enabled = "false",
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
  util.add_effect("kr-advanced-chemistry", {type="unlock-recipe", recipe="gas-reforming"})
  util.add_effect("kr-advanced-chemistry", {type="unlock-recipe", recipe="formaldehyde-methanol"})
end
