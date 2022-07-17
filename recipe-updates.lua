local util = require("data-util");

if util.me.use_phenol() then
  util.multiply_recipe("plastic-bar", 3)
  util.replace_some_ingredient("plastic-bar", "petroleum-gas", 15, "phenol", 1)
end
