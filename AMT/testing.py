import numpy as np
import matplotlib.pyplot as plt
import math
from scipy.ndimage.interpolation import map_coordinates
import pydicom as dc


def article_imgs2():
    layer = np.loadtxt(fname="/home/lia/Documents/article_figures/DoseProfile_160MeV_layer.txt")
    pencil = np.loadtxt(fname="/home/lia/Documents/article_figures/DoseProfile_160MeV_pencil.txt")

    layer_idd = np.loadtxt(fname="/home/lia/Documents/article_figures/idd_layer.txt")
    pencil_idd = np.loadtxt(fname="/home/lia/Documents/article_figures/idd_pencil.txt")

    plt.rcParams.update({'font.size': 12})
    fig, ax = plt.subplots(1, 1)
    plt.plot(layer[:, 0], np.true_divide(layer[:, 1], np.amax(layer, axis=0)[1]),
             label='Field 10x10 cm${}^2$ (depth-dose)', linewidth=2.7)
    plt.plot(pencil[:, 0], np.true_divide(pencil[:, 1], 1.2 * np.amax(layer, axis=0)[1]),
             label='Pencil beam (depth-dose)', linewidth=2.7)
    plt.plot(1.018 * layer_idd[:, 0], np.true_divide(layer_idd[:, 1], np.amax(layer_idd, axis=0)[1]),
             label='Field 10x10 cm${}^2$ (IDD)', linewidth=2.7, linestyle='dashdot')
    plt.plot(1.018 * pencil_idd[:, 0], np.true_divide(pencil_idd[:, 1], np.amax(pencil_idd, axis=0)[1]),
             label='Pencil beam (IDD)', linewidth=2.7, linestyle='dotted')
    plt.xlabel('radius [cm]')
    plt.ylabel('Dose [a.u.]')
    ax.tick_params(direction="in")
    plt.xticks(np.arange(0, 21, step=4))
    plt.tick_params(top='on', bottom='on', left='on', right='on', labelleft='on', labelbottom='on')
    plt.tight_layout()
    plt.xlim(0.5, 20)
    plt.ylim(0.0, 1.0)
    ax.legend(loc='upper left')
    # plt.savefig('/home/lia/Documents/IDDs', format='png')
    # plt.axvspan(6, 8.8, facecolor='r', alpha=0.3)
    plt.savefig('/home/lia/Documents/homogeneous_vs_pencil', format='png')
    plt.show()


def article_imgs():
    photon = np.loadtxt(fname="/home/lia/Documents/article_figures/DoseProfile_photon_6X_600MUmin.txt")
    proton_sopb = np.loadtxt(fname="/home/lia/Documents/article_figures/DoseProfile_proton.txt")
    proton_100 = np.loadtxt(fname="/home/lia/Documents/article_figures/DoseProfile_proton_100MeV.txt")

    # data, target = np.array_split(np.loadtxt('file', dtype=str), [-1], axis=1)

    plt.rcParams.update({'font.size': 12})
    fig, ax = plt.subplots(1, 1)
    plt.plot(proton_sopb[:, 0], proton_sopb[:, 1], label='Protons (spread-out peak)', linewidth=2.5)
    plt.plot(proton_100[:, 0], proton_100[:, 1], label='Protons (pristine peak 100 MeV)', linewidth=2.5, linestyle='--')
    plt.plot(photon[:, 0], photon[:, 1], label='X-rays (6 MV)', linewidth=2.5)
    ax.text(6.9, 1, 'Tumor', fontsize=14)
    plt.xlabel('radius [cm]')
    plt.ylabel('Dose [gray]')
    # plt.fill_between(0, proton_sopb[500:600,1])
    ax.tick_params(direction="in")
    plt.tick_params(top='on', bottom='on', left='on', right='on', labelleft='on', labelbottom='on')
    plt.tight_layout()
    ax.fill_between(proton_sopb[480:705, 0], 0, proton_sopb[480:705, 1], where=0 <= proton_sopb[480:705, 1],
                    facecolor='red', alpha=0.3, interpolate=True)
    plt.xlim(0.1, 10)
    plt.ylim(0.1, 16)
    ax.legend(loc='upper right')
    plt.savefig('/home/lia/Documents/IDDs', format='png')
    # plt.axvspan(6, 8.8, facecolor='r', alpha=0.3)
    plt.show()
    # plt.savefig('/home/lia/Documents/IDDs', format='eps')


