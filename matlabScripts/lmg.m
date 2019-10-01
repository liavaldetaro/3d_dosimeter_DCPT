% lmg creates the recipe for your dosimeter taking two parameters:
%
% volume : the total size of the dosimeter in ml.
%
% curing_agent : the percentage of Curing Agent. If you want 5% then write
%                5, NOT 0.05
%
% Dosimetry AU - 2019 by Janus Kramer Møller
% For questions or problems, e-mail: au521597@post.au.dk


function lmg(volume,curing_agent)

volume = volume;
CA = curing_agent*0.01;

% Calculation of ingredients
se    = volume*(1-(0.0026+CA)*1.03-0.015*1.49); % Sylgaard 184 Silicone Elastomer
ca    = volume*CA*1.03;                         % Sylgaard Curing Agent
lmg   = volume*1.03*0.0026;                       % MERCK Leuco Malachite Green
ChCl_3 = volume*1.03*0.015/1.49;                   % Chloroform

a = sprintf('Silicone Elastomer    : %d grams',se);
b = sprintf('Curing Agent          : %s grams',ca);
c = sprintf('Leuco Malachite Green : %c grams',lmg);
d = sprintf('Chloroform            : %d ml',ChCl_3);

% Print to console
format short
disp(a)
disp(b)
disp(c)
disp(d)

end

