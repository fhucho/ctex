#include "clustering.hh"
#include <iostream>
#include <functional>

namespace ctex {

    /**
    * Uses 1D array to store 3D array in it. Every dimension is shifted by 3 to
    * the left (each dimension has 8 values).
    * In the end it saves `num` indexes (colors) of the highest values into the result
    **/
    void dominant_colors(cv::Mat &image, uchar *result, size_t num) {
        std::array<int,8*8*8> *histogram = new std::array<int,8*8*8>(), *sorted = new std::array<int,8*8*8>();
        histogram->fill(0);
        // make histogram
        for(size_t x = 0; x < image.rows; ++x)
            for(size_t y = 0; y < image.cols; ++y)
                (*histogram)[(image.at<uchar>(x, y+0) / 32) + \
                          ((image.at<uchar>(x, y+1) / 32) << 3) + \
                          ((image.at<uchar>(x, y+2) / 32) << 6)] += 1;

        // sort values
        std::copy(histogram->begin(), histogram->end(), sorted->begin());
        std::sort(sorted->begin(), sorted->end(), std::greater<int>());

        // find the n-highest value and save it's index = color
        size_t last_index = 0;
        int last_value = -1;
        for(size_t i = 0; i < num; ++i) {
            int value = (*sorted)[i];
            size_t index = 0;
            // don't take one value twice
            if(last_value == value) index = last_index + 1;
            while((*histogram)[index] != value) ++index;
            result[(i*3)] = index & 0x07;
            result[(i*3)+1] = (index >> 3) & 0x07;
            result[(i*3)+2] = (index >> 6) & 0x07;
        }
        for(size_t i = 0; i < num*3; i++) result[i] = result[i] * 32 + 16;

        delete histogram, sorted;
    }

}
