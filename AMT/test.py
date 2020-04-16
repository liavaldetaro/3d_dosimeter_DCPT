import numpy as np
import matplotlib.pyplot as plt
import math
from scipy.optimize import curve_fit


def dummy_model():
    # generates the data points from EM parametrization - temporary
    a = 3.61
    b = 0.38
    c = 2.5 * 10 ** 3
    d = 2.1 * 10 ** 6

    curve = np.linspace(0, 10, num=16)
    supralin = np.linspace(0, 10, num=16)
    i = 0
    D = 10
    D0 = a * (b * (1 - math.exp(-D / c)) + (1 - b) * (1 - math.exp(-D ** 2 / d)))
    d_array = np.array([20, 50, 100, 110, 120, 150, 200, 500, 900, 1200, 2000, 2500, 5000, 7000, 10000, 10500])
    for D in d_array:
        y = a * (b * (1 - math.exp(-D / c)) + (1 - b) * (1 - math.exp(-D ** 2 / d)))
        curve[i] = y
        supralin[i] = y / (D0 / 10) / D
        i = i + 1

    return curve, d_array


def saturation_fit(x, a, b, c, d):
    return np.log(a * (b * (1 - np.exp(-np.divide(x, c))) + (1 - b) * (1 - (1 + x / d) * np.exp(-np.divide(x, d)))))


def saturation_best(x):
    a=3.61*2000
    b=0.28
    c=2030
    d=924
    return np.log(a * (b * (1 - np.exp(-np.divide(x, c))) + (1 - b) * (1 - (1 + x / d) * np.exp(-np.divide(x, d)))))

def main():
    data_points, dose = dummy_model()  # gamma saturation curve
    popt, pcov = curve_fit(saturation_fit, dose, np.log(data_points), bounds=([1, 0, 2000, 900],[1000, 1, 3000, 1000]))

    print(popt)

    plt.rcParams.update({'font.size': 16})
    fig, ax = plt.subplots(1, 1)
    plt.plot(np.log(dose), saturation_fit(dose, *popt), label='scipy fit')
    plt.plot(np.log(dose), np.log(data_points), label='Geiss fit (EM)', linestyle='none', marker='o', alpha=0.8)
    plt.xlabel('log(Dose) ')
    plt.ylabel('log(OD)')
    ax.legend()
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()