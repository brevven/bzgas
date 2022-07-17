data:extend({
  {
		type = "string-setting",
		name = "bzgas-recipe-bypass",
		setting_type = "startup",
		default_value = "",
    allow_blank = true,
	},
  {
		type = "bool-setting",
		name = "bzgas-list",
		setting_type = "startup",
    default_value = false,
	},
  {
		type = "string-setting",
		name = "bzgas-more-intermediates",
		setting_type = "startup",
		default_value = "phenol",
    allowed_values = {"phenol", "no"},
	},
})
