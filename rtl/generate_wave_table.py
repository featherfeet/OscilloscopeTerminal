#!/usr/bin/env python3

import math

DAC_BITS = 8
WAVE_TABLE_LENGTH = 255

x = 0.0

output_file = open("sine_wave_{}_bit_dac_{}_entries.mem".format(DAC_BITS, WAVE_TABLE_LENGTH), 'w')

while x <= math.pi * 2.0:
    y = 0.5 * math.sin(x) + 0.5
    y_integer = int(y * (2 ** DAC_BITS - 1))
    print(y_integer)
    output_file.write("{}\n".format(hex(y_integer)[2:]))
    x += (math.pi * 2.0) / WAVE_TABLE_LENGTH

output_file.close()
