require("tin-recipe-final-stacking")
require("tin-recipe-modules")
-- require("tin-recipe-final-5d")

local util = require("data-util");

-- core mining balancing TODO


-- Electronic circuits need final fixes
util.replace_ingredient("electronic-circuit-stone", "stone-tablet", "bakelite")
util.replace_ingredient("electronic-circuit", "wood", "bakelite")
util.replace_ingredient("electronic-circuit", "iron-plate", "bakelite")

-- Must be last
util.create_list()
