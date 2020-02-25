function write_TOPAS_files(plan_data, H_dos, D_dos)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%   TOPAS single field files   %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global plan 
global beam_files
global spot_weight_multiplier
plan = plan_data;
beam_files = [];
spot_weight_multiplier = 5000;   % scales number of particles in each spot
topas_folder = [plan.patient_folder(1:end-4) 'topas_files/' plan.plan_name '/'];
mkdir(topas_folder);
output_folder = 'dose_output';
time_steps = [1];
for i = 1:numel(plan.fieldnames)
    beam_files = [beam_files; [plan.fieldnames{i},'.txt']];
end

disp(['Writing TOPAS single field files for ' plan.plan_name '...'])
for i = 1:numel(plan.ion_Energy)
    if plan.has_RS
        snout_position = plan.snout_Pos{i}{1}+plan.RS_depth+plan.air_gap; 
    else
        snout_position = plan.snout_Pos{i}{1}+plan.air_gap; 
    end
    Source_TOPAS = fopen([topas_folder,plan.fieldnames{i},'.txt'],'wt');
    fprintf(Source_TOPAS, '##############################################\n');
    fprintf(Source_TOPAS, '###           V A R I A B L E S            ###\n');
    fprintf(Source_TOPAS, '##############################################\n');
    fprintf(Source_TOPAS, 'includeFile                          = DosimeterChemComp.txt\n');
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 'd:Rt/Plan/IsoCenterX                 = %0.2f mm\n', plan.isocenter_Pos{1}{1,1}(1));
    fprintf(Source_TOPAS, 'd:Rt/Plan/IsoCenterY                 = %0.2f mm\n', plan.isocenter_Pos{1}{1,1}(2));
    fprintf(Source_TOPAS, 'd:Rt/Plan/IsoCenterZ                 = %0.2f mm\n', plan.isocenter_Pos{1}{1,1}(3));
    fprintf(Source_TOPAS, 'd:Ge/snoutPosition                   = %0.2f mm #Note: Snout + RS depth + Air gap\n', snout_position);
    fprintf(Source_TOPAS, 'd:Ge/gantryAngle                     = %0.2f deg\n', plan.gantry_Angle{i}{1});
    fprintf(Source_TOPAS, 'd:Ge/couchAngle                      = %0.2f deg\n', plan.couch_Angle{i}{1});
    fprintf(Source_TOPAS, 'dc:Ge/Patient/DicomOriginX           = %0.2f mm\n', 0);
    fprintf(Source_TOPAS, 'dc:Ge/Patient/DicomOriginY           = %0.2f mm\n', 0);
    fprintf(Source_TOPAS, 'dc:Ge/Patient/DicomOriginZ           = %0.2f mm\n', 0);
    fprintf(Source_TOPAS, '\n\n');

    %% TOPAS setup
    write_topas_setup(Source_TOPAS);
    
    %% WORLD
    write_world_setup(Source_TOPAS);
    
    %% GEOMETRY
    write_geometry_setup(Source_TOPAS)
    
    %% BEAM
    write_beam_setup(Source_TOPAS)
    
    %% SCORER
    write_scorer_setup(Source_TOPAS, H_dos, D_dos);
    fprintf(Source_TOPAS, ['s:Sc/Dose/OutputFile                 = "' output_folder '/%s" \n'], beam_files(i,1:end-4));
    fprintf(Source_TOPAS, '\n\n');
    
    %% DEFINITION OF THE TIME VECTORS THAT ARE GOING TO BE USED %%
    Times_scan_length = 0;
    for t = 1:2:length(plan.spot_Weight{i})
        Times_scan_length = Times_scan_length + length(plan.spot_Weight{i}{t});
    end
    % Times_scan_length
    Times_scan = 1:Times_scan_length; % Total time of scanning (one by one)
    plan.Times_scan = Times_scan;
    
    %% TIME FEATURES %%
    fprintf(Source_TOPAS, '##############################################\n');    
    fprintf(Source_TOPAS, '###  T  I  M  E    F  E  A  T  U  R  E  S  ###\n');
    fprintf(Source_TOPAS, '##############################################\n');
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 'i:Tf/NumberOfSequentialTimes         = %i\n', length(Times_scan));
    fprintf(Source_TOPAS, 'd:Tf/TimelineStart                   = 1 s\n');
    fprintf(Source_TOPAS, 'd:Tf/TimelineEnd                     = %i s\n', length(Times_scan) + 1);
    fprintf(Source_TOPAS, '\n');
    
    %% BEAM PARAMETERS
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 's:Tf/Energy/Function                 = "Step"\n');
    fprintf(Source_TOPAS, 'dv:Tf/Energy/Times                   = %i ', length(Times_scan));
    fprintf(Source_TOPAS, '%i ', Times_scan);
    fprintf(Source_TOPAS, 's\n');
    fprintf(Source_TOPAS, 'dv:Tf/Energy/Values                  = %i ', length(Times_scan));
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for t = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_TOPAS, '%0.3f ', plan.ion_Energy{i}{m});
            end
        end
    end
    fprintf(Source_TOPAS, 'MeV\n');
    
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 's:Tf/EnergySpread/Function           = "Step"\n');
    fprintf(Source_TOPAS, 'dv:Tf/EnergySpread/Times             = %i ', length(Times_scan));
    fprintf(Source_TOPAS, '%i ', Times_scan);
    fprintf(Source_TOPAS, 's\n');
    fprintf(Source_TOPAS, 'uv:Tf/EnergySpread/Values            = %i ', length(Times_scan));
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for t = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_TOPAS, '%0.5f ', plan.E_Spread{i}{m});
            end
        end
    end
    fprintf(Source_TOPAS, '\n');
    
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 's:Tf/XYSpread/Function               = "Step"\n');
    fprintf(Source_TOPAS, 'dv:Tf/XYSpread/Times                 = %i ', length(Times_scan));
    fprintf(Source_TOPAS, '%i ', Times_scan);
    fprintf(Source_TOPAS, 's\n');
    fprintf(Source_TOPAS, 'dv:Tf/XYSpread/Values                = %i ', length(Times_scan));
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for t = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_TOPAS, '%0.5f ', plan.XY_Spread{i}{m});
            end
        end
    end
    fprintf(Source_TOPAS, 'mm\n');
    
    %% WEIGHTS, SCANNING POINT POSITIONS.
    % calculate beam angles from XY-positions
    
    use_positions(Source_TOPAS, plan, i)
