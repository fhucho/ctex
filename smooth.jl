using Images
using ImageView

function pm2(image, iters, lambda)
  rows, cols = size(image)
 
  for i in 1:iters
    padded = padarray(image, [1, 1], [1, 1], "replicate", float32(0))

    dN = padded[1:rows, 2:cols+1] - image
    dS = padded[3:rows+2, 2:cols+1] - image
    dE = padded[2:rows+1, 3:cols+2] - image
    dW = padded[2:rows+1, 1:cols] - image

		g(d) = exp(-(d / 25).^2)
    gN = g(dN)
    gS = g(dS)
    gE = g(dE)
    gW = g(dW)

    image += lambda * (gN.*dN + gS.*dS + gE.*dE + gW.*dW)
  end
  
  return image
end

function pm(image, iters, lambda)
	image = float(image)

	for i in 1:3
		image[:, :, i] = pm2(image[:, :, i], iters, lambda)
	end

	return uint8(clamp(image, 0, 255))
end


image = pm(convert(Array, imread("tiger.png")), 10, 0.3)
display(image)
