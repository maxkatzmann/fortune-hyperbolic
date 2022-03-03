#include <gtest/gtest.h>

#include "beachline.hpp"
#include "kernels.hpp"
#include "fortune.hpp"

#include <vector>
#include <memory>

using std::shared_ptr, std::make_shared;
using namespace hyperbolic;

TEST(VoronoiTest, ComputesCorrectly) {
    VoronoiDiagram v;
    vector<Point<double>> sites = {
            {3, 2.43},
            {2, 2.19},
            {6, 0.87},
            {9.2, 1.23}
    };
    FortuneHyperbolicImplementation<FullNativeKernel<double>, double>fortune(v, sites);
    fortune.calculate();

    EXPECT_EQ(3, v.edges.size());

    EXPECT_EQ(0, v.edges[0]->siteA.ID);
    EXPECT_EQ(1, v.edges[0]->siteB.ID);

    EXPECT_EQ(2, v.edges[1]->siteA.ID);
    EXPECT_EQ(1, v.edges[1]->siteB.ID);

    EXPECT_EQ(3, v.edges[2]->siteA.ID);
    EXPECT_EQ(1, v.edges[2]->siteB.ID);
}
