class SplitSprite
  attr_accessor :width
  attr_accessor :height

  def initialize(viewport = nil)
    @viewport = viewport
    @width = 64
    @height = 64
    @sprite = Sprite.new(@viewport)
  end

  def method_missing(name, *args)
    if @sprite.respond_to?(name)
      @sprite.method(name).call(*args)
    else
      super(name, *args)
    end
  end

  def refresh
    self.set(@file, @center)
  end

  def set?
    return @file && @center
  end

  def set(file, center = nil)
    validate file => [String, Windowskin], center => [Rect, Array, NilClass]
    if file.is_a?(Windowskin)
      center = file.center
      file = "gfx/windowskins/" + file.filename
    end
    center = Rect.new(*center) if center.is_a?(Array)
    @file = file
    @center = center
    bmp = Bitmap.new(@width, @height)
    src = Bitmap.new(@file)
    if @width == src.width && @height == src.height
      @sprite.set_bitmap(src)
      return
    elsif @width < src.width || @height < src.height
      raise "Width and height can't be lower than the source width and height."
    end

    # top left corner
    tlw = center.x
    tlh = center.y
    bmp.blt(0, 0, src, Rect.new(0, 0, tlw, tlh))

    # bottom left corner
    bly = center.y + center.height
    blw = center.x
    blh = src.height - center.y - center.height
    bmp.blt(0, @height - blh, src, Rect.new(0, bly, blw, blh))

    # top right corner
    trx = center.x + center.width
    trw = src.width - center.x - center.width
    trh = center.y
    bmp.blt(@width - trw, 0, src, Rect.new(trx, 0, trw, trh))

    # bottom right corner
    brx = center.x + center.width
    bry = center.y + center.height
    brw = src.width - center.x - center.width
    brh = src.height - center.y - center.height
    bmp.blt(@width - brw, @height - brh, src, Rect.new(brx, bry, brw, brh))

    # Space between top left and bottom left
    space_left = @height - tlh - blh
    i = nil
    for i in 0...(space_left / center.height.to_f).floor
      bmp.blt(0, tlh + i * center.height, src, Rect.new(0, center.y, center.x, center.height))
    end
    frac_left = (space_left / center.height.to_f) % 1
    bmp.blt(0, tlh + (i + 1) * center.height, src, Rect.new(0, center.y, center.x, (center.height * frac_left).round))

    # Space between top right and bottom right
    space_right = @height - trh - brh
    for i in 0...(space_right / center.height.to_f).floor
      bmp.blt(@width - trw, trh + i * center.height, src, Rect.new(center.x + center.width, center.y, center.x, center.height))
    end
    frac_right = (space_right / center.height.to_f) % 1
    bmp.blt(@width - trw, trh + (i + 1) * center.height, src, Rect.new(center.x + center.width, center.y, center.x, (center.height * frac_right).round))

    # Space between top left and top right
    space_top = @width - tlw - trw
    for i in 0...(space_top / center.width.to_f).floor
      bmp.blt(tlw + i * center.width, 0, src, Rect.new(center.x, 0, center.width, src.height - center.y - center.height))
    end
    frac_top = (space_top / center.width.to_f) % 1
    bmp.blt(tlw + (i + 1) * center.width, 0, src, Rect.new(center.x, 0, (center.width * frac_top).round, src.height - center.y - center.height))

    # Space between bottom left and bottom right
    space_bottom = @width - blw - brw
    for i in 0...(space_bottom / center.width.to_f).floor
      bmp.blt(blw + i * center.width, @height - blh, src, Rect.new(center.x, center.y + center.height, center.width, src.height - center.y - center.height))
    end
    frac_bottom = (space_bottom / center.width.to_f) % 1
    bmp.blt(blw + (i + 1) * center.width, @height - blh, src, Rect.new(center.x, center.y + center.height, (center.width * frac_bottom).round, src.height - center.y - center.height))

    # Space in the middle. Has to be drawn first since this may overlap with the sides or corners.
    space_middle_height = @height - tlh - blh
    space_middle_width = @width - tlw - trw
    y = nil
    for y in 0...(space_middle_height / center.height.to_f).floor
      x = nil
      for x in 0...(space_middle_width / center.width.to_f).floor
        bmp.blt(tlw + x * center.width, tlh + y * center.height, src, center)
      end
      frac_x = (space_middle_width / center.width.to_f) % 1
      bmp.blt(tlw + (x + 1) * center.width, tlh + y * center.height, src, Rect.new(center.x, center.y, (center.width * frac_x).round, center.height))
    end
    frac_y = (space_middle_height / center.height.to_f) % 1
    if frac_y > 0
      x = nil
      for x in 0...(space_middle_width / center.width.to_f).floor
        bmp.blt(tlw + x * center.width, tlh + (y + 1) * center.height, src, Rect.new(center.x, center.y, center.width, (center.height * frac_y).round))
      end
      frac_x = (space_middle_width / center.width.to_f) % 1
      bmp.blt(tlw + (x + 1) * center.width, tlh + y * center.height, src, Rect.new(center.x, center.y, (center.width * frac_x).round, (center.height * frac_y).round))
    end
    bmp.blt(tlw + (x + 1) * center.width, tlh + (y + 1) * center.height, src, Rect.new(center.x, center.y, (center.width * frac_x).round, (center.height * frac_y).round))

    @sprite.set_bitmap(bmp)
  end
end
