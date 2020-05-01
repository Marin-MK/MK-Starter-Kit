class Battle
  class LevelUpWindow < BaseWindow
    def initialize(viewport)
      super(192, 208, Windowskin.get(:choice), viewport)
      draw_stat_names
    end

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

    def show_increase(array)
      color = Color.new(72, 72, 72)
      shadow = Color::GREYSHADOW
      for i in 0...6
        self.draw_text(x: 130, y: 24 + 30 * i, text: "+", color: color, shadow_color: shadow)
        self.draw_text(x: 176, y: 22 + 30 * i, text: array[i].to_s, color: color, shadow_color: shadow, align: :right)
      end
    end

    def show_stats(array)
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
