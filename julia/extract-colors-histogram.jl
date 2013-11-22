function create_histogram(image)
	hist = Dict()
	for x in 1:size(image, 2), y in 1:size(image, 3)
		color = image[:, x, y]
		color_int = int(color * 255)
		color_quantized = (div(color_int,  32) * 32 + 16) / 255
		hist[color_quantized] = get(hist, color_quantized, 0) + 1
	end
	return hist
end

function extract_colors_hist(image, how_many)
	hist = create_histogram(image)
	entries = collect(hist)
	sorted_entries = sort(entries, by=(x -> getindex(x, 2)), rev=true)
	sorted_colors = map(x -> getindex(x, 1), sorted_entries)
	return sorted_colors[1:how_many]
end