%     use_angles(Source_TOPAS, plan, i) % Angles not working yet...
    
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 's:Tf/spotWeight/Function             = "Step"\n');
    fprintf(Source_TOPAS, 'dv:Tf/spotWeight/Times               = %i ', length(Times_scan));
    fprintf(Source_TOPAS, '%i ', Times_scan);
    fprintf(Source_TOPAS, 's\n');
    fprintf(Source_TOPAS, 'iv:Tf/spotWeight/Values              = %i ', length(Times_scan));
    no_of_particles = 0;
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for j = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_TOPAS, '%.0f ', spot_weight_multiplier * plan.spot_Weight{1,i}{1,m}(j) * plan.prot_MU{1,i}{1,m});
                no_of_particles = no_of_particles + spot_weight_multiplier * plan.spot_Weight{1,i}{1,m}(j) * plan.prot_MU{1,i}{1,m};
            end
        end
        % The spot weight is  not constant for every complete scan i.e. for
        % every beam energy. Look at the definition.
        % Every even item has Weigth equal to zero (Eclipse double check).
    end
    fprintf(Source_TOPAS, '\n\n#Total number of particles is %i\n', no_of_particles);
    fprintf(Source_TOPAS, '\n\n');
    
    time_steps = [time_steps time_steps(end)+length(Times_scan)];
    
    disp(['-> ' beam_files(i,1:end-4) '... Done.'])    
end
time_steps(end) = time_steps(end)-1;
disp(' ')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     All fields    %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Writing TOPAS combined fields file...')
output_file_total = 'combined_dose';
topas_file_combined = 'all_fields.txt';
no_of_fields = length(plan.fieldnames);
snout_position = [];
gantry_Angle = [];
couch_Angle = [];
for i = 1:no_of_fields
    if plan.has_RS
        snout_position = [snout_position plan.snout_Pos{i}{1}+plan.RS_depth+plan.air_gap]; % +400 to avoid geometry overlap in TOPAS
    else
        snout_position = [snout_position plan.snout_Pos{i}{1}+plan.air_gap]; % +400 to avoid geometry overlap in TOPAS
    end
    gantry_Angle = [gantry_Angle plan.gantry_Angle{i}{1}];
    couch_Angle = [couch_Angle plan.couch_Angle{i}{1}];
