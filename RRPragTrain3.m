%%% Pragmatic training Experiment 3: expanded version of Sedivy et al 1999
%%% with training / fillers that are either reliably using scalar
%%% adjectives or unreliably

clear all
Screen('Preference', 'VisualDebuglevel', 3);%gets rid of graphics check screen
rand('twister',sum(100*clock)) %resets the random number generator.
nums=rand*50;
sran=round(nums);
srand=num2str(sran);

subject= input('Enter Subject Number, e.g. "06".  ', 's');
subnum=str2num(subject);

list= input('Enter List Number(1 or 2):  ', 's');
listnum=str2num(list);

%% assigning conditions and lists
if listnum == 1;
    rel_condition='reliable';
elseif listnum == 2;
    rel_condition='unreliable';
else
    disp('The list number you entered is invalid. Please start over');
end;

if rem(subnum,2)==0
    counterbalancelist =  1;
else
    counterbalancelist = 2;
end;


%% folders and output files
pics_dir = '/Experiments/RRPragTrain3/pictures/'; %The location of the picture files to be used in the experiment
sounds_dir = '/Experiments/RRPragTrain3/audio/finished/'; %The location where the audio files are stored.
edf_folder= '/Experiments/RRPragTrain3/EDFs/';%where ET files will get saved
name_of_file=['/Experiments/RRPragTrain3/output/PrgTrn3S' subject '.csv'];
outputfile=fopen(name_of_file,'a');
fprintf(outputfile,'Subject\ttrialOrder\tcList\ttrialType\ttrialID\tRelCondition\tCondition\tPic1\tPic2\tPic3\tPic4\tTarget\tCompet\tResponseX\tResponseY\tAccuracy\n');

%% Set Screen things
%Screen('Preference','VBLTimestampingMode',-1); %This setting can be turned on if you have video driver problems.

white=[255 255 255];
purple=[255 40 200];
black=[0 0 0];
rect=[0 0 1920 1080];%screen size
green=[34 139 34];
gray=[3 3 3];

textfont = 'Helvetica';
textsize = 100;

%% Initialize Audio
InitializePsychSound;
%freq = 44100; % high frequency for high-quality audio recordings.
numchannels = 1;%1- mono sound; 2- stereo
  
%% Eyetracker Setup

commandwindow;
% AssertOSX;
% try
% if 1 Screen('Preference', 'SkipSyncTests', 0); end %The last # should be "1" for testing mode only.

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if EyelinkInit()~= 1; %
    return;
end;

% STEP 2
% Open a graphics window on the main screen using the PsychToolbox's Screen function.

screenNumber=max(Screen('Screens'));
[window, winsize]=Screen('OpenWindow', screenNumber, 0,[0 0 1920 1080],32,2);%for testing made window smaller than fullscreen- CHANGE BACK BEFORE RUNNING 0 0 1920 800
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% STEP 3
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% % and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(window);
% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a %s tracker.\n', vs );

% open file to record data to
edfFile=sprintf('%s%s%s.edf',subject,'pT3',srand)';
Eyelink('Openfile', edfFile);
Eyelink('message', sprintf('SubjInfo: %s %s %s %s %s %d', 'Pragmatics Training 3 expt, subject# ', subject, 'Cond:', rel_condition, 'cList:', counterbalancelist ) ); %Print info to top of EL file.  

% warning off MATLAB:DeprecatedLogicalAPI
% warning('off','MATLAB:dispatcher:InexactMatch')

%% setting up picture ports
xcenter= winsize(3)/2;
ycenter=winsize(4)/2;
x0=winsize(1)+30;
y0=winsize(2)+20;
x3=winsize(3)-30;
y3=winsize(4)-20;

width=(winsize(3)-x0)/3-40; 
height=width*0.5;%(winsize(4)-40-y0)/3; 

