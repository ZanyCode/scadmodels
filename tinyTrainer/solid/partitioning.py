from enum import Enum
from typing import List
import solid.solidpython as solid

def render_colored(objects):
    from solid import color, scad_render_to_file, union
    import random
    objects = [color((random.uniform(0, 1), random.uniform(0,1), random.uniform(0,1)))(o) for o in objects]
    scad_render_to_file(union()(*objects), 'tt_matek_frame.scad')

def render_uncolored(objects):
    from solid import color, scad_render_to_file, union
    import random
    scad_render_to_file(union()(*objects), 'tt_matek_frame.scad')

class IntersectionType(Enum):
    Zero = 0
    Partial = 1
    Total = 2
    Inside = 3


def get_interception_axis(partitioner_start, partitioner_end, partitionee_start, partitionee_end):
    if partitioner_start >= partitionee_end or partitioner_end <= partitionee_start:
        return IntersectionType.Zero
    if partitioner_start > partitionee_start and partitioner_end < partitionee_end:
        return IntersectionType.Inside
    if partitioner_start < partitioner_start and partitioner_end > partitionee_end:
        return IntersectionType.Total

    return IntersectionType.Partial


def is_intercepting(intercepter: "OpenSCADObject", interceptee: "OpenSCADObject") -> "OpenSCADObject":
    x_interception, y_interception, z_interception = [get_interception_axis(
        intercepter.origin[i],
        intercepter.get_extent()[i],
        interceptee.origin[i],
        interceptee.get_extent()[i])
        for i in range(3)]

    return x_interception != IntersectionType.Zero and y_interception != IntersectionType.Zero and z_interception != IntersectionType.Zero


def get_partitions(partitioner: "OpenSCADObject", partitionee: "OpenSCADObject") -> List["OpenSCADObject"]:
    if not is_intercepting(partitioner, partitionee):
        return [partitionee]

    def get_base3_bit(number, bit):
        def numberToBase(n, b):
            if n == 0:
                return [0]
            digits = []
            while n:
                digits.append(int(n % b))
                n //= b
            return digits[::-1]

        base3_representation = numberToBase(number, 3)[::-1]
        return base3_representation[bit] if len(base3_representation) > bit else 0

    partitioner_extent = tuple(min(partitioner.get_extent()[i], partitionee.get_extent()[i]) for i in range(3))
    partitioner_origin = tuple(max(partitioner.origin[i], partitionee.origin[i]) for i in range(3))

    origin_points = [partitionee.origin, partitioner_origin, partitioner_extent]
    origins = [(origin_points[get_base3_bit(t, 0)][0],
                origin_points[get_base3_bit(t, 1)][1],
                origin_points[get_base3_bit(t, 2)][2])
               for t in range(27)]

    extent_points = [partitioner_origin, partitioner_extent, partitionee.get_extent()]
    sizes = [(extent_points[get_base3_bit(t, 0)][0] - origin[0],
              extent_points[get_base3_bit(t, 1)][1] - origin[1],
              extent_points[get_base3_bit(t, 2)][2] - origin[2])
             for t, origin in zip(range(27), origins)]

    return [solid.objects.cube(size).translate(origin) for size, origin in zip(sizes, origins) if not min(size) <= 0]


def partition_element(partitioner: "OpenSCADObject", partitionee: "OpenSCADObject") -> List["OpenSCADObject"]:
    partitions = get_partitions(partitioner, partitionee)
    return [p for p in partitions if not is_intercepting(partitioner, p)]


def get_all_partitions(partitioners: List["OpenSCADObject"], partitionees: List["OpenSCADObject"]):
    if len(partitioners) <= 0:
        return partitionees

    partitioner = partitioners[0]
    new_partitionees_nested = [partition_element(partitioner, partitionee) for partitionee in partitionees]
    new_partitionees = [p for pn in new_partitionees_nested for p in pn]
    return get_all_partitions(partitioners[1:], new_partitionees)