end
Source_all = fopen([topas_folder, topas_file_combined],'wt');
%% Write TOPAS variables
fprintf(Source_all, '##############################################\n');
fprintf(Source_all, '###           V A R I A B L E S            ###\n');
fprintf(Source_all, '##############################################\n');
fprintf(Source_all, 'includeFile                          = DosimeterChemComp.txt\n');
fprintf(Source_all, '\n');
fprintf(Source_all, 'd:Rt/Plan/IsoCenterX                 = %0.2f mm\n', plan.isocenter_Pos{1}{1,1}(1));
fprintf(Source_all, 'd:Rt/Plan/IsoCenterY                 = %0.2f mm\n', plan.isocenter_Pos{1}{1,1}(2));
fprintf(Source_all, 'd:Rt/Plan/IsoCenterZ                 = %0.2f mm\n', plan.isocenter_Pos{1}{1,1}(3));
fprintf(Source_all, 'd:Ge/snoutPosition                   = Tf/snoutPos/value mm #Note: Snout + RS depth + Air gap\n');
fprintf(Source_all, 'd:Ge/gantryAngle                     = Tf/gantryAng/value deg\n');
fprintf(Source_all, 'd:Ge/couchAngle                      = Tf/couchAng/value deg\n');
fprintf(Source_all, 'dc:Ge/Patient/DicomOriginX           = %0.2f mm\n', 0);
fprintf(Source_all, 'dc:Ge/Patient/DicomOriginY           = %0.2f mm\n', 0);
fprintf(Source_all, 'dc:Ge/Patient/DicomOriginZ           = %0.2f mm\n', 0);
fprintf(Source_all, '\n\n');

%% Write static parameters
write_topas_setup(Source_all)
write_world_setup(Source_all)
write_geometry_setup(Source_all)
write_beam_setup(Source_all)
write_scorer_setup(Source_all, H_dos, D_dos)
fprintf(Source_all, ['s:Sc/Dose/OutputFile                 = "' output_folder '/%s" \n'], output_file_total);
fprintf(Source_all, '\n\n');

%% Write time features
fprintf(Source_all, '##############################################\n');    
fprintf(Source_all, '###        T I M E  F E A T U R E S        ###\n');
fprintf(Source_all, '##############################################\n');
fprintf(Source_all, 'i:Tf/NumberOfSequentialTimes     = %i\n',time_steps(end)); 
fprintf(Source_all, 'd:Tf/TimelineStart               = 1 s\n');
fprintf(Source_all, 'd:Tf/TimelineEnd                 = %i s\n', time_steps(end)+1);

fprintf(Source_all, '\n');


%% GEOMETRY PARAMETERS
fprintf(Source_all, 's:Tf/gantryAng/Function                = "Step"\n');
fprintf(Source_all, 'dv:Tf/gantryAng/Times                  = %i',no_of_fields);
fprintf(Source_all, ' %i',time_steps(1:end-1)); 
fprintf(Source_all, ' s\n');
fprintf(Source_all, 'dv:Tf/gantryAng/values                 = %i',no_of_fields);
fprintf(Source_all, ' %0.2f',gantry_Angle);
fprintf(Source_all, ' deg\n\n');

fprintf(Source_all, 's:Tf/couchAng/Function                = "Step"\n');
fprintf(Source_all, 'dv:Tf/couchAng/Times                  = %i',no_of_fields);
fprintf(Source_all, ' %i',time_steps(1:end-1)); 
fprintf(Source_all, ' s\n');

fprintf(Source_all, 'dv:Tf/couchAng/values                 = %i',no_of_fields);
fprintf(Source_all, ' %0.2f',couch_Angle); 
fprintf(Source_all, ' deg\n\n');
fprintf(Source_all, 's:Tf/snoutPos/Function                = "Step"\n');
fprintf(Source_all, 'dv:Tf/snoutPos/Times                  = %i',no_of_fields);
fprintf(Source_all, ' %i',time_steps(1:end-1)); 

fprintf(Source_all, ' s\n');
fprintf(Source_all, 'dv:Tf/snoutPos/values                 = %i',no_of_fields);
fprintf(Source_all, ' %0.2f',snout_position); 
fprintf(Source_all, ' mm\n');


%% BEAM PARAMETERS
fprintf(Source_all, '\n');
fprintf(Source_all, 's:Tf/Energy/Function                 = "Step"\n');
fprintf(Source_all, 'dv:Tf/Energy/Times                   = %i ', time_steps(end));
fprintf(Source_all, '%i ', 1:time_steps(end));
fprintf(Source_all, 's\n\n');
fprintf(Source_all, 'dv:Tf/Energy/Values                  = %i ', time_steps(end));
for i = 1:no_of_fields
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for t = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_all, '%0.3f ', plan.ion_Energy{i}{m});
            end
        end
    end
