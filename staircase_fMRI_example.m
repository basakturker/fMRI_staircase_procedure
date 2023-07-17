%% Paths
path = fileparts( pwd ); % get upper dir

path_stimlist  = fullfile(path, 'stim_lists');
path_results   = fullfile(path, 'results'   );
path_scripts   = fullfile(path, 'scripts'   );
path_stimuli   = fullfile(path, 'stimuli'   );
path_threshold = fullfile(path, 'threshold' );

%% Load stimuli and stimlist
load(sprintf('%s/stim_staircase.mat',path_stimuli),'stimuli');
stim_list = readtable(sprintf('%s/stimlist_staircase.txt',path_stimlist));
stim_list.volume = zeros(300,1);
stim_list.IsDetected = zeros(300,1);
stim_list.RT = zeros(300,1);
stim_list.audioVolumes = zeros(300,1);
stim_list.IsPresented = zeros(300,1);

%% Setup experiment
prompt="What is the subject number?";
subject_number=input(prompt);

KbName('UnifyKeyNames');
Response_key="b"; %%Change according to CENIR's keypad

% staircase parameters
stepsize=0.1; % intial step size
audio_volume=.5;  %starting point of staircase
audioVolumes=zeros(300,1);
audioVolumes(1)=audio_volume;

InitializePsychSound(1);
freq=48000;
pahandle = PsychPortAudio('Open', [], [], 0, freq, 2 );
%pahandle2 = PsychPortAudio('Open', [], [], 0, freq, 2 );
PsychPortAudio('Volume', pahandle, audio_volume);
%PsychPortAudio('Volume', pahandle2, audio_volume);

%% Staircase
fprintf('\n Everything is set! Press space to start the experiment.\n');
while true
    [keyIsDown,secs, KeyCode] = KbCheck;
    if keyIsDown
        if KbName(KeyCode)=="space"
        break
        end
    end
end

%noise = [background{1} background{1}];
%PsychPortAudio('FillBuffer', pahandle2, noise');
%PsychPortAudio('Start', pahandle2,1,0);

fprintf('\n Waiting for the scanner to start.\n');
PreviousResp=cell(1,1);
trial=0;
volume = 0; 
changed=0;

while volume<5 % wait for the scanner equilibrium ~5 scans  
        [keyIsDown,secs, KeyCode] = KbCheck;
        CurrentResp = KbName(KeyCode);
        if keyIsDown 
            if ismember('t',cellstr(KbName(KeyCode))) && ~ismember('t',PreviousResp)       
            volume=volume+1;
            end
        end
        
        if isempty(CurrentResp)
            PreviousResp={};   
        else
            PreviousResp=CurrentResp;
        end
end
    
disp('Starting');


stimtime=GetSecs;

    while true
        
       [keyIsDown,reaction,keyCode] = KbCheck; 
       CurrentResp = KbName(keyCode);
       
       if keyIsDown
            if ismember('t',cellstr(KbName(keyCode))) &&  ~ismember('t',PreviousResp)   
                volume=volume+1;
            end
            
            if (ismember('b',cellstr(KbName(keyCode)))) &&  ~ismember('b',PreviousResp) && (trial>0)  &&  (reaction-stimtime<2)  && changed==0         
                disp('detected');
                stim_list.RT(trial)=reaction-stimtime;
                stim_list.IsDetected(trial)=1;
                %stim_list.volume(trial)=volume;
                audio_volume=audio_volume-stepsize;
                PsychPortAudio('Volume', pahandle, audio_volume);
                %PsychPortAudio('Volume', pahandle2, audio_volume);
                changed=1;
            end
             
       end
       
       if isempty(CurrentResp)
        PreviousResp={};   
       else
        PreviousResp=CurrentResp;
       end
       
       if round((GetSecs-stimtime),3) > 2.5 && changed == 0 && trial>0
            audio_volume=audio_volume+stepsize;
            PsychPortAudio('Volume', pahandle, audio_volume);
            %PsychPortAudio('Volume', pahandle2, audio_volume);
            disp('nope')
            changed=1;   
       end
       
       % Change the step size as the procedure progresses
       if trial ==3
           stepsize=0.05;
       elseif trial == 10 
           stepsize=0.02;
       elseif trial == 22 
           stepsize=0.01;
       end
    
       if trial > 40 && stim_list.audioVolumes(trial)==stim_list.audioVolumes(trial-2) && stim_list.audioVolumes(trial-1)==stim_list.audioVolumes(trial-3)
            break
       end

            
       if round((GetSecs-stimtime),3) > stim_list.ISI(trial+1)
            trial=trial+1; 
            PsychPortAudio('FillBuffer', pahandle, stimuli.SNR09{1}');
            stimtime=GetSecs;
            PsychPortAudio('Start', pahandle,1,0);
            stim_list.volume(trial)=volume;
            fprintf('trial: %d, threshold: %02f\n',trial,audio_volume);
            stim_list.audioVolumes(trial)=audio_volume;
            stim_list.IsPresented(trial)=1;

            changed=0;
       end

    end
    
%PsychPortAudio('Stop', pahandle2,0,1);
PsychPortAudio('Close'); %close audiobuffer          
audio_volume=stim_list.audioVolumes(trial);
average_threshold=mean(stim_list.audioVolumes(trial-5:trial));
fprintf('final threshold is %02f\n', audio_volume);
fprintf('average threshold is %02f\n',average_threshold);
save(sprintf('%s/staircase_subject_%02d',path_threshold,subject_number),'audio_volume','stim_list','average_threshold')

