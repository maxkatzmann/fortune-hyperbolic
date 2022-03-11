#!/bin/bash

# Wrapper file to automatically generate the radii.
#
# Usage:
#
#     bazel run -c opt radii_generation_util -- -j 4

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bazel_utilities"
. "$DIR/experiments_config"

# Read command line flags

# Path to the Bazel target of the generator
parametersUtilPath=$(rlocation "__main__/experiments/point_parameters_util")
if [[ ! -f "${parametersUtilPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the point_parameters_util binary path."
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

# Path to where experiments are stored.
dataPath="${projectRoot}/data"
mkdir -p ${dataPath}

${parametersUtilPath} --maximum_radius $conf_maximumDiskRadius --steps $conf_numberOfDiskRadii --number_of_sites $conf_numberOfSites --slope_factor $conf_slopeFactor --output ${dataPath}/parameters.txt
