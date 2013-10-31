using Clustering
using Images
using ImageView

image = convert(Array, imread("test1.png"))
pixels = convert(Array{Float64,2}, transpose(reshape(image, size(image, 1) * size(image, 2), size(image, 3))))
result = kmeans(pixels, 3)
colors = convert(Array{Int,2}, round(result.centers))

image = permutedims(image, [3, 1, 2])

for i in 1:size(image, 2)
	for j in 1:size(image, 3)
		index =	indmin(sum((colors .- image[:,i,j]) .^ 2, 1))
		image[:,i,j] = colors[:,index]
	end
end

image = permutedims(image, [2, 3, 1])

display(image)

