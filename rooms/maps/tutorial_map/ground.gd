extends TileMapLayer

@onready var walls: TileMapLayer = $"../Wall"
@onready var decorate: TileMapLayer = $"../Decorate"

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return coords in walls.get_used_cells_by_id(1) || coords in decorate.get_used_cells_by_id(1)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
