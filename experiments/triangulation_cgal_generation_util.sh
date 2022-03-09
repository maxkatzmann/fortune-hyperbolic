#!/bin/bash

# Computes delaunay triangulations of point sets contained in the
# files in a directory using CGAL.
#
# Usage:
#
#     bazel run -c opt generate_cgal_triangulations_util

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bazel_utilities"

# Path to the Bazel target of the generator
cgalUtilPath=$(rlocation "__main__/experiments/triangulation_cgal_util")
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

    targetDir="${resultsPath}/${filename}"
    mkdir -p ${targetDir}

    triangulationsDir="${targetDir}/triangulations-cgal"
    mkdir -p ${triangulationsDir}

    ${cgalUtilPath} -i ${filePath} -o ${triangulationsDir}/${filename}-triangulation-cgal.txt
done
