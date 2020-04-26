class Battle
  class BaseMove
    def initialize(battle, move)
      @battle = battle
      @move = move
    end

    def physical?
      return @move.physical?
    end

    def special?
      return @move.special?
    end

    def status?
      return @move.status?
    end

    def message(msg, await_input = false, ending_arrow = false)
      @battle.message(msg, await_input, ending_arrow)
    end

    def get_target(user)
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

    def can_critical_hit?(user, target)
      return true
    end

    def critical_hit?(user)
      stage = @move.critical_hit_ratio
      if stage > 2
        return true
      else
        # 1 in 24, 8, 2, etc.
        odds = [24, 8, 2]
        return rand(odds[stage]) == 0
      end
      return false
    end

    def self.get_type_effectiveness_modifier(move_type, target_types)
      mod = 1.0
      target_types.each do |target_type|
        mod *= 2.0 if Type.get(move_type).strong_against?(target_type)
        mod /= 2.0 if Type.get(target_type).resistant_to?(move_type)
      end
      return mod
    end

    def get_damage_multiplier(user, target, multiple_targets, critical_hit)
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

    def get_user_attack(user, target, multiple_targets, critical_hit)
      if physical?
        attack = user.attack
        attack = user.pokemon.attack if critical_hit && user.attack < user.pokemon.attack # Ignore negative stat stages
      else
        attack = user.spatk
        attack = user.pokemon.spatk if critical_hit && user.spatk < user.pokemon.spatk # Ignore negative stat stages
      end
      return attack
    end

    def get_target_defense(user, target, multiple_targets, critical_hit)
      if physical?
        defense = target.defense
        defense = target.pokemon.defense if critical_hit && target.defense > target.pokemon.defense # Ignore negative stat stages
      else
        defense = target.spdef
        defense = target.pokemon.spdef if critical_hit && target.spdef > target.pokemon.spdef # Ignore negative stat stages
      end
      return defense
    end

    def calculate_damage(user, target, multiple_targets, critical_hit)
      # Gets the user's attack or special attack depending on the move/type,
      # and applies various modifiers.
      attack = get_user_attack(user, target, multiple_targets, critical_hit)
      # Gets the target's defense or special defense depending on the move/type,
      # and applies various modifiers.
      defense = get_target_defense(user, target, multiple_targets, critical_hit)
      dmg = (2 * user.level / 5 + 2) * @move.power * attack / defense / 50 + 2
      # Applies various multipliers to the final damage result.
      dmg *= get_damage_multiplier(user, target, multiple_targets, critical_hit)
      dmg = 1 if dmg < 1
      return dmg.floor
    end

    def get_accuracy_multiplier(user, target)
      mod = 1.0
      return mod
    end

    def hit?(user, target)
      t = @move.accuracy * user.accuracy * target.evasion
      t *= get_accuracy_multiplier(user, target)
      return rand(1..100) <= t
    end

    def execute(user)
      targets = get_target(user)
      targets = [targets] if targets.is_a?(Battler)
      # Determines if a critical hit for this user is possible
      # by checking each target.
      can_crit = true
      for target in targets
        if !can_critical_hit?(user, target)
          can_crit = false
          break
        end
      end
      # Calculates if this move is a critical hit if it's possible
      # to receive a critical hit in the first place.
      crit = critical_hit?(user) if can_crit
      for target in targets
        # Calculates the damage this move does if it's not a status move.
        hit = hit?(user, target)
        if hit
          damage = status? ? nil : calculate_damage(user, target, targets.size > 1, crit)
          use_move(user, target, damage, crit)
        else

        end
      end
    end

    def use_move_message(user, target, damage, critical_hit)
      message("#{user.name} used #{@move.name}!")
    end

    def critical_hit_message(user, target, damage, critical_hit)
      message("A critical hit!")
    end

    def use_move(user, target, damage, critical_hit)
      use_move_message(user, target, damage, critical_hit)
      before_use_effect(user, target, damage, critical_hit)
      if damage
        deal_damage(user, target, damage, critical_hit)
        critical_hit_message(user, target, damage, critical_hit) if critical_hit
      end
      after_use_effect(user, target, damage, critical_hit)
    end

    def before_use_effect(user, target, damage, critical_hit)

    end

    def after_use_effect(user, target, damage, critical_hit)

    end

    def deal_damage(user, target, damage, critical_hit)
      target.damage(damage)
    end
  end
end
