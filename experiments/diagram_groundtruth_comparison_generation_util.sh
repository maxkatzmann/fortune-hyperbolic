#!/bin/bash

# Compares diagrams computed with different precisions to the one with
# the highest precision.
#
# Usage:
#
#     bazel run -c opt generate_ground_truth_comparison_util

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bazel_utilities"

# Path to the Bazel target of the generator
comparisonUtilPath=$(rlocation "__main__/experiments/diagram_groundtruth_comparison_util")
if [[ ! -f "${comparisonUtilPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the diagram_groundtruth_comparison_util binary path."
    exit 1
fi

# Find the root directory of the project, so that we can find relevant sub
# directories from there.
readMePath=$(rlocation "__main__/experiments/README.md")
if [[ ! -f "${readMePath:-}" ]]; then
    echo >&2 "ERROR: could not look up project root directory."
    exit 1
fi
projectRoot=$(dirname "$readMePath")

# Path to where data is stored.
dataPath="${projectRoot}/data"
mkdir -p ${dataPath}

# Path to where experiments are stored.
resultsPath="${projectRoot}/results"
mkdir -p ${resultsPath}

for filePath in ${resultsPath}/*; do
    # filePathWithoutExtension=${filePath%.*}
    dirname=${filePath##*/}

    outputDir=${resultsPath}/${dirname}/diagrams-groundtruth-comparison
    mkdir -p ${outputDir}

    ${comparisonUtilPath} --diagrams ${resultsPath}/${dirname}/diagrams --output ${outputDir}
done
