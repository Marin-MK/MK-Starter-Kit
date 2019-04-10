class MessageWindow < BaseWindow
  attr_reader :text
  attr_reader :letter_by_letter

  def initialize(
        text: "",
        x: 0,
        y: 0,
        z: 0,
        width: 460,
        height: 84,
        windowskin: 1,
        viewport: nil,
        color: Color.new(48, 80, 200),
        shadow_color: Color.new(208, 208, 200),
        ending_arrow: false,
        letter_by_letter: true)
    validate text => String,
        x => Integer,
        y => Integer,
        z => Integer,
        width => Integer,
        height => Integer,
        windowskin => [Integer, NilClass, Windowskin],
        viewport => [NilClass, Viewport],
        color => Color,
        shadow_color => Color,
        ending_arrow => Boolean,
        letter_by_letter => Boolean
    @ending_arrow = ending_arrow
    @text_bitmap = Sprite.new(viewport)
    @text_bitmap.z = 99999
    @letter_by_letter = letter_by_letter
    super(width, height, windowskin, color, shadow_color, viewport)
    self.x = x
    self.y = y
    self.z = z
    self.text = text
  end

  def width=(value)
    super(value)
    @text_width = @windowskin.get_text_width(@width)
    @text_bitmap.bitmap = Bitmap.new(@text_width, 100)
  end

  def height=(value)
    super(value)
    @text_bitmap.bitmap = Bitmap.new(@text_width, 100)
  end

  def x=(value)
    super(value)
    @text_bitmap.x = value + @windowskin.line_x_start
  end

  def y=(value)
    super(value)
    @text_bitmap.y = value + @windowskin.line_y_start - 6
  end

  def z=(value)
    super(value)
    @text_bitmap.z = value
  end

  def visible=(value)
    super(value)
    @text_bitmap.visible = value
    @arrow.visible = value if @arrow
  end

  def letter_by_letter=(value)
    test_disposed
    validate value => Boolean
    @letter_by_letter = value
  end

  def text=(value)
    test_disposed
    @text = value.gsub(/{PLAYER}/, $trainer.name)
    @text_index = 0
    @line_index = 0
    @draw_counter = 0
    @current_line = 0
    @move_up_counter = 0
    @running = true
    @formatted_text = MessageWindow.get_formatted_text(@text_bitmap.bitmap, @text_width, @text).split("\n")
  end

  def update
    return unless super
    if @arrow
      @arrow_counter += 1
      if @arrow_counter == 32
        @arrow.y -= 2
      elsif @arrow_counter == 24
        @arrow.y += 2
      elsif @arrow_counter == 16
        @arrow.y += 2
      elsif @arrow_counter == 8
        @arrow.y -= 2
      end
      @arrow_counter = 0 if @arrow_counter == 32
    end
    @draw_counter_speed = 1
    if @move_up_counter > 0
      hide_arrow if @arrow && @arrow.visible
      @move_up_counter -= 1
      @text_bitmap.src_rect.y += @windowskin.line_y_space / 6.0
      @text_bitmap.src_rect.height -= @windowskin.line_y_space / 6.0
      @move_up_counter = -1 if @move_up_counter == 0
    elsif @move_up_counter == -1
      @current_line += 1
      @text_index = -1
      @draw_counter = -1
      @text_bitmap.src_rect.y = 0
      @text_bitmap.src_rect.height = @text_bitmap.bitmap.height
      @move_up_counter = 0
    end
    if @formatted_text[@line_index]
      if @line_index - @current_line < 2
        if @letter_by_letter
          if @move_up_counter == 0 && (Input.press?(Input::A) || Input.press?(Input::B))
            @draw_counter_speed = 3
          else
            @draw_counter_speed = 1
          end
          @draw_counter += 1
          if @draw_counter % (5 - @draw_counter_speed) == 0
            @text_index += 1
            if @text_index >= @formatted_text[@line_index].size
              @text_index = 0
              @line_index += 1
            end
            if @line_index - @current_line < 2 && @formatted_text[@line_index]
              @text_bitmap.bitmap.clear
              for i in @current_line..@line_index
                if i == @line_index
                  text = @formatted_text[i][0..@text_index]
                else
                  text = @formatted_text[i]
                end
                @text_bitmap.draw_text(
                    y: (i - @current_line) * @windowskin.line_y_space + 6,
                    text: text,
                    color: @color,
                    shadow_color: @shadow_color
                )
              end
            end
          end
        else # Not letter by letter
          @line_index = @current_line + 1
          @text_bitmap.bitmap.clear
          for i in @current_line..@line_index
            @text_bitmap.draw_text(
              y: (i - @current_line) * @windowskin.line_y_space + 6,
              text: @formatted_text[i],
              color: @color,
              shadow_color: @shadow_color
            )
          end
          @line_index = @current_line + 2
        end
      elsif @move_up_counter == 0
        show_arrow if !@arrow || !@arrow.visible
        if Input.trigger?(Input::A) || Input.trigger?(Input::B)
          @move_up_counter = 6
        end
      end
    else
      show_arrow if @ending_arrow && (!@arrow || !@arrow.visible)
      @running = false if Input.trigger?(Input::A)
    end
  end

  def show_arrow
    test_disposed
    unless @arrow
      @arrow = Sprite.new(@viewport)
      @arrow.bitmap = Bitmap.new("gfx/misc/message_window_arrow")
      @arrow.y = self.y + @windowskin.line_y_start + @windowskin.line_y_space + @arrow.bitmap.height - 10
      @arrow_counter = 0
    end
    @arrow.visible = true
    @arrow.x = self.x + @text_bitmap.bitmap.text_size(@formatted_text[@line_index - 1]).width + @windowskin.line_x_start
  end

  def hide_arrow
    test_disposed
    @arrow.visible = false
  end

  def dispose
    super
    @text_bitmap.dispose
    @arrow.dispose if @arrow
    @running = false
  end

  def self.get_formatted_text(bitmap, max_width, otxt)
    ntxt = ""
    last_word = ""
    for i in 0...otxt.size
      p, c, n = nil
      p = otxt[i - 1] if i > 0
      c = otxt[i]
      n = otxt[i + 1] if i < otxt.size - 1
      if c == ' ' || c == '-' || n.nil?
        test_string = (ntxt.split("\n").last || "") + last_word
        size = bitmap.text_size(test_string).width
        if size > max_width
          ntxt += "\n"
        end
        ntxt += last_word + c
        last_word = ""
      elsif c == '\n'
        ntxt += last_word + c
        last_word = ""
      else
        last_word << c
      end
    end
    return ntxt
  end
end

def show_message(text, color = Color::BLUE, ending_arrow = false)
  window = MessageWindow.new(
      text: text,
      x: 10,
      y: 224,
      z: 999999,
      width: 460,
      height: 84,
      windowskin: 1,
      color: color,
      ending_arrow: ending_arrow)
  while window.running?
    window.update
    Graphics.update
    Input.update
    $visuals.update(:no_events)
  end
  window.dispose
end
