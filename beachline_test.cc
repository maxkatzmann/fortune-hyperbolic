#include <gtest/gtest.h>

#include "beachline.hpp"
#include "kernels.hpp"
#include "fortune.hpp"

#include <vector>
#include <memory>

using std::shared_ptr, std::make_shared;
using namespace hyperbolic;

TEST(BeachLineTest, InsertsCorrectly) {
    FullNativeKernel<double> K;
    BeachLine<FullNativeKernel<double>, double> beachLine(K);

    Point<double> mock(0, 0);
    Point<double>* pMock = &mock;

    int n = 30;
    vector<Site<double>> v;
    for (int i = 0; i < n; i++) {
        v.emplace_back(Point<double>(1, 1), i);
    }

    for (int i = 1; i < n; i++) {
        Site<double>* hitSite = &v[i];
        if (beachLine.size() > 0) {
            auto result = beachLine.getFirstElement();
            hitSite = &result->second;
        }
        auto* first = new BeachLineElement<double>(v[i], *hitSite, nullptr, pMock);
        auto* second = new BeachLineElement<double>(*hitSite, v[i], nullptr, pMock);
        beachLine.insert(0, *first, *second);
    }

    vector<BeachLineElement<double>*> elements;
    beachLine.getRemainingElements(elements);

    unsigned long long current_id = elements[0]->second.ID;
    for (size_t i = 1; i < elements.size(); i++) {
        EXPECT_EQ(current_id, elements[i]->first.ID);
        current_id = elements[i]->second.ID;
    }
};
