require("factsheet")

-- Added by Brevven for bzgas
-- local gd = "__gas-boiler__"
local gd = "__bzgas__/gas-boiler"



gf_boiler_entity = util.table.deepcopy(data.raw.boiler.boiler)
gf_boiler_entity.name = "gas-boiler"
gf_boiler_entity.icon = gd.."/graphics/icons/gas-boiler.png"
gf_boiler_entity.icon_size = 32
gf_boiler_entity.minable.result = "gas-boiler"
gf_boiler_entity.fast_replaceable_group = "boiler"
gf_boiler_entity.energy_source = {
	type = "fluid",
	fluid_box = {
		base_area = 1,
		height = 1,
		base_level = -1,
		pipe_covers = pipecoverspictures(),
		pipe_picture = {
			north = {
				filename = gd.."/graphics/entity/"
					.."assembling-machine-1-pipe-N.png",
				priority = "extra-high",
				width = 35,
				height = 18,
				shift = util.by_pixel(2.5, 14),
				hr_version = {
					filename = gd.."/graphics/entity/"
						.."hr-assembling-machine-1-pipe-N.png",
					priority = "extra-high",
					width = 71,
					height = 38,
					shift = util.by_pixel(2.25, 13.5),
					scale = 0.5
				}
			},
			east = {
				filename = gd.."/graphics/entity/"
					.."assembling-machine-1-pipe-E.png",
				priority = "extra-high",
				width = 20,
				height = 38,
				shift = util.by_pixel(-25, 1),
				hr_version = {
					filename = gd.."/graphics/entity/"
						.."hr-assembling-machine-1-pipe-E.png",
					priority = "extra-high",
					width = 42,
					height = 76,
					shift = util.by_pixel(-24.5, 1),
					scale = 0.5
				}
			},
			south = {
				filename = gd.."/graphics/entity/"
					.."assembling-machine-1-pipe-S.png",
				priority = "extra-high",
				width = 44,
				height = 31,
				shift = util.by_pixel(0, -31.5),
				hr_version = {
					filename = gd.."/graphics/entity/"
						.."hr-assembling-machine-1-pipe-S.png",
					priority = "extra-high",
					width = 88,
					height = 61,
					shift = util.by_pixel(0, -31.25),
					scale = 0.5
				}
			},
			west = {
				filename = gd.."/graphics/entity/"
					.."assembling-machine-1-pipe-W.png",
				priority = "extra-high",
				width = 19,
				height = 37,
				shift = util.by_pixel(25.5, 1.5),
				hr_version = {
					filename = gd.."/graphics/entity/"
						.."hr-assembling-machine-1-pipe-W.png",
					priority = "extra-high",
					width = 39,
					height = 73,
					shift = util.by_pixel(25.75, 1.25),
					scale = 0.5
				}
			}
		},
		pipe_connections = {
			{type = "input", position = {0, 1.5}},
		},
    production_type = "input",
		secondary_draw_orders = {
			south = 32,
			north = -1,
			east = -1,
			west = -1,
		}
	},
	burns_fluid = true,
	scale_fluid_usage = true,
	emissions_per_minute = 30,
	smoke = {{
			name = "smoke",
			north_position = util.by_pixel(-38, -47.5),
			south_position = util.by_pixel(38.5, -32),
			east_position = util.by_pixel(20, -70),
			west_position = util.by_pixel(-19, -8.5),
			frequency = 15,
			starting_vertical_speed = 0.3,
			starting_frame_deviation = 0
	}},
	light_flicker = {
		color = colors.gas_fire_glow,
		minimum_light_size = 0.1,
		light_intensity_to_size_coefficient = 1
	}
}
gf_boiler_entity.fire_flicker_enabled = false
gf_boiler_entity.fire_glow_flicker_enabled = false
gf_boiler_entity.fire = {}
gf_boiler_entity.fire_glow.north.filename = 
	gd.."/graphics/entity/"..
	"gas-boiler-N-light.png"
gf_boiler_entity.fire_glow.south.filename = 
	gd.."/graphics/entity/"..
	"gas-boiler-S-light.png"
gf_boiler_entity.fire_glow.east.filename = 
	gd.."/graphics/entity/"..
	"gas-boiler-E-light.png"
gf_boiler_entity.fire_glow.west.filename = 
	gd.."/graphics/entity/"..
	"gas-boiler-W-light.png"
gf_boiler_entity.fire_glow.north.hr_version.filename = 
	gd.."/graphics/entity/"..
	"hr-gas-boiler-N-light.png"
gf_boiler_entity.fire_glow.south.hr_version.filename = 
	gd.."/graphics/entity/"..
	"hr-gas-boiler-S-light.png"
gf_boiler_entity.fire_glow.east.hr_version.filename = 
	gd.."/graphics/entity/"..
	"hr-gas-boiler-E-light.png"
gf_boiler_entity.fire_glow.west.hr_version.filename = 
	gd.."/graphics/entity/"..
	"hr-gas-boiler-W-light.png"
gf_boiler_entity.fire_glow.north.apply_runtime_tint = true
gf_boiler_entity.fire_glow.south.apply_runtime_tint = true
gf_boiler_entity.fire_glow.east.apply_runtime_tint = true
gf_boiler_entity.fire_glow.west.apply_runtime_tint = true
gf_boiler_entity.fire_glow.north.tint={r=1,g=0.6,b=0.6,a=0.4}
gf_boiler_entity.fire_glow.south.tint={r=1,g=0.6,b=0.6,a=0.4}
gf_boiler_entity.fire_glow.east.tint={r=1,g=0.6,b=0.6,a=0.4}
gf_boiler_entity.fire_glow.west.tint={r=1,g=0.6,b=0.6,a=0.4}
gf_boiler_entity.fire_glow.north.blend_mode = "additive-soft"
gf_boiler_entity.fire_glow.south.blend_mode = "additive-soft"
gf_boiler_entity.fire_glow.east.blend_mode = "additive-soft"
gf_boiler_entity.fire_glow.west.blend_mode = "additive-soft"


gf_boiler_item = util.table.deepcopy(data.raw.item.boiler)
gf_boiler_item.name = "gas-boiler"
gf_boiler_item.icon_size = 32
gf_boiler_item.icon = gd.."/graphics/icons/gas-boiler.png"
gf_boiler_item.order = "b[steam-power]-b[gas-boiler]"
gf_boiler_item.place_result = "gas-boiler"

gf_boiler_recipe = {
	type = "recipe",
	name = "gas-boiler",
	enabled = false,
	ingredients = {{
			"boiler",1
		},{
			"pump",1
	}},
	result = "gas-boiler"
}

data:extend({
	gf_boiler_item,
	gf_boiler_recipe,
	gf_boiler_entity
})
add_recipe_to_tech(
	"fluid-handling",
	"gas-boiler"
)
