require("prototypes/gas")
require("prototypes/gas-extractor")
require("prototypes/phenol")
require("prototypes/formaldehyde")
require("prototypes/bakelite")
require("prototypes/basic-chemical-plant")
require("prototypes/k2-recipe")

local util = require("data-util");

if util.me.use_boiler() and not data.raw.boiler["gas-boiler"] then
  require("gas-boiler/data")
end

-- Must be last
util.create_list()
