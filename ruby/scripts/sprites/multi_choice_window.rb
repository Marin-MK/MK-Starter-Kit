class MultiChoiceWindow < BaseWindow
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
        width:,
        height:,
        color: Color::GREYBASE,
        shadow_color: Color::GREYSHADOW,
        windowskin: :choice,
        line_y_start: 0, # offset for this specific instance of the choicewindow
        line_y_space: 0, # offset for this specific instance of the choicewindow
        line_x_start: 0, # offset for this specific instance of the choicewindow
        line_x_space:, # the space between two horizontal options
        arrow_path: "gfx/misc/choice_arrow",
        arrow_states: 2,
        small: false,
        viewport: nil)
    validate_array choices => Array
    validate \
        x => Integer,
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
        windowskin => [Symbol, Integer, NilClass, Windowskin],
        line_y_start => Integer,
        line_y_space => Integer,
        line_x_start => Integer,
        line_x_space => Integer,
        arrow_path => String,
        arrow_states => Integer,
        small => Boolean,
        viewport => [NilClass, Viewport]
    @choices = choices
    @initial_choice = initial_choice
    @cancel_choice = cancel_choice
    @can_loop = can_loop
    @windowskin = Windowskin.get(windowskin)
    @line_y_start = @windowskin.line_y_start + line_y_start
    @line_y_space = @windowskin.line_y_space + line_y_space
    @line_x_start = @windowskin.line_x_start + line_x_start
    @line_x_space = line_x_space
    @arrow_path = arrow_path
    @arrow_states = arrow_states
    @small = small
    super(width, height, @windowskin, viewport)
    @text_width = @windowskin.get_text_width(width)
    @text_sprite.set_bitmap(width, height)
    @text_sprite.z = z + 1
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
    @text_sprite.x = value + @line_x_start
    if @selector
      @selector.x = self.x + @line_x_start - 2 + @line_x_space * (@index % 2) - @selector.bitmap.width
    end
  end

  def y=(value)
    super(value)
    @text_sprite.y = value + @line_y_start
    if @selector
      @selector.y = self.y + @line_y_start - (@small ? 0 : 2) + @line_y_space * (@index / 2.0).floor
    end
  end

  def visible=(value)
    super(value)
    @text_sprite.visible = value
    if @selector
      @selector.visible = value
    end
  end

  def draw_choices
    test_disposed
    for y in 0...@choices.size
      for x in 0...@choices[y].size
        @text_sprite.draw_text(
          x: @line_x_space * x,
          y: @line_y_space * y,
          text: @choices[y][x],
          color: @color,
          shadow_color: @shadow_color,
          small: @small
        )
      end
    end
    unless @selector
      @selector = SelectableSprite.new(@viewport)
      @selector.set_bitmap(@arrow_path, @arrow_states)
      @selector.x = self.x + @line_x_start - 2 + @line_x_space * (@index % 2) - @selector.bitmap.width
      @selector.y = self.y + @line_y_start - (@small ? 0 : 2) + @line_y_space * (@index / 2.0).floor
      @selector.z = self.z + 1
    end
  end

  def update
    return unless super
    if Input.down?
      if @index < 2
        self.index += 2
      elsif @can_loop
        self.index %= 2
      end
    end
    if Input.up?
      if @index > 1
        self.index -= 2
      elsif @can_loop
        self.index = @choices.size - self.index % 2
      end
    end
    if Input.right?
      if @index % 2 == 0
        self.index += 1
      elsif @can_loop
        self.index -= 1
      end
    end
    if Input.left?
      if @index % 2 == 1
        self.index -= 1
      elsif @can_loop
        self.index += 1
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
    @selector.x = self.x + @line_x_start - 2 + @line_x_space * (@index % 2) - @selector.bitmap.width
    @selector.y = self.y + @line_y_start - (@small ? 0 : 2) + @line_y_space * (@index / 2.0).floor
    Audio.se_play("audio/se/menu_select") if audio
  end

  def stop
    test_disposed
    @running = false
  end

  def dispose
    super
    @text_sprite.dispose
    @selector.dispose if @selector
  end
end
