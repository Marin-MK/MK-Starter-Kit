Animations = {
  intro_scene: {
    black_overlay_top: {
      bitmap: {
        width: 480,
        height: 64,
        color: Color.new(0, 0, 0)
      },
      start: {
        z: 99999
      },
      commands: []
    },
    black_overlay_bottom: {
      bitmap: {
        width: 480,
        height: 64,
        color: Color.new(0, 0, 0)
      },
      start: {
        y: 256,
        z: 99999
      },
      commands: []
    },
    copyright: {
      bitmap: "gfx/intro/copyright",
      start: {
        x: 112,
        y: 96,
        opacity: 0
      },
      commands: [
        {
          seconds: 0.5,
          opacity: 255
        },
        {
          seconds: 2
        },
        {
          seconds: 0.5,
          opacity: 0,
          stop: true
        }
      ]
    },
    star_bg: {
      bitmap: {
        width: 480,
        height: 192,
        color: Color.new(24, 40, 72)
      },
      start: {
        zoom_y: 0,
        y: 64,
        seconds: 4
      },
      commands: [
        {
          seconds: 0.1,
          zoom_y: 1
        },
        {
          seconds: 9.5,
          stop: true
        }
      ]
    },
    star: {
      bitmap: "gfx/intro/star",
      start: {
        x: 490,
        y: 108,
        z: 4,
        seconds: 4.4
      },
      commands: [
        {
          seconds: 0.7,
          x: -32,
          y: 164,
          stop: true
        }
      ]
    },
    star_particle: {
      bitmap: "gfx/intro/star_particle",
      repeat: true,
      cell_width: 14,
      start: {
        z: 3
      },
      commands: [
        {
          seconds: 0.16,
          next_cell: 3,
        }
      ]
    },
    big_star_particle: {
      bitmap: "gfx/intro/big_star_particle",
      cell_width: 38,
      start: {
        z: 4
      },
      commands: [
        {
          seconds: 0.6,
          next_cell: 3,
          stop: true
        }
      ]
    },
    gamefreak_shadow: {
      bitmap: "gfx/intro/gamefreak",
      start: {
        x: 102,
        y: 146,
        opacity: 1,
        seconds: 6.84,
        color: Color.new(0, 0, 0)
      },
      commands: [
        {
          seconds: 0.1,
          opacity: 96
        },
        {
          seconds: 1.0,
          stop: true
        }
      ]
    },
    gamefreak: {
      bitmap: "gfx/intro/gamefreak",
      start: {
        x: 102,
        y: 146,
        z: 2,
        opacity: 0,
        seconds: 6.95
      },
      commands: [
        {
          seconds: 0.75,
          opacity: 255
        },
        {
          seconds: 4.3
        },
        {
          seconds: 1.0,
          opacity: 0,
          stop: true
        }
      ]
    },
    logo: {
      bitmap: "gfx/intro/logo",
      start: {
        x: 216,
        y: 88,
        z: 1,
        opacity: 0,
        seconds: 9.5
      },
      commands: [
        {
          seconds: 1.0,
          opacity: 255
        },
        {
          seconds: 1.5
        },
        {
          seconds: 1.0,
          opacity: 0,
          stop: true
        }
      ]
    },
    white_overlay: {
      bitmap: {
        width: 480,
        height: 192,
        color: Color.new(255, 255, 255)
      },
      start: {
        y: 64,
        z: 5,
        opacity: 0,
        seconds: 13.5
      },
      commands: [
        {
          seconds: 0.1,
          opacity: 255
        },
        {
          seconds: 0.1,
          opacity: 0
        },
        {
          seconds: 0.8
        },
        {
          seconds: 0.1,
          opacity: 255
        },
        {
          seconds: 0.1,
          opacity: 0
        },
        {
          seconds: 2.35
        },
        {
          seconds: 0.05,
          opacity: 255
        },
        {
          seconds: 0.05,
          opacity: 0
        }
      ]
    },
    grass_path_bg: {
      bitmap: "gfx/intro/grass_path_bg",
      cell_height: 192,
      start: {
        y: 64,
        opacity: 0,
        seconds: 13.5
      },
      commands: [
        {
          seconds: 0.1,
          opacity: 255
        },
        {
          seconds: 0.05
        },
        {
          seconds: 0.75,
          next_cell: 8
        },
        {
          seconds: 0.05,
          next_cell: 2,
          stop: true
        }
      ]
    },
    forest_bg: {
      bitmap: "gfx/intro/forest_bg",
      start: {
        x: -480,
        y: 24,
        seconds: 14.65
      },
      commands: [
        {
          seconds: 1.2,
          translate_x: 150
        },
        {
          seconds: 1.3,
          x: -480,
          y: 64
        },
        {
          seconds: 0.9,
          translate_x: 200
        },
        {
          seconds: 7.6,
          translate_x: 60,
          stop: true
        }
      ]
    },
    grass_fg: {
      bitmap: "gfx/intro/grass_fg",
      start: {
        y: 198,
        z: 2,
        seconds: 14.65
      },
      commands: [
        {
          seconds: 1.2,
          translate_x: -150,
          stop: true
        },
      ]
    },
    gengar_small_white: {
      bitmap: "gfx/intro/gengar_small",
      start: {
        x: 84,
        y: 96,
        z: 1,
        color: Color.new(255, 255, 255),
        seconds: 14.65
      },
      commands: [
        {
          seconds: 0.05,
          opacity: 0,
          stop: true
        }
      ]
    },
    gengar_small: {
      bitmap: "gfx/intro/gengar_small",
      start: {
        x: 84,
        y: 96,
        z: 1,
        seconds: 14.65
      },
      commands: [
        {
          seconds: 1.2,
          stop: true
        }
      ]
    },
    nidorino_small_white: {
      bitmap: "gfx/intro/nidorino_small",
      start: {
        x: 292,
        y: 138,
        z: 1,
        color: Color.new(255, 255, 255),
        seconds: 14.65
      },
      commands: [
        {
          seconds: 0.05,
          opacity: 0,
          stop: true
        }
      ]
    },
    nidorino_small: {
      bitmap: "gfx/intro/nidorino_small",
      start: {
        x: 292,
        y: 138,
        z: 1,
        seconds: 14.65
      },
      commands: [
        {
          seconds: 1.2,
          stop: true
        }
      ]
    },
    orange: {
      bitmap: {
        width: 480,
        height: 192,
        color: Color.new(248, 144, 0)
      },
      start: {
        y: 64,
        z: 3,
        seconds: 15.85
      },
      commands: [
        {
          seconds: 1.3,
          stop: true
        }
      ]
    },
    gengar_big: {
      bitmap: "gfx/intro/gengar_big",
      start: {
        x: 16,
        y: 136,
        z: 4,
        seconds: 15.85
      },
      commands: [
        {
          seconds: 1.3,
          translate_y: -18,
          stop: true
        }
      ]
    },
    nidorino_big: {
      bitmap: "gfx/intro/nidorino_big",
      start: {
        x: 260,
        y: 46,
        z: 4,
        seconds: 15.85
      },
      commands: [
        {
          seconds: 1.3,
          translate_y: 18,
          stop: true
        }
      ]
    },
    gengar_back: {
      bitmap: "gfx/intro/gengar_back",
      cell_width: 190,
      start: {
        x: 480,
        y: 84,
        z: 3,
        seconds: 17.15
      },
      commands: [
        {
          seconds: 0.9,
          x: 38
        },
        {
          seconds: 0.3,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.01,
          set_cell: 2
        },
        {
          seconds: 0.1,
          translate_x: 4
        },
        {
          seconds: 0.1,
          translate_x: -46,
          translate_y: 4
        },
        {
          seconds: 0.05
        },
        {
          seconds: 0.05,
          set_cell: 3,
          translate_x: 84,
          translate_y: -4
        },
        {
          seconds: 0.15,
          set_cell: 0,
          translate_x: -42
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.4,
          set_cell: 1
        },
        {
          seconds: 0.4,
          set_cell: 0
        },
        {
          seconds: 0.59
        },
        {
          seconds: 0.2,
          translate_x: -52,
          scale: 1.6
        },
        {
          seconds: 0.2,
          opacity: 0
        }
      ]
    },
    nidorino_front: {
      bitmap: "gfx/intro/nidorino_front",
      cell_width: 128,
      start: {
        x: -128,
        y: 148,
        z: 2,
        seconds: 17.15
      },
      commands: [
        {
          seconds: 0.9,
          x: 300
        },
        {
          seconds: 0.7
        },
        {
          seconds: 0.2,
          set_cell: 1
        },
        {
          seconds: 0.01,
          set_cell: 2,
          translate_y: -6
        },
        {
          seconds: 0.1,
          translate_y: -2
        },
        {
          seconds: 0.1,
          translate_y: 2
        },
        {
          seconds: 0.1,
          translate_y: -2
        },
        {
          seconds: 0.1,
          translate_y: 2
        },
        {
          seconds: 0.1,
          translate_y: -2
        },
        {
          seconds: 0.1,
          translate_y: 2
        },
        {
          seconds: 0.1,
          translate_y: -2
        },
        {
          seconds: 0.1,
          translate_y: 2
        },
        {
          seconds: 0.1,
          translate_y: -2
        },
        {
          seconds: 0.1,
          translate_y: 2
        },
        {
          seconds: 0.01,
          translate_y: 6,
          set_cell: 0
        },
        {
          seconds: 0.64
        },
        {
          seconds: 0.02,
          set_cell: 1
        },
        {
          seconds: 0.02,
          set_cell: 3,
          translate_x: 13,
          translate_y: -20
        },
        {
          seconds: 0.02,
          translate_x: 10,
          translate_y: -16
        },
        {
          seconds: 0.02,
          translate_x: 8,
          translate_y: -5
        },
        {
          seconds: 0.02,
          translate_x: 6,
          translate_y: -1
        },
        {
          seconds: 0.02,
          translate_x: 6,
          translate_y: 1,
        },
        {
          seconds: 0.02,
          translate_x: 8,
          translate_y: 5
        },
        {
          seconds: 0.02,
          translate_x: 10,
          translate_y: 14
        },
        {
          seconds: 0.04,
          translate_x: 7,
          translate_y: 18,
          set_cell: 1
        },
        {
          seconds: 0.12,
          translate_x: 22
        },
        {
          seconds: 0.01,
          translate_y: 4,
          set_cell: 0
        },
        {
          seconds: 0.4
        },
        {
          seconds: 0.01,
          translate_y: -6,
          set_cell: 1
        },
        {
          seconds: 0.1
        },
        {
          seconds: 0.02,
          translate_x: -14,
          translate_y: -12,
          set_cell: 3
        },
        {
          seconds: 0.02,
          translate_x: -12,
          translate_y: -8
        },
        {
          seconds: 0.02,
          translate_x: -10,
          translate_y: -6
        },
        {
          seconds: 0.02,
          translate_x: -8,
          translate_y: -2
        },
        {
          seconds: 0.02,
          translate_x: -8,
          translate_y: 2
        },
        {
          seconds: 0.02,
          translate_x: -10,
          translate_y: 6
        },
        {
          seconds: 0.02,
          translate_x: -12,
          translate_y: 8
        },
        {
          seconds: 0.02,
          translate_x: -12,
          translate_y: 12,
          set_cell: 1
        },
        {
          seconds: 0.1
        },
        {
          seconds: 0.01,
          translate_y: 6,
          set_cell: 0
        },
        {
          seconds: 0.3
        },
        {
          seconds: 0.05,
          set_cell: 1
        },
        {
          seconds: 0.02,
          translate_x: 2,
          translate_y: -4,
          set_cell: 3
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: -6
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: -6
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: 4
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: 6
        },
        {
          seconds: 0.02,
          translate_x: 2,
          translate_y: 6
        },
        {
          seconds: 0.01,
          set_cell: 1,
          translate_y: -6
        },
        {
          seconds: 0.15
        },
        {
          seconds: 0.01,
          set_cell: 3,
          translate_y: 6
        },
        {
          seconds: 0.02,
          translate_x: 2,
          translate_y: -4
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: -6
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: -6
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: 4
        },
        {
          seconds: 0.02,
          translate_x: 4,
          translate_y: 6
        },
        {
          seconds: 0.02,
          translate_x: 2,
          translate_y: 6
        },
        {
          seconds: 0.01,
          set_cell: 1,
          translate_y: -6
        },
        {
          seconds: 0.7
        },
        {
          seconds: 0.02,
          translate_x: 2
        },
        {
          seconds: 0.02,
          translate_x: -2
        },
        {
          seconds: 0.02,
          translate_x: 2
        },
        {
          seconds: 0.6
        },
        {
          seconds: 0.3,
          translate_x: -70,
          translate_y: -60,
          set_cell: 4
        },
        {
          seconds: 0.3,
          translate_x: -40,
          translate_y: -30
        },
        {
          seconds: 0.3,
          translate_x: -30,
          translate_y: -10
        },
        {
          seconds: 0.2,
          translate_x: -2,
          translate_y: -8,
          scale: 1.6
        },
        {
          seconds: 0.2,
          opacity: 0
        }
      ]
    },
    grass_patch_fg: {
      bitmap: "gfx/intro/grass_patch_fg",
      start: {
        x: 500,
        y: 204,
        z: 4,
        seconds: 17.15
      },
      commands: [
        {
          seconds: 0.9,
          x: 52
        },
        {
          seconds: 2,
          x: -120
        }
      ]
    },
    punch_particle: {
      bitmap: "gfx/intro/punch_particle",
      start: {
        x: 236,
        y: 92,
        z: 2,
        seconds: 20.85
      },
      commands: [
        {
          seconds: 0.05,
          visible: true
        },
        {
          seconds: 0.05,
          visible: false
        },
        {
          seconds: 0.05,
          visible: true,
          stop: true
        }
      ]
    },
    dust_particle: {
      bitmap: "gfx/intro/dust_particle",
      cell_height: 32,
      start: {
        x: 306,
        y: 224,
        z: 1,
        seconds: 21.1
      },
      commands: [
        {
          seconds: 1.1,
          next_cell: 13,
          stop: true
        }
      ]
    },
    white_bg: {
      bitmap: {
        width: 480,
        height: 192,
        color: Color.new(255, 255, 255)
      },
      start: {
        y: 64,
        z: 1,
        opacity: 0,
        seconds: 24.8
      },
      commands: [
        {
          seconds: 1.0,
          opacity: 255
        },
        {
          seconds: 0.2
        },
        {
          seconds: 0.2,
          opacity: 0
        }
      ]
    }
  }
}

