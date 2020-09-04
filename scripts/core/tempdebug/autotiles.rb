#temp

sand = MKD::Autotile.new(1)
sand.name = "Sand"
sand.graphic_name = "sand"
sand.format = :legacy
sand.passabilities = [15] * 48
sand.tags = [nil] * 48
sand.priorities = [0] * 48
sand.save

water = MKD::Autotile.new(2)
water.name = "Water"
water.graphic_name = "water"
water.format = :legacy
water.passabilities = [15] * 48
water.tags = [nil] * 48
water.priorities = [0] * 48
water.animate_speed = 20
water.save

flower = MKD::Autotile.new(3)
flower.name = "Flower"
flower.graphic_name = "flower"
flower.format = :single
flower.passabilities = [15] * 48
flower.tags = [nil] * 48
flower.priorities = [0] * 48
flower.animate_speed = 10
flower.save

template = MKD::Autotile.new(4)
template.name = "Template"
template.graphic_name = "template"
template.format = :full_corners
template.passabilities = [15] * 48
template.tags = [0] * 48
template.priorities = [0] * 48
template.save
