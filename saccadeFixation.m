function saccadeFixation (params)

% Function used by Run_saccadeTask.m
% Draws a simple fixation screen for the saccade task consitisting of a
% central fixation dot. Radius of the dot can be altered in the parameters
% section of the main script. For more information look up the screen
% function in psychtoolbox.

w        = params.w;
gray     = params.gray;
black    = params.black;
fix_cord = params.fix_cord;

    Screen('FillRect',w, gray); % Filling the screen with a grey background
    Screen('FillOval', w, black, fix_cord); % Filling a dot for fixation
    Screen('Flip', w); % Flip the screen to present the fixation