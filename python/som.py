import argparse
import png
from numpy import sqrt,sqrt,array,unravel_index,nditer,linalg,random,subtract,power,exp,pi,zeros,arange,outer,meshgrid
from collections import defaultdict

class MiniSom:
    def __init__(self,x,y,input_len,sigma=1.0,learning_rate=0.5):
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

arg_parser = argparse.ArgumentParser(description='Image processing')
arg_parser.add_argument('image', metavar='Path to input file', type=argparse.FileType('rb'), help='Path to input file')

try:    
    #args = arg_parser.parse_args()
    path_Image = "tiger.png"
    #path_Image = "C:/Users/jantk_000/Downloads/FIT2013_zimni/00ff00.png"
    args = arg_parser.parse_args([path_Image])
except FileNotFoundError as e:
    print('ERROR - Wrong path to input file.')    
    exit(-1)

input_image = png.Reader(file=args.image)
rgb = input_image.asRGB8()
rows = list(rgb[2])
processed_rows = []
processed_rows8 = []
train_data = []
for row in rows:
    a = row.tolist()
    new_row = []
    for color in a:
        #Reduce to 3bit values
        new_row.append(color >> 5)
    processed_rows.append(new_row)
    processed_rows8.append(a)

#MAKE COLOUR HISTOGRAM
histogram = {}

for row in processed_rows:
    index = 0
    while(index < len(row)):
        R = row[index]
        G = row[index + 1]
        B = row[index + 2]
        index = index + 3        
        value = histogram.get((R,G,B))        
        if(value == None):            
            histogram[(R,G,B)] = 1
        else:
            histogram[(R,G,B)] = value + 1

histogram = sorted(histogram.items(), key = lambda x: x[1], reverse = True)

for row in processed_rows8:
    index = 0
    while(index < len(row)):
        R = row[index]
        G = row[index + 1]
        B = row[index + 2]
        index = index + 3        
        train_data.append([R,G,B])

if(len(histogram) >= 16):
    seeds = histogram[:16]    
    #WE CAN FIND BEST COLOUR HERE OR DO NOTHING
    som = MiniSom(4,4,3)
    x,y = 0,0    
    for seed in seeds:
        som.weights[x][y] = [n << 5 for n in seeds[(x*4) + y][0]]
        x = x + 1
        if(x == 4):
            x = 0
            y = y + 1
    print("SOM WEIGHTS BEFORE TRAINING")
    print(som.weights)
    print("TRAINING")
    som.train_batch(train_data,len(train_data))
    print("SOM WEIGHTS AFTER TRAINING")
    print(som.weights)
    print("ROUNDING WEIGHTS")
    som.round_weights()
    print("QUANTIZATION")
    clustered = som.quantization(train_data)
    print("WRITING TO FILE")

    p = []
    row = []
    for i,pixel in enumerate(clustered):
        row.append(pixel[0])
        row.append(pixel[1])
        row.append(pixel[2])
        if(((i + 1) % rgb[0]) == 0):
            p.append(row)
            row = []
    
    f = open('clustered.png', 'wb')
    w = png.Writer(rgb[0], rgb[1])
    w.write(f, p)
    f.close()

    print("CALCULATION OF CONFIDENCE TABLE")
    confidence = {}
    clusters = som.quantizationW(train_data)
    for i,pixel in enumerate(train_data):
        cumulatedError = confidence.get(clusters[i])        
        if(cumulatedError == None):            
            confidence[clusters[i]] = som.get_distance(pixel, clustered[i])
        else:
            confidence[clusters[i]] = confidence[clusters[i]] + som.get_distance(pixel, clustered[i])

    for conf in confidence:
        confidence[conf] = confidence[conf] / clusters.count(conf)

    print(confidence)
    
    print("CALCULATION OF INTERCLUSTER VARIABILITY")
    matrix = {}
    for i,row in enumerate(som.weights):
        for j, weight in enumerate(row):
            for i2, row2 in enumerate(som.weights):
                for j2, weight2 in enumerate(row2):
                    matrix[((i,j),(i2,j2))] = som.get_distance(weight, weight2)
    
    matrix2 = sorted(matrix.items(), key = lambda x: x[1], reverse = True)
    print(matrix2)

    print("REMOVING SIMILAR CLUSTERS")
    clusters_to_be_removed = []
    for item in matrix:
        first, second = item
        if(matrix[item] < 0.3):
            if(som.is_adjacent(first,second)):
                confidence_A = confidence.get(first)
                confidence_B = confidence.get(second)
                if(confidence_A == None):
                    confidence_A = 1
                if(confidence_B == None):
                    confidence_B = 1
                if(confidence_A > confidence_B):
                    clusters_to_be_removed.append(first)
                else:
                    clusters_to_be_removed.append(second)
    clusters_to_be_removed = set(clusters_to_be_removed)
    print(clusters_to_be_removed)
    optimum_no_of_clusters = 16 - len(clusters_to_be_removed)
    print("OPTIMUM NUMBER OF CLUSTERS IS: " + optimum_no_of_clusters.__str__())
    optimal_centroids = []
    for i in range(0,4):
        for j in range(0,4):
            if(clusters_to_be_removed.__contains__((i,j)) == False):
                optimal_centroids.append(list(som.weights[i][j]))
    print("OPTIMAL CENTROIDS")
    print(optimal_centroids)

    helping_som = MiniSom(1,optimum_no_of_clusters,3)
    for i,value in enumerate(optimal_centroids):
        helping_som.weights[0][i] = value
    clustered2 = helping_som.quantization(train_data)

    p = []
    row = []
    for i,pixel in enumerate(clustered2):
        row.append(pixel[0])
        row.append(pixel[1])
        row.append(pixel[2])
        if(((i + 1) % rgb[0]) == 0):
            p.append(row)
            row = []
    
    f = open('clustered2.png', 'wb')
    w = png.Writer(rgb[0], rgb[1])
    w.write(f, p)
    f.close()
    
else:
    print("ERROR not enough colours - need to generate some")

