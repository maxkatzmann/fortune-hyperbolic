# Given a set of files containing voronoi vertices, compares in how many points
# they differ.
#
# Usage:
#   bazel run -c opt experiments/diagram_cgal_comparison_aggregation_util -- --diagrams path/to/directory/containing/diagrams --output path/to/where/the/result should be stored
#

import argparse
from functools import cmp_to_key
import sys
from os import listdir
from os.path import isdir, isfile, join
from pathlib import Path

from diagram_comparison import read_diagram, matches_between_point_sets, get_number_of_points_in_file


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Compares diagrams with repsect to how many Voronoi vertices they share and writes the result to a CSV.'
    )
    parser.add_argument('-r',
                        '--results',
                        help='Path to the directory containing the diagrams.')
    parser.add_argument('-o', '--output', help="Path to the output CSV file.")
    args = parser.parse_args(argv[1:])
    csv = generate_csv_from_results(args.results)
    write_csv_to_file(csv, args.output)


def get_diagram_names(results_directory):
    return [
        d for d in listdir(results_directory)
        if isdir(join(results_directory, d))
    ]


def get_native_precision_diagram(name, results_directory):
    diagrams_path = Path(results_directory) / name / 'diagrams'

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

    return read_diagram(diagram_files[-1])


def get_cgal_diagram(name, results_directory):
    diagrams_path = Path(results_directory) / name / 'diagrams-cgal'
    file_name = name + '-diagram-cgal.txt'

    return read_diagram(diagrams_path / file_name)


def get_row_from_comparison_between(name, diagram1, diagram2):
    disk_radius, diagram_id = name.split('-')
    number_of_points = get_number_of_points_in_file(disk_radius, diagram_id)

    vertex_percentage = float(len(diagram2)) / float(len(diagram1))
    number_of_matching_vertices = matches_between_point_sets(
        diagram1, diagram2)
    match_percentage = float(number_of_matching_vertices) / float(
        len(diagram1))

    return [
        disk_radius, diagram_id, number_of_points, vertex_percentage,
        match_percentage
    ]


def get_header():
    return [
        'DiskRadius', 'DiagramID', 'NumberOfPoints', 'VertexPercentage',
        'MatchingPercentage'
    ]


def generate_csv_from_results(results_directory):
    header = get_header()
    rows = []

    diagram_names = get_diagram_names(results_directory)
    for diagram_name in diagram_names:
        diagram_native = get_native_precision_diagram(diagram_name,
                                                      results_directory)
        diagram_cgal = get_cgal_diagram(diagram_name, results_directory)
        row = get_row_from_comparison_between(diagram_name, diagram_native,
                                              diagram_cgal)
        rows.append(row)

    rows = sorted(rows, key=lambda x: (int(x[0]), int(x[1])))
    rows = [[str(entry) for entry in row] for row in rows]

    header_string = ', '.join(header)
    row_strings = [', '.join(row) for row in rows]
    return '\n'.join([header_string, *row_strings])


def write_csv_to_file(csv, output_file):
    with open(output_file, 'w') as csv_file:
        csv_file.write(csv)


if __name__ == '__main__':
    main(sys.argv)
