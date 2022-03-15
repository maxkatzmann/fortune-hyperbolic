# A utility that can be used to compare how two triangulations differ.
#
# Usage:
#   bazel run -c opt triangulation_comparison_visualization_util -- \
#     --sites path/to/sites.txt
#     --triangulation1 path/to/triangulation1.txt
#     --triangulation2 path/to/triangulation2.txt
#     --output_svg path/to/output/visualization.svg

import argparse
import sys
import math
import numpy as np
import cairo

line_width = 0.0005
point_radius = 0.0005
offset = 0.5
scale = 0.5
twopi = 2 * math.pi


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Compares two triangulations with repsect to how many edges they have in commong.'
    )
    parser.add_argument(
        '-s',
        '--sites',
        help=
        'Path to the file containing the sites that the triangulations are based on.'
    )
    parser.add_argument('-t1',
                        '--triangulation1',
                        help="Path to the first triangulation")
    parser.add_argument('-t2',
                        '--triangulation2',
                        help="Path to the second triangulation")
    parser.add_argument(
        '-o',
        '--output_svg',
        help=
        "Path to the SVG file where the output visualizaton should be stored.")
    args = parser.parse_args(argv[1:])

    sites = read_sites(args.sites)
    triangulation1 = read_graph(args.triangulation1)
    triangulation2 = read_graph(args.triangulation2)
    output_file_path = args.output_svg
    visualize_comparison(sites, triangulation1, triangulation2,
                         output_file_path)


def add(adj, a, b):
    if not a in adj.keys():
        adj[a] = []
    adj[a].append(b)


def read_graph(filename):
    adj = {}
    with open(filename, 'r') as f:
        for line in f:
            a, b = [int(x) for x in line.split(' ')]
            add(adj, a, b)
            add(adj, b, a)
    return adj


def read_sites(filename):
    coordinates = []
    with open(filename, 'r') as f:
        for line in f:
            theta, r = [float(x) for x in line.split(' ')]
            coordinates.append([r * math.cos(theta), r * math.sin(theta)])
    coordinates = np.array(coordinates)
    max_val = np.max(coordinates.ravel()) + 0.3
    coordinates /= max_val
    return coordinates


def transform(x, y):
    return x * scale + offset, y * scale + offset


def draw_sites(
    context,
    coordinates,
):
    context.set_source_rgb(0, 0, 0)
    for x, y in coordinates:
        context.arc(*transform(x, y), point_radius, 0, twopi)
        context.fill()


def draw_edge(context, a, b, coordinates):
    context.move_to(*transform(*coordinates[a]))
    context.line_to(*transform(*coordinates[b]))
    context.stroke()


def draw_edges(context, adj1, adj2, coordinates):
    context.set_line_width(line_width)

    for u in adj1.keys():
        set1 = set(adj1[u])
        if u in adj2.keys():
            set2 = set(adj2[u])
        else:
            set2 = set()

        context.set_source_rgb(0.5, 0.5, 0.5)
        for v in set1.intersection(set2):
            draw_edge(context, u, v, coordinates)

        context.set_source_rgb(1, 0, 0)
        for v in set1 - set2:
            draw_edge(context, u, v, coordinates)

        context.set_source_rgb(0, 0, 1)
        for v in set2 - set1:
            draw_edge(context, u, v, coordinates)


def visualize_comparison(sites, triangulation1, triangulation2,
                         output_file_path):
    dim = 700
    with cairo.SVGSurface(output_file_path, dim, dim) as surface:
        context = cairo.Context(surface)
        context.scale(dim, dim)

        draw_edges(context, triangulation1, triangulation2, sites)
        draw_sites(context, sites)


if __name__ == '__main__':
    main(sys.argv)
