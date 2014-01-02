#include "settings.hh"
#include "filters.hh"
#include <iostream>
#include <array>
#include <functional>
#include <cmath>

namespace ctex {

    /**
    *   This filter smooths given image and perserve medium borders.
    *   It expects an 3 channel UINT8 image.
    **/ 
    void gb_fab(cv::Mat& image, int iters, int d, float alpha, float gamma) {
        const int neighs_cnt = 8;

        cv::Mat bordered; //(image.rows + 2, image.cols + 6, image.type());
        cv::Point neighs[] = {cv::Point(-1, -3), cv::Point(-1, 0), cv::Point(-1, 3), 
                              cv::Point( 0, -3),                   cv::Point( 0, 3),
                              cv::Point( 1, -3), cv::Point( 1, 0), cv::Point( 1, 3)};

        for(int iter=0; iter<iters; ++iter) {
            cv::copyMakeBorder(image, bordered, 1, 1 ,1 ,1, cv::BORDER_CONSTANT, 0);
            
            if(CTEX_LOG_LEVEL <= CTEX_INFO) std::cout << "Filter " << iter+1 << "/" << iters <<std::endl;

            /** DEBUG STUFF **/
            // std::cout << "Bordered (" << bordered.rows << "x" << bordered.cols << ")" << std::endl;
            // std::cout << "[";
            // for(size_t x = 0; x < 5; ++x) {
            //     for(size_t y = 0; y < 5 * 3 ; y+=3) {
            //         std::cout << "(";
            //         for(size_t d = 0; d < 3; ++d) {
            //             std::cout << uint32_t(image.at<uchar>(x, y+d)) << " ";
            //         }
            //         std::cout << "), ";
            //     }
            //     std::cout << std::endl;
            // }
            // std::cout << "]" << std::endl;


            for(size_t x = 1; x < bordered.rows - 1; ++x) {
                for(size_t y = 3; y < (bordered.cols - 1) * 3 ; ++y) {
                    // compute gradients for all directions
                    std::array<double, neighs_cnt> grads, boosted_abs_grad;
                    for(int j=0; j < neighs_cnt; ++j) {
                        int32_t a = bordered.at<uchar>(x, y);
                        int32_t b = bordered.at<uchar>(x + neighs[j].x, y + neighs[j].y);
                        grads[j] = a - b;
                    }
                    // compute the f*cking median which spoils simple matrix operations
                    auto grads_sorted = grads;
                    std::sort(grads_sorted.begin(), grads_sorted.end());
                    double median = grads_sorted[neighs_cnt / 2];

                    for(int j=0; j < neighs_cnt; ++j) {
                        // "boost" the gradient values
                        boosted_abs_grad[j] = std::abs(grads[j]) * (1 + 2.0 * exp(-1 * std::abs(std::abs(grads[j]) - median) / d1(iter, gamma)));
                        // multiply with the pixel value
                        grads[j] = Dfab(boosted_abs_grad[j], iter, gamma) * grads[j] * alpha;
                    }
                    // compute divergence
                    image.at<uchar>(x, y) += (char)std::accumulate(grads.begin(), grads.end(), 0.0, std::plus<double>());
                }
            } // end for each pixel
        }
    }

}
