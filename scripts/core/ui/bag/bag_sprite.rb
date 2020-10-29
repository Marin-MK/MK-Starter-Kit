class BagSprite < Sprite
  def initialize(gender, ui)
    @gender = gender
    @ui = ui
    super(@ui.viewport)
    pocket = $trainer.bag.last_pocket
    @suffix = ["_male", "_female"][$trainer.gender]
    self.bitmap = Bitmap.new(@ui.path + "bag" + @suffix)
    self.src_rect.width = self.bitmap.width / (Trainer::Bag::POCKETS.size + 1)
    self.ox = self.bitmap.width / 8
    self.oy = self.bitmap.height / 2
    self.z = 2
    @shadow = Sprite.new(@ui.viewport)
    @shadow.bitmap = Bitmap.new(@ui.path + "bag_shadow")
    @shadow.y = 96
    @shadow.z = 1
    pidx = Trainer::Bag::POCKETS.index(pocket)
    pidx = 0 if pidx < 1
    self.src_rect.x = self.src_rect.width * (pidx + 1)
  end

  def pocket=(value)
    self.src_rect.x = self.src_rect.width * (value + 1)
  end

  def x=(value)
    super(value + self.ox)
    @shadow.x = value
  end

  def y=(value)
    super(value + self.oy)
    @shadow.y = value + 96
  end

  def shake
    @i = 0
    self.angle = -2
  end

  def update
    super
    if @i
      @i += 1
      # One angle change takes 0.064 seconds and it can be interrupted.
      case @i
      when framecount(0.064 * 1)
        self.angle = 0
      when framecount(0.064 * 2)
        self.angle = 2
      when framecount(0.064 * 3)
        self.angle = -6
      when framecount(0.064 * 4)
        self.angle = 0
        @i = nil
      end
    end
  end
end
