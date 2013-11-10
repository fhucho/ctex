# coding: utf-8
import sys
import png
import copy
from math import sqrt, exp, fabs


def smooth(image, iters=10, d=25, alpha=0.3, gamma=0.8):
    '''
    Aka PM which smooths image within regions but preserve borders of regions

    :param image: image in format boxed row, flat pixel where pixel has 3 values
    :param iters: `int` how many iterations should be performed
    :param dist: `int` how far should be the gradient computed
    '''
    rows, cols = len(image), len(image[0])
    image_mod = copy.copy(image)  # image for modifications

    positions = (
        (0, -3),
        (+1, 0),
        (0, +3),
        (-1, 0)
    )
    # D function as it is written in the paper
    Dpm = lambda x, t: exp(-1*((x/d)**2))
    Dfab = lambda x, t: 2*exp(-1*(x/d1(t))**2) - exp(-1*(x/d2(t))**2)
    d1 =  lambda t: 40 * gamma**t
    d2 =  lambda t: 80 * gamma**t

    # transform image pixel by pixel
    for i in range(iters):
        for x in range(rows):
            for y in range(cols):
                gradients = []
                for pos in positions:
                    try:
                        gradients.append(image[x+pos[0]][y+pos[1]] - image[x][y])
                    except IndexError:
                        gradients.append(0.0)
                # transform gradients with theirs "boosted" version
                # m = sorted(gradients)[len(gradients) // 2]
                # gradients = map(lambda x: x * 1 + 2*exp(-1*(fabs((abs(x)-m) / d1(i)))), gradients)
                try:
                    image_mod[x][y] += int(sum(map(lambda x: x * 0.3 * Dpm(x, i), gradients)))  # divergence
                except OverflowError:
                    image_mod[x][y] = 0 if image_mod[x][y] < 128 else 255
            # end for y
        # end for x
        image[:][:] = image_mod[:][:]
        print("Iteration {}/{} finished".format(i+1, iters))
    #end for i



def gb_fab(image):
    '''Filters given image (either in RGB or YIQ format) using gabor function'''
    pass


if __name__ == "__main__":
    '''
    Runs the module as a program. Usage ./filters.py <image name>

    The png library loads image into format boxed row, flat pixel, which is
    for an 3x2 image: ([r,g,b, r,g,b, r,g,b], [r,g,b, r,g,b, r,g,b])
    '''

    imagename = sys.argv[1] if len(sys.argv) > 1 else "tiger.png"
    smoothedname = imagename.replace(".", ".smoothed.", 1)

    width, height, pixels, meta = png.Reader(imagename).read()
    pixels = list(pixels)  # evaluate iterator
    smooth(pixels)
    writer = png.Writer(width=width, height=height)
    with open(smoothedname, "wb") as fo:
        writer.write(fo, pixels)
