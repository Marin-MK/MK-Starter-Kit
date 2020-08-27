class EncounterTable < Serializable
  attr_accessor :density
  attr_accessor :battle_music
  attr_accessor :battle_background
  attr_accessor :battle_base
  attr_accessor :list
  attr_accessor :tiles

  def initialize(&block)
    validate block => Proc
    @density = 0.3
    @battle_music = ""
    @battle_background = ""
    @battle_base = ""
    @list = []
    @tiles = []
    instance_eval(&block)
    validate_table
  end

  def validate_table
    validate \
        @density => Float,
        @battle_music => String,
        @battle_background => String,
        @battle_base => String,
        @list => Array,
        @tiles => Array
    @list.each do |e|
      validate \
          e[0] => Integer,
          e[1] => Hash
    end
    @tiles.each do |e|
      validate \
          e[0] => Integer,
          e[1] => Integer
    end
  end
end
