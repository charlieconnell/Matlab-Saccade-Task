# Matlab-Saccade-Task
This repository contains Matlab scripts and functions that use psychtoolbox to present a visual stimulus to a screen while simultaneously recording saccadic eye movements on an Arrington eyetracker. It provides the option to input a custom participant name and outputs two files:
1. A matlab results file containing information such as the order that the different task conditions were presented in and stimulus timing information. You can define what directory this is saved to in the main script (line 63). 
2. The second file is a .wks file that contains the data recorded by the arrington eye tracker. This will be saved to the data directory located in the arrington eye tracker folders. This file contains tags input by the Run_saccadeTask.m script that signify events within each trial - fixation, stimulus presentation, trial end. This makes its easier to analyse the data later.

- Run_saccadeTask.m : This is the main task script. It has the options to alter the task parameters (dot size, stimulus timing etc.).
- saccadeSaccade.m : Function used by Run_saccadeTask.m. This is used to present a screen with instrcutions on it to remind the participants of the task requirements. At the moment it presents the instructions for both the pro- and antisaccade task. Change this to suit your specific task design.
- saccadeFixation.m : Function used by Run_saccadeTask.m. Draws a simple fixation screen consisting of a black dot on a gray background.

This was designed for a dual screen setup where the participant is sitting at a fixed distance away from the stimulus screen in an eye tracker with a chin rest, while the experimenter starts and observes the task from another screen located in a position that is not distracting for the participant. Some of the psychtoolbox commands may be outdated.
