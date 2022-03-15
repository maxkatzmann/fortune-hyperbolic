#!/bin/bash

# Generates plots from the experiment results.
#
# Usage:
#
#     bazel run -c opt plot_generation_util

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bazel_utilities"

# Find the root directory of the project, so that we can find relevant sub
# directories from there.
readMePath=$(rlocation "__main__/experiments/README.md")
if [[ ! -f "${readMePath:-}" ]]; then
    echo >&2 "ERROR: could not look up project root directory."
    exit 1
fi
projectRoot=$(dirname "$readMePath")

# Path to where results are stored.
resultsPath="${projectRoot}/results"

# Path to where the plots are stored.
plotPath="${projectRoot}/plots"
mkdir -p ${plotPath}

# Utility for plotting diagram/groundtruth comparisons.
voronoiVertexPlotPath=$(rlocation "__main__/experiments/voronoi_vertex_comparison_plot_util")
if [[ ! -f "${voronoiVertexPlotPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the voronoi_vertex_comparison_plot_util binary path."
    exit 1
fi

${voronoiVertexPlotPath} ${plotPath}

# Utility for plotting diagram/groundtruth comparisons.
delaunayEdgePlotPath=$(rlocation "__main__/experiments/delaunay_edge_comparison_plot_util")
if [[ ! -f "${delaunayEdgePlotPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the delaunay_edge_comparison_plot_util binary path."
    exit 1
fi

${delaunayEdgePlotPath} ${plotPath}

# Utility for plotting diagram/groundtruth comparisons.
plotUtilPath=$(rlocation "__main__/experiments/plot_util")
if [[ ! -f "${plotUtilPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the plot_util binary path."
    exit 1
fi

${plotUtilPath} ${plotPath} > ${plotPath}/merged-log.txt
