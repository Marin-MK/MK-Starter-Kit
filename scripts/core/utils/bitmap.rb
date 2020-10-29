Font.default_outline = false
Font.default_name = "fire_red"
Font.default_size = 32

class Bitmap
  alias original_draw_text draw_text
  def draw_text(*args)
    # {x:, y: , text:, color:, ...}
    args.each_with_index do |arg, idx|
      x = arg[:x] || 0
      y = arg[:y] || 0
      text = arg[:text]
      color = arg[:color] || Color::WHITE
      shadow_color = arg[:shadow_color]
      outline_color = arg[:outline_color]
      alignment = arg[:alignment] || arg[:align] || :left
      small = arg[:small] || false
      validate \
          x => Integer,
          y => Integer,
          text => String,
          color => Color,
          shadow_color => [NilClass, Color],
          outline_color => [NilClass, Color],
          alignment => [Symbol, Integer, String],
          small => Boolean
      y -= 8
      fontname = self.font.name
      if small
        self.font.name = "fire_red_small"
      end
      if shadow_color && outline_color
        if args.size > 1
          raise "Cannot draw text with both a shadow and an outline (draw operation #{i})."
        else
          raise "Cannot draw text with both a shadow and an outline."
        end
      end
      text_size = self.text_size(text)
      x -= text_size.width if [:RIGHT, :right, "right", "RIGHT"].include?(alignment)
      x -= text_size.width / 2 if [:CENTER, :center, "center", "CENTER", :MID, :mid, "mid", "MID", :MIDDLE, :middle, "middle", "MIDDLE"].include?(alignment)
      if shadow_color
        self.font.color = shadow_color
        original_draw_text(x + 2, y, text_size.width, text_size.height, text)
        original_draw_text(x, y + 2, text_size.width, text_size.height, text)
        original_draw_text(x + 2, y + 2, text_size.width, text_size.height, text)
      end
      if outline_color
        self.font.color = outline_color
        original_draw_text(x + 2, y + 2, text_size.width, text_size.height, text)
        original_draw_text(x + 2, y - 2, text_size.width, text_size.height, text)
        original_draw_text(x + 2, y, text_size.width, text_size.height, text)
        original_draw_text(x - 2, y + 2, text_size.width, text_size.height, text)
        original_draw_text(x - 2, y - 2, text_size.width, text_size.height, text)
        original_draw_text(x - 2, y, text_size.width, text_size.height, text)
        original_draw_text(x, y + 2, text_size.width, text_size.height, text)
        original_draw_text(x, y - 2, text_size.width, text_size.height, text)
      end
      self.font.color = color
      original_draw_text(x, y, text_size.width, text_size.height, text)
      self.font.name = fontname
    end
  end
end