end
disp(' ')

    fprintf(Source_all, 'MeV\n');
    
    fprintf(Source_all, '\n');
    fprintf(Source_all, 's:Tf/EnergySpread/Function           = "Step"\n');
    fprintf(Source_all, 'dv:Tf/EnergySpread/Times             = %i ', time_steps(end));
    fprintf(Source_all, '%i ', 1:time_steps(end));
    fprintf(Source_all, 's\n\n');
    fprintf(Source_all, 'uv:Tf/EnergySpread/Values            = %i ', time_steps(end));
for i = 1:no_of_fields
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for t = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_all, '%0.5f ', plan.E_Spread{i}{m});
            end
        end
    end
end
    fprintf(Source_all, '\n\n');
    
    fprintf(Source_all, 's:Tf/XYSpread/Function               = "Step"\n');
    fprintf(Source_all, 'dv:Tf/XYSpread/Times                 = %i ', time_steps(end));
    fprintf(Source_all, '%i ', 1:time_steps(end));
    fprintf(Source_all, 's\n\n');
    fprintf(Source_all, 'dv:Tf/XYSpread/Values                = %i ', time_steps(end));
for i = 1:no_of_fields
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for t = 1:length(plan.spot_Weight{1,i}{1,m})
                %fprintf(Source_all, '%0.5f ', pprot_MUlan.XY_Spread{i}{m});
                fprintf(Source_all, '%0.5f', plan.XY_Spread{i}{m});
            end
        end
    end
end
    fprintf(Source_all, 'mm\n');
    
    
% % % % % % %     fprintf(Source_TOPAS, '\n');
% % % % % % %     fprintf(Source_TOPAS, 's:Tf/XYSpread/Function               = "Step"\n');
% % % % % % %     fprintf(Source_TOPAS, 'dv:Tf/XYSpread/Times                 = %i ', length(Times_scan));
% % % % % % %     fprintf(Source_TOPAS, '%i ', Times_scan);
% % % % % % %     fprintf(Source_TOPAS, 's\n');
% % % % % % %     fprintf(Source_TOPAS, 'dv:Tf/XYSpread/Values                = %i ', length(Times_scan));
% % % % % % %     for m = 1:numel(plan.spot_Weight{1,i})
% % % % % % %         if plan.spot_Weight{1,i}{1,m} ~= 0
% % % % % % %             for t = 1:length(plan.spot_Weight{1,i}{1,m})
% % % % % % %                 fprintf(Source_TOPAS, '%0.5f ',D);
% % % % % % %             end
% % % % % % %         end
% % % % % % %     end
%% WEIGHTS, SCANNING POINT POSITIONS.
    % calculate beam angles from XY-positions
    
    fprintf(Source_all, '\n');
    fprintf(Source_all, 's:Tf/spotWeight/Function             = "Step"\n');
    fprintf(Source_all, 'dv:Tf/spotWeight/Times               = %i ', time_steps(end));
    fprintf(Source_all, '%i ', 1:time_steps(end));
    fprintf(Source_all, 's\n\n');
    fprintf(Source_all, 'iv:Tf/spotWeight/Values              = %i ', time_steps(end));
    no_of_particles = 0;
for i = 1:no_of_fields
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            for j = 1:length(plan.spot_Weight{1,i}{1,m})
                fprintf(Source_all, '%.0f ', spot_weight_multiplier * plan.spot_Weight{1,i}{1,m}(j) * plan.prot_MU{1,i}{1,m});
                no_of_particles = no_of_particles + spot_weight_multiplier * plan.spot_Weight{1,i}{1,m}(j) * plan.prot_MU{1,i}{1,m};
            end
        end
    end
end

        % The spot weight is  not constant for every complete scan i.e. for
        % every beam energy. Look at the definition.
        % Every even item has Weigth equal to zero (Eclipse double check).
    fprintf(Source_all, '\n\n#Total number of particles is %i\n', no_of_particles);
    fprintf(Source_all, '\n\n');
    fprintf(Source_all, 's:Tf/spotPositionX/Function          = "Step"\n');
    fprintf(Source_all, 'dv:Tf/spotPositionX/Times            = %i ', time_steps(end));
    fprintf(Source_all, '%i ', 1:time_steps(end));
    fprintf(Source_all, 's\n\n');
    fprintf(Source_all, 'dv:Tf/spotPositionX/Values           = %i ', time_steps(end));
for i = 1:no_of_fields
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            fprintf(Source_all, '%0.1f ', plan.spot_Pos{1,i}{1,m}(1:2:length(plan.spot_Pos{1,i}{1,m})));
        end
    end
