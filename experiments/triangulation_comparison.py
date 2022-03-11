from os.path import isdir, isfile, join
from os import listdir
import networkit as nk
from pathlib import Path
from functools import cmp_to_key

from diagram_comparison import precision_sort, get_precision_from_file_name


def get_triangulation_names(results_directory):
    return [
        d for d in listdir(results_directory)
        if isdir(join(results_directory, d))
    ]


def read_graph_from_file(file_path):
    return nk.readGraph(str(file_path), nk.Format.EdgeListSpaceZero)


def get_native_precision_triangulation(name, results_directory):
    triangulations_path = Path(results_directory) / name / 'triangulations'

    triangulation_files = sorted([
        join(triangulations_path, f) for f in listdir(triangulations_path)
        if isfile(join(triangulations_path, f))
    ],
                                 key=cmp_to_key(precision_sort))

    return read_graph_from_file(triangulation_files[-1])


def get_native_triangulations(name, results_directory):
    triangulations_path = Path(results_directory) / name / 'triangulations'

    triangulation_files = sorted([
        join(triangulations_path, f) for f in listdir(triangulations_path)
        if isfile(join(triangulations_path, f))
    ],
                                 key=cmp_to_key(precision_sort))

    return [(get_precision_from_file_name(f), read_graph_from_file(f))
            for f in triangulation_files]


def get_cgal_triangulation(name, results_directory):
    diagrams_path = Path(results_directory) / name / 'triangulations-cgal'
    file_name = name + '-triangulation-cgal.txt'
    file_path = diagrams_path / file_name

    return read_graph_from_file(file_path)
