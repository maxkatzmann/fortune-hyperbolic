# This package provides functionality related to experiments on
# hyperbolic voronoi diagrams.

load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@com_google_protobuf//:protobuf.bzl", "py_proto_library")

cc_binary(
    name = "triangulation_cgal_util",
    srcs = ["triangulation_cgal_util.cc"],
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

filegroup(
    name = "projectroot",
    srcs = ["README.md"],
)

sh_binary(
    name = "bazel_utilities",
    srcs = ["bazel_utilities.sh"],
)

sh_binary(
    name = "point_generation_util",
    srcs = ["point_generation_util.sh"],
    data = [
        ":projectroot",
        "//:generator_util",
    ],
    deps = [
        ":bazel_utilities",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

filegroup(
    name = "data",
    srcs = glob([
        "data/*.txt",
    ]),
)

sh_binary(
    name = "triangulation_generation_util",
    srcs = ["triangulation_generation_util.sh"],
    data = [
        ":data",
        ":projectroot",
        "//:main_util",
    ],
    deps = [
        ":bazel_utilities",
        "@bazel_tools//tools/bash/runfiles",
    ],
)

sh_binary(
    name = "triangulation_cgal_generation_util",
    srcs = ["triangulation_cgal_generation_util.sh"],
    data = [
        ":data",
        ":projectroot",
        ":triangulation_cgal_util",
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
