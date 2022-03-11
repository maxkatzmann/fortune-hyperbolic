# This package provides functionality related to experiments on
# hyperbolic voronoi diagrams.

load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@com_google_protobuf//:protobuf.bzl", "py_proto_library")

filegroup(
    name = "projectroot",
    srcs = ["README.md"],
)

sh_binary(
    name = "bazel_utilities",
    srcs = ["bazel_utilities.sh"],
)

sh_binary(
    name = "experiments_config",
    srcs = ["experiments_config.sh"],
)

py_binary(
    name = "point_parameters_util",
    srcs = ["point_parameters_util.py"],
)

sh_binary(
    name = "point_parameters_generation_util",
    srcs = ["point_parameters_generation_util.sh"],
    data = [
        ":point_parameters_util",
        ":projectroot",
    ],
    deps = [
        ":bazel_utilities",
        ":experiments_config",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

filegroup(
    name = "parameter_data",
    srcs = ["data/parameters.txt"],
)

sh_binary(
    name = "point_generation_util",
    srcs = ["point_generation_util.sh"],
    data = [
        ":parameter_data",
        ":projectroot",
        "//:generator_util",
    ],
    deps = [
        ":bazel_utilities",
        ":experiments_config",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

filegroup(
    name = "data",
    srcs = glob(
        ["data/*.txt"],
        exclude = ["data/parameters.txt"],
    ),
)

sh_binary(
    name = "diagram_generation_util",
    srcs = ["diagram_generation_util.sh"],
    data = [
        ":data",
        ":projectroot",
        "//:main_util",
    ],
    deps = [
        ":bazel_utilities",
        ":experiments_config",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

cc_binary(
    name = "cgal_util",
    srcs = ["cgal_util.cc"],
    defines = ["CGAL_USE_CORE"],
    deps = [
        "//:cxxopts",
        "@boost//:algorithm",
        "@boost//:any",
        "@boost//:config",
        "@boost//:property_map",
        "@boost//:random",
        "@boost//:variant",
        "@cgalinc//:headers",
        "@gmpinc//:headers",
        "@gmplib//:lib",
    ],
)

sh_binary(
    name = "diagram_cgal_generation_util",
    srcs = ["diagram_cgal_generation_util.sh"],
    data = [
        ":cgal_util",
        ":data",
        ":projectroot",
    ],
    deps = [
        ":bazel_utilities",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

filegroup(
    name = "result_diagrams",
    srcs = glob([
        "results/**/diagrams/*.txt",
    ]),
)

filegroup(
    name = "result_diagrams_cgal",
    srcs = glob([
        "results/**/diagrams-cgal/*.txt",
    ]),
)

filegroup(
    name = "result_triangulations",
    srcs = glob([
        "results/**/triangulations/*.txt",
    ]),
)

filegroup(
    name = "result_triangulations_cgal",
    srcs = glob([
        "results/**/triangulations-cgal/*.txt",
    ]),
)

py_library(
    name = "diagram_comparison",
    srcs = ["diagram_comparison.py"],
)

proto_library(
    name = "diagram_groundtruth_comparison_proto",
    srcs = ["diagram_groundtruth_comparison.proto"],
)

py_proto_library(
    name = "diagram_groundtruth_comparison_py_proto",
    srcs = ["diagram_groundtruth_comparison.proto"],
)

py_binary(
    name = "diagram_groundtruth_comparison_util",
    srcs = ["diagram_groundtruth_comparison_util.py"],
    data = [
        ":data",
        ":diagram_comparison",
        ":projectroot",
    ],
    deps = [":diagram_groundtruth_comparison_py_proto"],
)

sh_binary(
    name = "diagram_groundtruth_comparison_generation_util",
    srcs = ["diagram_groundtruth_comparison_generation_util.sh"],
    data = [
        ":diagram_groundtruth_comparison_util",
        ":projectroot",
        ":result_diagrams",
    ],
    deps = [
        ":bazel_utilities",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

py_binary(
    name = "diagram_groundtruth_comparison_aggregation_util",
    srcs = ["diagram_groundtruth_comparison_aggregation_util.py"],
    deps = [":diagram_groundtruth_comparison_py_proto"],
)

py_binary(
    name = "diagram_cgal_comparison_aggregation_util",
    srcs = ["diagram_cgal_comparison_aggregation_util.py"],
    data = [
        ":data",
        ":result_diagrams",
        ":result_diagrams_cgal",
    ],
    deps = [":diagram_comparison"],
)

py_library(
    name = "triangulation_comparison",
    srcs = ["triangulation_comparison.py"],
    deps = [
        ":diagram_comparison",
    ],
)

py_binary(
    name = "triangulation_connectedness_aggregation_util",
    srcs = ["triangulation_connectedness_aggregation_util.py"],
    data = [
        ":data",
        ":result_triangulations",
        ":result_triangulations_cgal",
    ],
    deps = [
        ":diagram_comparison",
        ":triangulation_comparison",
    ],
)

py_binary(
    name = "triangulation_comparison_aggregation_util",
    srcs = ["triangulation_comparison_aggregation_util.py"],
    data = [
        ":data",
        ":result_triangulations",
        ":result_triangulations_cgal",
    ],
    deps = [
        ":diagram_comparison",
        ":triangulation_comparison",
    ],
)
