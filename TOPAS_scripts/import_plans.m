function all_plans = import_plans(patient_folder)
%% Importing data message
disp(['Importing plans from ' patient_folder '...'])

%% Find folders and files
if patient_folder(end) ~= '/'
    patient_folder = [patient_folder '/'];
end

dcm_folder = [patient_folder 'dcm/'];
all_files = dir(dcm_folder);
index = [all_files.isdir];
filenames = {all_files(~index).name};
plan_files = [];
dose_files = [];
   
disp(length(filenames))

for i = 1:length(filenames)
    file_info = dicominfo([dcm_folder strjoin(filenames(i))]);
    if strcmp(file_info.Modality,'RTPLAN')
        disp('Im a RT plan')
        plan_files = [plan_files; dcm_folder strjoin(filenames(i))];
    elseif strcmp(file_info.Modality,'RTDOSE')
        disp('Im a RT dose') 
        dose_files = [dose_files; dcm_folder strjoin(filenames(i))];
    end
end
%%%%%%%%cbct_offset = get_cbct_offset_vector(patient_folder);   % Find offset vector between ct and cbct

for k = 1:length(plan_files(:,1))
    %% Load dicom file
    clear plan_data
    info_ion_plan = dicominfo(plan_files(k,:));
    plan_data.patient_folder = dcm_folder;
    
    %% Find matching dose file
    plan_id = info_ion_plan.SOPInstanceUID;
    for j=1:length(dose_files(:,1))
        dose_info = dicominfo(dose_files(j,:));
        dose_id = dose_info.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID;
        if sum(plan_id ~= dose_id) < 1
            plan_data.dose_file = dose_files(j,(length(dcm_folder)+1):end);
            plan_data.dose_grid_size = [dose_info.Columns dose_info.Rows dose_info.NumberOfFrames];
            break
        end
    end
    plan_data.plan_name = info_ion_plan.RTPlanLabel;
    disp(['-> Found plan: ' plan_data.plan_name])
    %% Starting Folder %%
    Beam_Data = info_ion_plan.IonBeamSequence

    %% DICOM Read %%
    Beam_data_items = {}; % lines-columns
    Ctr_Point_Sequence = {};
    Source_parameters = {};

    for i = 1:numel(fieldnames(Beam_Data))
        Field1{i} = (['Item_', num2str(i)]); % SHOULD BE THE NUMBER OF
                                             % PROTON BEAMS.
      
        for ii = 1:numel(Field1) 
            Beam_data_items{i} = getfield(Beam_Data, Field1{i});
            % Saved ISIDE CELLS the Fields(struct) found in Beam_Data,
            % these would be the different proton beams used in the plan.
            % EACH CELL IS A PROTON-BEAM.

            disp(Beam_data_items{i})
            Ctr_Point_Sequence{i}{ii} = Beam_data_items{i}.IonControlPointSequence;
            % There should be the same number of structs in Ctr_Point_Sequence
            % as in Beam_data_items.
            % EACH CELL IS A ION-CONTROL-POINT-SEQUENCE.

            for j = 1:numel(fieldnames(Ctr_Point_Sequence{i}{ii})) 
    
                Field2{i}{j} = (['Item_', num2str(j)]); % SHOULD BE THE NUMBER
                                                        % OF FIELDS INSIDE EACH
                                                        % ION-CONTROL-POINT-SEQUENCE.
                                                        
                disp(Field2{i}{j})
                Source_parameters{i}{j} = getfield(Ctr_Point_Sequence{i}{ii}, Field2{i}{j});
                % Each column correspond to a Item inside
                % ION-CONTROL-POINT-SEQUENCE.

                % ion_Energy{i}{j} = Source_parameters{i}{1}.NominalBeamEnergy;
                % Use for 10x10 (No SOBP): Could lead to a whole re-definition
                % of the script. Seems to work alright due to the scans with
                % Weigth equal to zero and saving the energies twice per 
                % ION-CONTROL-POINT-SEQUENCE.
