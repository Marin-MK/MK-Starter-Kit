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
        color: Color::GREYBASE,
        shadow_color: Color::GREYSHADOW,
        windowskin: :choice,
        line_y_start: 0, # offset for this specific instance of the choicewindow
        line_y_space: 0, # offset for this specific instance of the choicewindow
        line_x_start: 0, # offset for this specific instance of the choicewindow
        small: false,
        viewport: nil)
    validate_array choices => String
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
        small => Boolean,
        viewport => [NilClass, Viewport]
    @choices = choices
    @initial_choice = initial_choice
    @cancel_choice = cancel_choice
    @visible_choices = visible_choices || @choices.size
    @can_loop = can_loop
    @windowskin = Windowskin.get(windowskin)
    @line_y_start = @windowskin.line_y_start + line_y_start
    @line_y_space = @windowskin.line_y_space + line_y_space
    @line_x_start = @windowskin.line_x_start + line_x_start
    @small = small
    c = [@choices.size, @visible_choices].min
    height = [@line_y_space * (c + 1), 96].max
    super(width, height, @windowskin, viewport)
    @text_width = @windowskin.get_text_width(width)
    @text_sprite.set_bitmap(@text_width, 18 + @line_y_space * c)
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
      @selector.x = self.x + @line_x_start - @selector.src_rect.width - 2
    end
  end

  def y=(value)
    super(value)
    @text_sprite.y = value + @line_y_start
    if @selector
      @selector.y = self.y + @line_y_start - (@small ? 0 : 2) + @line_y_space * @index
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
    for i in 0...@visible_choices
      @text_sprite.draw_text(
        y: @line_y_space * i,
        text: @choices[i],
        color: @color,
        shadow_color: @shadow_color,
        small: @small
      )
    end
    unless @selector
      @selector = SelectableSprite.new(@viewport)
      @selector.set_bitmap("gfx/misc/choice_arrow")
      @selector.x = self.x + @line_x_start - 2 - @selector.src_rect.width
      @selector.y = self.y + @line_y_start - (@small ? 0 : 2) + @line_y_space * @index
      @selector.z = self.z + 1
    end
  end

  def update(audio = true)
    return unless super()
    if Input.down?
      if @choices[@index + 1]
        self.set_index(@index + 1, audio)
      elsif @can_loop
        self.set_index(0, audio)
      end
    end
    if Input.up?
      if @index > 0
        self.set_index(@index - 1, audio)
      elsif @can_loop
        self.set_index(@choices.size - 1, audio)
      end
    end
    if Input.cancel? && !@cancel_choice.nil?
      Audio.se_play("audio/se/menu_select") if audio
      return @cancel_choice
    end
    if Input.confirm?
      Audio.se_play("audio/se/menu_select") if audio
      return @index
    end
  end

  def get_choice
    loop do
      System.update
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
    @selector.y = self.y + @line_y_start - (@small ? 0 : 2) + @line_y_space * @index
    Audio.se_play("audio/se/menu_select") if audio
  end

  def stop
    test_disposed
    @running = false
  end

  def dispose
    super
    @selector.dispose if @selector
  end
end
