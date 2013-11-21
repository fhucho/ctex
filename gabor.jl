using Images
using ImageView

include("color.jl")

function gabor_function(x, y, sigma, angle, freq)
	angle_rad = angle / 180 * pi
	x_ = x * cos(angle_rad) + y * sin(angle_rad)
	y_ = -x * sin(angle_rad) + y * cos(angle_rad)
	gaussian = exp(-((x_^2 + y_^2) / (2 * sigma^2)))
	wave = cos(2 * pi * x_ * freq)
	return gaussian * wave
end

function gabor_kernel(sigma, freq, angle)
	size = int(8 * sigma)
	if size % 2 == 0
		size += 1
	end
	kernel = zeros(size, size)
	
	for x in 1:size, y in 1:size
		x_ = x - div(size, 2) - 1
		y_ = y - div(size, 2) - 1
		kernel[x, y] = gabor_function(x_, y_, sigma, angle, freq)
	end
	
	return kernel
end

function filter_with_gabor(image, sigma, freq, angle)
	kernel = gabor_kernel(sigma, freq, angle)
	filtered_image = imfilter(image, kernel, "reflect")
	return filtered_image
end

function extract_textures(image_rgb)
	image_yiq = rgb_image_to_yiq(image_rgb)
	luma = permutedims(image_yiq, [3, 2, 1])[:, :, 1]
	textures = Array{Float64, 2}[]

	for angle in [0, 45, 90, 135]
		texture = filter_with_gabor(luma, 3, 1.5/2pi, angle)
		push!(textures, texture)
	end

	min = minimum(map(minimum, textures))
	textures = map(t -> t - min, textures)
	max = maximum(map(maximum, textures))
	textures = map(t -> iround((t / max) * 255 + 1), textures)

	return textures
end
