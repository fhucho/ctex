#include "filters.hh"
#include <iostream>
#include <array>


namespace ctex {

    /**
    *   This filter smooths given image and perserve medium borders.
    *   It expects an 3 channel UINT8 image.
    **/ 
    void gb_fab(cv::Mat& image, int iters, int d, float alpha, float gamma) {
        const int neighs_cnt = 4;

        cv::Mat bordered(image.rows + 2, image.cols + 6, image.type());
        cv::Point neighs[] = {cv::Point(3, 0), cv::Point(0, -1), cv::Point(-3, 0), cv::Point(0, 1)};

        for(int i=0; i<iters; ++i) {
            cv::copyMakeBorder(image, bordered, 1, 1 ,1 ,1, cv::BORDER_CONSTANT, 0);
            
            /** DEBUG STUFF
            std::cout << "Original:" << std::endl << image << std::endl;
            std::cout << "Bordered:" << std::endl << "[";
            for(size_t x = 0; x < bordered.rows; ++x) {
                for(size_t y = 0; y < bordered.cols * 3 ; y+=3) {
                    std::cout << "(";
                    for(size_t d = 0; d < 3; ++d) {
                        std::cout << uint32_t(bordered.at<uchar>(x, y+d)) << " ";
                    }
                    std::cout << "), ";
                }
                std::cout << std::endl;
            }
            std::cout << "]" << std::endl;
            **/
            cv::Point cur = cv::Point(1, 3);
            for(; cur.x < bordered.rows - 1; ++(cur.x)) {
                for(; cur.y < (bordered.cols - 1) * 3 ; ++(cur.y)) {
                    int32_t grad[neighs_cnt];
                    for(int i=0; i < neighs_cnt; ++i) {
                        grad[i] = bordered.at(cur) - bordered.at(cur + neighs[i])
                    }
                }
            }
        }

        // divergence = sum (gradient)
        // grad_abs * (1 + 2 * exp(-1 * (grad_abs - median) / d1(t, gamma)));
    }

}
