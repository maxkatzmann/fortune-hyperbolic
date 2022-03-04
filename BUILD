# This package provides functionality related to hyperbolic voronoi
# diagrams.

load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "cxxopts",
    hdrs = ["cxxopts.h"],
)

cc_binary(
    name = "generator_util",
    srcs = ["generator_util.cc"],
    deps = [
        ":cxxopts",
    ],
)

cc_library(
    name = "beachline",
    hdrs = [
        "beachline.h",
        "calculations.h",
        "datastructures.h",
        "geometry.h",
    ],
)

cc_library(
    name = "kernels",
    hdrs = ["kernels.h"],
)

cc_test(
    name = "beachline_test",
    srcs = ["beachline_test.cc"],
    deps = [
        ":beachline",
        ":kernels",
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_library(
    name = "fortune",
    hdrs = [
        "canvas.h",
        "fortune.h",
        "kernels.h",
    ],
    deps = [
        ":beachline",
        ":kernels",
    ],
)

cc_test(
    name = "fortune_test",
    srcs = ["fortune_test.cc"],
    deps = [
        ":beachline",
        ":fortune",
        ":kernels",
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_library(
    name = "mpfr",
    hdrs = ["mpreal.h"],
    deps = [
        "@gmpinc//:headers",
        "@gmplib//:lib",
        "@mpfrinc//:headers",
        "@mpfrlib//:lib",
    ],
)

cc_binary(
    name = "main_util",
    srcs = ["main_util.cc"],
    deps = [
        ":cxxopts",
        ":fortune",
        ":mpfr",
        "@boost//:multiprecision",
    ],
)

cc_binary(
    name = "cgal_util",
    srcs = ["cgal_util.cc"],
    defines = ["CGAL_USE_CORE"],
    deps = [
        ":cxxopts",
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
