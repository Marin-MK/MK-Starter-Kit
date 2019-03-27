class ChoiceWindow < BaseWindow
  attr_reader :index

  def initialize(
        choices:,
        x: 0,
        y: 0,
        initial_choice: 0,
        cancel_choice: nil,
        visible_choices: 3,
        can_loop: true,
        width: 220,
        color: Color.new(96, 96, 96),
        shadow_color: Color.new(208, 208, 200),
        windowskin: 2,
        viewport: nil)
    validate_array choices => String
    validate x => Integer,
        y => Integer,
        initial_choice => Integer,
        cancel_choice => [NilClass, Integer],
        visible_choices => [NilClass, Integer],
        can_loop => Boolean,
        width => Integer,
        color => Color,
        shadow_color => Color,
        windowskin => [Integer, NilClass, Windowskin],
        viewport => [NilClass, Viewport]
    @choices = choices
    @initial_choice = initial_choice
    @cancel_choice = cancel_choice
    @visible_choices = visible_choices
    @can_loop = can_loop
    @index = initial_choice
    @text_bitmap = Sprite.new(viewport)
    @text_bitmap.z = 99999
    @windowskin = Windowskin.get(windowskin || 1)
    c = [@choices.size, visible_choices].min - 1
    @height = 24 + @windowskin.line_y_space * c + @windowskin.line_y_start + @windowskin.source_height - @windowskin.center.y - @windowskin.center.height
    @text_width = @windowskin.get_text_width(width)
    @text_bitmap.bitmap = Bitmap.new(@text_width, 18 + @windowskin.line_y_space * c)
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
      @selector.y = self.y + @windowskin.line_y_start - 2 + @windowskin.line_y_space * @index
    end
  end

  def draw_choices
    test_disposed
    for i in 0...@visible_choices
      @text_bitmap.draw_text(
        y: @windowskin.line_y_space * i,
        text: @choices[i],
        color: @color,
        shadow_color: @shadow_color
      )
    end
    unless @selector
      @selector = Sprite.new(@viewport)
      @selector.bitmap = Bitmap.new("gfx/misc/choice arrow")
      @selector.x = self.x + @windowskin.line_x_start - @selector.bitmap.width - 2
      @selector.y = self.y + @windowskin.line_y_start - 2 + @windowskin.line_y_space * @index
    end
  end

  def update
    return unless super
    if Input.trigger?(Input::DOWN)
      if @choices[@index + 1]
        @index += 1
      elsif @can_loop
        @index = 0
      end
      @selector.y = self.y + @windowskin.line_y_start - 2 + @windowskin.line_y_space * @index
    end
    if Input.trigger?(Input::UP)
      if @index > 0
        @index -= 1
      elsif @can_loop
        @index = @choices.size - 1
      end
      @selector.y = self.y + @windowskin.line_y_start - 2 + @windowskin.line_y_space * @index
    end
    if Input.trigger?(Input::B) && !@cancel_choice.nil?
      return @cancel_choice
    end
    if Input.trigger?(Input::A)
      return @index
    end
  end

  def stop
    test_disposed
    @running = false
  end

  def dispose
    super
    @text_bitmap.dispose
    @selector.dispose if @selector
  end
end