% %ports for placing images
% port1=[x0+20 y0+20 x0+width+20 y0+height+20];% port1
% port2=[x3-width-20 y0+20 x3-20 y0+height+20];%port 3
% port5=[xcenter-width/2 ycenter-height/2 xcenter+width/2 ycenter+height/2];%port5 
% port3=[x0+20 y3-height-20 x0+width+20 y3-20];%port7
% port4=[x3-width-20 y3-height-20 x3-20 y3-20];%port9
% %getting coordinates of centers of ports (this lets me paste different sized textures into same
% %ports
% portwidth=(port1(3)-port1(1))/2; %half width of ports
% portheight=(port1(4)-port1(2))/2;
% p1x=port1(1)+portwidth;
% p1y=port1(2)+portheight;
% p2x=port2(1)+portwidth;
% p2y=port2(2)+portheight;
% p3x=port3(1)+portwidth;
% p3y=port3(2)+portheight;
% p4x=port4(1)+portwidth;
% p4y=port4(2)+portheight;

%ports for determining if click was accurate - use same for all tasks
%(split screen in 4)
big_port1=[winsize(1) winsize(2) xcenter ycenter];
big_port3=[winsize(1) ycenter xcenter winsize(4)];
big_port2=[xcenter y0 winsize(3) ycenter];
big_port4=[xcenter ycenter winsize(3) winsize(4)]; 

%getting coordinates of centers of ports (this lets me paste different sized textures into same
%ports
p1x=xcenter/2;
p1y=ycenter/2;
p2x=xcenter+(winsize(3)-xcenter)/2;
p2y=ycenter/2;
p3x=xcenter/2;
p3y=ycenter+(winsize(4)-ycenter)/2;
p4x=xcenter+(winsize(3)-xcenter)/2;
p4y=ycenter+(winsize(4)-ycenter)/2;

%load grid
grid_pic=[pics_dir,'grid2.jpg'];
grid=imread(grid_pic);
grid_tex=Screen('MakeTexture',window,grid);

% %load fixation cross
% cross_pic=[pics_dir,'cross.jpg'];
% cross=imread(cross_pic);
% cross_tex=Screen('MakeTexture',window,cross);

%reads in TRIAL INFO
if counterbalancelist ==1;
    TrialOrder = 'PragTrain3cL1.txt';
elseif counterbalancelist == 2;
    TrialOrder = 'PragTrain3cL2.txt';
end;
fid = fopen(TrialOrder);
TrialList = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s','HeaderLines',1);
fclose(fid);

%% Calibrate the eye tracker
 EyelinkDoTrackerSetup(el);

%% Instructions 
message{1}='Welcome to the experiment! (press right arrow key to continue)';
message{2}='You will see 4 objects on the screen...'; 
message{3}='You will hear instructions telling you which object to click on.';
message{4}='Just click on the item that best matches what the speaker said.';
message{5}='If you are not sure, just use your best guess.';
message{6}='Please let the experimenter know if you have any questions.';
message{7}='If you have no questions, you may begin! (press right arrow key).';

for i=1:7;
    Screen('TextSize', window, 49);
    [normBoundsRect, offsetBoundsRect]=Screen('TextBounds', window, message{i});%figures out how long the text is going to be.
    l=normBoundsRect(3);
    start=xcenter-(l/2);%creates a x-starting point so the text is centered.
    Screen('DrawText', window, message{i}, start , ycenter, [], [],0);
    Screen('Flip',window, 0); 
     while KbCheck end;
    KbWait;
end;
 
%%determine order of trials for this subject
numTrials=300; %full experiment is 300 ; change if add any trials or want to test with fewer trials

% putting 3 random fillers first and randomizing the rest (filler trials
% are in rows 121 through 300)
fillerIndeces=[121:1:300];
randFillers=fillerIndeces(randperm(180));
firstThree=randFillers(1:3);
remainingTrials=setdiff([1:1:300],firstThree);
randomOrder=randperm(length(remainingTrials));

%the full order for this subject
trialOrder=[firstThree,remainingTrials(randomOrder)];

%% Begin TRIAL LOOP
for p=1:numTrials;
    pstr=num2str(p);
    index = trialOrder(p);%selects a random row in the trial list matrix

    %drift corrects before every fifth trial.
    if rem(p,5)==0;
        EyelinkDoDriftCorrection(el);
    end;
    
    %clears screen for new trial
    Screen('Flip', window,0);
    WaitSecs(1);
    
    trialNum=TrialList{1}{index};
    cList=TrialList{2}{index}; 
    trialType=TrialList{3}{index}; %test, train, filler
    trialID=TrialList{4}{index};
    cond=TrialList{5}{index}; %contrast vs. no contrast, etc
    audio_file=TrialList{6}{index};
    target=TrialList{7}{index};
    if strcmp(rel_condition,'reliable')
        targ_contrast=TrialList{8}{index};
    else
        targ_contrast=TrialList{9}{index};
    end
    big_filler=TrialList{10}{index};
    small_filler=TrialList{11}{index};
    
    
    allPics={target,targ_contrast,big_filler,small_filler};
    ScreenInfo={'target','targ_contrast','big_filler','small_filler'};
    
    [audiofortrial freq] = wavread([sounds_dir,'/', audio_file]); 
    numchannels = size(audiofortrial,2);
    audiochannel = PsychPortAudio('Open', [], 1, 1, freq, numchannels, 120);    
    PsychPortAudio('FillBuffer', audiochannel, audiofortrial');

    [pic1 m1 alphapic1] =imread([pics_dir,target]);
    [pic2 m2 alphapic2]=imread([pics_dir,targ_contrast]);
    [pic3 m2 alphapic3] =imread([pics_dir,big_filler]);
    [pic4 m3 alphapic4]=imread([pics_dir,small_filler]);
    
    [image1H, image1W, dim1]=size(pic1);
    [image2H, image2W, dim2]=size(pic2);
    [image3H, image3W, dim3]=size(pic3);
    [image4H, image4W, dim4]=size(pic4);
   
    tex1=Screen('MakeTexture',window,pic1);%target texture
    tex2=Screen('MakeTexture',window,pic2);
    tex3=Screen('MakeTexture',window,pic3);
    tex4=Screen('MakeTexture',window,pic4);
    
    %%randomizing location of pictures on screen
    pictureOrder=randperm(4); 
    shuffledPics=allPics(pictureOrder);
    shuffledScreenInfo=ScreenInfo(pictureOrder);
    
    listOfTextures={'tex1','tex2', 'tex3', 'tex4'};
    shrink=1;
    listOfHeights={image1H*shrink,image2H*shrink,image3H*shrink,image4H*shrink};
    listOfWidths={image1W*shrink,image2W*shrink,image3W*shrink,image4W*shrink};
    
    shuffledListOfTex=listOfTextures(pictureOrder);
    shuffledHeights=listOfHeights(pictureOrder);
    shuffledWidths=listOfWidths(pictureOrder);
    
    targetIndex=find(strcmp(shuffledListOfTex,'tex1'));
    competitorIndex=find(strcmp(shuffledListOfTex,'tex2'));
    
    
    Screen('DrawTexture', window,grid_tex,[],winsize);
    Screen('DrawTexture', window,eval(shuffledListOfTex{1}),[],[p1x-shuffledWidths{1}/2 p1y-shuffledHeights{1}/2 p1x+shuffledWidths{1}/2 p1y+shuffledHeights{1}/2]);
    Screen('DrawTexture', window,eval(shuffledListOfTex{2}),[],[p2x-shuffledWidths{2}/2 p1y-shuffledHeights{2}/2 p2x+shuffledWidths{2}/2 p2y+shuffledHeights{2}/2]);
    %Screen('DrawTexture', window,cross_tex,[],port5);
    Screen('DrawTexture', window,eval(shuffledListOfTex{3}),[],[p3x-shuffledWidths{3}/2 p3y-shuffledHeights{3}/2 p3x+shuffledWidths{3}/2 p3y+shuffledHeights{3}/2]);
    Screen('DrawTexture', window,eval(shuffledListOfTex{4}),[],[p4x-shuffledWidths{4}/2 p4y-shuffledHeights{4}/2 p4x+shuffledWidths{4}/2 p4y+shuffledHeights{4}/2]);
   
    Screen('Flip', window,[],1);
    
    targport=['port',num2str(targetIndex)];
    targetport=eval(['big_',targport]);
    compport=['port',num2str(competitorIndex)];
   % competport=eval(['big_',compport]);
    
    %preview time
    WaitSecs(1);
    
    %% start recording eye position
    Eyelink('startrecording');
    eye_used = -1;    
    
    %% START PLAYING AUDIO with fast latency
     PsychPortAudio('Start',audiochannel,[],[],1); % this actually STARTS the audio recording
%     audiostatus2=PsychPortAudio('GetStatus',audiochannel);%to check if working
    
    %% send messages to eyelink
    %sends condition info to Eyetracker. The screen line needs to go "port,picture;port,picture...".
    %The .asc conversion has a limit on how long this line can be.
    Eyelink('message', sprintf('Screen: %s,%s;%s,%s;%s,%s;%s,%s','1',shuffledScreenInfo{1},'2',shuffledScreenInfo{2},'3',shuffledScreenInfo{3},'4',shuffledScreenInfo{4}));
    Eyelink('message', sprintf('Stimuli: %s,%s,%s,%s,%s',pstr,cList,trialID,rel_condition,cond) );%gives condition and other info for each trial
    %time_of_stim_message=GetSecs;
    
    %% wait for mouse click to END TRIAL
     [clicks,x,y,whichButton] = GetClicks(window,0); 

     PsychPortAudio('Stop',audiochannel); % stop the audio channel
     
     %categorize whether the subject clicked on the target or not
     if x>=targetport(1) & x<=targetport(3) & y>=targetport(2) & y<=targetport(4);
         accuracy='correct';
     else
         accuracy='error';
     end;
 
     fprintf(outputfile,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\t%d\t%s\n',...
     subject,pstr,cList,trialType,trialID,rel_condition,cond,shuffledPics{1},...
     shuffledPics{2},shuffledPics{3},shuffledPics{4},targport,compport,x,y,accuracy);
    
Screen('Close',[tex1, tex2, tex3,tex4]);                    
                
end;%end trial loop  
    
Eyelink('stoprecording');

%display final message
 Screen('Flip', window,0);
% WaitSecs(0.5);
message2='You have completed the experiment! Thank you! ';
Screen('TextSize', window, 49);
[normBoundsRect, offsetBoundsRect]=Screen('TextBounds', window, message2);%figures out how long the text is going to be.
l=normBoundsRect(3);
start=xcenter-(l/2);%creates a x-starting point so the text is centered.
Screen('DrawText', window, message2, start , ycenter, [], [],0);
Screen('Flip',window, [],1); 

%saves EDF files to subject MAC and eyelink PC
status=Eyelink('closefile');
if status ~=0
    disp(sprintf('closefile error, status: %d',status))
end
status2=Eyelink('ReceiveFile',edfFile,edf_folder,1);
if status2~=0 
    fprintf('problem: ReceiveFile status: %d\n', status2)
end
if 2==exist(['EDFs/',edfFile'], 'file')
    fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile', edf_folder )
else
    disp('unknown where data file went');
end

%close Eyelink connection
Eyelink('shutdown');
  
fclose all;

%close audio port
PsychPortAudio('Close', audiochannel);

Screen('CloseAll');