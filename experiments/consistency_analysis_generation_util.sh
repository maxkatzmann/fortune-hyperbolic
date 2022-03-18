#!/bin/bash

# Generates a file showing how consistent the algorithms are.
#
# Usage:
#
#     bazel run -c opt consistency_analysis_generation_util.sh

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

# Utility for the analysis.
analysisUtilPath=$(rlocation "__main__/experiments/consistency_analysis_util")
if [[ ! -f "${analysisUtilPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the consistency_analysis_util binary path."
    exit 1
fi

${analysisUtilPath} ${resultsPath}
