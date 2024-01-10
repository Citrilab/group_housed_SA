function PR

% function PR runs an experiment for fentanyl progressive ratio.
% it is meant to be run through Bpod consule, and incorporate the use of
% sending and recieving soft codes. 
% IMPORTANT - CONNECT WATER TO PORT 1 AND FENTANYL TO PORT 2!!!!

    % settings:
    global BpodSystem
    settings = BpodSystem.ProtocolSettings; 
    
    % find the settings path and store it in Bpodsystem path:
    settings_path = [ BpodSystem.Path.ProtocolFolder,...
        BpodSystem.Status.CurrentProtocolName, ...
        '\Settings' ];
    x = dir(settings_path);
    y = {x.name};                
    if ismember('template.mat', y)
        BpodSystem.Path.settings_path = settings_path;      
    else
        disp ('Wrong settings path !')
    end
    
    if isempty(fieldnames(settings))            % If settings file was an empty struct, populate struct with default settings
            S.RewardAmount = 20;                % ul
     end
   
    BpodSystem.SoftCodeHandlerFunction = 'read_rf';
    
    % initiations :
    global RFID
    RFID = serial('COM7');
        
    BpodSystem.Data = struct;             
    BpodSystem.Data.TESTER_RFID = '00782B1799DD'; % It is advised to dedicate an RFID tag for manual testing of the system 
                                                  % by the experimenter when needed, change the tag accordingly. 
        
    %% initiate figures
    BpodSystem.GUIData.bar = struct;
    BpodSystem.GUIData.bar.x_labels = categorical(settings.names);
    BpodSystem.GUIData.bar.water = zeros(1, height(settings));
    BpodSystem.GUIData.bar.fentanyl = zeros(1, height(settings));
       
    BpodSystem.ProtocolFigures.water = figure('name','Water consumed (ul)','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    BpodSystem.ProtocolFigures.fentanyl = figure('name','Fentanyl consumed (ul)','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    
    BpodSystem.GUIHandles.water_ax = axes('Parent', BpodSystem.ProtocolFigures.water);
    BpodSystem.GUIHandles.fentanyl_ax = axes('Parent', BpodSystem.ProtocolFigures.fentanyl);
    
    BpodSystem.GUIHandles.water_bar = bar(BpodSystem.GUIHandles.water_ax, ...
        categorical(BpodSystem.GUIData.bar.x_labels),...
            BpodSystem.GUIData.bar.water,  0.6);
    BpodSystem.GUIHandles.fentanyl_bar = bar(BpodSystem.GUIHandles.fentanyl_ax, ...
        categorical(BpodSystem.GUIData.bar.x_labels),...
            BpodSystem.GUIData.bar.fentanyl,  0.6);
        
    % initiate counting of PR ratio:
    BpodSystem.GUIData.pr_count.names = BpodSystem.GUIData.bar.x_labels;
    BpodSystem.GUIData.pr_count.water = ones(size(BpodSystem.GUIData.pr_count.names)); 
    BpodSystem.GUIData.pr_count.fentanyl = ones(size(BpodSystem.GUIData.pr_count.names))*2; 
    BpodSystem.GUIData.pokes_count.water = zeros(size(BpodSystem.GUIData.pr_count.names)); 
    BpodSystem.GUIData.pokes_count.fentanyl = zeros(size(BpodSystem.GUIData.pr_count.names)); 
    BpodSystem.GUIData.pokes_to_ratio = 2;
            
  %% The main loop   
    n_trials = 100000;
    T = TrialManagerObject;
    T.Timer.Period = 0.2; % could be much smaller ( 0.001 )
    p = struct;
    
    BpodSystem.Status.tmp_rf = BpodSystem.Data.TESTER_RFID; 
    subject_settings = load_settings(BpodSystem.Status.tmp_rf, settings);  % Start a dummy trial with the tester RFID and template settings  
    p = define_trial(subject_settings);
    p.pr_count.fentanyl = 1;                                               
    p.pr_count.water = 1;
    p.RFID = BpodSystem.Status.tmp_rf;  
    sma = prepare_sma(p);
    T.startTrial(sma);   
    RawEvents = T.getTrialData;
    
    for i = 1:n_trials
            BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);   % Computes trial events from raw data
            disp(datetime('now'));                                         % serves as validation the the experiment is running
            tmp = p;                                                       % store previous trials parameters in tmp before re-initializing p
                        
            % Collect the relevant data of the *previous* trial: 
            previous_animal_ind = strcmp(settings.tags, tmp.RFID);         
            if all(~previous_animal_ind)                                   % if there is an unrecognized read mark it as the tester
                previous_animal_ind(length(previous_animal_ind)) = 1;
            end 
            trial_water = 0;
            trial_fentanyl = 0;
            
            if i>1   
            % compute PR change of the previous trial:
                if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward1 (1))
                    trial_water = tmp.reward;
                    BpodSystem.GUIData.pr_count.water(previous_animal_ind) = ...
                        BpodSystem.GUIData.pr_count.water(previous_animal_ind) + 1 ; % if a reward was given, update the PR, icrease by 1
                end 
                
                if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward2 (1))
                    trial_fentanyl = tmp.reward;
                    BpodSystem.GUIData.pr_count.fentanyl(previous_animal_ind) = ...
                       BpodSystem.GUIData.pr_count.fentanyl(previous_animal_ind) + 1; %  if a reward was given, update the PR, icrease by 1
                    
                end 
            end 
           % compute PR to be used  in the current trial:
            subject_settings = load_settings(BpodSystem.Status.tmp_rf, settings);
            p = define_trial(subject_settings);                            % collect individual settings into state machine variables
            current_animal_ind = strcmp(settings.tags, BpodSystem.Status.tmp_rf);         
            if all(~current_animal_ind)                                   % if there is an unrecognized read mark it as the tester
                current_animal_ind(length(current_animal_ind)) = 1;
            end
            p.pr_count.fentanyl = BpodSystem.GUIData.pr_count.fentanyl(current_animal_ind);                                              
            p.pr_count.water = BpodSystem.GUIData.pr_count.water(current_animal_ind);
            p.RFID = BpodSystem.Status.tmp_rf;                             % the current animal that was read. 
            sma = prepare_sma(p);                                          % Prepare next trial's state machine   
            
            if BpodSystem.Status.BeingUsed == 0
                delete(RFID)
                return; 
            end                                                            % If user hit console "stop" button, end session 
            % start trial
            T.startTrial(sma);                                             % run the state machine
                        
            if i>1
                update_graphs(previous_animal_ind, trial_water, trial_fentanyl, tmp.pr_count.water, tmp.pr_count.fentanyl)
                % save data :           
                BpodSystem.Data.water(i-1) = trial_water;
                BpodSystem.Data.fentanyl(i-1) = trial_fentanyl;
                BpodSystem.Data.pr_fentanyl  = tmp.pr_count.fentanyl;
                BpodSystem.Data.pr_water  = tmp.pr_count.water;
                BpodSystem.Data.RFID{i-1} = tmp.RFID;
                BpodSystem.Data.settings{i-1} = tmp.subject_settings; 
                SaveBpodSessionData;
            end 
             
           RawEvents = T.getTrialData;                                     % Hangs here until trial end, then returns the trial's raw data
    end
    

