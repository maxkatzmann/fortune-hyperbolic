from multiset import Multiset
from pathlib import Path
import os


class Point:
    def __init__(self, radius, angle):
        self.radius = radius
        self.angle = angle

    def __eq__(self, other):
        return self.radius == other.radius and self.angle == other.angle

    def __hash__(self):
        return hash((self.radius, self.angle))


def read_diagram(file_path):
    points = []
    with open(file_path, 'r') as f:
        for line in f:
            radius, angle = [float(x) for x in line.split(' ')]
            points.append(Point(radius, angle))

    def point_compare(p):
        return (p.radius, p.angle)

    return sorted(points, key=point_compare)


def matches_between_point_sets(points1, points2):
    point_set1 = Multiset(points1)
    point_set2 = Multiset(points2)
    return len(point_set1.intersection(point_set2))


def get_number_of_points_in_file(disk_radius, diagram_id):
    points_path = Path(os.getcwd()) / 'experiments' / 'data'
    file_path = str(disk_radius) + '-' + str(diagram_id) + '.txt'

    path = points_path / Path(file_path)
    num_lines = sum(1 for line in open(path))

    return num_lines
