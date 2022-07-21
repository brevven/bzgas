require("stacking")
require("modules")
-- require("tin-recipe-final-5d")

local util = require("data-util");

-- core mining balancing TODO


-- Electronic circuits need final fixes
if data.raw.recipe["electronic-circuit-stone"] then
  util.set_hidden("electronic-circuit-stone")
  util.replace_ingredient("electronic-circuit-stone", "stone-tablet", "bakelite")
  util.remove_recipe_effect("electronics", "electronics-circuit-stone")
  util.set_hidden("electronics-circuit-stone")
end

util.replace_ingredient("electronic-circuit", "wood", "bakelite")
util.replace_ingredient("electronic-circuit", "iron-plate", "bakelite")
util.set_icons("electronic-circuit", nil)

-- Vanilla burner phase tweaks -- green circuits after electronics
if not mods.Krastorio2 and not mods["aai-industry"] and not mods.bzaluminum and not mods.bzcarbon then
  util.replace_ingredient("offshore-pump", "electronic-circuit", "copper-cable")
  util.replace_ingredient("lab", "electronic-circuit", "copper-cable")
  util.replace_ingredient("electric-mining-drill", "electronic-circuit", "copper-cable")
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

util.remove_ingredient("small-lamp", "blank-circuit") -- mod mash
-- Must be last
util.create_list()
