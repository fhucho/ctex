function rgb_image_to_yiq(image_rgb::Array{Float64, 3})
	image_yiq = copy(image_rgb)
	for x in 1:size(image_rgb, 2), y in 1:size(image_rgb, 3)
		image_yiq[:, x, y] = rgb_pixel_to_yiq(image_rgb[:, x, y])
	end
	return image_yiq
end

function yiq_image_to_rgb(image_yiq::Array{Float64, 3})
	image_rgb = copy(image_yiq)
	for x in 1:size(image_yiq, 2), y in 1:size(image_yiq, 3)
		image_rgb[:, x, y] = yiq_pixel_to_rgb(image_yiq[:, x, y])
	end
	return image_rgb
end

function rgb_pixel_to_yiq(rgb::Array{Float64, 1})
	yiq = [0.299 0.587 0.114; 0.595716 -0.274453 -0.321263; 0.211456 -0.522591 0.311135] * rgb
	yiq[2] += 0.5957
	yiq[2] /= (0.5957 * 2)
	yiq[3] += 0.5226
	yiq[3] /= (0.5226 * 2)
	return yiq
end

function yiq_pixel_to_rgb(yiq::Array{Float64, 1})
	yiq[2] *= (0.5957 * 2)
	yiq[2] -= 0.5957
	yiq[3] *= (0.5226 * 2)
	yiq[3] -= 0.5226
	return [1 0.9563 0.6210; 1 -0.2721 -0.6474; 1 -1.1070 1.7046] * yiq
end
