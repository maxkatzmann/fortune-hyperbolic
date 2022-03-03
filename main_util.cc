#include <iostream>
#include <vector>
#include <chrono>

#include "geometry.h"
#include "canvas.h"
#include "kernels.h"
#include "fortune.h"

#include <boost/multiprecision/mpfr.hpp>

#include "cxxopts.h"

using namespace std;
using namespace hyperbolic;
using namespace boost;
using namespace multiprecision;

using floating_point_type_32 = number<mpfr_float_backend<32, allocate_stack>>;
using floating_point_type_48 = number<mpfr_float_backend<48, allocate_stack>>;
using floating_point_type_64 = number<mpfr_float_backend<64, allocate_stack>>;
using floating_point_type_80 = number<mpfr_float_backend<80, allocate_stack>>;
using floating_point_type_96 = number<mpfr_float_backend<96, allocate_stack>>;
using floating_point_type_112 = number<mpfr_float_backend<112, allocate_stack>>;
using floating_point_type_128 = number<mpfr_float_backend<128, allocate_stack>>;
using floating_point_type_144 = number<mpfr_float_backend<144, allocate_stack>>;
using floating_point_type_160 = number<mpfr_float_backend<160, allocate_stack>>;
using floating_point_type_176 = number<mpfr_float_backend<176, allocate_stack>>;
using floating_point_type_192 = number<mpfr_float_backend<192, allocate_stack>>;
using floating_point_type_208 = number<mpfr_float_backend<208, allocate_stack>>;
using floating_point_type_224 = number<mpfr_float_backend<224, allocate_stack>>;
using floating_point_type_240 = number<mpfr_float_backend<240, allocate_stack>>;
using floating_point_type_256 = number<mpfr_float_backend<256, allocate_stack>>;

int main(int argc, char* argv[]) {

    cxxopts::Options options(
            argv[0], "Calculates a hyperbolic voronoi diagram from a set of sites using the hyperbolic version of Fortune's Algorithm.");

    options.add_options()
            ("i,input", "Input Filename", cxxopts::value<std::string>())
            ("v,verbose", "Enable verbose output (only for debugging)", cxxopts::value<bool>()->default_value("false"))
            ("d,output_diagram", "Output Filename for writing the diagram svg", cxxopts::value<std::string>())
            ("t,output_triangulation", "Output Filename for writing the delaunay triangulation", cxxopts::value<std::string>())
            ("p,precision", "Specifies the number of bits that should be used for computations.  Allowed values are multiple of 16 in [32, ..., 256].  Defaults to Double presision for values outside of that range.", cxxopts::value<int>()->default_value("0"))
            ("h,help", "Print usage");

    auto result = options.parse(argc, argv);

    if (result.count("help")) {
        std::cout << options.help() << std::endl;
        exit(0);
    }

    string input_file = result["i"].as<string>();

    // read the input
    ifstream input_stream(input_file);
    vector<Point<double>> sites;
    try {
        if (input_stream.is_open()) {
            string line;
            while (getline(input_stream, line)) {
                _float_t theta, r;
                auto pos = line.find(' ');
                theta = stod(line.substr(0, pos));
                r = stod(line.substr(pos));
                sites.emplace_back(r, theta);
            }
            input_stream.close();
        } else {
            cout << "Unable to open input file \"" << input_file << "\"\n";
            exit(1);
        }
    } catch (...) {
        cout << "Error while reading file \"" << input_file << "\"\n";
        exit(1);
    }

    int precision = result["p"].as<int>();

    std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();

    VoronoiDiagram v;

    switch (precision) {
    case 32: {
      cout << "Using a precision of 32bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_32>, floating_point_type_32> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 48: {
      cout << "Using a precision of 48bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_48>, floating_point_type_48> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 64: {
      cout << "Using a precision of 64bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_64>, floating_point_type_64> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 80: {
      cout << "Using a precision of 80bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_80>, floating_point_type_80> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 96: {
      cout << "Using a precision of 96bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_96>, floating_point_type_96> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 112: {
      cout << "Using a precision of 112bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_112>, floating_point_type_112> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 128: {
      cout << "Using a precision of 128bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_128>, floating_point_type_128> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 144: {
      cout << "Using a precision of 144bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_144>, floating_point_type_144> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 160: {
      cout << "Using a precision of 160bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_160>, floating_point_type_160> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 176: {
      cout << "Using a precision of 176bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_176>, floating_point_type_176> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 192: {
      cout << "Using a precision of 192bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_192>, floating_point_type_192> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 208: {
      cout << "Using a precision of 208bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_208>, floating_point_type_208> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 224: {
      cout << "Using a precision of 224bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_224>, floating_point_type_224> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 240: {
      cout << "Using a precision of 240bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_240>, floating_point_type_240> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    case 256: {
      cout << "Using a precision of 256bits.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<floating_point_type_256>, floating_point_type_256> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
      break;
    }
    default: {
      cout << "Using Double precision.\n";
      FortuneHyperbolicImplementation<FullNativeKernel<double>, double> fortune(v, sites, result["v"].as<bool>());
      fortune.calculate();
    }
    }

    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();

    cout << "Finished calculating Voronoi diagram after " << std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count() << " microseconds" << endl;

    VoronoiCanvasOptions canvas_options;
    canvas_options.width = 500;
    VoronoiCanvas canvas(v, sites);
    if (result.count("d")) {
        string output_file = result["d"].as<string>();
        canvas.set_options(canvas_options);
        canvas.draw_diagram(output_file);
        cout << "Drawing written to: " << output_file << "\n";
    }

    if (result.count("t")) {
        string output_file = result["t"].as<string>();
        canvas.write_delaunay_triangulation(output_file);
        cout << "Triangulation written to: " << output_file << ".\n";
    }

    return 0;
}
