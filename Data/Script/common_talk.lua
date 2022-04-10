--[[
    common_talk.lua
    For talk personalities
]]--

COMMON.PERSONALITY = { }
COMMON.PERSONALITY[0] = { -- partner
  FULL = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
  HALF = {0, 1, 2},
  PINCH = {0, 1, 2},
  WAIT = {0, 1, 2, 3}
}
COMMON.PERSONALITY[1] = { -- confident
  FULL = {20, 21, 22, 23, 24, 25, 26},
  HALF = {5, 6, 7},
  PINCH = {5, 6, 7},
  WAIT = {5, 6, 7}
}
COMMON.PERSONALITY[2] = { -- nervous
  FULL = {40, 41, 42, 43, 44, 45, 46, 47, 48, 49},
  HALF = {10, 11, 12, 13},
  PINCH = {10, 11, 12},
  WAIT = {10, 11, 12}
}
COMMON.PERSONALITY[3] = { -- cautious
  FULL = {60, 61, 62, 63, 64, 65, 66},
  HALF = {15, 16, 17},
  PINCH = {15, 16, 17},
  WAIT = {15, 16, 17}
}
COMMON.PERSONALITY[4] = { -- musing
  FULL = {80, 81, 82, 83, 84, 85, 86},
  HALF = {20, 21, 22, 23},
  PINCH = {20, 21, 22},
  WAIT = {20, 21, 22}
}
COMMON.PERSONALITY[5] = { -- legend
  FULL = {100, 101, 102, 103, 104},
  HALF = {25, 26, 27},
  PINCH = {25, 26, 27},
  WAIT = {25, 26}
}
COMMON.PERSONALITY[6] = { -- robot
  FULL = {120, 121, 122, 123, 124, 125, 126},
  HALF = {30, 31, 32},
  PINCH = {30, 31, 32},
  WAIT = {30, 31, 32}
}
COMMON.PERSONALITY[7] = { -- jock
  FULL = {140, 141, 142, 143, 144, 145, 146, 147},
  HALF = {35, 36, 37},
  PINCH = {35, 36, 37},
  WAIT = {35, 36, 37}
}
COMMON.PERSONALITY[8] = { -- child
  FULL = {160, 161, 162, 163, 142, 144},
  HALF = {40, 41, 42},
  PINCH = {40, 41, 42},
  WAIT = {40, 41, 42}
}
COMMON.PERSONALITY[9] = { -- selfless
  FULL = {180, 181, 182, 183, 184, 2, 6, 10},
  HALF = {45, 46, 47},
  PINCH = {45, 46, 47},
  WAIT = {45, 46, 47, 0, 3}
}
COMMON.PERSONALITY[10] = { -- reckless
  FULL = {200, 201, 202, 203, 204, 205, 206},
  HALF = {50, 51, 52},
  PINCH = {50, 51, 52},
  WAIT = {50, 51, 52}
}
COMMON.PERSONALITY[11] = { -- lazy
  FULL = {220, 221, 222, 223, 224, 225, 226, 227, 228},
  HALF = {55, 56, 57},
  PINCH = {55, 56, 57},
  WAIT = {55, 56, 57, 58}
}
COMMON.PERSONALITY[12] = { -- loud
  FULL = {240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252},
  HALF = {60, 61, 62},
  PINCH = {60, 61, 62},
  WAIT = {60, 61, 62, 63}
}
COMMON.PERSONALITY[13] = { -- snooty
  FULL = {260, 261, 262, 263, 264, 265, 266, 267, 268},
  HALF = {65, 66, 67},
  PINCH = {65, 66, 67},
  WAIT = {65, 66, 67}
}
COMMON.PERSONALITY[14] = { -- hyped
  FULL = {280, 281, 282, 283, 284, 285, 261, 266},
  HALF = {70, 71, 72},
  PINCH = {70, 71, 72},
  WAIT = {70, 71, 72}
}
COMMON.PERSONALITY[15] = { -- reserved
  FULL = {300, 301, 302, 303, 304, 305, 22},
  HALF = {75, 76, 77},
  PINCH = {75, 76, 77},
  WAIT = {75, 76, 77}
}
COMMON.PERSONALITY[16] = { -- greedy
  FULL = {320, 321, 322, 323, 324, 325, 326, 327},
  HALF = {80, 81, 82},
  PINCH = {80, 81, 82},
  WAIT = {80, 81, 82}
}
COMMON.PERSONALITY[24] = { -- baby / manaphy
  FULL = {640, 641, 642, 643, 644, 645, 646, 647, 648},
  HALF = {135, 136, 137, 138, 139},
  PINCH = {135, 136, 137, 138, 139},
  WAIT = {135, 136, 137, 138, 139}
}
COMMON.PERSONALITY[26] = { -- formal
  FULL = {680, 681, 682, 683, 684, 685, 686, 687},
  HALF = {145, 146, 147, 148, 149},
  PINCH = {145, 146, 147, 148, 149},
  WAIT = {145, 146, 147, 148, 149}
}
COMMON.PERSONALITY[29] = { -- knight
  FULL = {740, 741, 742, 743, 744, 745},
  HALF = {160, 161, 162, 163},
  PINCH = {160, 161, 162, 163},
  WAIT = {150, 151, 152, 153}
}
COMMON.PERSONALITY[30] = { -- teenager
  FULL = {750, 751, 752, 753, 754, 755},
  HALF = {165, 166, 167, 168},
  PINCH = {165, 166, 167, 168},
  WAIT = {155, 156, 157, 158}
}
COMMON.PERSONALITY[31] = { -- normal
  FULL = {760, 761, 762, 763, 764, 765},
  HALF = {170, 171, 172, 173},
  PINCH = {170, 171, 172, 173},
  WAIT = {160, 161, 162, 163}
}
COMMON.PERSONALITY[32] = { -- dialga
  FULL = {770, 771, 772, 773, 774, 775},
  HALF = {175, 176, 177, 178},
  PINCH = {175, 176, 177, 178},
  WAIT = {165, 166, 167, 168}
}
COMMON.PERSONALITY[33] = { -- palkia
  FULL = {780, 781, 782, 783, 784, 785},
  HALF = {180, 181, 182, 183},
  PINCH = {180, 181, 182, 183},
  WAIT = {170, 171, 172, 173}
}
COMMON.PERSONALITY[34] = { -- regigigas
  FULL = {790, 791, 792, 793, 794, 795},
  HALF = {185, 186, 187, 188},
  PINCH = {185, 186, 187, 188},
  WAIT = {175, 176, 177, 178}
}
COMMON.PERSONALITY[35] = { -- darkrai
  FULL = {800, 801, 802, 803, 804, 805},
  HALF = {190, 191, 192, 193},
  PINCH = {190, 191, 192, 193},
  WAIT = {180, 181, 182, 183}
}
COMMON.PERSONALITY[36] = { -- shopkeeper
  FULL = {810, 811, 812, 813, 814, 815},
  HALF = {195, 196, 197, 198},
  PINCH = {195, 196, 197, 198},
  WAIT = {185, 186, 187, 188}
}
COMMON.PERSONALITY[37] = { -- escort
  FULL = {820},
  HALF = {200},
  PINCH = {200},
  WAIT = {190}
}