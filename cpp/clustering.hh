#ifndef _CLUSTERING_HH_
#define _CLUSTERING_HH_

#include <opencv2/core/core.hpp>
#include <array>

namespace ctex {
    
    /**
    * Returns 16 dominant colors from quantized image (quantization 255 -> 8)
    **/
    void dominant_colors(cv::Mat &image, uchar *result, size_t num=16);

}

#endif
