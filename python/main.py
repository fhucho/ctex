# Zkombinuje vysledek barevne segmentace s texturami a vrati celkovy vysledek 
def asmk(color_features, texture_features):
	pass


# Pomoci k-means algoritmu segmentuje RGB nebo YIQ obrazek
def cluster(image, colors):
	pass


# Zkombinuje segmentovane RGB a YIQ obrazky
def cluster_multispace(clustered_rgb_img, dominant_colors_rgb, clustered_yiq_img, dominant_colors_yiq):
	pass
	

# Snizi barevnou hloubku na 3 bity a vrati nejcasteji se vyskytujici barvy
def extract_colors_simple(image, num_colors):
	pass


# Pomoci self-organizing map (SOM) algoritmu vyextrahuje dominantni barvy
def extract_colors_som(simage):
	pass


# Vyextrahuje texturove info
def extract_textures(image):
	pass


# Odstrani sum
def smooth(image):
	pass


def cluster_multispace(rgb_img):
	smoothed_rgb_img = smooth(rgb_img)
	colors_rgb = extract_colors_som(smoothed_rgb_img)
	clustered_rgb_img = cluster(smoothed_rgb_img, colors_rgb)

	smoothed_yiq_img = smooth(rgb_to_yiq(rgb_img))
	colors_yiq = extract_colors_simple(smoothed_yiq, len(colors_rgb))
	clustered_yiq_img = cluster(smoothed_yiq_img, dominant_colors_yiq)

	return cluster_multispace(clustered_rgb_img, colors_rgb, clustered_yiq_img, colors_yiq)


funct main():
	image = load_image()
	color_features = cluster_multispace(image)
	texture_features = extract_textures(image)
	return asmk(color_features, texture_features)
