E = 85;
MU = 7600;

XYspread = 11.3826 - 0.10954*E + 5.4978e-4*E^2 - 9.63158e-7*E^3
Espread = 1.92416 - 1.30608e-2*E + 5.45467e-5*E^2 - 1.21633e-7*E^3
part = MU * (0.745864 + 2.5593e-2*E - 1.42046e-5*E^2 - 4.2087e-8*E^3)*10^2
                
clear E Espread part XYspread