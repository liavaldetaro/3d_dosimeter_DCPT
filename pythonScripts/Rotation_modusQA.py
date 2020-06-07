# This script find the best match for starting the CT scans reconstruction
# you need to have Numba installed to use the GPU functions

import numpy as np
import matplotlib.pyplot as plt
import math
import scipy as sc
from scipy.optimize import curve_fit
from scipy.io import loadmat
from numba import vectorize
from numba import jit
from numba import cuda
from timeit import default_timer as timer
from pathlib import Path
import imageio


@jit
def warp_reduction(val):
    offset = cuda.warpsize / 2
    while offset > 0:
        val[0] += cuda.shfl_down_sync(0xffffff, val[0], offset)
        offset /= 2
    # for (offset= warpSize/2, offset>0, offset /=2):


@jit
def sum_array_warp(n, v, sum):
    index = cuda.blockIdx.x * cuda.blockDim.x + cuda.threadIdx.x
    stride = cuda.blockDim.x * cuda.gridDim.x

    lane = cuda.threadIdx.x % cuda.warpsize
    sum_p = 0
    for i in range(index, n, stride):
        sum_p += v[i]

    __syncthreads()

    warp_reduction(sum_p)

    if lane == 0:
        cuda.atomic.add(sum, sum_p)


@jit
def block_reduction(sum_p):
    s = cuda.shared.array(shape=24, dtype=int)

    lane = cuda.threadIdx.x % cuda.warpsize
    wid = cuda.threadIdx.x / cuda.warpsize

    warp_reduction(sum_p)

    cuda.syncthreads()

    if lane == 0:
        s[wid] = sum_p

    if cuda.threadIdx.x < cuda.blockDim.x / cuda.warpsize:
        sum_p = s[lane]
    else:
        sum_p = 0

    if wid == 0:
        warp_reduction(sum_p)


@cuda.jit
def sum_array_block(n, v, sum):
    index = cuda.blockIdx.x * cuda.blockDim.x + cuda.threadIdx.x
    stride = cuda.blockDim.x * cuda.gridDim.x

    sum_p = 0
    i = index
    while i < n:
        i += stride
        sum_p += v[i]

    block_reduction(sum_p)

    if cuda.threadIdx.x == 0:
        cuda.atomic.add(sum, sum_p)


@cuda.jit
def comparison(A, B, Diff, N, M):
    for i in range(cuda.blockDim.x * cuda.blockIdx.x + cuda.threadIdx.x, N, cuda.blockDim.x * cuda.gridDim.x):
        for j in range(cuda.blockDim.y * cuda.blockIdx.y + cuda.threadIdx.y, M, cuda.blockDim.y * cuda.gridDim.y):
            idx = i + N * j
            Diff[idx] = A[idx] - B[idx]


def find_match(directory_ref, directory_data):
    ref_list = np.array([])
    data_list = np.array([])

    entries = Path(directory_ref)
    for entry in entries.iterdir():
        ref_list = np.append(ref_list, entry.name)

    entries = Path(directory_data)
    for entry in entries.iterdir():
        data_list = np.append(ref_list, entry.name)

    # first part: checking all data images against the first reference image -----
    reference_image = imageio.imread(directory_ref + '/' + ref_list[0])

    hl1 = reference_image.shape[0]
    hl2 = reference_image.shape[1]

    reference_image = reference_image[np.int(hl1 / 2 - hl1 / 4):np.int(hl1 / 2 + hl1 / 4),
                      np.int(hl2 / 2 - hl2 / 3):np.int(hl2 / 2 + hl2 / 3)]

    norm = np.amax(reference_image)
    reference_image = reference_image / norm

    reference_image_dev = cuda.to_device(reference_image.flatten())
    N = reference_image.shape[0]
    M = reference_image.shape[1]
    print(N, M)

    for i in range(0, data_list.size):
        moving_image = imageio.imread(directory_data + '/' + data_list[i])
        moving_image = moving_image[np.int(hl1 / 2 - hl1 / 4):np.int(hl1 / 2 + hl1 / 4),
                       np.int(hl2 / 2 - hl2 / 3):np.int(hl2 / 2 + hl2 / 3)] / norm

        b = 24
        blockdim = (b, b)
        griddim = (np.int((N + b - 1) / b), np.int((M + b - 1) / b))

        Diff = np.zeros(reference_image_dev.size)
        Diff_dev = cuda.to_device(Diff)
        moving_image_dev = cuda.to_device(moving_image.flatten())
        start = timer()
        comparison[griddim, blockdim](reference_image_dev, moving_image_dev, Diff_dev, N, M)
        cuda.synchronize()

        blockSize = b
        numBlocks = round((N * M + blockSize - 1) / blockSize)
        sum_total = 0
        sum_array_block[numBlocks, blockSize](N * M, Diff, sum_total)
        cuda.synchronize()

        print('runtime: ', timer() - start, 'seconds')
        print(sum_total)

    Diff_dev.to_host()
    Diff = np.reshape(Diff_dev, moving_image.shape)

    plt.imshow(Diff)
    plt.colorbar()
    plt.show()


def main():
    print("\n \n "
          "*************************************************************************\n"
          "This script find the best match for starting the CT scans reconstruction. \n"
          "Make sure to export the files as png on Modus QA\n"
          "You need to have Numba installed to use the GPU functions \n"
          "************************************************************************* \n \n"
          )

    answer = 'no'
    # while answer != 'y' and answer != 'Y' and answer != 'yes' and answer != 'YES':
    #    dir = input("Please enter the Reference images directory of the Optical scans: ")
    #    answer = input("\n \n You entered: " + dir + " Confirm? (y/n)")
    dir = '/' + 'home' + '/' + 'lia' + '/' 'Documents' + '/' + 'test' + '/' + 'Reference'

    answer = 'no'
    # while answer != 'y' and answer != 'Y' and answer != 'yes' and answer != 'YES':
    #    dir1 = input("Please enter the Data images directory of the Optical scans:")
    #    answer = input("\n \n You entered: " + dir1 + " Confirm? (y/n)")
    dir1 = '/' + 'home' + '/' + 'lia' + '/' 'Documents' + '/' + 'test' + '/' + 'Data'

    find_match(dir, dir1)


if __name__ == "__main__":
    main()
