# fMRI_staircase_procedure
Example script for an auditory staircase procedure in the fMRI scanner.

This is a descending staircase procedure. The step size decreases over time for finer tuning. Stimuli (stim_staircase.mat) and a text file (stimlist_staircase.txt) containing the stimulus ID and interstimulus interval for each trial can be found in the repository.

In this example, the volume of stimulus /a/ and a background noise are adjusted according to the participant's response. The 't' key indicates the start of the fMRI volume acquisition. Participants press 'b' when they hear the stimulus /a/. A key press is considered a detection if the response occurred in the 2.5 seconds following stimulus presentation.
