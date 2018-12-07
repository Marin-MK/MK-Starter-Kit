class Viewport
  alias old_init initialize
  # Alias to make the default arguments (0,0,Graphics.width,Graphics.height).
  def initialize(x = 0, y = 0, width = Graphics.width, height = Graphics.height)
    old_init(x, y, width, height)
  end
end