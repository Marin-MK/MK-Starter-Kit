class ChoiceWindow < BaseWindow
  attr_reader :index

  def initialize(
        choices:,
        x: 0,
        y: 0,
        initial_choice: 0,
        cancel_choice: nil,
        visible_choices: 3,
        width: 220,
        color: Color::BLUE,
        shadow_color: Color::SHADOW,
        windowskin: 1,
        viewport: nil)
    validate_array choices => String
    validate x => Integer,
        y => Integer,
        initial_choice => Integer,
        cancel_choice => [NilClass, Integer],
        visible_choices => [NilClass, Integer],
        width => Integer,
        color => Color,
        shadow_color => Color,
        windowskin => [Integer, NilClass, Windowskin],
        viewport => [NilClass, Viewport]
    @choices = choices
    @initial_choice = initial_choice
    @cancel_choice = cancel_choice
    @visible_choices = visible_choices
    @index = initial_choice
    @text_bitmap = Sprite.new(viewport)
    @text_bitmap.z = 99999
    @windowskin = Windowskin.get(windowskin || 1)
    c = [@choices.size, visible_choices].min - 1
    @height = 24 + 32 * c + @windowskin.line_y_start + @windowskin.source_height - @windowskin.center.y - @windowskin.center.height
    @text_width = @windowskin.get_text_width(width)
    @text_bitmap.bitmap = Bitmap.new(@text_width, 18 + 32 * c)
    super(width, @height, @windowskin, color, shadow_color, viewport)
    self.x = x
    self.y = y
    draw_choices
  end

  def x=(value)
    super(value)
    @text_bitmap.x = value + @windowskin.line_x_start
    if @selector
      @selector.x = self.x + @windowskin.line_x_start - @selector.bitmap.width - 2
    end
  end

  def y=(value)
    super(value)
    @text_bitmap.y = value + @windowskin.line_y_start
    if @selector
      @selector.y = self.y + @windowskin.line_y_start - 2 + 32 * @index
    end
  end

  def draw_choices
    for i in 0...@visible_choices
      @text_bitmap.draw_text(
        y: 32 * i,
        text: @choices[i],
        color: @color,
        shadow_color: @shadow_color
      )
    end
    unless @selector
      @selector = Sprite.new(@viewport)
      @selector.bitmap = Bitmap.new("gfx/misc/choice arrow")
      @selector.x = self.x + @windowskin.line_x_start - @selector.bitmap.width - 2
      @selector.y = self.y + @windowskin.line_y_start - 2 + 32 * @index
    end
  end

  def update
    return unless super
    if Input.trigger?(Input::DOWN) && @choices[@index + 1]
      @index += 1
      @selector.y = self.y + @windowskin.line_y_start - 2 + 32 * @index
    end
    if Input.trigger?(Input::UP) && @index > 0
      @index -= 1
      @selector.y = self.y + @windowskin.line_y_start - 2 + 32 * @index
    end
    if Input.trigger?(Input::B) && !@cancel_choice.nil?
      @index = @cancel_choice
      @running = false
    end
    if Input.trigger?(Input::A)
      @running = false
    end
  end

  def dispose
    super
    @text_bitmap.dispose
    @selector.dispose if @selector
  end
end
