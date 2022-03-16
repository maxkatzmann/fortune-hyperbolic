# Fortune's Algorithm in Hyperbolic Space

This is an implementation of Fortune's Algorithm in the polar
coordinate model of hyperbolic space. Based on
[this](https://arxiv.org/abs/2112.02553) paper.

You can use the code as a header-only library. Alternatively, you can
build an executable that calculates and draws a diagram based on a set
of points read from a file. The output then looks like the following
picture which shows a Voronoi diagram of N=500 points uniformly
distributed across a disk in the hyperbolic plane of radius R=9. The
red lines are the Delaunay triangulation that connects points whose
Voronoi cells are neighboring.

<p align="center">
<img src="example/voronoi_example.png" width="500" height="300" />
</p>

## Prerequisites

- [Bazel](https://bazel.build)
- [GMP](https://gmplib.org)
- [MPFR](https://www.mpfr.org)
- [CGAL](https://www.cgal.org)

If the libraries _GMP_, _MPFR_, and _CGAL_ are not are not installed
in their default locations `/usr/local/opt/...`, the `path` variables
in `cgal_deps.bzl` and `fortune_deps.bzl` have to be adjusted.  

## How to use

The `generator_util` provides functionality to generate random point
sets in the hyperbolic plane.

The command
```
bazel run -c opt generator_util -- -o path/to/points.txt -R 11.1 -N 500
```
samples 500 points uniformly at random within a disk of radius R=11.1.
Alternatively, the following command
```
bazel run -c opt generator_util -- -o path/to/points.txt -N 500 -a 0.75 -d 8
```
samples 500 points in a disk whose radius is specified using the
parameters `a` and `d`, which are the analogous version of `alpha` and
`deg`, when sampling hyperbolic random graphs (See this
[repository](https://github.com/chistopher/girgs) for further
information).

Given a set of points, the `main_util` can then be used to compute the
Voronoi diagram in the polar-coordinate model of the hyperbolic plane.
```
bazel run -c opt main_util -- -i path/to/points.txt -d path/to/output/drawing.svg -t path/to/output/triangulation.txt 
```