end
    fprintf(Source_all, 'mm\n');
    
    fprintf(Source_all, '\n');
    fprintf(Source_all, 's:Tf/spotPositionY/Function          = "Step"\n');
    fprintf(Source_all, 'dv:Tf/spotPositionY/Times            = %i ', time_steps(end));
    fprintf(Source_all, '%i ', 1:time_steps(end));
    fprintf(Source_all, 's\n\n');
    fprintf(Source_all, 'dv:Tf/spotPositionY/Values           = %i ', time_steps(end));
    
for i = 1:no_of_fields
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            fprintf(Source_all, '%0.1f ', plan.spot_Pos{1,i}{1,m}(2:2:length(plan.spot_Pos{1,i}{1,m})));
        end
    end
end
    fprintf(Source_all, 'mm\n');
disp('Done.')
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%    Test file    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Writing test file...')
Source_test = fopen([topas_folder,'test.txt'],'wt');
fprintf(Source_test, '# This file is used to test the coordinatesystem of the DICOM files.\n');
fprintf(Source_test, 'includefile                  = %s\n', beam_files(1,:));
fprintf(Source_test, '\n');
fprintf(Source_test, 'd:Ge/gantryAngle             = 0. deg\n');
fprintf(Source_test, 'd:Ge/couchAngle              = 0. deg\n');
fprintf(Source_test, '\n');
fprintf(Source_test, 'd:Ge/BeamPosition/TransX     = 0. mm\n');
fprintf(Source_test, 'd:Ge/BeamPosition/TransY     = 0. mm\n');
fprintf(Source_test, '\n');
fprintf(Source_test, 'i:Tf/NumberOfSequentialTimes = 1\n');
fprintf(Source_test, 'd:Tf/TimelineStart           = 1 s\n');
fprintf(Source_test, 'd:Tf/TimelineEnd             = 2 s\n');
fprintf(Source_test, '\n');
fprintf(Source_test, 'i:So/Field/NumberOfHistoriesInRun    = 2000\n');
fprintf(Source_test, 'sv:Ph/Default/Modules                = 1 "g4em-standard_opt4"\n');

disp('Done.')
disp(' ')

fclose('all');
end


function write_topas_setup(Source)
fprintf(Source, '##############################################\n');    
fprintf(Source, '###         T O P A S    S E T U P         ###\n');
fprintf(Source, '##############################################\n');
fprintf(Source, 'i:Ts/ShowHistoryCountAtInterval         = 10000\n');
fprintf(Source, 'i:Ts/NumberOfThreads                    = 0 # 0 for using all cores, -1 for all but one\n');
fprintf(Source, 'b:Ts/DumpParameters                     = "False"\n');
fprintf(Source, '\n\n');
end

function write_world_setup(Source)
    fprintf(Source, '##############################################\n');    
    fprintf(Source, '###         W O R L D    S E T U P         ###\n');
    fprintf(Source, '##############################################\n');
    fprintf(Source, 's:Ge/World/Type            = "TsBox"\n');
    fprintf(Source, 's:Ge/World/Material        = "Air"\n');
    fprintf(Source, 'd:Ge/World/HLX             = 90. cm\n');
    fprintf(Source, 'd:Ge/World/HLY             = 90. cm\n');
    fprintf(Source, 'd:Ge/World/HLZ             = 90. cm\n');
    fprintf(Source, 'b:Ge/World/Invisible       = "True"\n');
    fprintf(Source, '\n\n');
end

