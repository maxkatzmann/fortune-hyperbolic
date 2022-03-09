#include <cmath>
#include <cstdlib>
#include <iostream>
#include <random>
#include <fstream>
#include <iomanip>

#include "cxxopts.h"

using namespace std;

int main(int argc, char* argv[]) {
    cxxopts::Options options(
            "generator", "Generator for sampling points in the hyperbolic plane and writing them to a file.");

    options.add_options()
            ("o,output", "Output Filename", cxxopts::value<std::string>()->default_value("sample.txt"))
            ("N", "Number of points to sample", cxxopts::value<int>()->default_value("-1")) 
            ("R", "Radius within which points are sampled", cxxopts::value<double>()->default_value("-1"))
            ("a,alpha", "Parameter alpha of the distribution from which we sample",cxxopts::value<double>()->default_value("1"))
            ("d", "Desired average degree",cxxopts::value<double>()->default_value("8"))
            ("h,help", "Print usage");

    auto result = options.parse(argc, argv);

    if (result.count("help")) {
        std::cout << options.help() << std::endl;
        exit(0);
    }

    // Path to output
    string filename = result["o"].as<string>();

    // Radius of disk containing the points
    double R = result["R"].as<double>();

    // Number of points to be distributed
    int N = result["N"].as<int>();

    if (R < 0 && N < 0) {
      std::cerr << "At least one of R or N has to be specified.\n";
      return EXIT_FAILURE;
    }

    // This parameter can be used to skew the distribution away from
    // the boundary of the disk.  The smaller alpha, the more likely
    // it is that a point is sampled closeer to the origin.
    double alpha = result["alpha"].as<double>();

    // If R is not specified
    if (R < 0) {
      double d = result["d"].as<double>();
      double alpha_fraction = alpha / (alpha - 0.5);
      R = 2.0 * log(2.0 * N / (M_PI * d) * (alpha_fraction * alpha_fraction));
    }

    // If N is not specified
    if (N < 0) {
      // Choose depending on R such that for R = target_R we get
      // target_N nodes.
      const double target_R = 30.0;
      const double target_N = 10000000;

      const double c = acosh(target_N / (2 * M_PI) + 1) / target_R;

      N = 2.0 * M_PI * (cosh(c * R) - 1);
    }

    cout << "Using R = " << R << "\n";
    cout << "Using N = " << N << "\n";
    cout << "Writing to file: " << filename << "\n";

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);

    std::fstream output_file_stream(filename, std::fstream::out);
    output_file_stream << std::fixed << std::setprecision(6);

    for(int i=0; i<N; ++i) {
        double angle = dis(gen) * 2 * M_PI;
        double radius = acosh(1+(cosh(alpha*R)-1)*dis(gen))/alpha;

        output_file_stream << angle << " " << radius << "\n";
    }
    return 0;
}
