# Given the results of the comparison with the groundtruths, generates a CSV
# file that aggregates these results into a single table.
#
# Usage:
#   bazel run -c opt experiments/diagram_groundtruth_comparison_aggregation_util -- \
#     --results path/to/results

import argparse
import sys
from os import listdir
from os.path import isdir, isfile, join

from experiments.diagram_groundtruth_comparison_pb2 import Comparison


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Collects results from protobuffers and aggregates them in a single CSV file.'
    )
    parser.add_argument('-r',
                        '--results',
                        help='Path to the directory containing the results.')
    parser.add_argument('-o', '--output', help='Path to output csv file.')
    args = parser.parse_args(argv[1:])

    result_paths = get_result_paths(args.results)
    comparisons = [read_comparison_from_buffer(b) for b in result_paths]
    csv = generate_csv_from_comparisons(comparisons)
    write_csv_to_file(csv, args.output)


def get_result_paths(results_directory):
    return [
        join(results_directory, f, 'diagrams-groundtruth-comparison',
             str(f) + '-diagrams-groundtruth-comparison.pb')
        for f in listdir(results_directory)
        if isdir(join(results_directory, f))
    ]


def read_comparison_from_buffer(buffer_path):
    # Read the existing address book.
    try:
        comparison = Comparison()
        f = open(buffer_path, "rb")
        comparison.ParseFromString(f.read())
        f.close()
        return comparison
    except IOError as e:
        print(f'Unable to read buffer from file: {buffer_path}\n -> {e}')


def get_rows_from_comparison(comparison):
    rows = []
    components = [
        comparison.diskRadius, comparison.diagram, comparison.numberOfPoints
    ]

    results = sorted(comparison.comparisons, key=lambda x: x.precision)

    for result in results:
        rows.append(components + [
            result.precision,
            float(result.numberOfVertices) /
            float(comparison.groundTruth.numberOfVertices),
            float(result.numberOfVerticesMatchingGroundTruth) /
            float(comparison.groundTruth.numberOfVertices)
        ])

    return rows


def get_header():
    return [
        'DiskRadius', 'DiagramID', 'NumberOfSites', 'Precision',
        'VertexPercentage', 'MatchingPercentage'
    ]


def generate_csv_from_comparisons(comparisons):
    header = get_header()
    rows = []
    for comparison in comparisons:
        rows += get_rows_from_comparison(comparison)

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
