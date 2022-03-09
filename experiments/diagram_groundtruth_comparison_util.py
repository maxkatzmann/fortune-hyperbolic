# Given two files containing voronoi vertices, compares in how many points they
# differ.
#
# Usage:
#   bazel run -c opt experiments/diagram_groundtruth_comparison_util -- --diagrams path/to/directory/containing/diagrams --output path/to/where/the/result should be stored
#

import argparse
from functools import cmp_to_key
import sys
import os
from os import listdir
from os.path import isfile, join

from pathlib import Path
from multiset import Multiset

from experiments.diagram_groundtruth_comparison_pb2 import Comparison


class Point:
    def __init__(self, radius, angle):
        self.radius = radius
        self.angle = angle

    def __eq__(self, other):
        return self.radius == other.radius and self.angle == other.angle

    def __hash__(self):
        return hash((self.radius, self.angle))


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Compares diagrams with repsect to how many Voronoi vertices they share and writes the result to protobufs.'
    )
    parser.add_argument('-d',
                        '--diagrams',
                        help='Path to the directory containing the diagrams.')
    parser.add_argument(
        '-o',
        '--output',
        help="Path to the directory where the result file should be stored.")
    args = parser.parse_args(argv[1:])

    diagrams_path = args.diagrams

    def precision_sort(path1, path2):
        path1WithoutExtension = path1.replace('.txt', '')
        path2WithoutExtension = path2.replace('.txt', '')
        components1 = path1WithoutExtension.split('-')
        components2 = path2WithoutExtension.split('-')

        precision1 = int(components1[-1])
        precision2 = int(components2[-1])

        if precision1 < precision2:
            return -1
        else:
            return 1

    diagram_files = sorted([
        join(diagrams_path, f)
        for f in listdir(diagrams_path) if isfile(join(diagrams_path, f))
    ],
                           key=cmp_to_key(precision_sort))
    print(diagram_files)

    comparison = Comparison()

    groundtruth_path = diagram_files[-1]
    (groundtruth_radius, groundtruth_id,
     groundtruth_precision) = get_parameters_from_file_path(groundtruth_path)
    comparison.diskRadius = groundtruth_radius
    comparison.diagram = groundtruth_id
    comparison.numberOfPoints = get_number_of_points_in_file(
        groundtruth_radius, groundtruth_id)

    groundtruth_points = read_file(groundtruth_path)
    groundtruth_point_set = Multiset(groundtruth_points)

    comparison.groundTruth.precision = groundtruth_precision
    comparison.groundTruth.numberOfVertices = len(groundtruth_points)
    comparison.groundTruth.numberOfVerticesMatchingGroundTruth = -1

    for cmp_file in diagram_files[1:]:
        (comparison_radius, comparison_id,
         comparison_precision) = get_parameters_from_file_path(cmp_file)
        comparison_points = read_file(cmp_file)

        comparison_result = comparison.comparisons.add()
        comparison_result.precision = comparison_precision
        comparison_result.numberOfVertices = len(comparison_points)

        comparison_point_set = Multiset(comparison_points)

        number_of_matches = len(
            groundtruth_point_set.intersection(comparison_point_set))
        comparison_result.numberOfVerticesMatchingGroundTruth = number_of_matches

    # Write the new comparison to file.
    output_file_name = Path(args.output) / Path(
        str(groundtruth_radius) + "-" + str(groundtruth_id) +
        "-diagrams-groundtruth-comparison.pb")
    f = open(output_file_name, "wb")
    f.write(comparison.SerializeToString())
    f.close()
    print(f'Result written to file: {output_file_name}')


def read_file(file_path):
    print(f'Reading file: {file_path}')

    points = []
    with open(file_path, 'r') as f:
        for line in f:
            radius, angle = [float(x) for x in line.split(' ')]
            points.append(Point(radius, angle))

    def point_compare(p):
        return (p.radius, p.angle)

    return sorted(points, key=point_compare)


def get_parameters_from_file_path(file_path):
    # 24-1-precision-64.txt
    file_name = Path(file_path).name
    file_name = file_name.replace('.txt', '')
    file_name_components = file_name.split('-')
    return (int(file_name_components[0]), int(file_name_components[1]),
            int(file_name_components[-1]))


def get_number_of_points_in_file(disk_radius, diagram_id):
    points_path = Path(os.getcwd()) / 'experiments' / 'data'
    file_path = str(disk_radius) + '-' + str(diagram_id) + '.txt'

    path = points_path / Path(file_path)
    num_lines = sum(1 for line in open(path))

    return num_lines


if __name__ == '__main__':
    main(sys.argv)
