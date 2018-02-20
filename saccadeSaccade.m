function saccadeSaccade (params)

% Function used by Run_saccadeTask.m
% Draws a simple fixation screen for the saccade task consitisting of a
% central fixation dot. Radius of the dot can be altered in the parameters
% section of the main script. For more information look up the screen
% function in psychtoolbox.

w        = params.w;
gray     = params.gray;
black    = params.black;
text     = 'Prosaccade: Look AT the peripheral target when it appears.';
text1    = 'Antisaccade: Look AWAY from the peripheral target when it appears.';
text2    = 'Move your eyes as accurately and quickly as you can';
centerY  = params.center(2);
x  = 0;
below    = centerY+50;


    Screen('FillRect',w, gray); % Filling the screen with a grey background
    Screen('DrawText', w, text, x, centerY, black, gray);
    Screen('DrawText', w, text1, x, centerY, black, gray);
    Screen('DrawText', w, text2, x, below, black, gray);
    Screen('Flip', w); % Flip the screen to present the fixation