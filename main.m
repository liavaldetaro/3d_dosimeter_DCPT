%{

This is the main file that generates TOPAS , input the directory where the 
dose and plan files are located.

All the RN, RD and CT files must be in a folder called dcm INSIDE the
folder given to main

This script does not work without CT scans
 
%}

%clc close all, clear all
warning('off', 'all')
folder='D:\irradiation_21_02_20\sopb_2';

%dosimeter height and diameter (mm):
H_dos = 75;
D_dos = 74;

all_plans = import_plans(folder);
for i=1:length(all_plans)
    plan = all_plans(i).plan;
    write_TOPAS_files(plan, H_dos, D_dos);
end