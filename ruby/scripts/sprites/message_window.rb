class MessageWindow < BaseWindow
  attr_reader :text
  attr_reader :letter_by_letter
  attr_accessor :color
  attr_accessor :shadow_color
  attr_reader :cmdwin
  attr_accessor :ending_arrow

  def initialize(
        text: "",
        x: 0,
        y: 0,
        z: 0,
        width: 480,
        height: 96,
        visible: true,
        windowskin: :speech,
        viewport: nil,
        color: Color::GREYBASE,
        shadow_color: Color::GREYSHADOW,
        ending_arrow: false,
        letter_by_letter: true,
        line_y_start: 0, # offset for this specific instance of the messagewindow
        line_y_space: 0, # offset for this specific instance of the messagewindow
        line_x_start: 0, # offset for this specific instance of the messagewindow
        cmdwin: nil,
        update: nil)
    validate \
        text => String,
        x => Integer,
        y => Integer,
        z => Integer,
        width => Integer,
        height => Integer,
        visible => Boolean,
        windowskin => [Symbol, Integer, NilClass, Windowskin],
        viewport => [NilClass, Viewport],
        color => Color,
        shadow_color => Color,
        ending_arrow => Boolean,
        letter_by_letter => Boolean,
        cmdwin => [NilClass, ChoiceWindow],
        update => [NilClass, Proc]
    @ending_arrow = ending_arrow
    @text_bitmap = Sprite.new(viewport)
    @text_bitmap.z = 99999
    @letter_by_letter = letter_by_letter
    @cmdwin = cmdwin
    @update = update
    @cmdwin.visible = false if @cmdwin
    super(width, height, windowskin, viewport)
    @line_y_start = @windowskin.line_y_start + line_y_start
    @line_y_space = @windowskin.line_y_space + line_y_space
    @line_x_start = @windowskin.line_x_start + line_x_start
    self.color = color
    self.shadow_color = shadow_color
    self.x = x
    self.y = y
    self.z = z
    self.text = text || ""
    self.visible = visible
  end

  def width=(value)
    super(value)
    @text_width = @windowskin.get_text_width(@width)
    @text_bitmap.set_bitmap(@text_width + 2, 96)
  end

  def height=(value)
    super(value)
    @text_bitmap.set_bitmap(@text_width + 2, 96)
  end

  def x=(value)
    super(value)
    @text_bitmap.x = value + @line_x_start
  end

  def y=(value)
    super(value)
    @text_bitmap.y = value + @line_y_start - 6
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
    @arrow.dispose if @arrow
    @arrow = nil
    @formatted_text = MessageWindow.get_formatted_text(@text_bitmap.bitmap, @text_width, @text).split("\n")
    self.update if !@letter_by_letter
  end

  def cmdwin=(value)
    validate value => [ChoiceWindow, NilClass]
    @cmdwin = value
    @cmdwin.visible = false if @cmdwin
  end

  def update
    return unless super
    self.visible = true if !self.visible
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
    @update.call if @update.is_a?(Proc)
    @draw_counter_speed = 1
    if @move_up_counter > 0
      hide_arrow if @arrow && @arrow.visible
      @move_up_counter -= 1
      @text_bitmap.src_rect.y += @line_y_space / 6.0
      @text_bitmap.src_rect.height -= @line_y_space / 6.0
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
          if @move_up_counter == 0 && (Input.press_confirm? || Input.press_cancel?)
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
                    y: (i - @current_line) * @line_y_space + 6,
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
              y: (i - @current_line) * @line_y_space + 6,
              text: @formatted_text[i],
              color: @color,
              shadow_color: @shadow_color
            )
          end
          @line_index = @current_line + 2
        end
      elsif @move_up_counter == 0
        show_arrow if !@arrow || !@arrow.visible
        if Input.confirm? || Input.cancel?
          @move_up_counter = 6
        end
      end
    else
      show_arrow if @ending_arrow && (!@arrow || !@arrow.visible)
      if @cmdwin
        @cmdwin.visible = true if !@cmdwin.visible
        cmd = @cmdwin.update
        if cmd
          @running = false
          return cmd
        end
      elsif Input.confirm?
        @running = false
      end
    end
  end

  def set_cmdwin(cmdwin = nil)
    if cmdwin.is_a?(Array) || cmdwin.nil? # Array of choices or ["YES", "NO"] by default
      self.cmdwin = ChoiceWindow.new(
        x: 448,
        ox: :right,
        y: 224,
        oy: :bottom,
        z: 2,
        choices: cmdwin ? cmdwin : ["YES", "NO"],
        width: 128,
        viewport: @viewport,
        windowskin: :choice,
        line_y_space: -4
      )
    else
      self.cmdwin = cmdwin
    end
  end

  def show(text = nil)
    self.text = text if text
    ret = nil
    while self.running?
      Input.update
      ret = self.update
      Graphics.update
      yield if block_given?
      $visuals.update(:no_events)
    end
    Audio.se_play("audio/se/menu_select") if !@cmdwin
    return ret && @cmdwin ? @cmdwin.choices[ret] : ret
  end

  def show_confirm(text = nil)
    self.text = text if text
    self.set_cmdwin(["YES", "NO"]) if !@cmdwin
    ret = self.show
    self.cmdwin.dispose
    self.cmdwin = nil
    return ret == "YES"
  end

  def show_arrow
    test_disposed
    unless @arrow
      @arrow = Sprite.new(@viewport)
      @arrow.set_bitmap("gfx/misc/message_window_arrow")
      @arrow.y = self.y + @line_y_start + @line_y_space + @arrow.bitmap.height - 10
      @arrow.z = self.z + 1
      @arrow_counter = 0
    end
    @arrow.visible = true
    @arrow.x = self.x + @text_bitmap.bitmap.text_size(@formatted_text[@line_index - 1]).width + @line_x_start
  end

  def hide_arrow
    test_disposed
    @arrow.visible = false
  end

  def dispose
    super
    @text_bitmap.dispose
    @arrow.dispose if @arrow
    @cmdwin.dispose if @cmdwin && !@cmdwin.disposed?
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
        last_section = ntxt.include?("\n") ? ntxt.slice(ntxt.rindex("\n") + 1..-1) : ntxt
        test_string = (last_section || "") + last_word
        size = bitmap.text_size(test_string).width
        if size > max_width
          ntxt += "\n"
        end
        ntxt += last_word + c
        last_word = ""
      elsif c == "\n"
        ntxt += last_word + c
        last_word = ""
      else
        last_word << c
      end
    end
    return ntxt
  end
end

def create_message_window(text = "")
  validate text => [String, NilClass]
  return MessageWindow.new(
      text: text,
      y: 224,
      z: 999999,
      width: 480,
      height: 96,
      windowskin: :speech
  )
end

def show_message(text)
  validate text => String
  window = create_message_window(text)
  ret = window.show
  window.dispose
  return ret
end

def show_confirm(text)
  validate text => String
  window = create_message_window(text)
  window.set_cmdwin(["YES", "NO"])
  ret = window.show_confirm
  window.dispose
  return ret
end
