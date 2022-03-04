"""Dependency Setup"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def fortune_deps():
    """MPFR"""
    if not native.existing_rule("mpfrlib"):
        native.new_local_repository(
            name = "mpfrlib",
            build_file_content = """
cc_library(
name = "lib",
srcs = ["libmpfr.a"],
visibility = ["//visibility:public"],
)
""",
            path = "/usr/local/opt/mpfr/lib",
        )

    if not native.existing_rule("mpfrinc"):
        native.new_local_repository(
            name = "mpfrinc",
            build_file_content = """
package(default_visibility = ["//visibility:public"])
cc_library(
name = "headers",
hdrs = glob(["**/*.h"]),
includes = ["."],
)
""",
            path = "/usr/local/opt/mpfr/include",
        )

    """GMP"""
    if not native.existing_rule("gmplib"):
        native.new_local_repository(
            name = "gmplib",
            build_file_content = """
cc_library(
name = "lib",
srcs = ["libgmp.a"],
visibility = ["//visibility:public"],
)
""",
            path = "/usr/local/opt/gmp/lib",
        )

    if not native.existing_rule("gmpinc"):
        native.new_local_repository(
            name = "gmpinc",
            build_file_content = """
package(default_visibility = ["//visibility:public"])
cc_library(
name = "headers",
hdrs = glob(["**/*.h"]),
includes = ["."],
)
""",
            path = "/usr/local/opt/gmp/include",
        )

    # CGAL
    if not native.existing_rule("cgalinc"):
        native.new_local_repository(
            name = "cgalinc",
            build_file_content = """
package(default_visibility = ["//visibility:public"])
cc_library(
name = "headers",
hdrs = glob(["**/*"]),
includes = ["."],
)
""",
            path = "/usr/local/opt/cgal/include",
        )
