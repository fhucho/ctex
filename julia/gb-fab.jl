gamma = 0.8

d1(t) = 40 * gamma^t
d2(t) = 80 * gamma^t

function d(x, t)
	return 2 * exp((x / d1(t)).^2 * -1) - exp((x / d2(t)).^2 * -1)
end

function boost_gradient(g, m, t)
	return g .* (1 + 2 * exp(-1 * (g - m) / d1(t)))
end

function gradient2d(x)
	function horizontal(x)
		result = zeros(size(x))
		for i in 1:size(x, 1)
			result[i,:] = gradient(reshape(x[i,:], size(x, 2)))
		end
		return result
	end

	hor = horizontal(x)
	ver = transpose(horizontal(transpose(x)))
	return (hor, ver)
end

function divergence(x, y)
	(dx, _) = gradient2d(x)
	(_, dy) = gradient2d(y)
	return dx + dy
end

function gb_fab(image)
	image = permutedims(image, [2, 3, 1])
	for t in 1:6, i in 1:3
		(grad_x, grad_y) = gradient2d(image[:, :, i] * 255)
		grad = sqrt(grad_x.^2 + grad_y.^2)
		boosted_grad = boost_gradient(grad, median(grad), t)
		diffusion = d(boosted_grad, t)
		image[:, :, i] += divergence(diffusion .* grad_x, diffusion .* grad_y) / 255
	end
	return permutedims(image, [3, 1, 2])
end