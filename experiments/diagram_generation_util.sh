#!/bin/bash

# Computes delaunay triangulations of point sets contained in the
# files in a directory.
#
# Usage:
#
#     bazel run -c opt diagram_generation_util -- -j 4

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
voronoiUtilPath=$(rlocation "__main__/main_util")
if [[ ! -f "${voronoiUtilPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the main_util binary path."
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

# Path to where results should be stored.
resultsPath="${projectRoot}/results"

for filePath in ${dataPath}/*.txt;
do
    filePathWithoutExtension=${filePath%.*}
    filename=${filePathWithoutExtension##*/}

    if [ $filename == "parameters" ]; then
        continue
    fi

    targetDir="${resultsPath}/${filename}"
    mkdir -p ${targetDir}

    diagramsDir="${targetDir}/diagrams"
    mkdir -p ${diagramsDir}

    triangulationsDir="${targetDir}/triangulations"
    mkdir -p ${triangulationsDir}

    for precision in $(seq 16 16 $conf_maximumPrecision); do 
        sem -j $jobs "${voronoiUtilPath} -i ${filePath} -p ${precision} -o ${diagramsDir}/${filename}-diagram-precision-${precision}.txt -t ${triangulationsDir}/${filename}-triangulation-precision-${precision}.txt"
    done
    sem --wait
done
