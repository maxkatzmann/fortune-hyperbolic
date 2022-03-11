#!/bin/bash

# By default we perform all jobs sequentally -> 1 job at the time.
jobs=1
while getopts j: flag
do
    case "${flag}" in
        j) jobs=${OPTARG};;
    esac
done

# Generate the parameters for the point set generation.
bazel run -c opt //experiments:point_parameters_generation_util

# Generate the point sets.
bazel run -c opt //experiments:point_generation_util -- -j $jobs

# Generate native diagrams and triangulations.
bazel run -c opt //experiments:diagram_generation_util -- -j $jobs

# We compare the diagrams of different precisions.
bazel run -c opt //experiments:diagram_groundtruth_comparison_generation_util

# We aggregate the comparison results into a single CSV file.
bazel run -c opt //experiments:diagram_groundtruth_comparison_aggregation_util -- --results experiments/results --output experiments/results/diagram-groundtruth-comparisons.csv

# Now we compute the CGAL diagrams and triangulations.
bazel run -c opt //experiments:diagram_cgal_generation_util -- -j $jobs

# And we compare the CGAL diagrams with the native ones.
bazel run -c opt //experiments:diagram_cgal_comparison_aggregation_util -- --results experiments/results --output experiments/results/diagrams-cgal-comparisons.csv

# And we compare the CGAL triangulations with the native ones.
bazel run -c opt //experiments:triangulation_connectedness_aggregation_util -- --results experiments/results --output experiments/results/triangulations-cgal-comparisons.csv
