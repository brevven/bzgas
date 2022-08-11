require("stacking")
require("modules")
-- require("tin-recipe-final-5d")
require("compatibility/ir2")

local util = require("data-util");

-- core mining balancing
util.add_to_product("se-core-fragment-omni", "gas", -56)

-- Fix basic chemical plant fuels for K2
if mods.Krastorio2 and 
data.raw["assembling-machine"]["basic-chemical-plant"] and 
data.raw["assembling-machine"]["basic-chemical-plant"].energy_source and 
data.raw["assembling-machine"]["basic-chemical-plant"].energy_source.fuel_categories then
  table.insert(data.raw["assembling-machine"]["basic-chemical-plant"].energy_source.fuel_categories , "vehicle-fuel")
end

-- Vanilla burner phase tweaks -- green circuits after electronics
-- Electronic circuit recipe set below in compatibility script
if not mods.Krastorio2 and not mods["aai-industry"] and not mods.bzaluminum and not mods.bzcarbon then
  util.replace_ingredient("offshore-pump", "electronic-circuit", "copper-cable")
  util.replace_ingredient("lab", "electronic-circuit", "copper-cable")
  util.replace_ingredient("electric-mining-drill", "electronic-circuit", "copper-cable", 2, true)
  util.replace_ingredient("assembling-machine-1", "electronic-circuit", "copper-plate")
  util.replace_ingredient("radar", "electronic-circuit", "copper-plate")
  util.replace_ingredient("splitter", "electronic-circuit", "copper-cable", 20)

  -- Keep repair pack raw ingredients the same:
  util.remove_ingredient("repair-pack", "electronic-circuit")
  util.add_ingredient("repair-pack", "copper-cable", 6)
  util.set_ingredient("repair-pack", "iron-gear-wheel", 3)

  util.add_effect("electronics", { type = "unlock-recipe", recipe = "electronic-circuit" })
  util.add_effect("electronics", { type = "unlock-recipe", recipe = "inserter" })
  util.add_effect("electronics", { type = "unlock-recipe", recipe = "long-handed-inserter" })
  util.remove_recipe_effect("automation", "long-handed-inserter")
  util.set_enabled("electronic-circuit", false)
  util.set_enabled("inserter", false)
  util.add_prerequisite("logistic-science-pack", "electronics")
end
if not mods.bzaluminum and not mods.bzcarbon then
  util.replace_ingredients_prior_to("electronics", "electronic-circuit", "copper-cable", 2)
end

util.remove_ingredient("small-lamp", "blank-circuit") -- mod mash

-- Should come as late as possible, doesn't need to be last
require("compatibility/electronic-circuit")

-- Must be last
util.create_list()
