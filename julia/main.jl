using Images
using ImageView

include("cluster.jl")
include("cluster-askm.jl")
include("cluster-multispace.jl")
include("color.jl")
include("extract-colors-som.jl")
include("gabor.jl")
include("gb-fab.jl")

function show_image(image)
	display(permutedims(image, [3, 2, 1]))
end

function with_indexed_colors(image)
	w = size(image, 2)
	h = size(image, 3)

	colors = Set{Array{Float64, 1}}()
	
	for x in 1:w, y in 1:h
		rgb = image[:, x, y]
		push!(colors, rgb)
	end

	colors = collect(colors)

	indexed = Array(Int, h, w)

	for x in 1:w, y in 1:h
		rgb = image[:, x, y]
		indexed[y, x] = find(x -> x == rgb, colors)[1]
	end

	return indexed
end

function cluster_multispace(image_rgb)
	smoothed_rgb = gb_fab(image_rgb)
	colors_rgb = extract_colors_som(smoothed_rgb)
	clustered_rgb = cluster(smoothed_rgb, colors_rgb)

	smoothed_yiq = gb_fab(rgb_image_to_yiq(image_rgb))
	colors_yiq = extract_colors_hist(smoothed_yiq, size(colors_rgb, 1))
	clustered_yiq = cluster(smoothed_yiq, colors_yiq)

	return cluster_multispace(clustered_rgb, clustered_yiq, colors_rgb, colors_yiq), size(colors_rgb, 1)
end

function ctex(image_rgb)
	clustered_yiq, nclusters = cluster_multispace(image_rgb)
	clustered = with_indexed_colors(clustered_yiq)
	textures = extract_textures(image_rgb)
	cluster_askm(clustered, textures, nclusters)
end

image_rgb = permutedims(convert(Array, imread(ARGS[1]) / 255), [3, 2, 1])
result = ctex(image_rgb)
parts = split(ARGS[1], ".")
imwrite(result, "$(parts[1]).clustered.$(parts[2])")