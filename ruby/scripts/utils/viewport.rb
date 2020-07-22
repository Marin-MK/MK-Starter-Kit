class Viewport
  alias old_init initialize
  # Alias to make the default arguments (0,0,System.width,System.height).
  def initialize(x = 0, y = 0, width = System.width, height = System.height)
    old_init(x, y, width, height)
  end
end
