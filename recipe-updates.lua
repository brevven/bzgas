local util = require("data-util");

if util.me.use_phenol() then
  util.multiply_recipe("plastic-bar", 3)
  util.replace_some_ingredient("plastic-bar", "petroleum-gas", 15, "phenol", 1)
end

util.add_ingredient("power-switch", "bakelite", 5)
util.replace_ingredient("programmable-speaker", "iron-plate", "bakelite")
util.add_ingredient("accumulator", "bakelite", 5)
util.replace_ingredient("assembling-machine-2", "iron-gear-wheel", "bakelite")


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

