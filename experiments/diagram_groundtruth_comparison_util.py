# Given a set of files containing voronoi vertices, compares in how many points
# they differ.
#
# Usage:
#   bazel run -c opt experiments/diagram_groundtruth_comparison_util -- --diagrams path/to/directory/containing/diagrams --output path/to/result/directory
#

import argparse
from functools import cmp_to_key
import sys
from os import listdir
from os.path import isfile, join

from pathlib import Path

from experiments.diagram_groundtruth_comparison_pb2 import Comparison
from diagram_comparison import read_diagram, matches_between_point_sets, get_number_of_points_in_file, precision_sort


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

    diagram_files = sorted([
        join(diagrams_path, f)
        for f in listdir(diagrams_path) if isfile(join(diagrams_path, f))
    ],
                           key=cmp_to_key(precision_sort))

    comparison = Comparison()

    groundtruth_path = diagram_files[-1]
    (groundtruth_radius, groundtruth_id,
     groundtruth_precision) = get_parameters_from_file_path(groundtruth_path)
    comparison.diskRadius = groundtruth_radius
    comparison.diagram = groundtruth_id
    comparison.numberOfPoints = get_number_of_points_in_file(
        groundtruth_radius, groundtruth_id)

    groundtruth_points = read_diagram(groundtruth_path)

    comparison.groundTruth.precision = groundtruth_precision
    comparison.groundTruth.numberOfVertices = len(groundtruth_points)
    comparison.groundTruth.numberOfVerticesMatchingGroundTruth = -1

    for cmp_file in diagram_files[:-1]:
        (comparison_radius, comparison_id,
         comparison_precision) = get_parameters_from_file_path(cmp_file)
        comparison_points = read_diagram(cmp_file)

        comparison_result = comparison.comparisons.add()
        comparison_result.precision = comparison_precision
        comparison_result.numberOfVertices = len(comparison_points)

        number_of_matches = matches_between_point_sets(groundtruth_points,
                                                       comparison_points)
        comparison_result.numberOfVerticesMatchingGroundTruth = number_of_matches

    # Write the new comparison to file.
    output_file_name = Path(args.output) / Path(
        str(groundtruth_radius) + "-" + str(groundtruth_id) +
        "-diagrams-groundtruth-comparison.pb")
    f = open(output_file_name, "wb")
    f.write(comparison.SerializeToString())
    f.close()
    print(f'Result written to file: {output_file_name}')


def get_parameters_from_file_path(file_path):
    # 24-1-precision-64.txt
    file_name = Path(file_path).name
    file_name = file_name.replace('.txt', '')
    file_name_components = file_name.split('-')
    return (float(file_name_components[0]), int(file_name_components[1]),
            int(file_name_components[-1]))


if __name__ == '__main__':
    main(sys.argv)
