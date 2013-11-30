#include <iostream>
#include <opencv2/imgproc/imgproc.hpp>
#include "filters.hh"

#define FAILURE 1
#define SUCCES 0

int main(int argc, char *argv[]) {

    cv::Mat image;

    if (argc < 2) {
        std::cerr << "Usage: ./ctex <image_name>" << std::endl;
    }

    // we suppose format CV_16U with 3 channels
    image = cv::imread(argv[1])
    if (image.data == NULL) { return FAILURE; }

    Dfab(image);

    return 0;
}
