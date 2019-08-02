*****************
Proton Dosimetry
*****************


========================
Interactions with matter
========================

-----------------------------
Electromagnetic interactions
-----------------------------

We can characterize the interaction between protons and atomic electrons as a function
of the classical impact parameter, b (the closest distance between the initial trajectory 
of the incident particle and the nucleus), and a (the atomic radius).
  - b>>a: 
         Incident proton interacts with the atom as a whole, only transfering a small 
         amount of energy
  - b≈a: 
        Incident proton can interact with a single atomic electron, tranfering a large
        amount of energy, resulting in "knock-on electrons" or :math:`\gamma`-rays. The 
        collisions can be approximated by the Rutherford cross section (for non-relativistic
        energies) or the Bahha cross section (for relativistic energies), as the electron 
        binding energy is usually much small than the transferred.
  - b<<a:
        Incident proton can interact electromagnetically with the nucleus via elastic and                   inelastic coulomb interactions. These result in large angular deflection for the proton,           given its much smaller radius when compared to the nucleus.
         
Because the interactions are stochastic in nature, we will often discuss mean values - averaged over many particles. One important quantity for radiation therapy is the **stopping power**, representing the mean energy loss per unit of path length. Individual particle trajectories (and energy loss) can deviate widely from the mean, so the beam undergoes **energy straggling**, resulting in a gradual broadening of the energy spectrum with penetration depth. **Scattering power** is the mean angular deflection per unit of path length.

---------------------------------
Strong-force nuclear interactions
---------------------------------

We can characterze strong-force interactions as:
    - Inelastic: 
                Kinectic energy is not conserved, but target nucleus remains unchanged; remaining
                after the interaction and/or emiting a :math:`\gamma`-ray. It can be treated in a
                similar manner to inelastic coulomb interactions (in a sense that the incident 
                proton continues to be transported and :math:`\gamma`-rays can be emitted).
    - Non-elastic:
                Kinetic energy is not conserved and the target nucleus undergoes break-up and/or
                a particle transfer reaction occurs. This interaction results in attenuation, as
                protons are removed from the incident beam by absorption or projectile
                fragmentation.
If the projectile (resulting from non-elastic collisions) is absorbed, its nucleons penetrate the nucleus, leading to a intranuclear cascade. This results to the ejection of forward-directed protons, neutrons, and/or even pions (if the projectile's kinetic energy is high enough for its formation). The residual energy that is not carried away is distributed through the nucleus (precompound --> compound state), and any further emission is isotropic. The compound nucleus loses energy via evaporation of protons, neutrons, light fragments (mainly :math:`\alpha`-particles) and :math:`\gamma`-ray emission, until a stable nucleus is reached. 

The kinetic energy of the emitted particles from non-elastic collisions is well distributed; those originated in the intranuclear cascade are highly energetic and travel further, while those emitted in the evaporation stage deposit the the energy close to the generation point. This contributes to the reduction of the absorbed dose near the point in which the non-elastic collision took place. On the other hand, neutrons and :math:`\gamma`-rays make a negligible contrinution to local energy deposition, but need to be considered in shielding, radioprotection, and estimation of secondary cancer risks. They must also be considered in prompt gamma imaging to reconstruct the distribution of the primary proton absorption point by locating the origin of the:math:`\gamma`-rays.


========================================
Detector requirements for proton beams
========================================

--------------------
Reference Dosimetry
--------------------
The primary instrument to measure absorbed dose to medium are Calorimeters. The energy deposition in the medium is quantified by measuring the increase in temperature (given that there are no other types of energy storage - i.e. chemical changes). These dosimeters have only been realized as point detectors, due to their low sensitivity and spatial resolution, and long acquisition times.

In particle therapy, the most commonly used detectors are air-filled ionization chambers. Dose to air can, in principle, be derived directly from the ionization in the cavity, and dose to water or dose to medium can be found by applying the Bragg-Gray cavity theory. However, this is not possible, given the relatively large uncertainty in the volume to commercial ionization chambers, so they require calibrations against primary standards.





               
