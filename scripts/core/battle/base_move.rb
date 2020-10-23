class Battle
  class BaseMove
    # Creates a helper class for using a specific UsableMove.
    # @param battle [Battle] the associated battle.
    # @param move [UsableMove] the move to use.
    def initialize(battle, move)
      validate \
          battle => Battle,
          move => UsableMove
      @battle = battle
      @ui = @battle.ui
      @move = move
    end

    # @return [Boolean] whether the move is physical.
    def physical?
      return @move.physical?
    end

    # @return [Boolean] whether the move is special.
    def special?
      return @move.special?
    end

    # @return [Boolean] whether the move is status.
    def status?
      return @move.status?
    end

    # Shows a text message.
    # @param text [String] the text to display.
    # @param await_input [Boolean] whether to end the message without needing input.
    # @param ending_arrow [Boolean] whether the message should have a moving down arrow.
    # @param reset [Boolean] whether the message box should clear after the message is done.
    def message(msg, await_input = false, ending_arrow = false, reset = true)
      @battle.message(msg, await_input, ending_arrow, reset)
    end

    # Gets the target of the move given a user.
    # @param user [Battler] the battler that is to execute the move.
    def get_target(user)
      validate user => Battler
      if @move.target == :single_opponent
        # Battler directly opposite this battler.
        return @battle.sides[1 - user.side].battlers[user.index]
      elsif @move.target == :self
        return user
      elsif @move.target == :adjacent_opponents
        # TODO: Support for triple battles (only target adjacent 2)
        return @battle.sides[1 - user.side].battlers
      elsif @move.target == :all_opponents
        return @battle.sides[1 - user.side].battlers
      elsif @move.target == :ally
        return @battle.sides[user.side].battlers[1 - user.index]
      elsif @move.target == :all_others
        return [@battle.sides[user.side].battlers[1 - user.index]].concat(@battle.sides[1 - user.side].battlers)
      elsif @move.target == :everyone
        return @battle.sides[user.side].battlers.concat(@battle.sides[1 - user.side].battlers)
      end
    end

    # Gets whether or not this move can be a critical hit.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @return [Boolean] whether this move can be a critical hit.
    def can_critical_hit?(user, target)
      validate \
          user => Battler,
          target => Battler
      return false if status?
      return true
    end

    # Gets the critical hit stage when executed.
    # @param user [Battler] the user of the move.
    def get_critical_hit_stage(user)
      validate user => Battler
      stage = @move.critical_hit_ratio
      return stage
    end

    # Gets whether or not this particular usage of the move is a critical hit.
    # @param user [Battler] the user of the move.
    # @return [Boolean] whether the usage is a critical hit.
    def critical_hit?(user)
      validate user => Battler
      stage = get_critical_hit_stage(user)
      if stage > 2
        return true
      else
        # 1 in 24, 8, 2, etc.
        odds = [24, 8, 2]
        return rand(odds[stage]) == 0
      end
    end

    # Gets the type effectiveness modifier of a type when used on a set of other types.
    # @param move_type [Type] the type of the move.
    # @param target_types [Array<Type>] the types of the target.
    # @return [Float] the modifier based on type effectiveness.
    def self.get_type_effectiveness_modifier(move_type, target_types)
      validate move_type => Type
      validate_array target_types => Type
      mod = 1.0
      target_types.each do |target_type|
        next if target_type.nil?
        mod *= 2.0 if Type.get(move_type).strong_against?(target_type)
        mod /= 2.0 if Type.get(target_type).resistant_to?(move_type)
      end
      return mod
    end

    # Gets the attack multiplier when the move is used.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @param multiple_target [Boolean] whether the move has multiple targets.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    # @return [Float] the damage multiplier.
    def get_damage_multiplier(user, target, multiple_targets, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          multiple_targets => Boolean,
          critical_hit => Boolean
      mod = 1.0
      # TODO: Weather boosting
      mod *= 0.75 if multiple_targets
      mod *= 1.5 if critical_hit
      mod *= rand(85..100) / 100.0
      mod *= 1.5 if user.has_type?(@move.type)
      mod *= BaseMove.get_type_effectiveness_modifier(@move.type, target.types)
      mod *= 0.5 if user.burned? && physical?
      return mod
    end

    # Gets the effective user attack stat.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @param multiple_targets [Boolean] whether the move has multiple targets.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def get_user_attack(user, target, multiple_targets, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          multiple_targets => Boolean,
          critical_hit => Boolean
      if physical?
        # Use physical stats if the move is physical.
        attack = user.attack
        attack = user.pokemon.attack if critical_hit && user.attack < user.pokemon.attack # Ignore negative stat stages
      else
        # Use special stats if the move is special.
        attack = user.spatk
        attack = user.pokemon.spatk if critical_hit && user.spatk < user.pokemon.spatk # Ignore negative stat stages
      end
      return attack
    end

    # Gets the effective target defense stat.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @param multiple_targets [Boolean] whether the move has multiple targets.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def get_target_defense(user, target, multiple_targets, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          multiple_targets => Boolean,
          critical_hit => Boolean
      if physical?
        # Use physical stats if the move is physical.
        defense = target.defense
        defense = target.pokemon.defense if critical_hit && target.defense > target.pokemon.defense # Ignore negative stat stages
      else
        # Use special stats if the move is special.
        defense = target.spdef
        defense = target.pokemon.spdef if critical_hit && target.spdef > target.pokemon.spdef # Ignore negative stat stages
      end
      return defense
    end

    # Calculate the total damage done by the user against the target.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @param multiple_targets [Boolean] whether the move has multiple targets.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def calculate_damage(user, target, multiple_targets, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          multiple_targets => Boolean,
          critical_hit => Boolean
      # Gets the user's attack or special attack depending on the move/type,
      # and applies various modifiers.
      attack = get_user_attack(user, target, multiple_targets, critical_hit)
      # Gets the target's defense or special defense depending on the move/type,
      # and applies various modifiers.
      defense = get_target_defense(user, target, multiple_targets, critical_hit)
      dmg = (2 * user.level / 5 + 2) * @move.power * attack / defense / 50
      # Applies various multipliers to the final damage result.
      dmg *= get_damage_multiplier(user, target, multiple_targets, critical_hit)
      dmg += 2
      dmg = 1 if dmg < 1
      return dmg.floor
    end

    # Gets the accuracy multiplier based on secondary effects.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @return [Float] the accuracy multiplier.
    def get_accuracy_multiplier(user, target)
      validate \
          user => Battler,
          target => Battler
      mod = 1.0
      return mod
    end

    # Gets whether or not this usage hit the target.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.
    # @return [Boolean] whether the move landed.
    def hit?(user, target)
      validate \
          user => Battler,
          target => Battler
      t = @move.accuracy * ACCURACY_STAGE_MULTIPLIER[user.accuracy_stage - target.evasion_stage + 6]
      t *= get_accuracy_multiplier(user, target)
      return rand(1..100) <= t
    end

    # Execute this move.
    # @param user [Battler] the user of the move.
    # @param target [NilClass, Battler] the target of the move.
    def execute(user, target = nil)
      validate \
          user => Battler,
          target => [NilClass, Battler]
      targets = target || get_target(user)
      targets = [targets] if targets.is_a?(Battler)
      # Determines if a critical hit for this user is possible by checking each target.
      can_crit = true
      for target in targets
        if !can_critical_hit?(user, target)
          can_crit = false
          break
        end
      end
      # Calculates if this move is a critical hit, but only if it's possible
      # to receive a critical hit in the first place.
      crit = can_crit ? critical_hit?(user) : false
      for target in targets
        # Determines whether the move hit the target.
        hit = hit?(user, target)
        if hit
          # Calculates the damage this move does if it's not a status move.
          damage = status? ? nil : calculate_damage(user, target, targets.size > 1, crit)
          # Use the move.
          use_move(user, target, damage, crit)
        else
          # Move missed
          use_move_message(user, target, nil, false)
          message("#{user.name}'s\nattack missed!'")
        end
      end
    end

    # Displays the move used message.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [NilClass, Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def use_move_message(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => [NilClass, Integer],
          critical_hit => Boolean
      message("#{user.name} used #{@move.name}!", false, false, false)
    end

    # Displays the critical hit message.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def critical_hit_message(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => Integer,
          critical_hit => Boolean
      message("A critical hit!", false, false, false)
      @ui.wait(0.4)
    end

    # Displays the move failed message.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [NilClass, Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def fail_message(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => [NilClass, Integer],
          critical_hit => Boolean
      message("But it failed!")
    end

    # Uses the move.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [NiLClass, Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def use_move(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => [NilClass, Integer],
          critical_hit => Boolean
      # Show the move used message.
      use_move_message(user, target, damage, critical_hit)
      # Apply any potential before-use effects.
      before_use_effect(user, target, damage, critical_hit)
      if damage
        # Deal the damage dealt by the move.
        deal_damage(user, target, damage, critical_hit)
        @ui.wait(0.2)
        # Show the critical hit message if this move is a critical hit
        critical_hit_message(user, target, damage, critical_hit) if critical_hit
      end
      # Apply any potential after-use effects.
      after_use_effect(user, target, damage, critical_hit)
      @ui.wait(0.2)
      # Faint the target if it is out of HP.
      if target.fainted?
        @ui.wait(0.4)
        target.faint
      end
    end

    # Show the animation of the move being used.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def execute_animation(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => [NilClass, Integer],
          critical_hit => Boolean
      anim = BaseMoveAnimation.new(@battle, user, target, damage, critical_hit)
      anim.main
      anim.dispose
    end

    # Apply this move's before-use effects.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def before_use_effect(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => [NilClass, Integer],
          critical_hit => Boolean
      execute_animation(user, target, damage, critical_hit)
    end

    # Apply this move's after-use effects.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [NilClass, Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def after_use_effect(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => [NilClass, Integer],
          critical_hit => Boolean
      # Example: Lower attack 3 stats
      target.lower_stat(:attack, 1, true, false) if @move.intname == :GROWL
    end

    # Deals damage when the move is being used.
    # @param user [Battler] the user of the move.
    # @param target [Battler] the target of the move.f
    # @param damage [Integer] the damage the user did to the target.
    # @param critical_hit [Boolean] whether the move is a critical hit.
    def deal_damage(user, target, damage, critical_hit)
      validate \
          user => Battler,
          target => Battler,
          damage => Integer,
          critical_hit => Boolean
      target.lower_hp(damage)
    end
  end
end