def radial_dose():
    Dose = np.loadtxt(fname="/home/lia/PycharmProjects/test/radial_dose_y.txt")
    radius = np.loadtxt(fname="/home/lia/PycharmProjects/test/radial_dose_x.txt")
    beta = np.loadtxt(fname="/home/lia/PycharmProjects/test/beta.txt")
    a0 = 10e-8

    Dose_180 = Dose[1::6] * beta[0] * beta[0] * a0*a0
    Dose_190 = Dose[2::6] * beta[1] * beta[0] * a0*a0
    Dose_200 = Dose[3::6] * beta[2] * beta[0] * a0*a0
    Dose_210 = Dose[4::6] * beta[3] * beta[0] * a0*a0
    Dose_220 = Dose[5::6] * beta[4] * beta[0] * a0*a0
    #    Dose_230 = Dose[6::6]
    radius = radius[1::6] / a0

    av = (Dose_180[1] + Dose_190[1] + Dose_200[1] + Dose_210[1] + Dose_220[1]) / 5
    print(av)

    plt.rcParams.update({'font.size': 16})
    fig, ax = plt.subplots(1, 1)
    ax.set_yscale('log')
    ax.set_xscale('log')
    plt.plot(radius, Dose_180, label='10 MeV/u')
    plt.plot(radius, Dose_190, label='48 MeV/u')
    plt.plot(radius, Dose_200, label='86 MeV/u')
    plt.plot(radius, Dose_210, label='124 MeV/u')
    plt.plot(radius, Dose_220, label='162 MeV/u')
    plt.xlabel('$r/a_0$')
    plt.axhline(y=av, linestyle='--', color='k')
    plt.ylabel('$D\\beta^2\\alpha_0^2/z^2$ [gray$\cdot m^2$]')
    ax.legend()
    plt.tight_layout()
    plt.savefig('/home/lia/Documents/ATM_notes/radial_dose_kappa.eps', format='eps')
    plt.show()


def electron_range():
    range = np.loadtxt(fname="/home/lia/PycharmProjects/test/electron_range_y.txt")
    energy = np.loadtxt(fname="/home/lia/PycharmProjects/test/electron_range_x.txt")

    plt.rcParams.update({'font.size': 16})
    fig, ax = plt.subplots(1, 1)
    ax.set_yscale('log')
    ax.set_xscale('log')
    plt.plot(energy, range, label='$\delta$-electrons')
    plt.xlabel('Energy [MeV/u]')
    plt.ylabel('Range [cm]')
    ax.legend()
    plt.tight_layout()
    plt.savefig('/home/lia/Documents/Track_structure_theory/electron_range.eps', format='eps')
    plt.show()


def saturation_curve():
    a = 3.61
    b = 0.38
    c = 2.5 * 10**3
    d = 2.1 * 10**6

    curve = np.linspace(0, 10 ** 5, num=10000)
    supralin = np.linspace(0, 10 ** 5, num=10000)
    i = 0
    D = 10
    D0 = a * (b * (1 - math.exp(-D / c)) + (1 - b) * (1 - math.exp(-D ** 2 / d)))
    for D in np.linspace(0, 10 ** 5, num=10000):
        y = a * (b * (1 - math.exp(-D / c)) + (1 - b) * (1 - math.exp(-D ** 2 / d)))
        curve[i] = y
        supralin[i] = y / (D0/10) / D
        i = i + 1

    return curve, supralin, np.linspace(0, 10 ** 5, num=10000)


def saturation_libamtrack():
    OC = np.loadtxt(fname="/home/lia/PycharmProjects/test/saturation_curve_OC.txt")
    dose = np.loadtxt(fname="/home/lia/PycharmProjects/test/saturation_curve_Dose.txt")

    return OC, dose


def main():

    #OC, dose = saturation_libamtrack()
    #curve, supralin, dose1 = saturation_curve()

    #plt.rcParams.update({'font.size': 16})
    #fig, ax = plt.subplots(1, 1)
    #ax.set_yscale('log')
    #ax.set_xscale('log')
    #plt.plot(dose, OC, label='libamtrack')
    #plt.plot(dose1, curve, label='Geiss fit (EM)', linestyle='none', marker='o', markevery=0.1, alpha=0.8)
    #plt.xlabel('Dose [Gy]')
    #plt.xlim(9, 100000)
    #plt.ylim(0.001, 10)
    #plt.ylabel('OD [cm${}^{-1}$')
    #ax.legend()
    #plt.tight_layout()
    #plt.savefig('/home/lia/Documents/ATM_notes/saturation.eps', format='eps')
    #plt.show()

    radial_dose()



if __name__ == "__main__":
    main()