%                 
%                  if isfield(Source_parameters{i}{j},'NominalBeamEnergy') == 0
%                     disp('Im inside the loop');
%                     Source_parameters{i}{j}.NominalBeamEnergy = Source_parameters{i}{1}.NominalBeamEnergy;
%                 end

                %plan_data.ion_Energy{i}{j} = 0.81845 + 0.996069*(Source_parameters{i}{j}.NominalBeamEnergy);
                plan_data.ion_Energy{i}{j} = 0.99734956*Source_parameters{i}{j}.NominalBeamEnergy+85.1/Source_parameters{i}{j}.NominalBeamEnergy+0.076;
                
                % SOBP defined in Eclipse.
                %plan_data.XY_Spread{i}{j} = 11.3826 - 0.10954*plan_data.ion_Energy{i}{j} + 5.4978e-4*plan_data.ion_Energy{i}{j}^2 - 9.63158e-7*plan_data.ion_Energy{i}{j}^3;
                %plan_data.E_Spread{i}{j} = 1.92416 - 1.30608e-2*plan_data.ion_Energy{i}{j} + 5.45467e-5*plan_data.ion_Energy{i}{j}^2 - 1.21633e-7*plan_data.ion_Energy{i}{j}^3;
                %plan_data.prot_MU{i}{j} = 0.745864 + 2.5593e-2*plan_data.ion_Energy{i}{j} - 1.42046e-5*plan_data.ion_Energy{i}{j}^2 - 4.2087e-8*plan_data.ion_Energy{i}{j}^3;
                plan_data.XY_Spread{i}{j} = 11.3826 - 0.10954*plan_data.ion_Energy{i}{j} + 5.4978e-4*plan_data.ion_Energy{i}{j}^2 - 9.63158e-7*plan_data.ion_Energy{i}{j}^3;
                plan_data.prot_MU{i}{j} = 0.3167*plan_data.ion_Energy{i}{j}^(0.5319)-0.9840;
                if plan_data.ion_Energy{i}{j} > 120
                    plan_data.E_Spread{i}{j} = -5.85246999e-03 * plan_data.ion_Energy{i}{j}+...
                        6.71948653e-02*sin(6.30349472e-02*plan_data.ion_Energy{i}{j}+8.38920469e+00)+...
                            1.65191007e+00
                else 
                    plan_data.E_Spread{i}{j} = -0.00429944 *plan_data.ion_Energy{i}{j} + 1.47870547;
                end
                plan_data.prot_MU{i}{j} = 0.3167*plan_data.ion_Energy{i}{j}^(0.5319)-0.9840;
                plan_data.spot_Pos{i}{j} = Source_parameters{i}{j}.ScanSpotPositionMap; 
                % Even entrees: X                                                                       
                % Odd entrees: Y

                plan_data.spot_Weight{i}{j} = Source_parameters{i}{j}.ScanSpotMetersetWeights;
                plan_data.Weigth_T(i,j) = numel(Source_parameters{i}{j}.ScanSpotMetersetWeights);
                plan_data.scan_SpotSize{i}{j} = Source_parameters{i}{j}.ScanningSpotSize;
                % each column correspond to a Item inside
                % ION-CONTROL-POINT-SEQUENCE.

                if any(ismember(fields(Source_parameters{i}{j}),'GantryAngle'))
                    plan_data.gantry_Angle{i}{j} = Source_parameters{i}{j}.GantryAngle;
                    plan_data.gantry_Pitch{i}{j} = Source_parameters{i}{j}.GantryPitchAngle;
                    % One angle per Beam used.
                end
                if any(ismember(fields(Source_parameters{i}{j}),'PatientSupportAngle'))
                    plan_data.couch_Angle{i}{j} = Source_parameters{i}{j}.PatientSupportAngle;
                    plan_data.couch_Pitch{i}{j} = Source_parameters{i}{j}.TableTopPitchAngle;
                    plan_data.couch_Roll{i}{j} = Source_parameters{i}{j}.TableTopRollAngle;
                    plan_data.couch_Vert{i}{j} = Source_parameters{i}{j}.TableTopVerticalPosition;
                    plan_data.couch_Long{i}{j} = Source_parameters{i}{j}.TableTopLongitudinalPosition;
                    plan_data.couch_Lat{i}{j} = Source_parameters{i}{j}.TableTopLateralPosition;
                    % One angle per Beam used.
                end
                if any(ismember(fields(Source_parameters{i}{j}),'IsocenterPosition'))
                    plan_data.isocenter_Pos{i}{j} = Source_parameters{i}{j}.IsocenterPosition;
                    % One isocenter position per Beam used
                    % (it should be the same for every beam).
                end
                if any(ismember(fields(Source_parameters{i}{j}),'SnoutPosition'))
                    plan_data.snout_Pos{i}{j} = Source_parameters{i}{j}.SnoutPosition;
                end
            end
        end
        plan_data.fieldnames{i} = regexprep(getfield(getfield(Beam_Data, Field1{i}), 'BeamName'), ' ', '_');
    end
    %% check for Range shifters
    if Beam_data_items{1}.NumberOfRangeShifters > 0
        plan_data.has_RS = true;
        plan_data.RS_depth = 50; %mm
    else
        plan_data.has_RS = false;
    end
    %% Set air gap
    plan_data.air_gap = 50; % mm

    %% Get number of fractions
    plan_data.fractions = info_ion_plan.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
    
    %% CBCT offset vector
%    plan_data.cbct_offset = cbct_offset;
    
    %% Save plan in array
    all_plans(k).plan = plan_data;
end
%% End of import message
disp(' ')
disp('Plans imported successfully!')
disp(' ')
end