end 


function subject_settings = load_settings(tag, settings)
% This function may be redundant in this experiment, but I preferred to
% keep a unified protocol activation path. 

    global BpodSystem
    animal_ind = strcmp(settings.tags, tag);
    if all(~animal_ind)
        settings_name = 'template';
    else
        settings_name = settings.settings{animal_ind};
    end 
    subject_settings = load([BpodSystem.Path.settings_path, '\', settings_name]);
    tmp = fields(subject_settings);
    subject_settings = subject_settings.(tmp{1});
    
    
end 

function p = define_trial(S) 
    % function DEFINE_TRIAL defins the trial parameters - in this case only
    % the reward amount
    global BpodSystem
    p.ValveTime = GetValveTimes(S.RewardAmount, [1,2] ); 
    p.reward = S.RewardAmount;
    p.subject_settings = S;
    p.light1 = S.light1;
    p.light2 = S.light2;
    
end 
 

function sma = prepare_sma(p)
% function PREPARE_SMA creates a single trial of a state machine fo be run.

sma = NewStateMatrix();
    sma = SetGlobalCounter(sma, 1, 'Port1In',  p.pr_count.water);           % Counter for water pokes
    sma = SetGlobalCounter(sma, 2, 'Port2In',  p.pr_count.fentanyl);        % Counter for fentanyl pokes
   
    
        sma = AddState(sma, 'Name', 'Wait_for_poke', ...
        'Timer', 3,...
        'StateChangeConditions', {'Port1In','Report_poke_1','Port2In','Report_poke_2', 'Tup', 'ReadRF'},...
        'OutputActions',  {});
    
    sma = AddState(sma, 'Name', 'Report_poke_1', ...
        'Timer', 0.01,...
        'StateChangeConditions', {'GlobalCounter1_End','Reward1','Tup', 'Wait_for_poke'},...
        'OutputActions',  {'GlobalCounterReset', 2});
    
   sma = AddState(sma, 'Name', 'Report_poke_2', ...
        'Timer', 0.01,...
        'StateChangeConditions', {'GlobalCounter2_End','Reward2', 'Tup', 'Wait_for_poke'},...
        'OutputActions',  {'GlobalCounterReset', 1});
        
    sma = AddState(sma, 'Name', 'Reward1', ...
        'Timer', p.ValveTime(1),...
        'StateChangeConditions', {'Tup', 'Drinking1'},...
        'OutputActions', {'ValveState', 1, 'GlobalCounterReset', 1 , 'PWM1', p.light1});
    
    sma = AddState(sma, 'Name', 'Reward2', ...
        'Timer', p.ValveTime(2),...
        'StateChangeConditions', {'Tup', 'Drinking2'},...
        'OutputActions', {'ValveState', 2, 'GlobalCounterReset', 2,  'PWM2' p.light2});
  
    sma = AddState(sma, 'Name', 'Drinking1', ...
        'Timer', 0.3,...
        'StateChangeConditions', {'Tup','ReadRF'},...
        'OutputActions', {'PWM1', p.light1}); 
    
    sma = AddState(sma, 'Name', 'Drinking2', ...
        'Timer', 0.3,...
        'StateChangeConditions', {'Tup','ReadRF'},...
        'OutputActions', {'PWM2' p.light2});
     
    sma = AddState(sma, 'Name', 'ReadRF', ...
        'Timer', 0,...
        'StateChangeConditions', {'SoftCode1', 'exit'},...
        'OutputActions', {'SoftCode', 2});

end 


function update_graphs(animal_ind, trial_water, trial_fentanyl, ~, ~)

    global BpodSystem
    % update water:
    BpodSystem.GUIData.bar.water(animal_ind) = ...
        BpodSystem.GUIData.bar.water(animal_ind) + trial_water;
    set(BpodSystem.GUIHandles.water_bar, 'ydata', ...
        BpodSystem.GUIData.bar.water);
    
    % update fentanyl
   BpodSystem.GUIData.bar.fentanyl(animal_ind) = ...
       BpodSystem.GUIData.bar.fentanyl(animal_ind) + trial_fentanyl; 
   set(BpodSystem.GUIHandles.fentanyl_bar, 'ydata', ...
        BpodSystem.GUIData.bar.fentanyl);

    drawnow();
end 