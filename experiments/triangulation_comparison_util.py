# Takes two triangulations and compares the two.
#
#

import sys
import argparse

from triangulation_comparison import read_graph_from_file


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Compares triangulations with repsect to how many edges they share and writes the result to console.'
    )
    parser.add_argument('-t1',
                        '--triangulation1',
                        help='Path to the first triangulation file.')
    parser.add_argument('-t2',
                        '--triangulation2',
                        help='Path to the second triangulation file.')
    args = parser.parse_args(argv[1:])

    triangulation1 = read_graph_from_file(args.triangulation1)
    triangulation2 = read_graph_from_file(args.triangulation2)

    coverage_2, coverage_1 = percent_of_covered_edges(triangulation1,
                                                      triangulation2)
    print(f'2 covers {coverage_2 * 100.0}% of the edges in 1.')
    print(f'1 covers {coverage_1 * 100.0}% of the edges in 2.')


def percent_of_covered_edges(triangulation1, triangulation2):
    edges_from_1_covered_by_2 = 0
    edges_from_2_covered_by_1 = 0

    edges_in_1 = 0
    edges_in_2 = 0
    for u, v in triangulation1.iterEdges():
        edges_in_1 += 1

        if triangulation2.hasEdge(u, v):
            edges_from_1_covered_by_2 += 1
        else:
            print(f'Edge {u} {v} appears in 1 but not in 2.')

    for u, v in triangulation2.iterEdges():
        edges_in_2 += 1
        if triangulation1.hasEdge(u, v):
            edges_from_2_covered_by_1 += 1
        else:
            print(f'Edge {u} {v} appears in 2 but not in 1.')

    return (float(edges_from_1_covered_by_2) / float(edges_in_1),
            float(edges_from_2_covered_by_1) / float(edges_in_2))


if __name__ == '__main__':
    main(sys.argv)
