function FR

% function FR runs an experiment for fentanyl self administration.
% it is meant to be run through Bpod console, and incorporate the use of
% sending and recieving soft codes. 
% IMPORTANT - CONNECT WATER TO PORT 1 AND FENTANYL TO PORT 2!!!!
% IMPORTANT - Check RFID COM!!!! (Line 38)
  
    
  
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
        disp ('wrong settings path !')
    end
    
    if isempty(fieldnames(settings))            % If settings file was an empty struct, populate struct with default settings
            S.RewardAmount = 10;                % ul
            S.fentanyl_pokes = 1;               % the FR schedule of reinforcement for fentanl / port 2
            S.water_pokes = 1;                  % the FR schedule of reinforcement for water / port 1
            S.light1 = 0; S.light2 = 255;           % light intensity on the port LED could be any number between 0-255
                                  
    end
   
    BpodSystem.SoftCodeHandlerFunction = 'read_rf';
    
    % initiations :
    global RFID
    RFID = serial('COM7');
        
    BpodSystem.Data = struct;             
    BpodSystem.Data.TESTER_RFID = '00782B1799DD';  % It is advised to dedicate an RFID tag for manual testing of the system 
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
            
            
  %% The main loop   
    
    n_trials = 100000;
    T = TrialManagerObject;
    T.Timer.Period = 0.2; %cpild be much lower (0.001)
    p = struct;
    BpodSystem.Status.tmp_rf = BpodSystem.Data.TESTER_RFID;                % Start a dummy trial with the tester RFID and template settings                                      
    
    for i = 1:n_trials
            disp(datetime('now'));                                         % serves as validation that the experiment is running
            subject_settings = load_settings(BpodSystem.Status.tmp_rf, settings);
            tmp = p;                                                       % store previous trial parameters in tmp before re-initializing p
            p = define_trial(subject_settings);                            % collect individual settings into state machine variables
            sma = prepare_sma(p);                                          % Prepare next trial's state machine   
            p.RFID = BpodSystem.Status.tmp_rf;                             % the current animal that was read. 
            if BpodSystem.Status.BeingUsed == 0                            % If user hit console "stop" button, end session
                delete(RFID)
                return; 
            end                                                             
            T.startTrial(sma);                                             % run the state machine
            
            %%%  inside the state machine: sent a soft code to start read_rf 
            % function when a tag was read matlab sends a soft code to end 
            % the current trial so a new trial can be initiated. 
            
            if i > 1
                BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes previous trial events from raw data
                
                % update online graphics :
                animal_ind = strcmp(settings.tags, tmp.RFID);
                if all(~animal_ind)                                          % if there is n unrecognized read mark it as the tester
                    animal_ind(length(animal_ind)) = 1;
                end 
                trial_water = 0;
                trial_fentanyl = 0;
                trial_pokes_water = 0;
                trial_pokes_fentanyl = 0;
                
                if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward1 (1))
                    trial_pokes_water = size(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward1,1);
                    trial_water = tmp.reward * trial_pokes_water;
                end 
                if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward2 (1))
                    trial_pokes_fentanyl = size(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward2,1);
                    trial_fentanyl = tmp.reward * trial_pokes_fentanyl;
                end 
                update_graphs(animal_ind, trial_water, trial_fentanyl)
              
                % save data :           
                BpodSystem.Data.water(i-1) = trial_water;
                BpodSystem.Data.pokes_water(i-1) = trial_pokes_water;
                BpodSystem.Data.fentanyl(i-1) = trial_fentanyl;
                BpodSystem.Data.pokes_fentanyl(i-1) = trial_pokes_fentanyl;
               
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
    % function DEFINE_TRIAL defins the trial parameters 
    p.fentanyl_pokes = S.fentanyl_pokes;
    p.water_pokes = S.water_pokes;
    p.ValveTime = GetValveTimes(S.RewardAmount, [1,2] ); 
    p.reward = S.RewardAmount;
    p.subject_settings = S;
    p.light1 = S.light1;
    p.light2 = S.light2;
end 
 

function sma = prepare_sma(p)
% function PREPARE_SMA creates a single trial of a state machine fo be run.
% the input is the cue action (aud or aud+vis), and the claoud laser action
% (+ / - cloud +/ - laser). both are stated as state machine actions. 
    
    sma = NewStateMatrix();
    sma = SetGlobalCounter(sma, 1, 'Port1In', p.water_pokes);              % Counter for water pokes
    sma = SetGlobalCounter(sma, 2, 'Port2In', p.fentanyl_pokes); % Counter for fentanyl pokes;
    
    
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
        'OutputActions', {'ValveState', 1,  'PWM1', p.light1});
    
    sma = AddState(sma, 'Name', 'Reward2', ...
        'Timer', p.ValveTime(2),...
        'StateChangeConditions', {'Tup', 'Drinking2'},...
        'OutputActions', {'ValveState', 2, 'PWM2' p.light2});
  
    sma = AddState(sma, 'Name', 'Drinking1', ...
        'Timer', 0.3,...
        'StateChangeConditions', {'Tup','CounterReset1'},...
        'OutputActions', {'PWM1', p.light1}); 
    
    sma = AddState(sma, 'Name', 'CounterReset1', ...
        'Timer', 0.0001,...
        'StateChangeConditions', {'Tup','Wait_for_poke'},...
        'OutputActions', {'GlobalCounterReset', 1}); 
    
    sma = AddState(sma, 'Name', 'Drinking2', ...
        'Timer', 0.3,...
        'StateChangeConditions', {'Tup','CounterReset2'},...
        'OutputActions', {'PWM2' p.light2});
    
    sma = AddState(sma, 'Name', 'CounterReset2', ...
        'Timer', 0.0001,...
        'StateChangeConditions', {'Tup','Wait_for_poke'},...
        'OutputActions', {'GlobalCounterReset', 2}); 
     
    sma = AddState(sma, 'Name', 'ReadRF', ...
        'Timer', 0,...
        'StateChangeConditions', {'SoftCode1', 'exit'},...
        'OutputActions', {'SoftCode', 2});

end 


function update_graphs(animal_ind, trial_water, trial_fentanyl)

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