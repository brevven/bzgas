require("tin-recipe-final-stacking")
require("tin-recipe-modules")
-- require("tin-recipe-final-5d")
require("tin-recipe-final-rrr")

local util = require("data-util");
util.replace_some_ingredient("se-glass-vulcanite", "sand", 1, "tin-plate", 1)
util.add_product("se-glass-vulcanite", {type="item", name="tin-plate", amount=1, probability=0.8})
util.set_main_product("se-glass-vulcanite", "glass")

-- core mining balancing
util.add_to_product("se-core-fragment-omni", "tin-ore", -4)


-- Electronic circuits need final fixes
util.multiply_recipe("electronic-circuit-stone", 2)
util.replace_some_ingredient("electronic-circuit-stone", "copper-cable", 1, "solder", 1)

util.multiply_recipe("electronic-circuit", 2)
util.replace_some_ingredient("electronic-circuit", "copper-cable", 1, "solder", 1)

-- Must be last
util.create_list()
