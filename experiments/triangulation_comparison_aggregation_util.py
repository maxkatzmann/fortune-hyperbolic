# A utility to check whether triangulations are identical

import argparse
import sys

from diagram_comparison import get_number_of_points_in_file, get_precision_from_file_name
from triangulation_comparison import get_triangulation_names, get_native_precision_triangulation, get_cgal_triangulation, get_native_triangulations


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Compares triangulations with repsect to how many edges they share and writes the result to a CSV.'
    )
    parser.add_argument('-r',
                        '--results',
                        help='Path to the directory containing the results.')
    parser.add_argument(
        '-o',
        '--output',
        help="Path to the directory where the result file should be stored.")
    args = parser.parse_args(argv[1:])

    csv = generate_csv_from_results(args.results)
    write_csv_to_file(csv, args.output)


def numbers_of_missing_edges(native_triangulation, cgal_triangulation):
    edges_missing_in_native = 0
    edges_missing_in_cgal = 0
    for u, v in native_triangulation.iterEdges():
        if cgal_triangulation.hasEdge(u, v):
            continue

        edges_missing_in_cgal += 1

    for u, v in cgal_triangulation.iterEdges():
        if native_triangulation.hasEdge(u, v):
            continue

        edges_missing_in_native += 1

    return (edges_missing_in_native, edges_missing_in_cgal)


def get_row_from_comparison_between(name, precision_triangulation,
                                    native_triangulations, cgal_triangulation):
    disk_radius, diagram_id = name.split('-')
    number_of_points = get_number_of_points_in_file(disk_radius, diagram_id)

    edges_missing_in_precision, edges_missing_in_cgal = numbers_of_missing_edges(
        precision_triangulation, cgal_triangulation)

    row_values = [
        disk_radius, diagram_id, number_of_points, edges_missing_in_precision,
        edges_missing_in_cgal
    ]

    for (precision, native_triangulation) in native_triangulations:
        edges_missing_in_precision, edges_missing_in_native = numbers_of_missing_edges(
            precision_triangulation, native_triangulation)

        row_values.append(edges_missing_in_precision)
        row_values.append(edges_missing_in_native)

    return row_values


def get_header(native_triangulations):
    header = [
        'DiskRadius', 'DiagramID', 'NumberOfPoints',
        'EdgesMissingPreciseFromCGAL', 'EdgesMissingCGALFromPrecise'
    ]

    for (precision, triangulation) in native_triangulations:
        header.append('EdgesMissingPreciseFrom' + str(precision))
        header.append('EdgesMissing' + str(precision) + 'FromPrecise')

    return header


def generate_csv_from_results(results_directory):
    header = []
    rows = []

    triangulation_names = get_triangulation_names(results_directory)
    for triangulation_name in triangulation_names:
        triangulation_precise = get_native_precision_triangulation(
            triangulation_name, results_directory)
        triangulations_native = get_native_triangulations(
            triangulation_name, results_directory)
        header = get_header(triangulations_native)
        triangulation_cgal = get_cgal_triangulation(triangulation_name,
                                                    results_directory)
        row = get_row_from_comparison_between(triangulation_name,
                                              triangulation_precise,
                                              triangulations_native,
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
