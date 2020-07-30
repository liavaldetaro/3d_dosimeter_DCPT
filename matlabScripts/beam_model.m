%takes the probeam_energy in MeV as input and returns a list of beam model
%parameters for MC calculation in TOPAS
% - mean_energy (MeV)
% - energy_spread (%)
% - Mprotons per MU
% - spot_size (mm)
%   - s_x (mm); positional spread in x-direction
%   - s_xp ;    angular spread
%   - corr_x ;  correlation between x and x'
%   - corresponding parameters for y direction... 
% The values are calculated from analytical expressions (for interpolation) 
% fitted to the results from simulations and measurements.
function [mean_energy,energy_spread,ppmu,spot_size] = beam_model(E_probeam)
    mean_energy = 0.99764*E_probeam+88.1314/E_probeam+0.06351;
    energy_spread = -0.0044727 * E_probeam + 1.5104;
    if E_probeam > 120
        energy_spread = -6.0274e-03 * E_probeam+...
            6.4705e-02*sin(6.21102e-02*E_probeam+8.4989e+00)+...
            1.6986e+00;
    end
    %spot_spread = 11.3826 - 0.10954*E_probeam + 5.4978e-4*E_probeam^2 - 9.63158e-7*E_probeam^3
    
    %Fitted parameters for bigaussian spatial-angular distrubution
    %are interpolated to energies which have not been queried
    E_q =  [ 70.  80.  90. 100. 110. 120. 130. 140. 150. 160. 170. 180. 190. 200. 210. 220. 230. 240. 244.] ;

    s_x = [4.472 4.299 3.983 3.845 3.778 3.767 3.78  3.792 3.886 3.989 3.984 3.852 3.832 3.793 3.815 3.895 3.855 3.669 3.595] ;
    spot_size.s_x = interp1(E_q,s_x,E_probeam);
    
    s_y = [3.629 3.504 3.29  3.179 3.072 2.971 2.875 2.852 2.802 2.704 2.669 2.634 2.626 2.613 2.506 2.468 2.503 2.728 2.845] ;
    spot_size.s_y = interp1(E_q,s_y,E_probeam);

    s_xp = [0.0061 0.0055 0.0045 0.0041 0.0038 0.0036 0.0036 0.0035 0.0035 0.0036 0.0031 0.0027 0.0027 0.0027 0.0031 0.0035 0.0031 0.003  0.003 ] ;
     spot_size.s_xp = interp1(E_q,s_xp,E_probeam);

    s_yp = [0.0056 0.005  0.0039 0.0037 0.0033 0.0031 0.0029 0.0031 0.0029 0.0026 0.0025 0.0024 0.0024 0.0023 0.0024 0.0024 0.0022 0.0029 0.0033] ;
     spot_size.s_yp = interp1(E_q,s_yp,E_probeam);

    cov_x = [-0.0167 -0.0117 -0.0135 -0.011  -0.0082 -0.0057 -0.0031 -0.0015  0.0017 0.0045  0.0033  0.0014  0.0029  0.0041  0.0068  0.0101  0.0087  0.0083 0.0081] ;
      spot_size.corr_x = -interp1(E_q,cov_x,E_probeam) / (2*spot_size.s_xp*spot_size.s_x);

   cov_y = [-0.0301 -0.0245 -0.0242 -0.0207 -0.0188 -0.0168 -0.0154 -0.0127 -0.0122 -0.0125 -0.0117 -0.0113 -0.0109 -0.0105 -0.0105 -0.0101 -0.0095 -0.0052 -0.0026] ;
    spot_size.corr_y = -interp1(E_q,cov_y,E_probeam) / (2*spot_size.s_yp*spot_size.s_y);

    
    
    ppmu = 0.3167*E_probeam^(0.5319)-0.9840; 
end