using Images

# Array formats:
# textures[i][y, x]
# clusters[cluster, window, bin]
# hists[window, bin]
# dhists[cluster, window, bin]
# ds[cluster, window]

const GRANULANITY = 256
const BINS = 4 * GRANULANITY

const MAXWINDOW = 12

type Askm
	nclusters::Int
	width::Int
	height::Int
	image::Array{Int, 2}
	textures::Array{Array{Int, 2}, 1}

	clustered::Array{Int, 2}
	counts::Array{Int, 1}
	changed::Int
	objective::Float64
	clusters_clr::Array{Float64, 3}
	clusters_tex::Array{Float64, 3}
	sums_clr::Array{Float64, 3}
	sums_tex::Array{Float64, 3}

	function init_clusters_clr(image, nclusters, w, h)
		clusters = Array(Float64, nclusters, MAXWINDOW, nclusters)
		
		for i in 1:nclusters
			x = iround((w / (nclusters + 1)) * i)
			y = iround((h / (nclusters + 1)) * i)
			hists = color_hists(image, nclusters, x + 13, y + 13)
			clusters[i, :, :] = reshape(hists, 1, MAXWINDOW, nclusters)
		end

		return clusters
	end

	function init_clusters_tex(textures, nclusters, w, h)
		clusters = Array(Float64, nclusters, MAXWINDOW, BINS)
		
		for i in 1:nclusters
			x = iround((w / (nclusters + 1)) * i)
			y = iround((h / (nclusters + 1)) * i)
			hists = hists_of_pixel(textures, x + 13, y + 13)
			clusters[i, :, :] = reshape(hists, 1, MAXWINDOW, BINS)
		end

		return clusters
	end

	function Askm(image, textures, nclusters)
		w = size(textures[1], 2)
		h = size(textures[1], 1)
		
		clustered = zeros(Int, h, w) - 1

		padded_image = padarray(image, [13, 13], [13, 13], "reflect", 0)

		padded_textures = copy(textures)
		for i in 1:4
			padded_textures[i] = padarray(textures[i], [13, 13], [13, 13], "reflect", 0)
		end

		clusters_clr = init_clusters_clr(padded_image, nclusters, w, h)
		clusters_tex = init_clusters_tex(padded_textures, nclusters, w, h)

		new(nclusters, w, h, padded_image, padded_textures, clustered, Array(Int, 0), 0, 0.0, clusters_clr, clusters_tex, Array(Float64, 0, 0, 0), Array(Float64, 0, 0, 0))
	end
end

function color_hists(image, nclusters, x, y)
	hists = zeros(Int, MAXWINDOW, nclusters)
	for w in 1:MAXWINDOW
		for x2 in (x - w):(x + w)
			for y2 in (y - w):(y + w)
				value = image[y2, x2]
				hists[w, value] += 1
			end
		end
	end
	return hists
end

# Calculates minimal (over all window sizes) histogram differences for every cluster. Returns ds[clusterind].
function process_clr_pixel(askm, x, y)
	hists = color_hists(askm.image, askm.nclusters, x, y)
	ds = Array(Float64, askm.nclusters)

	for i in 1:askm.nclusters
		ds[i] = Inf
		for w in 1:MAXWINDOW
			histd = hists[w, :] - reshape(askm.clusters_clr[i, w, :], 1, askm.nclusters)
			d = sum(abs(histd)) / (2w + 1)^2
			if d < ds[i]
				ds[i] = d
			end
		end
	end

	return ds, hists
end

function hists_of_pixel(textures, x, y)
	hists = zeros(Int, MAXWINDOW, BINS)
	for w in 1:MAXWINDOW
		for x2 in (x - w):(x + w)
			for y2 in (y - w):(y + w)
				for t in 1:4
					value = textures[t][y2, x2] + GRANULANITY * (t - 1)
					hists[w, value] += 1
				end
			end
		end
	end
	return hists
end

function dhists_from_hists(hists, clusters)
	nclusters = size(clusters, 1)
	dhists = Array(Float64, nclusters, MAXWINDOW, BINS)
	
	for i in 1:nclusters
		dhists[i, :, :] = reshape(hists, 1, MAXWINDOW, BINS)
		dhists[i, :, :] -= clusters[i, :, :]
	end

	return dhists
