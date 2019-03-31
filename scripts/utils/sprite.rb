Font.default_outline = false
Font.default_name = "Fire Red"
Font.default_size = 36

class Sprite
  def draw_text(*args)
    # {x:, y: , text:, color:, ...}
    args.each_with_index do |arg, idx|
      x = arg[:x] || 0
      y = arg[:y] || 0
      text = arg[:text]
      color = arg[:color] || Color.new(255, 255, 255)
      shadow_color = arg[:shadow_color]
      outline_color = arg[:outline_color]
      alignment = arg[:alignment] || :left
      validate x => Integer,
          y => Integer,
          text => String,
          color => Color,
          shadow_color => [NilClass, Color],
          outline_color => [NilClass, Color],
          alignment => [Symbol, Integer, String]
      y -= 8
      if shadow_color && outline_color
        if args.size > 1
          raise "Cannot draw text with both a shadow and an outline (draw operation #{i})."
        else
          raise "Cannot draw text with both a shadow and an outline."
        end
      end
      text_size = self.bitmap.text_size(text)
      x -= text_size.width if [:RIGHT, :right, "right", "RIGHT"].include?(alignment)
      x -= text_size.width / 2 if [:CENTER, :center, "center", "CENTER"].include?(alignment)
      if shadow_color
        self.bitmap.font.color = shadow_color
        self.bitmap.draw_text(x + 2, y, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x, y + 2, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x + 2, y + 2, text_size.width, text_size.height, text)
      end
      if outline_color
        self.bitmap.font.color = outline_color
        self.bitmap.draw_text(x + 2, y + 2, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x + 2, y - 2, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x + 2, y, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x - 2, y + 2, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x - 2, y - 2, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x - 2, y, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x, y + 2, text_size.width, text_size.height, text)
        self.bitmap.draw_text(x, y - 2, text_size.width, text_size.height, text)
      end
      self.bitmap.font.color = color
      self.bitmap.draw_text(x, y, text_size.width, text_size.height, text)
    end
  end

  def set_bitmap(*args)
    self.bitmap = Bitmap.new(*args)
  end

  def move_to(x, y, seconds)
    if sprite_moving?
      raise "The sprite is still being moved by an older #move_to call and can therefore not start another."
    end
    @move_sx = self.x
    @move_dx = x
    @move_sy = self.y
    @move_dy = y
    @move_frames = (seconds * Graphics.frame_rate).ceil
    @current_frame = 0
  end

  def sprite_moving?
    return @move_sx || @move_dx || @move_sy || @move_dy || @move_frames || @current_frame
  end

  def stop_movement
    @move_sx = nil
    @move_dx = nil
    @move_sy = nil
    @move_dy = nil
    @move_frames = nil
    @current_frame = nil
  end

  alias old_sprite_update update
  def update
    raise RGSSError, "disposed sprite" if disposed?
    old_sprite_update
    if sprite_moving?
      if @current_frame >= @move_frames
        stop_movement
      else
        @current_frame += 1
        diff_x = @move_dx - @move_sx
        increment_x = diff_x / @move_frames.to_f
        self.x = @move_sx + (increment_x * @current_frame).round
        diff_y = @move_dy - @move_sy
        increment_y = diff_y / @move_frames.to_f
        self.y = @move_sx + (increment_y * @current_frame).round
      end
    end
  end
end

=begin
s = Sprite.new
s.set_bitmap(100, 100)
s.bitmap.fill_rect(0, 0, 100, 100, Color.new(255, 0, 0))

t1 = Time.now

loop do
  Graphics.update
  Input.update
  oldmove = s.sprite_moving?
  s.update
  if !s.sprite_moving? && oldmove
    t2 = Time.now
    msgbox [s.x, s.y, t2 - t1].inspect
  end
  abort if Input.trigger?(Input::A) || Input.trigger?(Input::CTRL)
end
=end
