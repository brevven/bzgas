require("prototypes/gas")
require("prototypes/gas-extractor")
require("prototypes/phenol")
require("prototypes/formaldehyde")
require("prototypes/bakelite")
require("prototypes/basic-chemical-plant")

local util = require("data-util");

if util.me.use_boiler() then
  require("gas-boiler/data")
end

-- Must be last
util.create_list()
