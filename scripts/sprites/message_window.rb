Font.default_outline = false
Font.default_name = "Pokemon Fire Red"
Font.default_size = 36

class MessageWindow
  attr_reader :width
  attr_reader :height
  attr_reader :windowskin
  attr_reader :text
  attr_reader :viewport

  def initialize(width = 96, height = 96, windowskin = 1, text = "", viewport = nil)
    validate width => Integer,
        height => Integer,
        windowskin => [Integer, NilClass, Windowskin],
        text => String,
        viewport => [NilClass, Viewport]
    @width = width
    @height = height
    @windowskin = Windowskin.get(windowskin || 1)
    @viewport = viewport
    @window = SplitSprite.new(@viewport)
    @window.width = @width
    @window.height = @height
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center)
    @text_bitmap = Sprite.new(@viewport)
    @text_bitmap.z = 99999
    @text_bitmap.bitmap = Bitmap.new(@width, @height)
    @text_width = @windowskin.get_text_width(@width)
    @running = false
    self.text = text
  end

  def width=(value)
    validate value => Integer
    @window.width = value
    @width = value
    @text_bitmap.bitmap = Bitmap.new(@text_width, 100)
  end

  def height=(value)
    validate value => Integer
    @window.height = value
    @height = value
    @text_bitmap.bitmap = Bitmap.new(@text_width, 100)
  end

  def windowskin=(value)
    validate value => [Integer, Windowskin]
    @windowskin = Windowskin.get(value)
    @window.set("gfx/windowskins/" + @windowskin.filename, @windowskin.center)
  end

  def viewport=(value)
    @window.viewport = value
  end

  def x
    return @window.x
  end

  def x=(value)
    @window.x = value
    @text_bitmap.x = value + @windowskin.line_x_start
  end

  def y
    return @window.y
  end

  def y=(value)
    @window.y = value
    @text_bitmap.y = value + @windowskin.line_y_start
  end

  def text=(value)
    @text = value
    @text_index = 0
    @line_index = 0
    @draw_counter = 0
    @current_line = 0
    @move_up_counter = 0
    @running = true
    @formatted_text = MessageWindow.get_formatted_text(@text_bitmap.bitmap, @text_width, @text).split("\n")
  end

  def update
    return unless @running
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
                  y: (i - @current_line) * @windowskin.line_y_space,
                  text: text,
                  color: Color.new(224, 8, 8),
                  shadow_color: Color.new(208, 208, 200)
              )
            end
          end
        end
      elsif @move_up_counter == 0
        show_arrow if !@arrow || !@arrow.visible
        if Input.trigger?(Input::A) || Input.trigger?(Input::B)
          @move_up_counter = 6
        end
      end
    elsif Input.trigger?(Input::A)
      @running = false
    end
  end

  def show_arrow
    unless @arrow
      @arrow = Sprite.new(@viewport)
      @arrow.bitmap = Bitmap.new("gfx/misc/message window arrow")
      @arrow.y = self.y + @windowskin.line_y_start + @windowskin.line_y_space + @arrow.bitmap.height - 4
      @arrow_counter = 0
    end
    @arrow.visible = true
    @arrow.x = self.x + @text_bitmap.bitmap.text_size(@formatted_text[@line_index - 1]).width + @windowskin.line_x_start
  end

  def hide_arrow
    @arrow.visible = false
  end

  def dispose
    @text_bitmap.dispose
    @window.dispose
    @running = false
  end

  def running?
    return @running
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
