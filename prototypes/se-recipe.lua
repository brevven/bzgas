local util = require("data-util");

if mods["space-exploration"] then
  se_delivery_cannon_recipes["formaldehyde-barrel"] = {name= "formaldehyde-barrel"}
  se_delivery_cannon_recipes["gas-barrel"] = {name= "gas-barrel"}
  se_delivery_cannon_recipes["bakelite"] = {name= "bakelite"}
end

if util.se6() then
  data:extend({
    {
      type = "recipe",
      name = "methane-pre-reforming",
      category = "chemistry",
      subgroup = "chemical",
      main_product = "se-methane-gas",
      icons = {
        {icon =  "__space-exploration-graphics__/graphics/icons/fluid/methane-gas.png", icon_size = 64},
        {icon =  "__bzgas__/graphics/icons/gas.png", icon_size = 128, scale = 0.125, shift={-8,-8}},
      },
      enabled = false,
      ingredients = {
        {type="fluid", name="gas", amount=25},
      },
      energy_required = 1,
      results = {
        {type="fluid", name="se-methane-gas", amount = 25},
      },
    },
    {
      type = "recipe",
      name = "formaldehyde-methane",
      category = "chemistry",
      subgroup = "chemical",
      icons = {
        {icon =  "__bzgas__/graphics/icons/formaldehyde.png", icon_size = 128, scale = 0.125},
        {icon =  "__space-exploration-graphics__/graphics/icons/fluid/methane-gas.png", icon_size = 64, scale = 0.125, shift={-8,-8}},
      },
      enabled = false,
      ingredients = {
        {type="fluid", name="se-methane-gas", amount=10},
      },
      energy_required = 1,
      results = {
        {type="fluid", name="formaldehyde", amount = 10},
      },
    },
  })
  util.add_unlock("se-space-biochemical-laboratory", "methane-pre-reforming")
  util.add_unlock("se-space-biochemical-laboratory", "formaldehyde-methane")
  if data.raw.fluid["se-methane-gas"] then
    data.raw.fluid["se-methane-gas"].fuel_value = "1000KJ"
  end
end
