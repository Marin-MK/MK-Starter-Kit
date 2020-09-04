class CellSprite < Sprite
  attr_reader :frame

  def initialize(viewport = nil)
    super(viewport)
    @frame = 0
  end

  def frame=(frame)
    @frame = frame % @frame_count
    self.src_rect.x = self.src_rect.width * (@frame % @horizontal_frames)
    self.src_rect.y = self.src_rect.height * (@frame.to_f / @horizontal_frames).floor
  end

  def set_cell(width, height)
    @cell_width = width
    @cell_height = height
    @frame = 0
    self.src_rect.set(0, 0, width, height)
    if self.bitmap
      @horizontal_frames = (self.bitmap.width / self.src_rect.width).ceil
      @vertical_frames = (self.bitmap.height / self.src_rect.height).ceil
      @frame_count = @horizontal_frames * @vertical_frames
    end
  end

  def bitmap=(bmp)
    update = self.bitmap.nil?
    super(bmp)
    if update && !self.bitmap.nil?
      @horizontal_frames = (self.bitmap.width / self.src_rect.width).ceil
      @vertical_frames = (self.bitmap.height / self.src_rect.height).ceil
      @frame_count = @horizontal_frames * @vertical_frames
    end
  end
end