function write_geometry_setup(Source)
    global plan
    fprintf(Source, '##############################################\n');
    fprintf(Source, '###            G E O M E T R Y             ###\n');
    fprintf(Source, '##############################################\n');
    
    % PATIENT
    fprintf(Source, 's:Ge/Patient/Parent                  = "World"\n');
    fprintf(Source, 's:Ge/Patient/Type                    = "TsCylinder"\n');
    fprintf(Source, 's:Ge/Patient/Material                = "FlexDos"\n');
    fprintf(Source, 's:Ge/Patient/DicomDirectory          = "dcm"\n');
    fprintf(Source, 'd:Ge/Patient/TransX                  = Ge/Patient/DicomOriginX - Rt/Plan/IsoCenterX mm\n');
    fprintf(Source, 'd:Ge/Patient/TransY                  = Ge/Patient/DicomOriginY - Rt/Plan/IsoCenterY mm\n');
    fprintf(Source, 'd:Ge/Patient/TransZ                  = Ge/Patient/DicomOriginZ - Rt/Plan/IsoCenterZ mm\n');
    fprintf(Source, 'd:Ge/Patient/RotX                    = %0.2f deg\n', 0);
    fprintf(Source, 'd:Ge/Patient/RotY                    = %0.2f deg\n', 0);
    fprintf(Source, 'd:Ge/Patient/RotZ                    = %0.2f deg\n', 0);
    fprintf(Source, 's:Ge/Patient/Color                   = "Red"\n');
    
    % GANTRY DEFINITION
    fprintf(Source, '\n');
    fprintf(Source, 's:Ge/Gantry/Parent                   = "DCM_to_IEC"\n');
    fprintf(Source, 's:Ge/Gantry/Type                     = "Group"\n');
    fprintf(Source, 'd:Ge/Gantry/TransX                   = 0.00 mm\n');
    fprintf(Source, 'd:Ge/Gantry/TransY                   = 0.00 mm\n');
    fprintf(Source, 'd:Ge/Gantry/TransZ                   = 0.00 mm\n');
    fprintf(Source, 'd:Ge/Gantry/RotX                     = %0.2f deg\n', 0);
    fprintf(Source, 'd:Ge/Gantry/RotY                     = Ge/gantryAngle deg\n');
    fprintf(Source, 'd:Ge/Gantry/RotZ                     = %0.2f deg\n', 0);
    fprintf(Source, '\n');
    
    fprintf(Source, 's:Ge/Support/Parent                  = "World"\n');
    fprintf(Source, 's:Ge/Support/Type                    = "Group"\n');
    fprintf(Source, 'd:Ge/Support/RotX                    = 0. deg\n');
    fprintf(Source, 'd:Ge/Support/RotY                    = -1.0 * Ge/couchAngle deg\n');
    fprintf(Source, 'd:Ge/Support/RotZ                    = 0. deg\n');
    fprintf(Source, 'd:Ge/Support/TransX                  = 0.0 mm\n');
    fprintf(Source, 'd:Ge/Support/TransY                  = 0.0 mm\n');
    fprintf(Source, 'd:Ge/Support/TransZ                  = 0.0 mm\n');
    fprintf(Source, '\n');
    
    fprintf(Source, 's:Ge/DCM_to_IEC/Parent               = "Support"\n');
    fprintf(Source, 's:Ge/DCM_to_IEC/Type                 = "Group"\n');
    fprintf(Source, 'd:Ge/DCM_to_IEC/TransX               = 0.0 mm\n');
    fprintf(Source, 'd:Ge/DCM_to_IEC/TransY               = 0.0 mm\n');
    fprintf(Source, 'd:Ge/DCM_to_IEC/TransZ               = 0.0 mm\n');
    fprintf(Source, 'd:Ge/DCM_to_IEC/RotX                 = %0.2f deg\n', 90);
    fprintf(Source, 'd:Ge/DCM_to_IEC/RotY                 = 0.0 deg\n');
    fprintf(Source, 'd:Ge/DCM_to_IEC/RotZ                 = 0.0 deg\n');
    fprintf(Source, '\n');
    
    % BEAM POSITION
    fprintf(Source, 's:Ge/BeamPosition/Parent             = "Gantry"\n');
    fprintf(Source, 's:Ge/BeamPosition/Type               = "Group"\n');
    fprintf(Source, 'd:Ge/BeamPosition/TransZ             = -1.0 * Ge/snoutPosition mm\n');
    fprintf(Source, 'd:Ge/BeamPosition/TransX             = Tf/spotPositionX/Value mm\n');
    fprintf(Source, 'd:Ge/BeamPosition/TransY             = -1.0 * Tf/spotPositionY/Value mm\n'); % Coordinatesystem is rotated relative to Eclipse
    fprintf(Source, 'd:Ge/BeamPosition/RotX               = %0.2f deg\n', 0);
    fprintf(Source, 'd:Ge/BeamPosition/RotY               = %0.2f deg\n', 0);
    fprintf(Source, 'd:Ge/BeamPosition/RotZ               = %0.2f deg\n', 0);
    
    fprintf(Source, '\n');
    if plan.has_RS   % true if treatment plan is using a Range Shifter
        fprintf(Source, '#### Range shifter ####\n');
        fprintf(Source, 's:Ge/RS/Parent                       = "BeamPosition"\n');
        fprintf(Source, 's:Ge/RS/Type                         = "TsBox"\n');
        fprintf(Source, 's:Ge/RS/Material                     = "Lexan"\n');
        fprintf(Source, 'b:Ge/RS/Isparallel                   = "True"\n');
        fprintf(Source, 'sv:Ph/Default/LayeredMassGeometryWorlds = 2 "Patient/RTDoseGrid" "RS"\n'); % By listing it like this, RS material will take precedence over Patient
        fprintf(Source, 'd:Ge/RS/HLX                          = %0.2f mm\n', 40);
        fprintf(Source, 'd:Ge/RS/HLY                          = %0.2f mm\n', 40);
        fprintf(Source, 'd:Ge/RS/HLZ                          = %0.2f mm\n', plan.RS_depth/2);    % half-depth of 5 cm
        fprintf(Source, 's:Ge/RS/Color                        = "Orange"\n');
        fprintf(Source, 'd:Ge/RS/TransZ                       = 30.00 mm\n');
        fprintf(Source, '\n\n');
    end
