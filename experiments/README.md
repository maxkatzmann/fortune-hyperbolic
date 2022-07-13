# Experiments

The `experiments` directory contains all functionality related to
performing the experiments, starting from the generation of the
considered point sets, and including the generation of the plots.


## Prerequisites

- [Bazel](https://bazel.build)
- [GMP](https://gmplib.org)
- [MPFR](https://www.mpfr.org)
- [CGAL](https://www.cgal.org)
- [Multiset](https://pypi.org/project/multiset/)
- [Parallel](https://www.gnu.org/software/parallel/)
- [NetworKit](https://networkit.github.io)

## Usage

Starting from the root directory of the project, you can run all experiments using the command

``` shell
./run_experiments_util.sh -j 8 
```
where you can swap `8` with the number of experiments that should be run in parallel.

The script then performs the following tasks.

### Parameter Generation

Can be run manually using
```shell
bazel run -c opt //experiments:site_parameters_generation_util
```

This task is used to generate the disk radii and corresponding number of sites for each radius.  To this end, it reads the parameter configuration from the `experiments_config.sh` file.  The following configurations are specified there:

- `maximumDiskRadius` - The radius of the largest disk that is considered in the experiments.
- `numberOfDiskRadii` - How many disks are considered up to the largest disk.
- `slopeFactor` - Determines how quickly the disk radii approach the maximum radius.
- `numberOfSites` - Number of sites we want in the largest disk.  The number of sites in the remaining disks is then chosen such that all disks are equally densely filled.
- `numberOfSamples` - How many sets of sites are sampled for a given disk radius.
- `maximumPrecision` - The maximum precision in bits (a multiple of 16) that are considered when using the multiple precision library.

The generated parameters are then saved in `data/parameters.txt`

### Site Generation

Can be run manually using
```shell
bazel run -c opt //experiments:site_generation_util -- -j 8
```
where `8` can be replaced with the desired number of simultaneous generation processes.

Generates the sets of sites for the different disk radii, as defined in the `data/parameters.txt` file.  The resulting sets are stored in `data/{R}-{sample}.txt` where `R` is the radius of the disk that the sites were sampled in and `sample` is the identifier of the generated set.

### Diagram Generation (Fortune-based)

Can be run manually using
```shell
bazel run -c opt //experiments:diagram_generation_util -- -j 8
```
where `8` can be replaced with the desired number of simultaneous generation processes.

Uses the adaptation of Fortunes algorithm implemented in this repository to compute the Voronoi diagrams and Delaunay triangulations of the site sets that were computed using during __Site Generation__.  For each multiple of `16` starting with 32, going up to the configured `maximumPrecision`, one such diagram/triangulation is computed using the this many bits as precision in the multiple precision library.  Additionally, one diagram/triangulation is computed using Double precision.

For a site set with radius `R` and identifier `sample`, the resulting diagrams are written to `results/{R}-{sample}/diagrams/` and the triangulations to `results/{R}-{sample}/triangulations/`.  The file names of the generated files contain the number of bits that were used as precision.  A precision of 16 indicates that Double precision was used.

### Diagram vs "Ground Truth" Comparison

Can be run manually using
```shell
bazel run -c opt //experiments:diagram_groundtruth_comparison_generation_util
```

As "ground truth" we use the diagram/triangulation that was computed using the largest precision value.  The comparison util then determines for how many Voronoi vertices the Double representation of the coordinates in a given diagram and the "ground truth" diagram match.  For the triangulations the edges of the triangulation are compared.

### Diagram vs "Ground Truth" Aggregation

Can be run manually using
```shell
bazel run -c opt //experiments:diagram_groundtruth_comparison_aggregation_util -- --results experiments/results --output experiments/results/diagrams-groundtruth-comparisons.csv
```

Collects the computed comparison results in the specified CSV file.

### Diagram Generation (CGAL-based)

Can be run manually using
```shell
bazel run -c opt //experiments:diagram_cgal_generation_util -- -j 8
```
where `8` can be replaced with the desired number of simultaneous generation processes.

Computes the Voronoi diagrams and Delaunay triangulations analogous to how it was done in __Diagram Generation (Fortune-based)__, but uses the CGAL implementation instead.

The results are written next to the corresponding diagrams/triangulations computed using the Fortune-based method.  Instead of using a precision in bits, the file names are marked with `cgal`.

### CGAL-Diagram vs "Ground Truth" Aggregation

Can be run manually using
```shell
bazel run -c opt //experiments:diagram_cgal_comparison_aggregation_util -- --results experiments/results --output experiments/results/diagrams-cgal-comparisons.csv
```

Compares the diagrams computed using CGAL with the "ground truth" variants, analogous to how it was done in __Diagram vs "Ground Truth" Comparison__ and __Diagram vs "Ground Truth" Aggregation__.

### Triangulation Connectedness Aggregation

Can be run manually using
```shell
bazel run -c opt //experiments:triangulation_connectedness_aggregation_util -- --results experiments/results --output experiments/results/triangulations-cgal-comparisons.csv
```

Determines the number of connected components in the graphs represented by the computed triangulations.  Since the Delaunay triangulation is connected, this number should be 1 for all diagrams.

### Triangulation Comparison Aggregation

Can be run manually using
```shell
bazel run -c opt //experiments:triangulation_comparison_aggregation_util -- --results experiments/results --output experiments/results/triangulation-edge-comparisons.csv
```

Compares how many edges of the "ground truth" triangulation are covered by another triangulation and aggregates the results into a CSV file.

### Plot Generation

Can be run manually using
```shell
bazel run -c opt //experiments:plot_generation_util
```

Generates the plots that are shown in the paper from the data computed earlier.  The plots are written to `experiments/plots` as `.tex` and `.pdf` files.

### Consistency Analysis


Can be run manually using
```shell
bazel run -c opt //experiments:consistency_analysis_generation_util
```

Determines the percentages denoting how often the different algorithms computed the same outputs up to a certain disk radius.  The results are stored in `results/consistency_analsysis.csv`.
