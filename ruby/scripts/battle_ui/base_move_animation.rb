class Battle
  class BaseMoveAnimation
    def initialize(battle, user, target, damage, critical_hit)
      @battle = battle
      @viewport = @battle.ui.viewport
      @user = user
      @user_sprite = @battle.ui.get_battler_sprite(@user)
      @user_databox = @battle.ui.get_battler_databox(@user)
      @target = target
      @target_sprite = @battle.ui.get_battler_sprite(@target)
      @target_databox = @battle.ui.get_battler_databox(@target)
      @damage = damage
      @critical_hit = critical_hit
    end

    def inflict_damage
      frames = framecount(0.4)
      up = true
      @target_databox.y -= 1
      for i in 1..frames
        @battle.ui.update
        if i % framecount(0.05) == 0
          @target_sprite.visible = !@target_sprite.visible
          if up
            @target_databox.y += 2
            up = false
          else
            @target_databox.y -= 2
            up = true
          end
        end
      end
      @target_sprite.visible = true
      @target_databox.y += up ? 1 : -1
    end

    def main
      inflict_damage
    end

    def dispose

    end
  end
end
