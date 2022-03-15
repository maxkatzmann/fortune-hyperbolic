# A utility to check whether triangulations are identical

import argparse
import sys

from diagram_comparison import get_number_of_points_in_file
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


def percent_of_covered_edges(triangulation1, triangulation2):
    edges_from_1_covered_by_2 = 0
    edges_from_2_covered_by_1 = 0

    edges_in_1 = 0
    edges_in_2 = 0
    for u, v in triangulation1.iterEdges():
        edges_in_1 += 1

        if triangulation2.hasEdge(u, v):
            edges_from_1_covered_by_2 += 1

    for u, v in triangulation2.iterEdges():
        edges_in_2 += 1
        if triangulation1.hasEdge(u, v):
            edges_from_2_covered_by_1 += 1

    return (float(edges_from_1_covered_by_2) / float(edges_in_1),
            float(edges_from_2_covered_by_1) / float(edges_in_2))


def get_rows_from_comparison_between(name, precision_triangulation,
                                     native_triangulations,
                                     cgal_triangulation):
    rows = []
    disk_radius, diagram_id = name.split('-')
    number_of_points = get_number_of_points_in_file(disk_radius, diagram_id)

    precise_edges_covered_by_cgal, cgal_edges_covered_by_precise = percent_of_covered_edges(
        precision_triangulation, cgal_triangulation)

    cgal_row = [
        disk_radius, diagram_id, number_of_points, "CGAL",
        precise_edges_covered_by_cgal, cgal_edges_covered_by_precise
    ]

    rows.append(cgal_row)

    for (precision, native_triangulation) in native_triangulations:
        precise_edges_covered_by_native, native_edges_covered_by_precise = percent_of_covered_edges(
            precision_triangulation, native_triangulation)

        row = [
            disk_radius, diagram_id, number_of_points, precision,
            precise_edges_covered_by_native, native_edges_covered_by_precise
        ]
        rows.append(row)

    return rows


def get_header():
    header = [
        'DiskRadius', 'DiagramID', 'NumberOfSites', 'Precision',
        'PreciseCoveredByTechnique', 'TechniqueCoveredByPrecise'
    ]

    return header


def generate_csv_from_results(results_directory):
    header = get_header()
    rows = []

    triangulation_names = get_triangulation_names(results_directory)
    for triangulation_name in triangulation_names:
        triangulation_precise = get_native_precision_triangulation(
            triangulation_name, results_directory)
        triangulations_native = get_native_triangulations(
            triangulation_name, results_directory)
        triangulation_cgal = get_cgal_triangulation(triangulation_name,
                                                    results_directory)
        compare_rows = get_rows_from_comparison_between(
            triangulation_name, triangulation_precise, triangulations_native,
            triangulation_cgal)
        rows += compare_rows

    rows = sorted(rows, key=lambda x: (float(x[0]), int(x[1])))
    rows = [[str(entry) for entry in row] for row in rows]

    header_string = ','.join(header)
    row_strings = [','.join(row) for row in rows]
    return '\n'.join([header_string, *row_strings])


def write_csv_to_file(csv, output_file):
    with open(output_file, 'w') as csv_file:
        csv_file.write(csv)


if __name__ == '__main__':
    main(sys.argv)
