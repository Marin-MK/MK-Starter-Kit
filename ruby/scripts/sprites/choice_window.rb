class ChoiceWindow < BaseWindow
  attr_reader :index
  attr_reader :choices
  attr_accessor :color
  attr_accessor :shadow_color

  def initialize(
        choices:,
        x: 0,
        ox: :left,
        y: 0,
        oy: :right,
        z: 0,
        initial_choice: 0,
        cancel_choice: -1, # nil to disable cancelling
        visible_choices: nil, # as many as there are
        can_loop: true, # can or can't go from top to bottom and bottom to top
        width: 220,
        color: Color.new(96, 96, 96),
        shadow_color: Color.new(208, 208, 200),
        windowskin: 2,
        line_y_start: 0, # offset for this specific instance of the choicewindow
        line_y_space: 0, # offset for this specific instance of the choicewindow
        viewport: nil)
    validate_array choices => String
    validate x => Integer,
        ox => [Symbol, Integer],
        y => Integer,
        oy => [Symbol, Integer],
        z => Integer,
        initial_choice => Integer,
        cancel_choice => [NilClass, Integer],
        visible_choices => [NilClass, Integer],
        can_loop => Boolean,
        width => Integer,
        color => Color,
        shadow_color => Color,
        windowskin => [Integer, NilClass, Windowskin],
        line_y_start => Integer,
        line_y_space => Integer,
        viewport => [NilClass, Viewport]
    @choices = choices
    @initial_choice = initial_choice
    @cancel_choice = cancel_choice
    @visible_choices = visible_choices || @choices.size
    @can_loop = can_loop
    @text_bitmap = Sprite.new(viewport)
    @text_bitmap.z = z + 1
    @windowskin = Windowskin.get(windowskin)
    @line_y_start = @windowskin.line_y_start + line_y_start
    @line_y_space = @windowskin.line_y_space + line_y_space
    c = [@choices.size, @visible_choices].min - 1
    height = 24 + @line_y_space * c + @line_y_start + @windowskin.source_height - @windowskin.center.y - @windowskin.center.height
    height = [height, 92].max
    @text_width = @windowskin.get_text_width(width)
    @text_bitmap.set_bitmap(@text_width, 18 + @line_y_space * c)
    super(width, height, @windowskin, viewport)
    self.color = color
    self.shadow_color = shadow_color
    self.x = x
    if ox == :right || ox == :RIGHT
      self.x -= self.width
    elsif ox.is_a?(Integer)
      self.x -= ox
    end
    self.y = y
    if oy == :bottom || oy == :BOTTOM
      self.y -= self.height
    elsif oy.is_a?(Integer)
      self.y -= oy
    end
    self.z = z
    @index = initial_choice
    draw_choices
  end

  def x=(value)
    super(value)
    @text_bitmap.x = value + @windowskin.line_x_start
    if @selector
      @selector.x = self.x + @windowskin.line_x_start - @selector.src_rect.width - 2
    end
  end

  def y=(value)
    super(value)
    @text_bitmap.y = value + @line_y_start
    if @selector
      @selector.y = self.y + @line_y_start - 2 + @line_y_space * @index
    end
  end

  def visible=(value)
    super(value)
    @text_bitmap.visible = value
    if @selector
      @selector.visible = value
    end
  end

  def draw_choices
    test_disposed
    for i in 0...@visible_choices
      @text_bitmap.draw_text(
        y: @line_y_space * i,
        text: @choices[i],
        color: @color,
        shadow_color: @shadow_color
      )
    end
    unless @selector
      @selector = SelectableSprite.new(@viewport)
      @selector.set_bitmap("gfx/misc/choice_arrow")
      @selector.x = self.x + @windowskin.line_x_start - @selector.src_rect.width - 2
      @selector.y = self.y + @line_y_start - 2 + @line_y_space * @index
      @selector.z = self.z + 1
    end
  end

  def update
    return unless super
    if Input.down?
      if @choices[@index + 1]
        self.index += 1
      elsif @can_loop
        self.index = 0
      end
    end
    if Input.up?
      if @index > 0
        self.index -= 1
      elsif @can_loop
        self.index = @choices.size - 1
      end
    end
    if Input.cancel? && !@cancel_choice.nil?
      Audio.se_play("audio/se/menu_select")
      return @cancel_choice
    end
    if Input.confirm?
      Audio.se_play("audio/se/menu_select")
      return @index
    end
  end

  def get_choice
    loop do
      Graphics.update
      Input.update
      oldidx = @index
      cmd = self.update
      yield oldidx, @index if block_given?
      return @choices[cmd] if cmd
    end
  end

  def index=(value)
    if @index != value
      self.set_index(value, true)
    end
  end

  def set_index(value, audio = true)
    @index = value
    @selector.y = self.y + @line_y_start - 2 + @line_y_space * @index
    Audio.se_play("audio/se/menu_select") if audio
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
