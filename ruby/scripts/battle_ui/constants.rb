class Battle
  class Databox
    PLAYER_BOX_PATH = "gfx/ui/battle/databox_player"
    OPPONENT_BOX_PATH = "gfx/ui/battle/databox_opponent"

    BASE_COLOR = Color.new(64, 64, 64)
    SHADOW_COLOR = Color.new(216, 208, 176)

    OPPONENT_NAME_X = 14
    OPPONENT_NAME_Y = 8
    PLAYER_NAME_X = 32
    PLAYER_NAME_Y = 8

    GENDER_COLOR_MALE = Color.new(64, 200, 248)
    GENDER_COLOR_FEMALE = Color.new(248, 152, 144)

    OPPONENT_LEVEL_X = 170
    OPPONENT_LEVEL_Y = 8
    PLAYER_LEVEL_X = 188
    PLAYER_LEVEL_Y = 8

    HP_BAR_PATH = "gfx/ui/battle/hp_bar"
    OPPONENT_HP_BAR_X = 46
    OPPONENT_HP_BAR_Y = 30
    PLAYER_HP_BAR_X = 64
    PLAYER_HP_BAR_Y = 30

    HP_PATH = "gfx/ui/battle/hp"
    OPPONENT_HP_X = 78
    OPPONENT_HP_Y = 34
    PLAYER_HP_X = 96
    PLAYER_HP_Y = 34

    OWNED_BALL_PATH = "gfx/ui/battle/owned_ball"
    OWNED_BALL_X = 14
    OWNED_BALL_Y = 30
  end

  GENERIC_STAGE_MULTIPLIER = [2/8.0,  2/7.0,  2/6.0,  2/5.0,  2/4.0,  2/3.0,  1,  3/2.0,  4/2.0,  5/2.0,  6/2.0,  7/2.0,  8/2.0]
  ACCURACY_EVASION_STAGE_MULTIPLIER = [3/9.0,  3/8.0,  3/7.0,  3/6.0,  3/5.0,  3/4.0,  1,  4/3.0,  5/3.0,  6/3.0,  7/3.0,  8/3.0,  9/3.0]
end
