# Erratic
# Fast
# Medium Fast
# Medium Slow
# Slow
# Fluctuating

module EXP
  ERRATIC = [0,
    #case n
    #when 0..50
    #  ((100.0 - n) * n ** 3) / 50.0
    #when 51..68
    #  ((150.0 - n) * n ** 3) / 100.0
    #when 69..98
    #  (((1911.0 - 10.0 * n) / 3.0).floor * n ** 3) / 500.0
    #when 99..100
    #  ((160.0 - n) * n ** 3) / 100.0
    #end
    2, 16, 52, 123, 238, 406, 638, 942, 1327, 1800,
    2369, 3041, 3823, 4720, 5738, 6881, 8156, 9564, 11112, 12800,
    14632, 16611, 18737, 21012, 23438, 26012, 28737, 31611, 34632, 37800,
    41112, 44564, 48156, 51881, 55738, 59720, 63823, 68041, 72369, 76800,
    81327, 85942, 90638, 95406, 100238, 105123, 110052, 115016, 120002, 125000,
    131324, 137796, 144411, 151165, 158056, 165079, 172229, 179503, 186895, 194400,
    202013, 209729, 217541, 225444, 233431, 241497, 249633, 257834, 267406, 276458,
    286329, 296359, 305767, 316075, 326531, 336256, 346965, 357812, 367807, 378880,
    390078, 400293, 411687, 423191, 433572, 445239, 457001, 467490, 479379, 491346,
    501878, 513934, 526049, 536557, 548720, 560923, 571333, 583539, 591882, 600000
  ]

  FAST = [0,
    # (4.0 * n ** 3) / 5.0
    1, 6, 22, 51, 100, 173, 274, 410, 583, 800,
    1065, 1382, 1758, 2195, 2700, 3277, 3930, 4666, 5487, 6400,
    7409, 8518, 9734, 11059, 12500, 14061, 15746, 17562, 19511, 21600,
    23833, 26214, 28750, 31443, 34300, 37325, 40522, 43898, 47455, 51200,
    55137, 59270, 63606, 68147, 72900, 77869, 83058, 88474, 94119, 100000,
    106121, 112486, 119102, 125971, 133100, 140493, 148154, 156090, 164303, 172800,
    181585, 190662, 200038, 209715, 219700, 229997, 240610, 251546, 262807, 274400,
    286329, 298598, 311214, 324179, 337500, 351181, 365226, 379642, 394431, 409600,
    425153, 441094, 457430, 474163, 491300, 508845, 526802, 545178, 563975, 583200,
    602857, 622950, 643486, 664467, 685900, 707789, 730138, 752954, 776239, 800000
  ]

  MEDIUMFAST = [0,
    # n ** 3
    1, 8, 27, 64, 125, 216, 343, 512, 729, 1000,
    1331, 1728, 2197, 2744, 3375, 4096, 4913, 5832, 6859, 8000,
    9261, 10648, 12167, 13824, 15625, 17576, 19683, 21952, 24389, 27000,
    29791, 32768, 35937, 39304, 42875, 46656, 50653, 54872, 59319, 64000,
    68921, 74088, 79507, 85184, 91125, 97336, 103823, 110592, 117649, 125000,
    132651, 140608, 148877, 157464, 166375, 175616, 185193, 195112, 205379, 216000,
    226981, 238328, 250047, 262144, 274625, 287496, 300763, 314432, 328509, 343000,
    357911, 373248, 389017, 405224, 421875, 438976, 456533, 474552, 493039, 512000,
    531441, 551368, 571787, 592704, 614125, 636056, 658503, 681472, 704969, 729000,
    753571, 778688, 804357, 830584, 857375, 884736, 912673, 941192, 970299, 1000000
  ]

  MEDIUMSLOW = [0,
    # (6.0 * n ** 3) / 5.0 - 15.0 * n ** 2 + 100.0 * n - 140
    0, 10, 57, 97, 135, 179, 237, 314, 420, 560,
    742, 974, 1261, 1613, 2035, 2535, 3121, 3798, 4576, 5460,
    6458, 7578, 8825, 10209, 11735, 13411, 15245, 17242, 19412, 21760,
    24294, 27022, 29949, 33085, 36435, 40007, 43809, 47846, 52128, 56660,
    61450, 66506, 71833, 77441, 83335, 89523, 96013, 102810, 109924, 117360,
    125126, 133230, 141677, 150477, 159635, 169159, 179057, 189334, 200000, 211060,
    222522, 234394, 246681, 259393, 272535, 286115, 300141, 314618, 329556, 344960,
    360838, 377198, 394045, 411389, 429235, 447591, 466465, 485862, 505792, 526260,
    547274, 568842, 590969, 613665, 636935, 660787, 685229, 710266, 735908, 762160,
    789030, 816526, 844653, 873421, 902835, 932903, 963633, 995030, 1027104, 1059860
  ]

  SLOW = [0,
    # (5.0 * n ** 3) / 4.0
    1, 10, 34, 80, 156, 270, 429, 640, 911, 1250,
    1664, 2160, 2746, 3430, 4219, 5120, 6141, 7290, 8574, 10000,
    11576, 13310, 15209, 17280, 19531, 21970, 24604, 27440, 30486, 33750,
    37239, 40960, 44921, 49130, 53594, 58320, 63316, 68590, 74149, 80000,
    86151, 92610, 99384, 106480, 113906, 121670, 129779, 138240, 147061, 156250,
    165814, 175760, 186096, 196830, 207969, 219520, 231491, 243890, 256724, 270000,
    283726, 297910, 312559, 327680, 343281, 359370, 375954, 393040, 410636, 428750,
    447389, 466560, 486271, 506530, 527344, 548720, 570666, 593190, 616299, 640000,
    664301, 689210, 714734, 740880, 767656, 795070, 823129, 851840, 881211, 911250,
    941964, 973360, 1005446, 1038230, 1071719, 1105920, 1140841, 1176490, 1212874, 1250000
  ]

  FLUCTUATING = [0,
    #case n
    #when 0..15
    #  ((((n + 1.0) / 3.0).floor + 24) / 50.0) * n ** 3
    #when 16..36
    #  ((n + 14.0) / 50.0) * n ** 3
    #when 37..100
    #  (((n / 2.0) + 32.0) / 50.0) * n ** 3
    #end
    0, 4, 14, 32, 65, 112, 178, 276, 394, 540,
    745, 968, 1230, 1592, 1957, 2458, 3046, 3732, 4527, 5440,
    6483, 7667, 9004, 10506, 12188, 14061, 16140, 18440, 20975, 23760,
    26812, 30147, 33781, 37732, 42018, 46656, 51160, 55969, 61099, 66560,
    72367, 78533, 85072, 91999, 99326, 107070, 115244, 123863, 132943, 142500,
    152549, 163105, 174186, 185808, 197986, 210739, 224084, 238037, 252616, 267840,
    283726, 300293, 317560, 335544, 354266, 373745, 394000, 415050, 436917, 459620,
    483180, 507617, 532953, 559209, 586406, 614566, 643712, 673864, 705046, 737280,
    770589, 804997, 840527, 877202, 915046, 954084, 994340, 1035837, 1078603, 1122660,
    1168035, 1214753, 1262840, 1312323, 1363226, 1415578, 1469404, 1524731, 1581587, 1640000
  ]

  module_function
  def get_exp(rate, level)
    validate rate => [Symbol, String], level => Integer
    return const_get(rate)[level]
  end

  def get_level(rate, exp)
    validate rate => [Symbol, String], exp => Integer
    a = const_get(rate)
    for i in 0...a.size
      if a[i] > exp
        return i - 1
      end
    end
    return 100
  end
end
