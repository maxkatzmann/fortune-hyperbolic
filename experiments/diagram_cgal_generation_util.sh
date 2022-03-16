#!/bin/bash

# Computes delaunay triangulations of point sets contained in the
# files in a directory using CGAL.
#
# Usage:
#
#     bazel run -c opt diagram_cgal_generation_util -- -j 4

# Import bazel utitlities.
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bazel_utilities"

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
cgalUtilPath=$(rlocation "__main__/experiments/cgal_util")
if [[ ! -f "${cgalUtilPath:-}" ]]; then
    echo >&2 "ERROR: could not look up the cgal_util binary path."
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

for filePath in ${dataPath}/*.txt;
do
    filePathWithoutExtension=${filePath%.*}
    filename=${filePathWithoutExtension##*/}

    if [ $filename == "parameters" ]; then
        continue
    fi

    targetDir="${resultsPath}/${filename}"
    mkdir -p ${targetDir}

    diagramsDir="${targetDir}/diagrams-cgal"
    mkdir -p ${diagramsDir}

    triangulationsDir="${targetDir}/triangulations-cgal"
    mkdir -p ${triangulationsDir}

    sem -j $jobs "${cgalUtilPath} -i ${filePath} -o ${diagramsDir}/${filename}-diagram-cgal.txt -t ${triangulationsDir}/${filename}-triangulation-cgal.txt"
done
sem --wait
