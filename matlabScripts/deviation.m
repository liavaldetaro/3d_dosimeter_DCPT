% An easy and fast script to get the deviations to the recipe for a 
% 0.26% LMG, 5% CA dosimeter 
%
% - just type in the volume required in mL in the parentheses
% - then give Silicon Elastomer, LMG and Curing Agent in that order
% - the deviations will be written out in the command window in latex
%   format
%
%
% Dosimetry AU - 2019 by Janus Kramer Møller
% For questions or problems, e-mail: au521597@post.au.dk

function deviation(v, LMG, SE, CA)
volume = v;

% Calculation of ingredients
se    = volume*(1-(0.0026+0.05)*1.03-0.015*1.49); % Sylgaard 184 Silicone Elastomer
ca    = volume*0.05*1.03;                         % Sylgaard Curing Agent
lmg   = volume*1.03*0.0026;                       % MERCK Leuco Malachite Green
chcl3 = volume*1.03*0.015/1.49;                   % Chloroform

% calculate deviations
se_dev = (se/SE-1)*100;
ca_dev = (ca/CA-1)*100;
lmg_dev= (lmg/LMG-1)*100;


a = sprintf('\begin{table}[]');
b = sprintf('\begin{tabular}{lllll}');
c = sprintf('Ingredient   & recipe & measured & deviation \\');
d = sprintf('Sylgard 184  & %.3f g & %.3f     & %.1f      \\', se, SE, se_dev );
E = sprintf('Curing Agent & %.3f g & %.3f     & %.1f      \\', ca, CA, ca_dev);
f = sprintf('LMG          & %.3f g & %.3f     & %.1f      \\', lmg, LMG, lmg_dev);
g = sprintf('Chloroform   & %.3f ml& * & * \\',chcl3);
h = sprintf('\end{tabular}');
i = sprintf('\end{table}');

% Print to console
format short
disp(a)
disp(b)
disp(c)
disp(d)
disp(E)
disp(f)
disp(g)
disp(h)
disp(i)

end
