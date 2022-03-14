# A utility to generate the radii of the disks we consider in our experiments.
#
# Usage:
#   bazel run -c opt site_parameters_util -- \
#     --maximum_radius 30 \
#     --steps 10 \
#     --number_of_sites 100000 \
#     --slope_factor 1

import argparse
import sys
import math
import matplotlib.pyplot as plt


def main(argv):
    parser = argparse.ArgumentParser(
        description=
        'Generates a sequence of radii that approach the specified maximum_radius logarithmically.  The length of the sequence is defined by the steps.'
    )
    parser.add_argument('-r',
                        '--maximum_radius',
                        help='The maximum radius that should be produced.')
    parser.add_argument('-s',
                        '--steps',
                        help='The number of steps that should be produced.')
    parser.add_argument(
        '-n',
        '--number_of_sites',
        help=
        'The number of sites that should be produced in the disk of maximum radius.'
    )
    parser.add_argument(
        '-S',
        '--slope_factor',
        help=
        'Determines how quickly the radii approach the maximum radius.  For large slope_factors all radii are very clos to the maximum and approach it slowly.'
    )
    parser.add_argument('-p',
                        '--plot',
                        help='If specified, the values are plotted.',
                        action=argparse.BooleanOptionalAction)
    parser.add_argument(
        '-o',
        '--output',
        help="Path to the txt file where the radii should be stored.")
    args = parser.parse_args(argv[1:])
    radii = get_radii(float(args.maximum_radius), int(args.steps),
                      float(args.slope_factor))
    sites = [
        int(
            get_number_of_sites_for_radius(radius, float(args.maximum_radius),
                                           int(args.number_of_sites)))
        for radius in radii
    ]

    if args.plot:
        plot_parameters(radii, sites)

    write_parameters_to_file(radii, sites, args.output)


def get_radii(maximum_radius, steps, slope_factor):
    values = [
        maximum_radius * (1.0 / slope_factor) *
        math.log(1 + (x * (math.exp(slope_factor) - 1) / float(steps)))
        for x in range(1, steps + 1)
    ]

    return values


def get_number_of_sites_for_radius(radius, maximum_radius, maximum_sites):
    c = math.acosh(maximum_sites / (2.0 * math.pi) + 1) / maximum_radius

    return 2.0 * math.pi * (math.cosh(c * radius) - 1)


def plot_parameters(radii, sites):
    fig, ax = plt.subplots(2, figsize=(10, 10))
    ax[0].scatter([i for i in range(1,
                                    len(radii) + 1)],
                  radii,
                  color='black',
                  s=50)
    ax[0].set_ylim([0, radii[-1]])

    ax[1].scatter([i for i in range(1,
                                    len(sites) + 1)],
                  sites,
                  color='blue',
                  s=50)
    ax[1].set_ylim([0, sites[-1]])

    plt.show()


def write_parameters_to_file(radii, sites, file_path):
    parameter_pairs = list(zip(radii, sites))
    parameter_pair_strings = [
        str(r) + ' ' + str(n) for (r, n) in parameter_pairs
    ]
    with open(file_path, 'w') as output_file:
        output_file.write('\n'.join(parameter_pair_strings))


if __name__ == '__main__':
    main(sys.argv)
