#include <iostream>
#include <algorithm>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "filters.hh"

#define FAILURE 1
#define SUCCES 0


int main(int argc, char *argv[]) {

    cv::Mat image, image_rgb, image_yiq;

    if (argc < 2) {
        std::cerr << "Usage: ./ctex <image_name>" << std::endl;
    }

    /** 
    *   The image is in the format CV_8U with 3 channels B G R, so the data are
    *   in a matrix of size image.rows * (image.cols * 3). One can access these
    *   values using image.at<uchar>(x, y). Remember y is in range (0, image.cols * 3).
    */
    image = cv::imread(argv[1], CV_LOAD_IMAGE_COLOR);
    if (image.data == NULL) { return FAILURE; }

    image_rgb = image.clone();
    ctex::gb_fab(image_rgb, 1);


    return 0;
}
