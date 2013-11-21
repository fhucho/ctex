using Images
using ImageView

include("extract-colors-histogram.jl")

function euclid_dist(a, b)
	return sqrt(sum((a - b) .^ 2))
end

function find_most_similar_color(colors, color)
	diff(c1, c2) = sum((c1 - c2) .^ 2)

	bmu = 1
	lowest_dist = euclid_dist(colors[1], color)
	
	for i in 2:16
		d = euclid_dist(colors[i], color)
		if d < lowest_dist
			bmu = i
			lowest_dist = d
		end
	end

	return bmu
end

function update_nodes(nodes, color, radius, learning_rate)
	loc(index) = [div(index - 1, 4), (index - 1) % 4]
	dist(a, b) = euclid_dist(loc(a), loc(b))

	bmu = find_most_similar_color(nodes, color)
	for i in 1:16
		d = dist(i, bmu)
		if d <= radius
			nodes[i] += learning_rate * (color - nodes[i])
		end
	end
end

function som(image, initial_colors, initial_learning_rate, initial_radius, min_radius, iter_length, k)
	colors = copy(initial_colors)
	learning_rate = initial_learning_rate
	radius = initial_radius

	while radius > min_radius
		for i in 1:iter_length
			x = rand(Uint) % size(image, 2) + 1
			y = rand(Uint) % size(image, 3) + 1
			color = image[:, x, y]
			update_nodes(colors, color, radius, learning_rate)
		end

		radius *= k
		learning_rate *= k
	end

	return colors
end

function calc_confidences(image, colors)
	cummulative_dists = zeros(16)
	counts = zeros(Int, 16)

	for x in 1:size(image, 2), y in 1:size(image, 3)
		color = image[:, x, y]
		idx = find_most_similar_color(colors, color)
		
		counts[idx] += 1
		cummulative_dists[idx] += euclid_dist(color, colors[idx])
	end

	return counts
end

function reduce_colors(image, colors)
	confidences = calc_confidences(image, colors)
	removed = falses(16)

	function process_adjacent_colors(a, b)
		if removed[a] || removed[b]
			return
		end

		if euclid_dist(colors[a], colors[b]) < 0.3
			if confidences[a] > confidences[b]
				removed[a] = true
			else
				removed[b] = true
			end
		end
	end

	# Find out which colors should be removed.
	for x in 0:3, y in 0:3
		node = y * 4 + x + 1
		right_neighbour = y * 4 + (x + 1) + 1
		bottom_neighbour = (y + 1) * 4 + x + 1
		for nbr in [right_neighbour, bottom_neighbour]
			if nbr <= 16
				process_adjacent_colors(node, nbr)
			end
		end
	end

	# Remove the colors marked for removal.
	survivors = Array(Array{Float64, 1}, 16 - nnz(removed))
	c = 1
	for i in 1:16
		if removed[i] == false
			survivors[c] = colors[i]
			c += 1
		end
	end

	return survivors
end

function display_colors(colors)
	colors = reshape(colors, 4, 4)
	map = Array(Float64, 4, 4, 3)
	for x in 1:4, y in 1:4
		map[x, y, :] = colors[x, y][:]
	end
	display(map)
end

function extract_colors_som(image)
	initial_colors = extract_colors_hist(image, 16)
	colors = som(image, initial_colors, 0.5, 4, 0.5, 5000, 0.9)
	colors = reduce_colors(image, colors)
	return colors
end
