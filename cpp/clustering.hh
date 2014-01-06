#ifndef _CLUSTERING_HH_
#define _CLUSTERING_HH_

#include <opencv2/core/core.hpp>
#include <array>


#define GRANULANITY = 256
#define BINS = 4 * GRANULANITY
#define MAXWINDOW = 12

namespace ctex {
    
    /**
    * Returns 16 dominant colors from quantized image (quantization 255 -> 8)
    **/
    void dominant_colors(cv::Mat &image, uchar *result, size_t n=16);

    void cluster(cv::Mat &image, uchar *colors, size_t n=16, float sigma=1.0f, float learning_rate=0.5f);

// # Array formats:
// # textures[i][y, x]
// # clusters[cluster, window, bin]
// # hists[window, bin]
// # dhists[cluster, window, bin]
// # ds[cluster, window]


struct Askm {
    int nclusters, width=4, height=4;
    cv::Mat image;
    // TODO!!
    textures::Array{Array{Int, 2}, 1}

    clustered::Array{Int, 2}
    counts::Array{Int, 1}
    changed::Int
    objective::Float64
    clusters_clr::Array{Float64, 3}
    clusters_tex::Array{Float64, 3}
    sums_clr::Array{Float64, 3}
    sums_tex::Array{Float64, 3}

    Askm(cv::Mat& image, int nclusters, int w, int h): image(image), nclusters(nclusters), width(w), height(h)
    {
        clusters = Array(Float64, nclusters, MAXWINDOW, nclusters)
        
        for i in 1:nclusters
            x = iround((w / (nclusters + 1)) * i)
            y = iround((h / (nclusters + 1)) * i)
            hists = color_hists(image, nclusters, x + 13, y + 13)
            clusters[i, :, :] = reshape(hists, 1, MAXWINDOW, nclusters)
        end

        return clusters
    }

    function init_clusters_tex(textures, nclusters, w, h)
        clusters = Array(Float64, nclusters, MAXWINDOW, BINS)
        
        for i in 1:nclusters
            x = iround((w / (nclusters + 1)) * i)
            y = iround((h / (nclusters + 1)) * i)
            hists = hists_of_pixel(textures, x + 13, y + 13)
            clusters[i, :, :] = reshape(hists, 1, MAXWINDOW, BINS)
        end

        return clusters
    end

    function Askm(image, textures, nclusters)
        w = size(textures[1], 2)
        h = size(textures[1], 1)
        
        clustered = zeros(Int, h, w) - 1

        padded_image = padarray(image, [13, 13], [13, 13], "reflect", 0)

        padded_textures = copy(textures)
        for i in 1:4
            padded_textures[i] = padarray(textures[i], [13, 13], [13, 13], "reflect", 0)
        end

        clusters_clr = init_clusters_clr(padded_image, nclusters, w, h)
        clusters_tex = init_clusters_tex(padded_textures, nclusters, w, h)

        new(nclusters, w, h, padded_image, padded_textures, clustered, Array(Int, 0), 0, 0.0, clusters_clr, clusters_tex, Array(Float64, 0, 0, 0), Array(Float64, 0, 0, 0))
    end
};

}

#endif
