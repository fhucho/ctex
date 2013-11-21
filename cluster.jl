using Clustering
using Images
using ImageView

function convert_colors(colors)
	converted = Array(Float64, 3, size(colors, 1))
	for i in 1:size(colors, 1)
		converted[:, i] = colors[i]
	end
	return converted
end

function cluster(image, initial_colors)
	image = permutedims(image, [2, 3, 1])
	pixels = convert(Array{Float64,2}, transpose(reshape(image, size(image, 1) * size(image, 2), size(image, 3))))
	result = kmeans(pixels, convert_colors(initial_colors); display=:none)
	colors = result.centers

	image = permutedims(image, [3, 1, 2])

	for i in 1:size(image, 2), j in 1:size(image, 3)
		index =	indmin(sum((colors .- image[:,i,j]) .^ 2, 1))
		image[:,i,j] = colors[:,index]
	end

	return image
end