end

function ds_from_dhists(dhists)
	nclusters = size(dhists, 1)
	ds = zeros(Float64, nclusters, MAXWINDOW)
	
	for i in 1:nclusters
		for w in 1:MAXWINDOW
			ds[i, w] = sum(abs(reshape(dhists[i, w, :], BINS)))
		end
	end

	return ds
end

function collect_border_values(textures, x, y, w, dir)
	wsize = w * 2 + 1
	values = Array(Int, wsize * 4)

	i = 1
	for t in 1:4
		x2 = x
		if dir == 1
			x2 += w
		elseif dir == -1
			x2 -= (w + 1)
		end

		for y2 in (y - w):(y + w)
			values[i] = textures[t][y2, x2] + GRANULANITY * (t - 1)
			i += 1
		end
	end

	return values
end

function process_tex_pixel(textures, x, y, hists, dhists, ds)
	for w in 1:MAXWINDOW
		added = collect_border_values(textures, x, y, w, 1)
		removed = collect_border_values(textures, x, y, w, -1)

		wsize = w * 2 + 1
		for i in 1:(wsize * 4)
			hists[w, added[i]] += 1
			hists[w, removed[i]] -= 1
		end

		nclusters = size(dhists, 1)
		for i in 1:nclusters
			for j in 1:(wsize * 4)
				ds[i, w] -= abs(dhists[i, w, added[j]])
				dhists[i, w, added[j]] += 1.0
				ds[i, w] += abs(dhists[i, w, added[j]])

				ds[i, w] -= abs(dhists[i, w, removed[j]])
				dhists[i, w, removed[j]] -= 1.0
				ds[i, w] += abs(dhists[i, w, removed[j]])
			end
		end
	end

	normalized_ds = ds ./ transpose([4 * (2w + 1)^2 for w in 1:MAXWINDOW])
	return minimum(normalized_ds, 2)
end

function process_row(askm, y)
	hists_tex = hists_of_pixel(askm.textures, 13, y + 13)
	dhists = dhists_from_hists(hists_tex, askm.clusters_tex)
	ds_tex = ds_from_dhists(dhists)

	for x in 1:askm.width
		min_ds_clr, hists_clr = process_clr_pixel(askm, x + 13, y + 13)
		min_ds_tex = process_tex_pixel(askm.textures, x + 13, y + 13, hists_tex, dhists, ds_tex)
		min_ds = min_ds_clr + min_ds_tex
		
		clusterind = indmin(min_ds)

		askm.objective += min_ds[clusterind]

		if askm.clustered[y, x] != clusterind
			askm.clustered[y, x] = clusterind
			askm.changed += 1
		end

		askm.counts[clusterind] += 1
		
		for w in 1:MAXWINDOW, b in 1:BINS
			askm.sums_tex[clusterind, w, b] += hists_tex[w, b]
		end

		for w in 1:MAXWINDOW, b in 1:askm.nclusters
			askm.sums_clr[clusterind, w, b] += hists_clr[w, b]
		end
	end
end

function kmeans_iter(askm)
	askm.changed = 0
	askm.objective = 0
	askm.counts = zeros(Int, askm.nclusters)
	askm.sums_tex = zeros(Int, askm.nclusters, MAXWINDOW, BINS)
	askm.sums_clr = zeros(Int, askm.nclusters, MAXWINDOW, askm.nclusters)

	for y in 1:askm.height
		process_row(askm, y)
	end

	for i in 1:nclusters
		askm.clusters_clr[i, :, :] = askm.sums_clr[i, :, :] / askm.counts[i]
		askm.clusters_tex[i, :, :] = askm.sums_tex[i, :, :] / askm.counts[i]
	end
end

# The textures argument contains the outputs of the Gabor filter for 4 orientations. The format is: textures[i][y, x]. Values should be in the range 1:GRANULANITY.
function cluster_askm(image, textures, nclusters)
	askm = Askm(image, textures, nclusters)

	prev_objective = Inf
	while true
		kmeans_iter(askm)
		println("Changed: $(askm.changed), objective: $(askm.objective)")
		if askm.changed < 100
			break
		end
		prev_objective = askm.objective
	end

	return askm
end