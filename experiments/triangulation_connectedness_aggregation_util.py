# A utility that checks whether the graphs represented by triangulations are
# connected.
#
# Usage:
#   bazel run -c opt triangulation_connectedness_aggregation_util -- --results path/to/results

import argparse
import sys
import networkit as nk

from diagram_comparison import get_number_of_points_in_file
from triangulation_comparison import get_triangulation_names, get_native_precision_triangulation, get_cgal_triangulation


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Iterates the triangulations in the passed results directory and determines whether which consists of only one component.'
    )
    parser.add_argument(
        '-r',
        '--results',
        help='Path to the results directory containing the triangluations.')
    parser.add_argument('-o', '--output', help="Path to the output CSV file.")
    args = parser.parse_args(argv[1:])

    csv = generate_csv_from_results(args.results)
    write_csv_to_file(csv, args.output)


def get_number_of_connected_components(graph):
    cc = nk.components.ConnectedComponents(graph)
    cc.run()
    return cc.numberOfComponents()


def get_row_from_comparison_between(name, native_triangulation,
                                    cgal_triangulation):
    disk_radius, diagram_id = name.split('-')
    number_of_points = get_number_of_points_in_file(disk_radius, diagram_id)

    native_components = get_number_of_connected_components(
        native_triangulation)
    cgal_components = get_number_of_connected_components(cgal_triangulation)

    return [
        disk_radius, diagram_id, number_of_points, native_components,
        cgal_components
    ]


def get_header():
    return [
        'DiskRadius', 'DiagramID', 'NumberOfSites', 'NativeComponents',
        'CGALComponents'
    ]


def generate_csv_from_results(results_directory):
    header = get_header()
    rows = []

    triangulation_names = get_triangulation_names(results_directory)
    for triangulation_name in triangulation_names:
        triangulation_native = get_native_precision_triangulation(
            triangulation_name, results_directory)
        triangulation_cgal = get_cgal_triangulation(triangulation_name,
                                                    results_directory)
        row = get_row_from_comparison_between(triangulation_name,
                                              triangulation_native,
                                              triangulation_cgal)
        rows.append(row)

    rows = sorted(rows, key=lambda x: (float(x[0]), int(x[1])))
    rows = [[str(entry) for entry in row] for row in rows]

    header_string = ', '.join(header)
    row_strings = [', '.join(row) for row in rows]
    return '\n'.join([header_string, *row_strings])


def write_csv_to_file(csv, output_file):
    with open(output_file, 'w') as csv_file:
        csv_file.write(csv)


if __name__ == '__main__':
    main(sys.argv)
