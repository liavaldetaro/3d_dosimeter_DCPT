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



def find_match(directory):

    ref_list = np.array([])
    sig_list = np.array([])

    entries = Path(directory)
    for entry in entries.iterdir():
        if entry.name[0] == 'R':
            ref_list = np.append(ref_list, entry.name)
        else:
            sig_list = np.append(sig_list, entry.name)

    #print("\n \n ref list: --------------")
    #print(ref_list)
    #print("\n \n sig list: --------------")
    #print(sig_list)

    


def main():
    print("\n \n "
          "*************************************************************************\n"
          "This script find the best match for starting the CT scans reconstruction. \n"
          "You need to have Numba installed to use the GPU functions \n"
          "************************************************************************* \n \n"
          )

    answer = 'no'
    while answer != 'y' and answer != 'Y' and answer != 'yes' and answer != 'YES':
        dir = input("Please enter the directory of the Optical scans: ")
        answer = input("\n \n You entered: " + dir + " Confirm? (y/n)")

    find_match(dir)








if __name__ == "__main__":
    main()
