# Title     : TRACK STRUCTURE CALCULATIONS
# Objective : find the parameters for
# Created by: lia
# Created on: 3/26/20

library(libamtrack)

#################################
##### DOSIMETER COMPOSITION #####
#################################

cat("defining the silicone dosimeter material composition\n")
A <- c(1, 12, 14, 16, 28, 34)
Z <- c(1, 6, 7, 8, 14, 17)
fraction <- c(0.0806, 0.3223, 0.0003, 0.2114, 0.3721, 0.0134)
AT.set.user.material.from.composition(1.05, Z, A, fraction)


#################################
####### DOSE AROUND TRACK #######
#################################

cat("dose distribution around the track using Geiss model\n")

df <- expand.grid(E.MeV.u = seq(180, 230, length.out = 3),
                  particle.no = 1001,
                  r.m = 10^seq(-9, -2, length.out=1000),
                  material.no = 1,
                  rdd.model = 3,
                  rdd.parameter = 5e-8,
                  er.model = 4,
                  D.Gy = 0)

df$particle.name <-  "Protons"

for (i in 1:nrow(df)){ # Loop through particles/energies
    df$D.Gy[i]    <-    AT.D.RDD.Gy(     r.m              = df$r.m[i],
                                         E.MeV.u          = df$E.MeV.u[i],
                                         particle.no      = df$particle.no[i],
                                         material.no      = df$material.no[i],
                                         rdd.model        = df$rdd.model[i],
                                         rdd.parameter    = df$rdd.parameter[i],
                                         er.model         = df$er.model[i],
                                         stopping.power.source.no = 2 )[[1]]

}

cat("plotting")
lattice::xyplot(log10(D.Gy) ~ log10(r.m)|particle.name,
               # Plot
                 df,
                 type      = 'l',
                 groups    = E.MeV.u,
                 auto.key  = TRUE)

#cat(df$D.Gy, file = "radial_dose_y.txt", append = FALSE, sep = "\t")
#cat(df$r.m, file = "radial_dose_x.txt", append = FALSE, sep = "\t")

#################################
######### ELECTRON RANGE ########
#################################




df <- expand.grid(E.MeV.u = c(180, 200, 220), #10^seq(0, 3, length.out=500)
                  particle.no = 1001,
                  material.no = 1,
                  rdd.model = 4,
                  rdd.parameter =  1,
                  gamma.model   = 2,
                  gamma.parameters = 1,
                  er.model = 6,
                  fluence.cm2.or.dose.Gy = seq(0, 100, length.out=10),
                  D.Gy = 0)

   df$particle.name <-  "Protons"

    for (i in 1:nrow(df)){ # Loop through particles/energies
        results <- AT.run.CPPSC.method(        E.MeV.u          = df$E.MeV.u[i],
                                  particle.no      = df$particle.no[i],
                                  material.no      = df$material.no[i],
                                  fluence.cm2.or.dose.Gy = df$fluence.cm2.or.dose.Gy[i],
                                  rdd.model        = df$rdd.model[i],
                                  rdd.parameters   = c(10e-8, 1e-10),
                                  gamma.model      = df$gamma.parameters[i],
                                  gamma.parameter  = c( k1 = k1, D01 = 2.031*10^3, c1 = 1, m1 = 1,
                                                        k2 = k2, D02 =9.24*10^2, c2 = 2, m2 = 1, 0),
                                  er.model         = df$er.model[i],
                                  write.output     = TRUE,
                                               N2 = 10,
                                               fluence.factor = 1.0,
                                               shrink.tails = TRUE,
                                               shrink.tails.under = 1e-30,
                                               adjust.N2 = TRUE,
                                               lethal.events.mode = FALSE,
                                  stopping.power.source.no = 2)[[1]]
    }



