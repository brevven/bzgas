local util = require("data-util");

if util.me.use_phenol() then
  util.multiply_recipe("plastic-bar", 3)
  util.replace_some_ingredient("plastic-bar", "petroleum-gas", 15, "phenol", 1)
end

util.add_ingredient("power-switch", "bakelite", 5)
util.replace_ingredient("programmable-speaker", "iron-plate", "bakelite")
util.replace_ingredient("assembling-machine-2", "iron-gear-wheel", "bakelite")

util.add_ingredient("accumulator", "bakelite", 5)
util.add_to_ingredient("accumulator", "battery", 3)
util.set_product_amount("accumulator", "accumulator", 2)


util.replace_some_ingredient("explosives", "coal", 1, "formaldehyde", 10)


-- Gas boiler updates, from this mod or another
util.remove_ingredient("gas-boiler", "pump")
util.add_ingredient("gas-boiler", "pipe", 1)
util.add_ingredient("gas-boiler", "solder", 1)
util.add_effect("gas-extraction", {type="unlock-recipe", recipe="gas-boiler"})


if mods.Krastorio2 then
  util.add_prerequisite("kr-fluids-chemistry", "basic-chemistry")
  util.add_prerequisite("basic-chemistry", "kr-basic-fluid-handling")
end


util.replace_ingredient("se-bio-combustion-data", "se-plasma-stream", "gas")
util.replace_ingredient("se-bio-combustion-resistance-data", "se-plasma-stream", "gas")
util.add_ingredient("se-genetic-data", "phenol", 1)
util.add_ingredient("se-comparative-genetic-data", "phenol", 2)


-- Bob's Electronics SE KR
util.remove_recipe_effect("electronics", "basic-circuit-board-stone")
util.set_hidden("basic-circuit-board-stone")
util.replace_ingredient("basic-circuit-board-stone", "stone-tablet", "bakelite")
util.remove_ingredient("basic-circuit-board", "wood")
util.remove_ingredient("basic-circuit-board", "wooden-board")
util.remove_ingredient("basic-circuit-board", "iron-plate")
util.add_ingredient("basic-circuit-board", "bakelite", 1)
util.set_enabled("basic-circuit-board", false)
util.add_unlock("electronics", "basic-circuit-board")


-- Modmash electronics
util.replace_ingredient("blank-circuit", "iron-plate", "bakelite")
util.set_enabled("blank-circuit", false)
util.add_unlock("electronics", "blank-circuit")

