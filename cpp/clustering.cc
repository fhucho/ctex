#include "clustering.hh"
#include <iostream>
#include <functional>
#include <random>
#include "utils.hh"
#include "settings.hh"

namespace ctex {

    /**
    * Uses 1D array to store 3D array in it. Every dimension is shifted by 3 to
    * the left (each dimension has 8 values).
    * In the end it saves `num` indexes (colors) of the highest values into the result
    **/
    void dominant_colors(cv::Mat &image, uchar *result, size_t n) {
        std::array<int,8*8*8> *histogram = new std::array<int,8*8*8>(), *sorted = new std::array<int,8*8*8>();
        histogram->fill(0);
        // make a histogram
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
        for(size_t i = 0; i < n; ++i) {
            int value = (*sorted)[i];
            size_t index = 0;
            // don't take one value twice
            if(last_value == value) index = last_index + 1;
            while((*histogram)[index] != value) ++index;
            result[(i*3)] = index & 0x07;
            result[(i*3)+1] = (index >> 3) & 0x07;
            result[(i*3)+2] = (index >> 6) & 0x07;
        }
        for(size_t i = 0; i < n*3; i++) result[i] = result[i] * 32 + 16;
        delete histogram, sorted;
    }

    void cluster(cv::Mat &image, uchar *colors, size_t n, float sigma, float learning_rate) {
        auto generator = std::default_random_engine();
        cv::Mat activation_map(4, 4, CV_8UC3, colors); // activation_map.at<uchar>(x,y+z), beware BGR order
    }

}


/*

    import argparse
import png
from numpy import sqrt,sqrt,array,unravel_index,nditer,linalg,random,subtract,power,exp,pi,zeros,arange,outer,meshgrid
from collections import defaultdict

class MiniSom:
    def __init__(self,x,y,input_len,):
        """
Initializes a Self Organizing Maps.
x,y - dimensions of the SOM
input_len - number of the elements of the vectors in input
sigma - spread of the neighborhood function (Gaussian)
(at the iteration t we have sigma(t) = sigma / (1 + t/T) where T is #num_iteration/2)
learning_rate - initial learning rate
(at the iteration t we have learning_rate(t) = learning_rate / (1 + t/T) where T is #num_iteration/2)
"""
        self.learning_rate = learning_rate
        self.sigma = sigma
        self.weights = random.rand(x,y,input_len)*255 # random initialization
        #self.weights = array([v/linalg.norm(v) for v in self.weights]) # normalization
        self.activation_map = zeros((x,y))
        self.neigx = arange(x)
        self.neigy = arange(y) # used to evaluate the neighborhood function
        self.neighborhood = self.gaussian

    def _activate(self,x):
        """ Updates matrix activation_map, in this matrix the element i,j is the response of the neuron i,j to x """
        s = subtract(x,self.weights) # x - w        
        it = nditer(self.activation_map, flags=['multi_index'])
        while not it.finished:
            distance = s[it.multi_index] * s[it.multi_index]
            distance = sum(distance)            
            distance = sqrt(distance)
            self.activation_map[it.multi_index] = distance # || x - w ||            
            it.iternext()
    def get_distance(self, pixel1, pixel2):
        s = list(pixel1)
        for i, v in enumerate(pixel2):
            s[i] = s[i] - v
            s[i] = s[i] / 255 #normalization
        distance = [a * a for a in s]
        distance = sum(distance)
        distance = sqrt(distance)
        return distance

    def is_adjacent(self, tuple1, tuple2):
        x1,y1 = tuple1
        x2,y2 = tuple2

        if(x1 == x2):
            if(abs(y1-y2) == 1):
                return True
        if(y1 == y2):
            if(abs(x1-x2) == 1):
                return True
        return False
        
    def activate(self,x):
        """ Returns the activation map to x """
        self._activate(x)
        return self.activation_map

    def gaussian(self,c,sigma):
        """ Returns a Gaussian centered in c """
        d = 2*pi*sigma*sigma
        ax = exp(-power(self.neigx-c[0],2)/d)
        ay = exp(-power(self.neigy-c[1],2)/d)
        return outer(ax,ay) # the external product gives a matrix

    def winner(self,x):
        """ Computes the coordinates of the winning neuron for the sample x """
        self._activate(x)
        return unravel_index(self.activation_map.argmin(),self.activation_map.shape)

    def update(self,x,win,t):
        """
Updates the weights of the neurons.
x - current pattern to learn
win - position of the winning neuron for x (array or tuple).
eta - learning rate
t - iteration index
"""
        # eta(t) = eta(0) / (1 + t/T)
        # keeps the learning rate nearly constant for the first T iterations and then adjusts it
        eta = self.learning_rate/(1+t/self.T)
        sig = self.sigma/(1+t/self.T) # sigma and learning rate decrease with the same rule
        g = self.neighborhood(win,sig)*eta # improves the performances
        it = nditer(g, flags=['multi_index'])
        while not it.finished:
            # eta * neighborhood_function * (x-w)
            self.weights[it.multi_index] += g[it.multi_index]*(x-self.weights[it.multi_index])
            # normalization
            #self.weights[it.multi_index] = self.weights[it.multi_index] / linalg.norm(self.weights[it.multi_index])
            it.iternext()

    def quantization(self,data):
        """ Assigns a code book (weights vector of the winning neuron) to each sample in data. """
        q = []
        for i, x in enumerate(data):
            if((i % 1000) == 0):
                print('Iteration ' + i.__str__() + ' of ' + len(data).__str__())
            q.append(list(self.weights[self.winner(x)]))
        return q

    def quantizationW(self,data):
        """ Assigns a code book (weights vector of the winning neuron) to each sample in data. """
        q = []
        for i, x in enumerate(data):
            if((i % 1000) == 0):
                print('Iteration ' + i.__str__() + ' of ' + len(data).__str__())
            q.append(self.winner(x))
        return q  
    
    def train_batch(self,data,num_iteration):
        """ Trains using all the vectors in data sequentially """
        self._init_T(len(data)*num_iteration)
        iteration = 0
        while iteration < num_iteration:
            if((iteration % 1000) == 0):
                print('Iteration ' + iteration.__str__() + ' of ' + num_iteration.__str__())
            idx = iteration % (len(data)-1)
            self.update(data[idx],self.winner(data[idx]),iteration)
            iteration += 1

    def _init_T(self,num_iteration):
        """ Initializes the parameter T needed to adjust the learning rate """
        self.T = num_iteration/2 # keeps the learning rate nearly constant for the first half of the iterations

    def round_weights(self):
        it = nditer(self.weights, flags=['multi_index'])
        while not it.finished:            
            self.weights[it.multi_index] = int(self.weights[it.multi_index])
            it.iternext()


}
*/
