#ifndef _FILTERS_HH_
#define _FILTERS_HH_

#include <opencv2/imgproc/imgproc.hpp>
#include <cmath>

void smooth(cv::Mat& image, int iters=10, int d=25, float alpha=0.3, float gamma=0.8);

inline double d1(int t, float gamma) {
    return 40 * pow(gamma, t);
}

inline double d2(int t, float gamma) {
    return 80 * pow(gamma, t);
}

inline uint8_t Dfab(uint8_t x, int t, float gamma) {
    return 2*exp(-1*(x/d1(t, gamma)*x/d1(t, gamma))) - exp(-1*((x/d2(t, gamma))*(x/d2(t, gamma))));
}

#endif