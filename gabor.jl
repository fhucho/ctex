using Images
using ImageView

function gabor_function(x, y, sigma, angle, wavelen)
	angle_rad = angle / 180 * pi
	x_ = x * cos(angle_rad) + y * sin(angle_rad)
	y_ = -x * sin(angle_rad) + y * cos(angle_rad)
	gaussian = exp(-((x_^2 + y_^2) / (2 * sigma^2)))
	wave = cos(2 * pi * x_ / wavelen)
	return gaussian * wave
end

function gabor_kernel(wavelen, angle)
	sigma = wavelen * 0.65
	size = int(8 * sigma)
	if size % 2 == 0
		size += 1
	end
	kernel = zeros(size, size)
	
	for x in 1:size
		for y in 1:size
			x_ = x - div(size, 2) - 1
			y_ = y - div(size, 2) - 1
			kernel[x, y] = gabor_function(x_, y_, sigma, angle, wavelen)
		end
	end
	
	return kernel
end

function filter_with_gabor(image, wavelen, angle)
	kernel = gabor_kernel(wavelen, angle)
	filtered_image = imfilter(image, kernel, "reflect")
	return filtered_image
end

function a(image, sigma)
	f = zeros(size(image))
	for angle in [0, 45, 90, 135]
		f += filter_with_gabor(image, sigma, angle)
	end
	return f / 4
end

image = convert(Array, imread("tiger.png"))
image = reshape(mean(image / 255, 3), size(image, 1), size(image, 2))
display(a(image, 6))

