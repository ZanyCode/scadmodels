import random
from enum import Enum

from solid import *
from solid.partitioning import get_all_partitions, render_colored, render_uncolored
from solid.utils import *

fast_render = True

# Matek board
strength = 1.8
hole_distance = 24
hole_radius = 1.25
nut_inlay_radius_outer = 3
nut_inlay_radius_inner = 3.9 / 2
board_size = hole_distance + nut_inlay_radius_outer * 2

# Receiver
receiver_x = 48
receiver_y = 15
receiver_z = 25.5

receiver_cutout = union()(
    cube((receiver_x + strength, receiver_y, receiver_z / 2)).move_right(strength),
    cube([receiver_x + strength, receiver_y, receiver_z / 2]).move_up(receiver_z / 2)
)

receiver_clamp = difference()(
    cube((receiver_x + strength * 2, receiver_y + strength, receiver_z + strength * 2)),
    receiver_cutout().move_up(strength),
)

nut_inlay = difference()(
        cylinder(nut_inlay_radius_outer, 5).rotate(90, LEFT_VEC),
        cylinder(nut_inlay_radius_inner, 5).rotate(90, LEFT_VEC)
      ) \
    .center_behind(receiver_clamp, self_point_relative=(.5, 0, .5))

frame = receiver_clamp() \
    + cube((board_size, strength, board_size)).center_behind(receiver_clamp, (.5, 1, .5)) \
    + nut_inlay.move_up(hole_distance / 2).move_left(hole_distance / 2) \
    + nut_inlay.move_up(hole_distance / 2).move_right(hole_distance / 2) \
    + nut_inlay.move_down(hole_distance / 2).move_left(hole_distance / 2) \
    + nut_inlay.move_down(hole_distance / 2).move_right(hole_distance / 2)

spacer = cylinder(3.2/2.0, 5.8) - cylinder(2.4/2, 5.8)
scad_render_to_file(frame, 'tt_matek_frame.scad',
                    file_header=f'$fn = {"10" if fast_render else "100"};')
