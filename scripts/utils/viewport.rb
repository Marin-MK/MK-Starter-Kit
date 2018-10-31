class Viewport
  alias old_init initialize
  def initialize(x = 0, y = 0, width = Graphics.width, height = Graphics.height)
    old_init(x, y, width, height)
  end
end