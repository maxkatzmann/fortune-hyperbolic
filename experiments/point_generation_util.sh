#!/bin/bash

# Generates files containing randomly sampled point sets.
#
# Usage:
#
#     bazel run -c opt point_generation_util -- -j 4

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bazel_utilities"
. "$DIR/experiments_config"

# Read command line flags

# By default we perform all jobs sequentally -> 1 job at the time.
jobs=1
while getopts j: flag
do
    case "${flag}" in
        j) jobs=${OPTARG};;
    esac
done
echo "Using: $jobs jobs in parallel";

# Path to the Bazel target of the generator
generatorPath=$(rlocation "__main__/generator_util")
if [[ ! -f "${generatorPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the generator_util binary path."
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

# Path to where the parameters are stored.
parametersPath="${dataPath}/parameters.txt"

while IFS="" read -r parameters || [ -n "$parameters" ]
do
    parameterPair=( $parameters )
    R=${parameterPair[0]}
    N=${parameterPair[1]}
    for sample in $(seq $conf_numberOfSamples); do
        sem -j $jobs "${generatorPath} -R $R -N $N -o ${dataPath}/${R}-${sample}.txt"
    done
    sem --wait
done < $parametersPath
