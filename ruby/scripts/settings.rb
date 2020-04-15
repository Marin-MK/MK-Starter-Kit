# How fast the player walks. The higher, the faster.
PLAYERWALKSPEED = 0.25

# How fast the player runs. The higher, the faster.
PLAYERRUNSPEED = 0.125

# Chance for a newly generated Pokemon to be shiny out of 65536.
# For example, a value of 8 means 1 / 8192 (8 / 65536).
SHINYCHANCE = 8


INITIAL_MONEY = 3000

# Used for the save folder name
GAME_NAME = "MK Starter Kit"

# The number of tiles a map should be away from the player's view to be loaded.
# If the map is closer than this number of tiles from the player, it will be loaded.
MAP_LOAD_BUFFER_HORIZONTAL = Graphics.width / 32 / 2 + 1
MAP_LOAD_BUFFER_VERTICAL = Graphics.height / 32 / 2 + 1

# The number of tiles a map should be away from the player's view to be unloaded.
# If the map is further than this number of tiles, it will be unloaded (if it was loaded to begin with)
# This may be controlled separately from the LOAD_BUFFER to avoid loading and unloading a map
# just by taking one single step. This avoids frequent reloading of the map by keeping the map
# cached until the player steps out of range.
# Useful if the player is going back and forth near the map edge a lot.
MAP_UNLOAD_BUFFER_HORIZONTAL = MAP_LOAD_BUFFER_HORIZONTAL + 3
MAP_UNLOAD_BUFFER_VERTICAL = MAP_LOAD_BUFFER_VERTICAL + 3
