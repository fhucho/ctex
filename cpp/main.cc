#include <iostream>
#include <algorithm>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "filters.hh"
#include "clustering.hh"

#define FAILURE 1
#define SUCCES 0

using std::string;


int main(int argc, char *argv[]) {

    cv::Mat image, image_rgb; // , image_yiq;

    if (argc < 2) {
        std::cerr << "Usage: ./ctex <image_name>" << std::endl;
        return 1;
    }

    string output = string(argv[1]) + string(".filtered.rgb.png");

    /** 
    *  The image is in the format CV_8U with 3 channels B G R, so the data are
    *  in a matrix of size image.rows * (image.cols * 3). One can access these
    *  values using image.at<uchar>(x, y).
    *  Remember that `y` is in the range (0, image.cols * 3) and the color order
    *  is B G R.
    */
    image = cv::imread(argv[1], CV_LOAD_IMAGE_COLOR);
    if (image.data == NULL) { return FAILURE; }

    // image_bgr = image.clone();
    // ctex::gb_fab(image_bgr, 2);
    // cv::imwrite(output, image_bgr);

    // cvtColor(image, image_yiq, CV_BGR2YUV); // TODO: replace with proper YIQ
    // ctex::gb_fab(image_yiq, 2);

    auto *dc_bgr = new std::array<uchar, 16*3>;
    ctex::dominant_colors(image, dc_bgr->data(), 16);
    ctex::cluster(image_bgr, dc_bgr->data(), 16);
    delete dc_bgr;

    return 0;
}
