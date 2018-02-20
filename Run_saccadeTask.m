% RUN_SACCADETASK Draws and presents stimuli for an Anti- and pro-saccade task
%
% A program to collect eye movements using an Arrington eyetracker
% while a participant completes an antisaccade task presented using stimuli
% created in PsychToolbox.
 
% Charlotte Joy Waikauri Connell
% Exercise Metabolism Lab, Dept. Sport and Exercise Science
% The University of Auckland, New Zealand
% c.connell@auckland.ac.nz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code presents a saccade task with gap and overlap conditions. It
% uses psychtoolbox to present a central fixation point and peripheral dots
% under 4 diffferent conditions:
%   - Gap Right: where the fixation point appears, it is then extinguished for a
%   period of time, following this temporal 'gap', a peripheral stimulus
%   appears on the right side of the screen
%
%   - Gap Left: same as above but peripheral stimulus appears on the left
%
%   - Overlap Right: in this condition the fixation dot appears, and then remains
%   onscreen when a peripheral stimulus appears on the right of the screen
%
%   - Overlap Left: same as above but the peripheral stimulus appears on the
%   left while the fixation dot remains visible.
%
% Prosaccade vs Antisaccade Tasks
% For pro- and antisaccade tasks the stimuli is exactly the same. The only
% thing that differs between the two is the instructions the participant is
% given. For the antisaccade task the participant is instructed to "look at the
% target while it is in the central position and when a peripheral target
% appears make an eye movement to a position that is opposite to that
% peripheral target in both direction an size". In the prosaccade task the
% participant is instructed to "look at the target while it is in the
% central position and when a peripheral target appears make an eye
% movement to that peripheral target as quickly as possible".
% 
%
% In this script Gap and Overlap conditions are randomised. 
% Fixation, gap and interstimulus times can be edited by changing the 
% parameters. Enter the unique characteristics of your setup in the 
% parameters section to ensure that the stimuli subtend the appropriate 
% visual angle (eg screen width, viewing distance etc).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all
clear all

% usual psychtoolbox stuff
AssertOpenGL;
warning off

Screen('Preference', 'SkipSyncTests', 1);

oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);

%--------------------------------------------------------------------------
% Defining the location data will be stored
%--------------------------------------------------------------------------

data_directory = 'C:\Users\fMRI Eyetracker\Desktop\Visual_Test_Battery\Charlotte_Saccade\Prosaccade Task\Data';
Date_and_time = fix(clock);

%--------------------------------------------------------------------------
%Eyetracker settings
%--------------------------------------------------------------------------

vpx_Initialize;
vpx_SendCommandString ('binocular_mode On');
vpx_SendCommandString ('calibration_eyeTarget both');
vpx_SendCommandString('calibrationStart');

%--------------------------------------------------------------------------
% Set up the desired parameters : for an explanation of why the particular
% fixation, gap and overlap intervals were chosen please refer to the
% Fischer, Dafoe and Dyckman (1997) literature located in the folder.
%--------------------------------------------------------------------------
  
    params.fixation_duration_gap = 0.8;     % duration of fixation in gap condition (seconds)
    params.fixation_duration_overlap = 1;   % duration of fixation in overlap condition (seconds)   
    params.stimulus_duration = 1;           % duration of stimulus image in seconds
    params.gapduration = 0.2;               % duration of 'gap' in seconds
    params.ISI_duration = 1;                % duration of interstimulus interval in seconds.
    params.mon_width   = 35.5;              % horizontal dimension of viewable screen (cm)
    params.v_dist      = 66;                % viewing distance (cm)
    params.numberOfRepeats = 25;             % number of times each stimulus is shown (4 stimuli therefore 25 repeats = 100 trials)
    display = 1;                            % set to 1 to show on an external monitor or 2 to show on primary monitor
    params.fix_r = 0.25;                    % radius of fixation point (deg)
    params.saccade_amp = 10;                % visual angle subtended between central fixation point and peripheral stimulus
    
    %set up response keys
    
    KbName('UnifyKeyNames');
    
    params.start_key = KbName('Space');
    params.esc_key = KbName('ESCAPE');

 try
    while 1
        
        reenter = 1;
