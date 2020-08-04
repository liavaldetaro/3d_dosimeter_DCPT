% Function for normalizing data to another, e.g. TOPAS (target) to Eclipse (reference). Both
% datasets have to be of same dimensions (e.g. 1 cm^3).

function [ratio,u_ratio] = normali_cube(ref_data,tar_data)
abs_ref = sum(ref_data(:));
abs_tar = sum(tar_data(:));
std_ref = std(ref_data(:));
std_tar = std(tar_data(:));

[ratio,u_ratio] = camas('ref/tar','ref',abs_ref,std_ref,'tar',abs_tar,std_tar);
end