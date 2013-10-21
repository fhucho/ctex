'''
TODO

asmk(color_features, texture_features)
cluster(image, colors)
cluster_multispace(clustered_rgb_img, dominant_colors_rgb, clustered_yiq_img, dominant_colors_yiq)
extract_colors_simple(image, num_colors)
extract_colors_som(simage)
extract_textures(image)
smooth(image)
'''


def cluster_multispace(rgb_img):
	smoothed_rgb_img = smooth(rgb_img)
	colors_rgb = extract_colors_som(smoothed_rgb_img)
	clustered_rgb_img = cluster(smoothed_rgb_img, colors_rgb)

	smoothed_yiq_img = smooth(rgb_to_yiq(rgb_img))
	colors_yiq = extract_colors_simple(smoothed_yiq, len(colors_rgb))
	clustered_yiq_img = cluster(smoothed_yiq_img, dominant_colors_yiq)

	return cluster_multispace(clustered_rgb_img, colors_rgb, clustered_yiq_img, colors_yiq)


def main():
	image = load_image()
	color_features = cluster_multispace(image)
	texture_features = extract_textures(image)
	return asmk(color_features, texture_features)
