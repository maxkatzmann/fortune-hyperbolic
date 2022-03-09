"""Dependency Setup"""

# load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def cgal_deps():
    """CGAL"""
    if not native.existing_rule("cgalinc"):
        native.new_local_repository(
            name = "cgalinc",
            build_file_content = """
package(default_visibility = ["//visibility:public"])
cc_library(
name = "headers",
hdrs = glob(["**/*.h"]),
includes = ["."],
)
""",
            path = "/usr/local/opt/cgal/include",
        )
