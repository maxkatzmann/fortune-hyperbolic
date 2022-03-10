#include <CGAL/Hyperbolic_Delaunay_triangulation_2.h>
#include <CGAL/Hyperbolic_Delaunay_triangulation_traits_2.h>
#include <CGAL/Timer.h>
#include <CGAL/point_generators_2.h>

#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <unordered_map>
#include <vector>

#include "cxxopts.h"

using Point_2 = CGAL::Hyperbolic_Delaunay_triangulation_traits_2<>::Point_2;
using DelaunayTriangulation = CGAL::Hyperbolic_Delaunay_triangulation_2<
    CGAL::Hyperbolic_Delaunay_triangulation_traits_2<>>;

int main(int argc, char** argv) {
  CGAL::Timer timer;
  std::vector<Point_2> pts;

  cxxopts::Options options(
      argv[0],
      "Calculates a hyperbolic voronoi diagram from a set of sites using the "
      "implementation of CGAL 5.2 operating in the Poincare disk model");

  options.add_options()("i,input", "Input Filename",
                        cxxopts::value<std::string>())(
      "o,output_diagram_txt",
      "Output Filename for writing the diagram coordinates",
      cxxopts::value<std::string>())("t,output_triangulation",
                                     "Output Filename for writing the delaunay "
                                     "triangulation",
                                     cxxopts::value<
                                         std::string>())("h,help",
                                                         "Print usage");

  auto result = options.parse(argc, argv);

  if (result.count("help")) {
    std::cout << options.help() << std::endl;
    exit(0);
  }

  const std::string inputFile = result["i"].as<std::string>();

  // read the input
  std::ifstream inputStream(inputFile);
  try {
    if (inputStream.is_open()) {
      std::string line;
      while (getline(inputStream, line)) {
        double theta, r;
        auto pos = line.find(' ');
        theta = stod(line.substr(0, pos));
        r = stod(line.substr(pos));
        r = tanh(r / 2);
        Point_2 p(r * cos(theta), r * sin(theta));
        pts.push_back(p);
      }
      inputStream.close();
    } else {
      std::cout << "Unable to open input file \"" << inputFile << "\"\n";
      return EXIT_FAILURE;
    }
  } catch (...) {
    std::cout << "Error while reading file \"" << inputFile << "\"\n";
    return EXIT_FAILURE;
  }

  std::unordered_map<DelaunayTriangulation::Vertex_handle, size_t>
      vertext_to_id;
  DelaunayTriangulation dtEnd;
  std::cout
      << "Insertion of point set (hyperbolic filtering only once at the end)"
      << std::endl;
  std::cout
      << "==================================================================="
      << std::endl;
  timer.reset();
  timer.start();
  for (size_t i = 0; i < pts.size(); i++) {
    DelaunayTriangulation::Vertex_handle h = dtEnd.insert(pts[i]);
    vertext_to_id[h] = i;
  }
  timer.stop();
  std::cout << "Number of vertices:         " << dtEnd.number_of_vertices()
            << std::endl;
  std::cout << "Number of hyperbolic faces: "
            << dtEnd.number_of_hyperbolic_faces() << std::endl;
  std::cout << "Number of hyperbolic edges: "
            << dtEnd.number_of_hyperbolic_edges() << std::endl;
  std::cout << "Time:                       " << timer.time() << std::endl;

  // Writing the diagram
  if (result.count("o")) {
    const std::string diagramOutputFile = result["o"].as<std::string>();
    std::fstream diagramOutputFileStream(diagramOutputFile, std::fstream::out);

    for (DelaunayTriangulation::All_faces_iterator f = dtEnd.all_faces_begin();
         f != dtEnd.all_faces_end(); ++f) {
      auto voronoi_vertex = dtEnd.dual(f);
      auto x = CGAL::to_double(voronoi_vertex.x());
      auto y = CGAL::to_double(voronoi_vertex.y());

      auto r = sqrt(x * x + y * y);
      r = 2.0 * atanh(r);
      auto angle = atan2(y, x);

      // Make sure angle is in [0, 2pi]
      if (angle < 0.0) {
        angle += 2 * M_PI;
      }

      diagramOutputFileStream << r << " " << angle << "\n";
    }
  }

  // Writing the triangulation
  if (result.count("t")) {
    const std::string triangulationOutputFile = result["t"].as<std::string>();
    std::fstream outputFileStream(triangulationOutputFile, std::fstream::out);
    for (DelaunayTriangulation::All_edges_iterator e = dtEnd.all_edges_begin();
         e != dtEnd.all_edges_end(); e++) {
      DelaunayTriangulation::Face_handle f = e->first;
      DelaunayTriangulation::Vertex_handle a = f->vertex(f->cw(e->second));
      DelaunayTriangulation::Vertex_handle b = f->vertex(f->ccw(e->second));
      outputFileStream << vertext_to_id[a->handle()] << " "
                       << vertext_to_id[b->handle()] << "\n";
    }
  }

  return EXIT_SUCCESS;
}