end

function write_beam_setup(Source)
    fprintf(Source, '##############################################\n');
    fprintf(Source, '###               B  E  A  M               ###\n');
    fprintf(Source, '##############################################\n');
    fprintf(Source, 's:So/Field/Type                      = "Beam"\n');
    fprintf(Source, 's:So/Field/Component                 = "BeamPosition"\n');
    fprintf(Source, 's:So/Field/BeamParticle              = "proton"\n');
    fprintf(Source, 'd:So/Field/BeamEnergy                = Tf/Energy/Value MeV\n');
    fprintf(Source, 'u:So/Field/BeamEnergySpread          = Tf/EnergySpread/Value\n');
    fprintf(Source, 's:So/Field/BeamPositionDistribution  = "Gaussian"\n');
    fprintf(Source, 's:So/Field/BeamPositionCutoffShape   = "Rectangle"\n');
    fprintf(Source, 'd:So/Field/BeamPositionCutoffX       = %0.2f cm\n', 5.0);
    fprintf(Source, 'd:So/Field/BeamPositionCutoffY       = %0.2f cm\n', 5.0);
    fprintf(Source, 'd:So/Field/BeamPositionSpreadX       = Tf/XYSpread/Value mm\n');
    fprintf(Source, 'd:So/Field/BeamPositionSpreadY       = Tf/XYSpread/Value mm\n');
    fprintf(Source, 's:So/Field/BeamAngularDistribution   = "Gaussian"\n');
    fprintf(Source, 'd:So/Field/BeamAngularCutoffX        = 90. deg\n');
    fprintf(Source, 'd:So/Field/BeamAngularCutoffY        = 90. deg\n');
    fprintf(Source, 'd:So/Field/BeamAngularSpreadX        = 0.0001 rad\n');
    fprintf(Source, 'd:So/Field/BeamAngularSpreadY        = 0.0001 rad\n');
    fprintf(Source, 's:So/Field/BeamXYDistribution        = "Gaussian"\n');
    fprintf(Source, 'd:So/Field/BeamStandardDeviationX    = 0.0 mm\n');
    fprintf(Source, 'd:So/Field/BeamStandardDeviationY    = 0.0 mm\n');
    fprintf(Source, '\n');
    fprintf(Source, 'i:So/Field/NumberOfHistoriesInRun    = Tf/spotWeight/Value\n');
    fprintf(Source, '\n\n');
end

