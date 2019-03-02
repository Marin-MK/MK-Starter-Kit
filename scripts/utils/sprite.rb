class Sprite
  def draw_text(x: 0, y: 0, text:, color: Color.new(255, 255, 255), shadow_color: nil, outline_color: nil, alignment: :left, clear: false)
    validate x => Integer,
        y => Integer,
        text => String,
        color => Color,
        shadow_color => [NilClass, Color],
        outline_color => [NilClass, Color],
        alignment => [Symbol, Integer, String]
    alignment = 0 if [:LEFT, :left, "left", "LEFT"].include?(alignment)
    alignment = 1 if [:CENTER, :center, "center", "CENTER"].include?(alignment)
    alignment = 2 if [:RIGHT, :right, "right", "RIGHT"].include?(alignment)
    raise "Cannot draw text with both a shadow and an outline." if shadow_color && outline_color
    self.bitmap.clear if clear
    text_size = self.bitmap.text_size(text)
    if shadow_color
      self.bitmap.font.color = shadow_color
      self.bitmap.draw_text(x + 2, y, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x, y + 2, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x + 2, y + 2, text_size.width, text_size.height, text, alignment)
    end
    if outline_color
      self.bitmap.font.color = outline_color
      self.bitmap.draw_text(x + 2, y + 2, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x + 2, y - 2, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x + 2, y, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x - 2, y + 2, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x - 2, y - 2, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x - 2, y, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x, y + 2, text_size.width, text_size.height, text, alignment)
      self.bitmap.draw_text(x, y - 2, text_size.width, text_size.height, text, alignment)
    end
    self.bitmap.font.color = color
    self.bitmap.draw_text(x, y, text_size.width, text_size.height, text, alignment)
  end
end
