class BasicParticle
  attr_reader :bitmap
  attr_reader :x
  attr_reader :y
  attr_reader :angle
  attr_reader :zoom_x
  attr_reader :zoom_y
  attr_reader :opacity
  attr_reader :visible
  attr_reader :color

  attr_reader :start_x
  attr_reader :start_y
  attr_reader :start_z
  attr_reader :start_angle
  attr_reader :start_zoom_x
  attr_reader :start_zoom_y
  attr_reader :start_opacity
  attr_reader :start_color

  def initialize(viewport = nil)
    @sprite = Sprite.new(viewport)
    @x = @start_x = @sprite.x
    @y = @start_y = @sprite.y
    @z = @start_z = @sprite.z
    @angle = @start_angle = @sprite.angle
    @zoom_x = @start_zoom_x = @sprite.zoom_x
    @zoom_y = @start_zoom_y = @sprite.zoom_y
    @opacity = @start_opacity = @sprite.opacity
    @color = @start_color = @sprite.color
    @visible = @sprite.visible
    @cell = 0
    @i = 0
    @queue = []
    @start_wait = false
    @cell_width = nil
    @cell_height = nil
  end

  def get_value(arg)
    if arg.is_a?(Hash)
      if arg[:min] && arg[:max]
        float = arg[:min].is_a?(Float) || arg[:max].is_a?(Float)
        min = arg[:min]
        max = arg[:max]
        if float
          min = (min * 1000.0).round
          max = (max * 1000.0).round
        end
        value = rand(min..max)
        return value / 1000.0 if float
        return value
      else
        raise "Invalid argument."
      end
    end
    return arg
  end

  def create_bitmap(data)
    if data.is_a?(String)
      return Bitmap.new(data)
    elsif data.is_a?(Hash)
      bmp = Bitmap.new(data[:width], data[:height])
      bmp.fill_rect(0, 0, bmp.width, bmp.height, data[:color])
      return bmp
    elsif data.is_a?(Bitmap)
      return data
    else
      return Bitmap.new(data)
    end
  end

  def load_data(data)
    self.bitmap = create_bitmap(data[:bitmap])
    self.set_cell_width(data[:cell_width]) if data[:cell_width]
    self.set_cell_height(data[:cell_height]) if data[:cell_height]
    block = proc do
      for c in data[:commands]
        if c[:seconds].nil? && c[:stop].nil?
          raise "A particle command must specify a timespan in the ':seconds' key."
        end
        self.during(c[:seconds]) do
          for key in c.keys
            parse_key(c, key)
          end
        end
      end
    end
    start = data[:start]
    if start.is_a?(Hash)
      for key in start.keys
        parse_key(start, key, true)
      end
      if start[:seconds]
        @sprite.visible = false
        @start_wait = true
      end
    end
    if data[:repeat]
      self.repeat(&block)
    else
      block.call
    end
  end

  def parse_key(data, key, start = false)
    case key
    when :x
      if start
        self.start_x = get_value(data[:x])
      else
        self.x = get_value(data[:x])
      end
    when :y
      if start
        self.start_y = get_value(data[:y])
      else
        self.y = get_value(data[:y])
      end
    when :z
      if start
        self.start_z = get_value(data[:z])
      else
        self.z = get_value(data[:z])
      end
    when :translate_x, :translate_y
      if start
        raise "Command not available in the 'start' section of a particle animation."
      else
        self.translate(get_value(data[:translate_x] || 0), get_value(data[:translate_y] || 0))
      end
    when :angle
      if start
        self.start_angle = get_value(data[:angle])
      else
        self.angle = get_value(data[:angle])
      end
    when :rotate
      if start
        raise "Command not available in the 'start' section of a particle animation."
      else
        self.rotate(get_value(data[:rotate]))
      end
    when :zoom_x
      if start
        self.start_zoom_x = get_value(data[:zoom_x])
      else
        self.zoom_x = get_value(data[:zoom_x])
      end
    when :zoom_y
      if start
        self.start_zoom_y = get_value(data[:zoom_y])
      else
        self.zoom_y = get_value(data[:zoom_y])
      end
    when :scale
      if start
        self.start_zoom_x = get_value(data[:scale])
        self.start_zoom_y = get_value(data[:scale])
      else
        self.scale(get_value(data[:scale]))
      end
    when :opacity
      if start
        self.start_opacity = get_value(data[:opacity])
      else
        self.opacity = get_value(data[:opacity])
      end
    when :change_opacity
      if start
        raise "Command not available in the 'start' section of a particle animation."
      else
        self.change_opacity(get_value(data[:change_opacity]))
      end
    when :next_cell
      if start
        raise "Command not available in the 'start' section of a particle animation."
      else
        self.next_cell(get_value(data[:next_cell]))
      end
    when :set_cell
      if start
        self.start_set_cell(get_value(data[:set_cell]))
      else
        self.set_cell(get_value(data[:set_cell]))
      end
    when :visible
      if start
        self.start_opacity = get_value(data[:visible]) ? 255 : 0
      else
        self.visible = get_value(data[:visible])
      end
    when :color
      if start
        self.start_color = get_value(data[:color])
      else
        self.color = get_value(data[:color])
      end
    when :stop
      if start
        raise "Command not available in the 'start' section of a particle animation."
      else
        self.stop
      end
    when :seconds
      if start
        self.wait(get_value(data[:seconds]))
      end
    else
      raise "Invalid command '#{key}'"
    end
  end

  def start_x=(value)
    @sprite.x = value + (@sprite.bitmap ? @sprite.ox : 0)
    @x = value
  end

  def start_y=(value)
    @sprite.y = value + (@sprite.bitmap ? @sprite.oy : 0)
    @y = value
  end

  def start_z=(value)
    @sprite.z = value
    @z = value
  end

  def start_angle=(value)
    @sprite.angle = value
    @angle = value
  end

  def start_zoom_x=(value)
    @sprite.zoom_x = value
    @zoom_x = value
  end

  def start_zoom_y=(value)
    @sprite.zoom_y = value
    @zoom_y = value
  end

  def start_opacity=(value)
    @sprite.opacity = value
    @opacity = value
  end

  def start_color=(value)
    @sprite.color = value
    @color = value
  end

  def start_set_cell(value)
    update_cell(value)
  end

  def bitmap=(value)
    @sprite.bitmap = create_bitmap(value)
    @sprite.src_rect.width = @cell_width || @sprite.bitmap.width
    @sprite.src_rect.height = @cell_height || @sprite.bitmap.height
    @sprite.ox = @sprite.src_rect.width / 2
    @sprite.oy = @sprite.src_rect.height / 2
    @sprite.x += @sprite.ox
    @sprite.y += @sprite.oy
    @bitmap = value
  end

  def set_cell_width(value)
    @cell_width = value
    if @sprite.bitmap
      @sprite.src_rect.width = @cell_width
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.x = @sprite.ox
    end
  end

  def set_cell_height(value)
    @cell_height = value
    if @sprite.bitmap
      @sprite.src_rect.height = @cell_height
      @sprite.oy = @sprite.src_rect.height / 2
      @sprite.y = @sprite.oy
    end
  end

  def set_cell_size(width, height)
    set_cell_width(width)
    set_cell_height(height)
  end

  def x=(value)
    @queue.last[:start_x] = @sprite.x
    @queue.last[:x] = value - @x
    @x = value
  end

  def y=(value)
    @queue.last[:start_y] = @sprite.y
    @queue.last[:y] = value - @y
    @y = value
  end

  def z=(value)
    @queue.last[:start_z] = @sprite.z
    @queue.last[:z] = value - @z
    @z = value
  end

  def angle=(value)
    @queue.last[:start_angle] = @sprite.angle
    @queue.last[:angle] = value - @angle
    @angle = value
  end

  def zoom_x=(value)
    @queue.last[:start_zoom_x] = @sprite.zoom_x
    @queue.last[:zoom_x] = value - @zoom_x
    @zoom_x = value
  end

  def zoom_y=(value)
    @queue.last[:start_zoom_y] = @sprite.zoom_y
    @queue.last[:zoom_y] = value - @zoom_y
    @zoom_y = value
  end

  def opacity=(value)
    @queue.last[:start_opacity] = @sprite.opacity
    @queue.last[:opacity] = value - @opacity
    @opacity = value
  end

  def visible=(value)
    @queue.last[:visible] = value
    @visible = value
  end

  def color=(value)
    @queue.last[:color] = value
    @color = value
  end

  def translate(x, y)
    self.x += x
    self.y += y
  end

  def rotate(angle)
    self.angle += angle
  end

  def scale(arg1, arg2 = nil)
    if arg1 && arg2
      validate arg1 => Numeric, arg2 => Numeric
      self.zoom_x = arg1
      self.zoom_y = arg2
    elsif arg1
      validate arg1 => Numeric
      self.zoom_x = arg1
      self.zoom_y = arg1
    end
  end

  def change_opacity(value)
    self.opacity += value
  end

  def next_cell(value = 1)
    @queue.last[:next_cell] = value
  end

  def set_cell(value)
    @queue.last[:set_cell] = value
  end

  def stop
    @queue.last[:stop] = true
  end

  def start(&block)
    block.call
  end

  def during(seconds, &block)
    frames = (seconds.to_f * Graphics.frame_rate).round
    @queue << {frames: frames}
    block.call
  end

  def wait(seconds = nil)
    if seconds.nil? || seconds < 0
      @queue << {frames: -1}
    else
      frames = (seconds.to_f * Graphics.frame_rate).round
      @queue << {frames: frames}
    end
  end

  def repeat(&block)
    @repeat_block = block
    block.call
  end

  def next_command
    @repeat_block.call if @queue.empty? && @repeat_block
    if @queue.size > 0
      @queue[0][:start_x] = @sprite.x if @queue[0][:start_x]
      @queue[0][:start_y] = @sprite.y if @queue[0][:start_y]
      @queue[0][:start_z] = @sprite.z if @queue[0][:start_z]
      @queue[0][:start_angle] = @sprite.angle if @queue[0][:start_angle]
      @queue[0][:start_zoom_x] = @sprite.zoom_x if @queue[0][:start_zoom_x]
      @queue[0][:start_zoom_y] = @sprite.zoom_y if @queue[0][:start_zoom_y]
      @queue[0][:start_opacity] = @sprite.opacity if @queue[0][:start_opacity]
    end
    if @start_wait && !@sprite.visible
      @sprite.visible = true
      @start_wait = false
    end
  end

  def execute_command(args, oldfraction, fraction)
    @sprite.x = args[:start_x] + (args[:x] * fraction).round if args[:x]
    @sprite.y = args[:start_y] + (args[:y] * fraction).round if args[:y]
    @sprite.z = args[:start_z] + (args[:z] * fraction).round if args[:z]
    @sprite.angle = args[:start_angle] + (args[:angle] * fraction).round if args[:angle]
    @sprite.zoom_x = args[:start_zoom_x] + args[:zoom_x] * fraction if args[:zoom_x]
    @sprite.zoom_y = args[:start_zoom_y] + args[:zoom_y] * fraction if args[:zoom_y]
    @sprite.opacity = args[:start_opacity] + (args[:opacity] * fraction).round if args[:opacity]
    @sprite.color = args[:color] if args[:color]
    if !args[:visible].nil?
      @sprite.visible = args[:visible]
    end
    if args[:next_cell]
      next_cell = (oldfraction * args[:next_cell]).floor != (fraction * args[:next_cell]).floor
      if next_cell
        update_cell(@cell + 1)
      end
    end
    if args[:set_cell]
      update_cell(args[:set_cell])
    end
  end

  def update_cell(index)
    frames_wide = (@sprite.bitmap.width / @sprite.src_rect.width).ceil
    frames_high = (@sprite.bitmap.height / @sprite.src_rect.height).ceil
    @cell = index % (frames_wide * frames_high)
    @sprite.src_rect.x = (@cell % frames_wide.to_f) * @sprite.src_rect.width
    @sprite.src_rect.y = (@cell / frames_wide.to_f).floor * @sprite.src_rect.height
  end

  def update
    return if disposed?
    if @queue.size > 0
      args = @queue[0]
      if args[:frames] == 0 && args[:stop]
        dispose
        return
      elsif args[:frames] == -1
        @i += 1
      elsif @i >= args[:frames]
        @queue.delete_at(0)
        next_command
        @i = 0
      else
        @i += 1
        fraction = @i / args[:frames].to_f
        if args[:stop] && fraction == 1
          dispose
          return
        end
        execute_command(args, (@i - 1) / args[:frames].to_f, fraction)
      end
    end
  end

  def dispose
    @sprite.dispose
    @bitmap.dispose
    @queue.clear
    @repeat_block = nil
  end

  def disposed?
    return @sprite.disposed?
  end
end
