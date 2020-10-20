class Battle
  class BaseMoveAnimation
    # Creates a new move animation instance.
    # @param battle [Battle] the associated battle.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @param damage [Integer] the damage dealt.
    # @param critical_hit [Boolean] whether this move was a critical hit.
    def initialize(battle, user, target, damage, critical_hit)
      validate \
          battle => Battle,
          user => Battler,
          target => Battler,
          damage => Integer,
          critical_hit => Boolean
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

    # Shows the damage-inflicting flickering of the battler sprite.
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

    # Performs the animation.
    def main
      inflict_damage
    end

    # Disposes any new sprites this animation created.
    def dispose

    end
  end
end
