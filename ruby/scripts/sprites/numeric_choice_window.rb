class NumericChoiceWindow < BaseWindow
  def initialize(
      x: 0,
      y: 0,
      z: 0,
      width: 112,
      height: 96,
      digits: 3,
      min: 1,
      max: 999,
      start: 1,
      cancel_value: -1,
      viewport: nil,
      windowskin: :choice
    )
    validate x => Integer,
        y => Integer,
        z => Integer,
        width => Integer,
        height => Integer,
        digits => Integer,
        min => Integer,
        max => Integer,
        start => Integer,
        cancel_value => [Integer, NilClass],
        viewport => [Viewport, NilClass],
        windowskin => [Symbol, Integer, Windowskin]
    @digits = digits
    @min = min
    @max = max
    @start = start
    @value = @start
    @cancel_value = cancel_value
    super(width, height, windowskin, viewport)
    @up = ArrowSprite.new(:up, @viewport)
    @down = ArrowSprite.new(:down, @viewport)
    @text_bitmap = Sprite.new(@viewport)
    @text_bitmap.set_bitmap(self.width, self.height)
    self.x = x
    self.y = y
    self.z = z
    @i = 0
    draw_value
  end

  def x=(value)
    super(value)
    @up.x = value + 42
    @down.x = value + 42
    @text_bitmap.x = value
  end

  def y=(value)
    super(value)
    @up.y = value - 2
    @down.y = value + self.height - @down.bitmap.height + 2
    @text_bitmap.y = value
  end

  def z=(value)
    super(value)
    @up.z = value + 1
    @down.z = value + 1
    @text_bitmap.z = value + 1
  end

  def draw_value
    text = @value.to_s
    (@digits - text.length).times { text.prepend("0") }
    x = (self.width - @text_bitmap.text_size(text, true).width - 2) / 2 - 2
    @text_bitmap.bitmap.clear
    @text_bitmap.draw_text(
      {x: x,
       y: self.height / 2 - 6,
       text: text,
       color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200),
       small: true},
      {x: x,
       y: self.height / 2 - 8,
       text: "x",
       color: Color.new(96, 96, 96),
       shadow_color: Color.new(208, 208, 200),
       alignment: :right}
    )
  end

  def update
    super
    @up.update
    @down.update
    oldvalue = @value
    if Input.repeat_up?
      if @value < @max
        @value += 1
      else
        @value = @min
      end
    end
    if Input.repeat_down?
      if @value > @min
        @value -= 1
      else
        @value = @max
      end
    end
    if @value < @max && Input.repeat_right?
      @value = [@value + 10, @max].min
    end
    if @value > @min && Input.repeat_left?
      @value = [@value - 10, @min].max
    end
    if oldvalue != @value
      draw_value
      Audio.se_play("audio/se/menu_select")
    end
    if Input.confirm?
      Audio.se_play("audio/se/menu_select")
      return @value
    end
    if Input.cancel? && @cancel_value
      Audio.se_play("audio/se/menu_select")
      return @cancel_value
    end
  end

  def get_choice
    loop do
      Graphics.update
      Input.update
      oldvalue = @value
      value = self.update
      yield oldvalue, value if block_given?
      return value if value
    end
  end

  def dispose
    super
    @up.dispose
    @down.dispose
    @text_bitmap.dispose
  end
end
