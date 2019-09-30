% An easy and fast script to get the recipe for a 0.26% LMG, 5% CA dosimeter 
% - just type in the volume required in mL in the parentheses 
% - the recipe will be written out in the command window
% - ingredients are calculated to a measurable format i.e. grams and mL
%
% Dosimetry AU - 2019 by Janus Kramer Møller
% For questions or problems, e-mail: au521597@post.au.dk

function lmg026(v)
volume = v;

% Calculation of ingredients
se    = volume*(1-(0.0026+0.05)*1.03-0.015*1.49); % Sylgaard 184 Silicone Elastomer
ca    = volume*0.05*1.03;                         % Sylgaard Curing Agent
lmg   = volume*1.03*0.0026;                       % MERCK Leuco Malachite Green
chcl3 = volume*1.03*0.015/1.49;                   % Chloroform

a = sprintf('Silicone Elastomer    : %.3f grams',se);
b = sprintf('Curing Agent          : %.3f grams',ca);
c = sprintf('Leuco Malachite Green : %.3f grams',lmg);
d = sprintf('Chloroform            : %.3f ml',chcl3);

% Print to console
format short
disp(a)
disp(b)
disp(c)
disp(d)

end

