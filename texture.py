import matplotlib.cm as cm

from math import exp, cos, sin, pi
from numpy import zeros
from pylab import imread, imshow, gray, mean, show
from scipy.ndimage.filters import convolve

def gabor(x, y, sigma, angle, wavelen):
	"""Compute the real component of a 2D Gabor function."""
	angle_rad = angle / 180 * pi
	x_ = x * cos(angle_rad) + y * sin(angle_rad)
	y_ = -x * sin(angle_rad) + y * cos(angle_rad)
	gaussian = exp(-((x_**2 + y_**2) / (2 * sigma**2)))
	wave = cos(2 * pi * x_ / wavelen)
	return gaussian * wave


def gabor_kernel(wavelen, angle):
	"""Return the real component of a 2D Gabor filter."""
	sigma = wavelen * 0.65 # Found on the internet
	size = (int) (8 * sigma) # -4 sigma to +4 sigma
	kernel = zeros((size, size))
	
	for x in range(size):
		for y in range(size):
			kernel[x][y] = gabor(x - size // 2, y - size // 2, sigma, angle, wavelen)
	
	return kernel


def show_gray(image):
	imshow(image, cmap=cm.gray)
	show()


def filter_with_gabor(image, wavelen=20, angle=0):
	kernel = gabor_kernel(wavelen, angle)
	filtered_image = abs(convolve(image, kernel))
	imshow(filtered_image, cmap=cm.gray)
	show()


image = mean(imread('woods.png'), 2)
filter_with_gabor(image)
