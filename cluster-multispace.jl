function cluster_multispace(clustered_rgb, clustered_yiq, colors_rgb, colors_yiq)
	index = 1
	pixels = Array(Float64, 6, size(clustered_rgb, 2) * size(clustered_rgb, 3))
	for x in 1:size(clustered_rgb, 2), y in 1:size(clustered_rgb, 3)
		pixels[:, index] = [clustered_rgb[:, x, y], clustered_yiq[:, x, y]]
		index += 1
	end

	result = kmeans(pixels, size(colors_rgb, 1))
	colors = result.centers[4:6, :]

	clustered = copy(clustered_yiq)

	for i in 1:size(clustered, 2), j in 1:size(clustered, 3)
		index =	indmin(sum((colors .- clustered[:, i, j]) .^ 2, 1))
		clustered[:, i, j] = colors[:, index]
	end

	return clustered
end