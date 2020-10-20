class Battle
  class LevelUpWindow < BaseWindow
    # Creates a window for displaying 6 stats.
    # @param viewport [Viewport] the viewport of the window.
    def initialize(viewport)
      validate viewport => [NilClass, Viewport]
      # Creates a window with fixed parameters.
      super(192, 208, Windowskin.get(:choice), viewport)
      # Draws the names of the stats.
      draw_stat_names
    end

    # Draws the names of the stats.
    def draw_stat_names
      color = Color.new(72, 72, 72)
      shadow = Color::GREYSHADOW
      self.draw_text(x: 16, y: 22, text: "MAX.", color: color, shadow_color: shadow, small: true)
      self.draw_text(x: 68, y: 22, text: "HP", color: color, shadow_color: shadow)
      self.draw_text(x: 16, y: 52, text: "ATTACK", color: color, shadow_color: shadow)
      self.draw_text(x: 16, y: 82, text: "DEFENSE", color: color, shadow_color: shadow)
      self.draw_text(x: 16, y: 112, text: "SP. ATK", color: color, shadow_color: shadow)
      self.draw_text(x: 16, y: 142, text: "SP. DEF", color: color, shadow_color: shadow)
      self.draw_text(x: 16, y: 172, text: "SPEED", color: color, shadow_color: shadow)
    end

    # Draws the given stats as an increase.
    # @param array [Array<Integer>] the stat increases to draw.
    def show_increase(array)
      validate_array array => Integer
      color = Color.new(72, 72, 72)
      shadow = Color::GREYSHADOW
      for i in 0...6
        self.draw_text(x: 130, y: 24 + 30 * i, text: "+", color: color, shadow_color: shadow)
        self.draw_text(x: 176, y: 22 + 30 * i, text: array[i].to_s, color: color, shadow_color: shadow, align: :right)
      end
    end

    # Draws the total new stats.
    # @param array [Array<Integer>] the stats to draw.
    def show_stats(array)
      validate_array array => Integer
      self.clear
      draw_stat_names
      color = Color.new(72, 72, 72)
      shadow = Color::GREYSHADOW
      for i in 0...6
        self.draw_text(x: 176, y: 22 + 30 * i, text: array[i].to_s, color: color, shadow_color: shadow, align: :right)
      end
    end
  end
end