%--------------------------------------------------------------------------    
%Setting up matlab and eyetracker filenames
%--------------------------------------------------------------------------

    params.sub_name = input ('Please enter subject ID   ','s'); %get participant name
    filename = strcat (data_directory, '\', params.sub_name, '_saccade.mat'); %matlab file name
    filename_eyeT = strcat (params.sub_name, '_saccade_eyeT.wks');
    
    %Check to see if the given filename will overwrite an existing file and
    %provide the option to continue or re-enter a new filename
    
       if exist(filename)
            
            while 1
                reenter = input('WARNING: This filename already exists. Press 1 to overwrite, 2 to re-enter  ');
                if reenter == 1
                    break
                end
                
                if reenter == 2
                    break
                end
                
            end
            
        end
        
        if reenter == 1
            break
        end
   end
   
%--------------------------------------------------------------------------
%set up the screen
%--------------------------------------------------------------------------
    
    params.doublebuffer = 1;
    params.screens = Screen('Screens');
    
    if display == 1
        
        params.screenNumber = max(params.screens);
        
    elseif display == 2
        
        params.screenNumber = min(params.screens);
        
    end
    
    [params.w, params.rect] = Screen('OpenWindow', params.screenNumber, 0,[], 32, params.doublebuffer+1);
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of smoothed points:
    Screen('BlendFunction', params.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    params.fps = Screen('FrameRate',params.w);      % frames per second
    params.ifi = Screen('GetFlipInterval', params.w);
    if params.fps==0
       params.fps = 1/params.ifi;
    end;
    
    params.black = BlackIndex(params.w);
    params.white = WhiteIndex(params.w);
    params.gray =((params.white+params.black)/2)+65;
    
    if round(params.gray)==params.white
        params.gray=params.black;
    end
    
%--------------------------------------------------------------------------
%Creating fixation and stimuli dots
%--------------------------------------------------------------------------
    
    params.inc = params.white-params.gray;
    params.ppd = pi * (params.rect(3)-params.rect(1)) / atan(params.mon_width/params.v_dist/2) / 360;    
    [params.center(1), params.center(2)] = RectCenter(params.rect);
    params.fix_cord = [params.center-params.fix_r*params.ppd params.center+params.fix_r*params.ppd]; 
    
    params.fix_cord(2) = params.fix_cord(2)+2;
    params.fix_cord(4) = params.fix_cord(4)+2;
    
    params.left_dot = [params.fix_cord(1)-params.saccade_amp*params.ppd params.fix_cord(2) params.fix_cord(3)-params.saccade_amp*params.ppd params.fix_cord(4)]; 
    params.right_dot = [params.fix_cord(1)+params.saccade_amp*params.ppd params.fix_cord(2) params.fix_cord(3)+params.saccade_amp*params.ppd params.fix_cord(4)]; 
    
    HideCursor;	% Hide the mouse cursor
    params.Priority = Priority(MaxPriority(params.w));

    
%--------------------------------------------------------------------------
% Set up presentation sequence
%-------------------------------------------------------------------------- 
    % 1 = gap right, 2 = gap left, 3 = overlap right, 4 = overlap left
    sequence = [ones(1,params.numberOfRepeats) ones(1,params.numberOfRepeats)+1 ones(1,params.numberOfRepeats)+2 ones(1,params.numberOfRepeats)+3]; %makes 1 row matrix of 1, 2, 3 and 4's
    sequence = Shuffle (sequence);
    saccadeProSaccade(params);
    fprintf('\n hit space to begin\n')
    
%--------------------------------------------------------------------------    
% check the state of the keyboard
%--------------------------------------------------------------------------

    while 1
        % Check the state of the keyboard.
        [ keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
            resp = find(keyCode);
            if resp == params.start_key
            break;
            end
            
        end
         
    end
    
%--------------------------------------------------------------------------
% Start recording eye movements
%--------------------------------------------------------------------------     

vpx_SendCommandString(['dataFile_NewName ' filename_eyeT '.wks']); 
SessionTimer = GetSecs; %timing info
vpx_SendCommandString('dataFile_InsertMarker A'); %A for start
    
    for i = 1:params.numberOfRepeats*4
    TrialTimer = GetSecs;

%--------------------------------------------------------------------------
%see whether the user wants to quit
%--------------------------------------------------------------------------

       [ keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
            resp = find(keyCode);
            if resp == params.esc_key
                clear screen
            break;
            end
            
        end 

%--------------------------------------------------------------------------
%set up presentation
%--------------------------------------------------------------------------
    
    PreFixTime = GetSecs;
    % Draw and present trial fixation screen
    saccadeFixation (params);
    vpx_SendCommandString('dataFile_InsertMarker L'); %L for look (start of fixation)
    PostFixTime = GetSecs;
    
    % see whether user wants to quit
    [ keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
            resp = find(keyCode);
            if resp == params.esc_key
                clear screen
            break;
            end
            
        end
        
        
        switch sequence (i)
         
            case 1 % Gap right
                WaitSecs (params.fixation_duration_gap);
                
                % Draw and Present Gap

                Screen('FillRect',params.w, params.gray); %Gap
                params.vbl = Screen ('Flip', params.w);

                % Draw and present stimulus
                
                Screen('FillRect',params.w, params.gray);
                Screen ('FillOval', params.w, params.black, params.right_dot);
                WaitSecs (params.gapduration);
                PreStimulusTime = GetSecs;
                params.vbl = Screen ('Flip', params.w);

                
                
            case 2 % Gap Left
                WaitSecs (params.fixation_duration_gap);
                
                Screen('FillRect',params.w, params.gray); %Gap
                params.vbl = Screen ('Flip', params.w);

                % Draw and present stimulus
                
                Screen('FillRect',params.w, params.gray);
                Screen ('FillOval', params.w, params.black, params.left_dot);
                WaitSecs (params.gapduration);
                PreStimulusTime = GetSecs;
                params.vbl = Screen ('Flip', params.w);
               
                
                
            case 3 % Overlap Right
                WaitSecs (params.fixation_duration_overlap);
                
                % Draw and present stimulus
                Screen('FillRect',params.w, params.gray); %Filling the screen with a grey background
                Screen('FillOval', params.w, params.black, params.fix_cord); % Filling a dot for fixation
                Screen ('FillOval', params.w, params.black, params.right_dot);
                PreStimulusTime = GetSecs;
                params.vbl = Screen ('Flip', params.w);

            
            case 4 % Overlap Left
                WaitSecs (params.fixation_duration_overlap);
                
                % Draw and present stimulus
                Screen('FillRect',params.w, params.gray); %Filling the screen with a grey background
                Screen('FillOval', params.w, params.black, params.fix_cord); % Filling a dot for fixation
                Screen ('FillOval', params.w, params.black, params.left_dot);
                PreStimulusTime = GetSecs;
                params.vbl = Screen ('Flip', params.w);


        end
        
        PostStimulusTime = GetSecs;
        vpx_SendCommandString('dataFile_InsertMarker T'); %T for trial
        WaitSecs (params.stimulus_duration);

     
        %see whether user want to quit%
       [ keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
            resp = find(keyCode);
            if resp == params.esc_key
                clear screen
            break;
            end
            
        end 
        
    PreISI = GetSecs;
    % Draw and Present blank screen for interval    
    Screen('FillRect',params.w, params.gray); 
    params.vbl = Screen ('Flip', params.w);


    WaitSecs(params.ISI_duration);
    PostISI = GetSecs;
    vpx_SendCommandString('dataFile_InsertMarker D'); %D for dot


    
    %Save out results of this trial: column 1 is condition (see line 173 for
    %definition), pre fixation from start of experiment, post fixation from start
    %of experiment (i.e. fixation is on screen), pre trial stimulus from
    %start of experiment, post trial stimulus from start of experiment, pre
    %ISI time from start of experiment, post ISI from start of experiment, 
    %pre fixation from start of trial, post fixation from start
    %of trial (i.e. fixation is on screen), pre trial stimulus from
    %start of trial, post trial stimulus from start of trial, pre
    %ISI time from start of trial, post ISI from start of trial, start of
    %trial relative to start of experiment.
    
    Results(i,:) = [sequence(i) PreFixTime-SessionTimer PostFixTime-SessionTimer PreStimulusTime-SessionTimer PostStimulusTime-SessionTimer PreISI-SessionTimer PostISI-SessionTimer ...
        PreFixTime-TrialTimer PostFixTime-TrialTimer PreStimulusTime-TrialTimer PostStimulusTime-TrialTimer PreISI-TrialTimer PostISI-TrialTimer TrialTimer-SessionTimer];
    
    end %%end of for loop showing trials
    
    save(filename);
    vpx_SendCommandString('dataFile_Close');
    clear screen
    vpx_Unload;
catch
    clear screen
    error = lasterror
    error.message
    error.stack
    
    save(filename)
    vpx_SendCommandString('dataFile_Close');
    Priority(0);
    ShowCursor
    vpx_Unload;
    % At the end of your code, it is a good idea to restore the old level.
    Screen('Preference','SuppressAllWarnings',oldEnableFlag);
    Screen('CloseAll');

end 