function write_scorer_setup(Source, H_dos, D_dos)
    fprintf(Source, '##############################################\n');    
    fprintf(Source, '###       S C O R E R    S E T U P         ###\n');
    fprintf(Source, '##############################################\n');
    fprintf(Source, 's:Ge/ScoringBox/Parent               = "World"\n');
    fprintf(Source, 's:Ge/ScoringBox/Type                 = "TsBox"\n');
    fprintf(Source, 'd:Ge/ScoringBox/HLX                  = %0.2f mm\n', D_dos);
    fprintf(Source, 'd:Ge/ScoringBox/HLY                  = %0.2f mm\n', D_dos);
    fprintf(Source, 'd:Ge/ScoringBox/HLZ                  = %0.2f mm\n', H_dos);
    fprintf(Source, 'i:Ge/ScoringBox/Xbins                = %0.2f mm\n', 2*D_dos/0.25);
    fprintf(Source, 'i:Ge/ScoringBox/Ybins                = %0.2f mm\n', 2*D_dos/0.25);
    fprintf(Source, 'i:Ge/ScoringBox/Zbins                = %0.2f mm\n', 2*H_dos/0.25);
    fprintf(Source, 'b:Ge/ScoringBox/isParallel           = "True"\n');
    
    fprintf(Source, 'd:Ge/ScoringBox/TransX               = Ge/Patient/DicomOriginX - Rt/Plan/IsoCenterX mm\n');
    fprintf(Source, 'd:Ge/ScoringBox/TransY               = Ge/Patient/DicomOriginY - Rt/Plan/IsoCenterY mm\n');
    fprintf(Source, 'd:Ge/ScoringBox/TransZ               = Ge/Patient/DicomOriginZ - Rt/Plan/IsoCenterZ mm\n');
    fprintf(Source, 'd:Ge/ScoringBox/RotX                 = "0.0 deg"\n');
    fprintf(Source, 'd:Ge/ScoringBox/RotY                 = "0.0 deg"\n');
    fprintf(Source, 'd:Ge/ScoringBox/RotZ                 = "0.0 deg"\n');
    
    fprintf(Source, '##############################################\n');    
    fprintf(Source, '###             DOSE AND LET               ###\n');
    fprintf(Source, '##############################################\n');
    
    fprintf(Source, 's:Sc/DoseAtPhantom/Quantity          = "DoseToMedium"\n');
    fprintf(Source, 's:Sc/DoseAtPhantom/Component         = "ScoringBox"\n');
    fprintf(Source, 's:Sc/DoseAtPhantom/IfOutputFileAlreadyExists = "Overwrite"\n');
    
    fprintf(Source, 'd:Sc/LETatPhantom/Quantity           = "ProtonLET"\n');
    fprintf(Source, 's:Sc/LETatPhantom/Component          = "ScoringBox"\n');
    fprintf(Source, 'd:Sc/LETatPhantom/MaxScoredLET       = 100 MeV/mm/(g/cm3)\n');
    fprintf(Source, 'd:Ph/Default/CutForElectron          = 0.25 mm\n');
    fprintf(Source, 's:Sc/LETatPhantom/IfOutputFileAlreadyExists = "Overwrite"\n');    
    
    fprintf(Source, '##############################################\n');    
    fprintf(Source, '###             DICOM EXPORT               ###\n');
    fprintf(Source, '##############################################\n');
    
    fprintf(Source, 's:Sc/Dose/Quantity                   = "DoseToMedium"\n');
    fprintf(Source, 's:Sc/Dose/Component                  = "ScoringBox"\n');
    fprintf(Source, 's:Sc/Dose/OutputType                 = "DICOM"\n');
    fprintf(Source, 'b:Sc/Dose/DICOMOutput32BitsPerPixel  = "F"\n');
    fprintf(Source, 's:Sc/Dose/OutputFile                 = "Dose_dicom"\n');
    fprintf(Source, 's:Sc/Dose/IfOutputFileAlreadyExists = "Overwrite"\n');
    
    fprintf(Source, 'd:Sc/LET/Quantity           = "ProtonLET"\n');
    fprintf(Source, 's:Sc/LET/Component          = "ScoringBox"\n');
    fprintf(Source, 'd:Sc/LET/MaxScoredLET       = 100 MeV/mm/(g/cm3)\n');
    fprintf(Source, 's:Sc/LET/OutputFile                 = "LET_dicom"\n');
    fprintf(Source, 's:Sc/LET/IfOutputFileAlreadyExists = "Overwrite"\n');    
     
end

function use_positions(output_file, plan, iteration)
% NOTE: this function is only implemented for single field files!
    Source_TOPAS = output_file;
    i = iteration;
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 's:Tf/spotPositionX/Function          = "Step"\n');
    fprintf(Source_TOPAS, 'dv:Tf/spotPositionX/Times            = %i ', length(plan.Times_scan));
    fprintf(Source_TOPAS, '%i ', plan.Times_scan);
    fprintf(Source_TOPAS, 's\n');
    fprintf(Source_TOPAS, 'dv:Tf/spotPositionX/Values           = %i ', length(plan.Times_scan));
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            fprintf(Source_TOPAS, '%0.1f ', plan.spot_Pos{1,i}{1,m}(1:2:length(plan.spot_Pos{1,i}{1,m})));
        end
    end
    fprintf(Source_TOPAS, 'mm\n');
    
    fprintf(Source_TOPAS, '\n');
    fprintf(Source_TOPAS, 's:Tf/spotPositionY/Function          = "Step"\n');
    fprintf(Source_TOPAS, 'dv:Tf/spotPositionY/Times            = %i ', length(plan.Times_scan));
    fprintf(Source_TOPAS, '%i ', plan.Times_scan);
    fprintf(Source_TOPAS, 's\n');
    fprintf(Source_TOPAS, 'dv:Tf/spotPositionY/Values           = %i ', length(plan.Times_scan));
    for m = 1:numel(plan.spot_Weight{1,i})
        if plan.spot_Weight{1,i}{1,m} ~= 0
            fprintf(Source_TOPAS, '%0.1f ', plan.spot_Pos{1,i}{1,m}(2:2:length(plan.spot_Pos{1,i}{1,m})));
        end
    end
    fprintf(Source_TOPAS, 'mm\n');
end