class Animation
  attr_accessor :data
  attr_accessor :particles

  def self.load(viewport, id)
    return self.new(viewport, id)
  end

  def initialize(viewport, id)
    @viewport = viewport
    @data = Animations[id]
    @particles = []
    @i = 0
    @max_frame_count = 0
    @disposed = false
  end

  def set_duration(seconds)
    @max_frame_count = (seconds * Graphics.frame_rate).round
  end

  def create_particle(name)
    particle = BasicParticle.new(@viewport)
    particle.load_data(@data[name])
    @particles << particle
  end

  def update
    raise "Animation disposed" if disposed?
    @particles.each { |p| p.update }
    @i += 1
    if @i > @max_frame_count && @max_frame_count > 0
      dispose
    end
  end

  def dispose
    @particles.each { |p| p.dispose }
    @particles.clear
    @disposed = true
  end

  def disposed?
    return @disposed
  end
end

class IntroScene
  def self.start
    scene = self.new
    scene.main
  end

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @anim = Animation.load(@viewport, :intro_scene)
    @anim.set_duration(27.1)
    @anim.create_particle(:black_overlay_top)
    @anim.create_particle(:black_overlay_bottom)
    @anim.create_particle(:copyright)
    @anim.create_particle(:star_bg)
    @anim.create_particle(:star)
    #create_star_particle(x, y, delay, x_speed, y_speed, flicker_delay, flicker_time, flicker_times)
    # Star's particle trail
    create_star_particle(442, 120, 0, 6, -3)
    create_star_particle(452, 132, 0, 5, 3)
    create_star_particle(464, 128, 0, 5, 2)
    create_star_particle(436, 124, 0.05, 7, -2)
    create_star_particle(418, 126, 0.05, 5, -1, 6, 0.02, 5)
    create_star_particle(394, 134, 0.1, 6, 0, 6, 0.02, 5)
    create_star_particle(384, 136, 0.1, 6, 1, 5, 0.02, 5)
    create_star_particle(376, 140, 0.1, 7, 2, 4, 0.02, 5)
    create_star_particle(352, 144, 0.15, 3, 1, 5, 0.02, 5)
    create_star_particle(338, 134, 0.15, 5, -3, 5, 0.02, 5)
    create_star_particle(338, 130, 0.15, 1, -3, 5, 0.02, 5)
    create_star_particle(316, 136, 0.2, 3, -2, 6, 0.02, 4)
    create_star_particle(296, 142, 0.2, 3, 0, 6, 0.02, 4)
    create_star_particle(282, 144, 0.25, 4, 1, 6, 0.02, 5)
    create_star_particle(274, 148, 0.25, 5, 2, 6, 0.02, 4)
    create_star_particle(256, 150, 0.25, 1, 1, 6, 0.02, 4)
    create_star_particle(250, 138, 0.3, 5, -2, 7, 0.02, 5)
    create_star_particle(242, 140, 0.3, 4, -1, 6, 0.02, 4)
    create_star_particle(242, 140, 0.3, 4, 0, 7, 0.02, 4)
    create_star_particle(200, 148, 0.35, 3, 0, 7, 0.02, 4)
    create_star_particle(182, 152, 0.35, 2, 0, 7, 0.02, 3)
    create_star_particle(172, 154, 0.35, 1, 1, 5, 0.02, 5)
    create_star_particle(162, 158, 0.35, 2, 2, 6, 0.02, 4)
    create_star_particle(148, 144, 0.4, 1, -1, 6, 0.02, 4)
    create_star_particle(148, 148, 0.4, 4, -1, 7, 0.02, 5)
    create_star_particle(126, 150, 0.4, 1, 0, 7, 0.02, 4)
    create_star_particle(110, 156, 0.45, 3, 0, 7, 0.02, 5)
    create_star_particle(96, 160, 0.45, 2, 1, 6, 0.02, 5)
    create_star_particle(78, 164, 0.5, 3, 2, 6, 0.02, 4)
    create_star_particle(64, 166, 0.5, 2, 1, 5, 0.02, 6)
    create_star_particle(52, 154, 0.5, 2, -2, 6, 0.02, 5)
    create_star_particle(38, 158, 0.55, 4, -2, 5, 0.02, 5)
    create_star_particle(36, 162, 0.55, 6, 1, 4, 0.02, 4)
    create_star_particle(2, 170, 0.6, 2, 0, 6, 0.02, 5)
    create_star_particle(-2, 174, 0.6, 4, 1, 5, 0.02, 5)

    # Additional particles
    time = 0.9
    diff = 0.04
    create_star_particle(138, 154, time, 0, 1, 1, 0.02, 2)
    create_star_particle(266, 142, time + diff * 1, 0, 0, 1, 0.02, 3)
    create_star_particle(330, 154, time + diff * 2, 0, 1, 1, 0.02, 2)
    create_star_particle(190, 156, time + diff * 3, 1, 1, 1, 0.02, 3)
    create_star_particle(234, 154, time + diff * 4, 1, 1, 1, 0.02, 2)
    create_star_particle(318, 144, time + diff * 5, 1, 1, 1, 0.02, 3)
    create_star_particle(202, 166, time + diff * 6, 1, 1, 1, 0.02, 2)
    create_star_particle(358, 156, time + diff * 7, 1, 1, 1, 0.02, 2)
    create_star_particle(242, 158, time + diff * 8, 0, -2, 1, 0.02, 3)
    create_star_particle(286, 156, time + diff * 9, 2, 2, 1, 0.02, 2)
    create_star_particle(370, 146, time + diff * 10, 1, 2, 1, 0.02, 2)
    create_star_particle(362, 142, time + diff * 11, 1, 1, 1, 0.02, 2)
    create_star_particle(254, 142, time + diff * 12, 0, 1, 1, 0.02, 3)
    create_star_particle(306, 158, time + diff * 13, 1, 1, 1, 0.02, 2)
    create_star_particle(106, 166, time + diff * 14, 1, 1, -1, 0.02, 2)
    create_star_particle(294, 160, time + diff * 14, 1, 1, 1, 0.02, 2)
    create_star_particle(222, 144, time + diff * 15, 1, -1, 1, 0.02, 3)
    create_star_particle(298, 166, time + diff * 16, 1, 0, 1, 0.02, 2)
    create_star_particle(338, 158, time + diff * 16, 1, 0, 1, 0.02, 3)
    create_star_particle(318, 148, time + diff * 17, 1, -1, 1, 0.02, 3)
    create_star_particle(326, 144, time + diff * 17, 1, -2, 2, 0.02, 2)
    create_star_particle(138, 154, time + diff * 18, 1, 1, 1, 0.02, 2)
    create_star_particle(306, 144, time + diff * 18, 1, -1, 1, 0.02, 2)
    create_star_particle(158, 142, time + diff * 19, 1, 0, 1, 0.02, 2)
    create_star_particle(254, 160, time + diff * 19, 1, 1, 1, 0.02, 3)
    create_star_particle(274, 146, time + diff * 20, 1, 1, 1, 0.02, 3)
    create_star_particle(346, 162, time + diff * 20, 1, -1, 1, 0.02, 2)
    create_star_particle(266, 150, time + diff * 21, -1, -1, 1, 0.02, 2)
    create_star_particle(350, 142, time + diff * 21, 1, 1, 1, 0.02, 2)
    create_star_particle(330, 154, time + diff * 22, 1, -1, 1, 0.02, 3)
    create_star_particle(310, 160, time + diff * 22, 1, 1, 1, 0.02, 2)
    create_star_particle(358, 146, time + diff * 23, 1, 1, 1, 0.02, 3)
    create_star_particle(202, 162, time + diff * 24, 1, -1, 1, 0.02, 2)
    create_star_particle(210, 144, time + diff * 24, 1, 1, 1, 0.02, 3)
    create_star_particle(234, 154, time + diff * 24, 1, 1, 1, 0.02, 2)
    create_big_star_particle(126, 140, time + diff * 25)
    create_star_particle(298, 162, time + diff * 25, 1, 1, 1, 0.02, 2)
    create_star_particle(214, 152, time + diff * 26, -1, 1, 1, 0.02, 3)
    create_star_particle(222, 148, time + diff * 26, 0, 1, 1, 0.02, 2)
    create_big_star_particle(190, 152, time + diff * 28)
    create_star_particle(316, 162, time + diff * 27, 0, 1, 1, 0.02, 2)
    create_star_particle(150, 164, time + diff * 28, 1, 1, 1, 0.02, 2)
    create_star_particle(170, 142, time + diff * 28, 1, 1, 1, 0.02, 2)
    create_star_particle(242, 158, time + diff * 28, 1, 1, 1, 0.02, 3)
    create_star_particle(262, 146, time + diff * 29, 1, 1, 1, 0.02, 2)
    create_star_particle(286, 156, time + diff * 29, -1, 1, 1, 0.02, 2)
    create_star_particle(290, 166, time + diff * 29, 0, 1, 1, 0.02, 3)
    create_star_particle(192, 168, time + diff * 29, 2, 1, 1, 0.02, 2)
    create_star_particle(190, 178, time + diff * 30, -1, 1, 1, 0.02, 1)
    create_star_particle(212, 134, time + diff * 30, 1, 1, 1, 0.02, 3)
    create_star_particle(362, 150, time + diff * 30, -1, 1, 1, 0.02, 3)
    create_star_particle(362, 142, time + diff * 30, 0, 0, 1, 0.02, 2)
    create_star_particle(370, 146, time + diff * 30, 0, -1, 1, 0.02, 2)
    create_big_star_particle(286, 152, time + diff * 30)
    create_star_particle(246, 164, time + diff * 31, -1, 0, 1, 0.02, 3)
    create_star_particle(286, 146, time + diff * 31, 1, 1, 1, 0.02, 2)
    create_star_particle(170, 150, time + diff * 32, 1, 1, 1, 0.02, 2)
    create_star_particle(306, 158, time + diff * 32, 1, 1, 1, 0.02, 3)
    create_star_particle(106, 166, time + diff * 33, 1, 0, 1, 0.02, 2)
    create_star_particle(278, 150, time + diff * 33, -1, 1, 1, 0.02, 2)
    create_star_particle(98, 166, time + diff * 34, 1, 1, 1, 0.02, 3)
    create_star_particle(222, 144, time + diff * 34, 0, 1, 1, 0.02, 2)
    create_big_star_particle(222, 140, time + diff * 34)
    create_star_particle(314, 148, time + diff * 34, 0, 1, 1, 0.02, 2)
    create_star_particle(238, 142, time + diff * 35, 1, 1, 1, 0.02, 2)
    create_star_particle(338, 158, time + diff * 35, 0, 1, 1, 0.02, 3)
    create_star_particle(326, 144, time + diff * 35, 1, 1, 1, 0.02, 2)
    create_star_particle(306, 144, time + diff * 36, 0, 1, 1, 0.02, 2)
    create_star_particle(194, 166, time + diff * 36, 0, 1, 1, 0.02, 2)
    @anim.create_particle(:gamefreak_shadow)
    @anim.create_particle(:gamefreak)
    create_big_star_particle(94, 154, time + diff * 37)
    create_star_particle(158, 142, time + diff * 37, 0, 1, 2, 0.02, 3)
    create_star_particle(118, 152, time + diff * 37, 1, 1, 2, 0.02, 2)
    create_star_particle(254, 160, time + diff * 37, 0, 1, 2, 0.02, 2)
    create_star_particle(274, 146, time + diff * 38, 0, 1, 2, 0.02, 2)
    create_star_particle(346, 162, time + diff * 38, -1, 1, 2, 0.02, 3)
    create_star_particle(150, 144, time + diff * 39, 0, 1, 2, 0.02, 3)
    create_star_particle(366, 150, time + diff * 39, 0, 1, 2, 0.02, 2)
    create_big_star_particle(318, 140, time + diff * 39)
    create_star_particle(350, 142, time + diff * 40, 0, 1, 2, 0.02, 2)
    create_star_particle(142, 142, time + diff * 41, 0, 1, 2, 0.02, 2)
    create_star_particle(182, 150, time + diff * 41, 0, 1, 2, 0.02, 1)
    create_star_particle(130, 154, time + diff * 42, 0, 1, 2, 0.02, 2)
    create_star_particle(358, 146, time + diff * 42, 0, 1, 2, 0.02, 2)
    create_star_particle(202, 162, time + diff * 43, 0, 1, 2, 0.02, 1)
    create_star_particle(210, 144, time + diff * 43, 0, 1, 2, 0.02, 1)
    create_star_particle(174, 154, time + diff * 43, 0, 1, 2, 0.02, 0)
    create_big_star_particle(350, 128, time + diff * 43)
    create_star_particle(342, 164, time + diff * 44, 1, 1, 1, 0.02, 1)
    create_star_particle(298, 162, time + diff * 45, 0, 4, 1, 0.02, 1)
    create_star_particle(206, 158, time + diff * 46, 0, 2, 2, 0.02, 2)
    create_star_particle(214, 152, time + diff * 46, 0, 3, 2, 0.02, 1)
    create_star_particle(222, 148, time + diff * 46, 0, 5, 2, 0.02, 0)
    create_big_star_particle(254, 128, time + diff * 46)
    create_star_particle(150, 164, time + diff * 47, 1, 1, 4, 0.02, 0)
    create_star_particle(182, 156, time + diff * 47, 0, 2, 3, 0.02, 1)
    create_big_star_particle(158, 128, time + diff * 48)
    create_star_particle(290, 166, time + diff * 48, 0, 3, 1, 0.02, 1)
    create_star_particle(270, 154, time + diff * 49, 0, 3, 2, 0.02, 1)
    create_star_particle(286, 146, time + diff * 49, 0, 4, 2, 0.02, 1)
    create_star_particle(246, 164, time + diff * 49, 1, 1, 4, 0.02, 0)
    create_star_particle(162, 154, time + diff * 50, 0, 4, 2, 0.02, 1)
    create_star_particle(170, 150, time + diff * 50, 1, 3, 3, 0.02, 0)
    create_star_particle(118, 156, time + diff * 51, 1, 1, 3, 0.02, 1)
    create_star_particle(98, 166, time + diff * 52, 1, 0, 4, 0.02, 0)
    create_star_particle(314, 148, time + diff * 52, 0, 3, 4, 0.02, 0)
    create_star_particle(310, 152, time + diff * 53, -1, 2, 3, 0.02, 1)
    create_star_particle(194, 166, time + diff * 54, 0, 4, 3, 0.02, 0)
    create_star_particle(110, 156, time + diff * 55, 0, 3, 4, 0.02, 0)
    create_star_particle(234, 148, time + diff * 55, 0, 4, 4, 0.02, 0)
    create_star_particle(366, 150, time + diff * 57, 0, 4, 4, 0.02, 0)
    create_star_particle(258, 154, time + diff * 58, 0, 3, 4, 0.02, 0)
    create_star_particle(182, 150, time + diff * 59, 0, 3, 4, 0.02, 0)
    create_star_particle(322, 152, time + diff * 61, 0, 5, 3, 0.02, 0)
    @anim.create_particle(:logo)
    @anim.create_particle(:white_overlay)
    @anim.create_particle(:grass_path_bg)
    @anim.create_particle(:forest_bg)
    @anim.create_particle(:grass_fg)
    @anim.create_particle(:gengar_small)
    @anim.create_particle(:gengar_small_white)
    @anim.create_particle(:nidorino_small)
    @anim.create_particle(:nidorino_small_white)
    @anim.create_particle(:orange)
    @anim.create_particle(:gengar_big)
    @anim.create_particle(:nidorino_big)
    @anim.create_particle(:gengar_back)
    @anim.create_particle(:nidorino_front)
    @anim.create_particle(:grass_patch_fg)
    @anim.create_particle(:punch_particle)
    @anim.create_particle(:dust_particle)
    @anim.create_particle(:white_bg)
  end

  def create_star_particle(x, y, delay, xdir, ydir, flicker_delay = nil, flicker_time = nil, flicker_times = nil)
    particle = BasicParticle.new(@viewport)
    data = @anim.data[:star_particle].deep_clone
    data[:start][:x] = x
    data[:start][:y] = y
    data[:start][:seconds] = delay + 4.5
    data[:commands][0][:translate_x] = xdir
    data[:commands][0][:translate_y] = ydir
    if flicker_delay
      cmd = data[:commands][0]
      for i in 0...flicker_delay
        data[:commands] << cmd.clone
      end
      for i in 0...flicker_times
        fraction = flicker_time / cmd[:seconds]
        data[:commands] << {
          seconds: flicker_time,
          translate_x: (cmd[:translate_x] * fraction).round,
          translate_y: (cmd[:translate_y] * fraction).round,
          visible: false,
          next_cell: 1
        }
        data[:commands] << {
          seconds: flicker_time,
          translate_x: (cmd[:translate_x] * fraction).round,
          translate_y: (cmd[:translate_y] * fraction).round,
          visible: true
        }
      end
      data[:commands] << {
        stop: true
      }
    end
    particle.load_data(data)
    @anim.particles << particle
  end

  def create_big_star_particle(x, y, delay)
    particle = BasicParticle.new(@viewport)
    data = @anim.data[:big_star_particle].deep_clone
    data[:start][:x] = x
    data[:start][:y] = y
    data[:start][:seconds] = delay + 4.5
    particle.load_data(data)
    @anim.particles << particle
  end

  def main
    loop do
      Graphics.update
      Input.update
      @anim.update if !@anim.disposed?
      break if @anim.disposed?
      if Input.confirm? || Input.cancel?
        frames = framecount(0.2)
        decrease = 255.0 / frames
        for i in 1..frames
          Graphics.brightness = 255 - (decrease * i).round
          @anim.update if !@anim.disposed?
          Graphics.update
          Input.update
        end
        @anim.dispose if !@anim.disposed?
        Graphics.brightness = 255
        break
      end
    end
  end

  def dispose
    @anim.dispose
    @viewport.dispose
  end
end

IntroScene.start
