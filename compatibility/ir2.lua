local util = require("data-util");


-- absolute barebones "compatibility", won't be very playable
if mods.IndustrialRevolution then
  util.set_category("explosives", "crafting-with-fluid")
  util.remove_prerequisite("ir2-electronics-1", "ir2-steam-power")

  util.replace_ingredient("gas-extractor", "iron-plate", "copper-beam")
  util.replace_ingredient("gas-extractor", "pipe", "copper-pipe")

  util.replace_ingredient("basic-chemical-plant", "iron-plate", "copper-beam")
  util.replace_ingredient("basic-chemical-plant", "pipe", "copper-pipe")

  util.set_category("phenol", "crafting")
end

