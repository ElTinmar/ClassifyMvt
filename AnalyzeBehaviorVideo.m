clear all; close all; clc

% initialize pseudo-random number generator to always get same sequence
rng();

%% STEP 0 : Get movie and timestasmp files 
%--------------------------------------------------------------------------

[file, path] = uigetfile('*.avi','Select movie file');
movieFile = fullfile(path,file);
[file, path] = uigetfile('*.txt','Select timestamps file');
timestampsFile = fullfile(path,file);

[framenum, timestamps] = readvars(timestampsFile);

%% STEP 1 : Backround extraction
%--------------------------------------------------------------------------

mov = VideoReader(movieFile);

% WARNING this takes a long time (has to go through the whole video)
numFrames = mov.NumFrames; 

height = mov.Height;
width = mov.Width;

method = 0;
% 0: very slow but should be more reliable
% 1: fast and dirty, but may work as well

if method == 0
    % WARNING: random access to frames in h264 encoded video is very slow
    % tune samplingPeriodAvg to not get too many frames and store video
    % on a SSD
    
    % get equally spaced frame samples from the whole recording
    numSamplesAvg = 100; 
    indAvg = round(linspace(1,numFrames-1,numSamplesAvg));

elseif method == 1
    % alternatively, don't do the average but use only the first frame
    numSamplesAvg = 1;
    indAvg = 1;

end

avgImg = zeros(height,width,'single');
current_frame = 0;
for i=1:numel(indAvg)
    i
    % NOTE
    % using mov.read(index) starts at the beginning of video each time
    % using mov.readFrame() like bellow allows to read sequentially (faster)
    while (current_frame ~= indAvg(i))
        img = mov.readFrame();
        current_frame = current_frame+1;
    end
    imgGrayScaled = im2single(img(:,:,1));
    avgImg = avgImg+imgGrayScaled/numSamplesAvg;
end

% select the outlines of the larva to remove it from the picture of the
% background
f = figure
bckg = roifill(avgImg);
close(f)

% select start and end of the tail
f = figure
imshow(avgImg)
[x,y] = ginput(2);
xOrigin = x(1);
yOrigin = y(1);
Len = sqrt((x(2)-x(1))^2+(y(2)-y(1))^2);
close(f)

% test threshold values
threshBW = 0.025; % pixel intensity cutoff
threshSize = 400; % min size of the object (surface) in pixels
gamma = 1.5; % non linearity, improve contrast
sigmaXY = 5; % size of gaussian filter in pixels
radius = 10; % typical size (pixels) used for closing gaps in the tail

% check that the tail os properly extracted at different times in the
% video, update thresholds if necessary
N = 100;

if method == 0
    % read random image WARNING SLOW
    % sort images to read sequentially (faster)
    ids = sort(randi(numFrames,N,1));

elseif method == 1
    % read random image at the beginning of the video
    % WARNING: may not be representative if lighting conditions
    % change accross the video
    ids = sort(randi([2 1000],N,1));
end

mov = VideoReader(movieFile); % rewind at the beginning of the movie
h=fspecial('gaussian',sigmaXY,sigmaXY);
se = strel('disk',radius,0);
f = figure;
current_frame = 0;
for i = 1:numel(ids)

    % read image
    while (current_frame ~= ids(i))
        img = mov.readFrame();
        current_frame = current_frame+1;
    end
    imgGrayScaled = im2single(img(:,:,1));  

    % remove background abd apply an exponent
    noback = (abs(imgGrayScaled-bckg)).^gamma;

    % spatial gaussian filer to smooth the image
    noback = imfilter(noback,h,'replicate');

    % binarize and keep only big blobs
    BW = (noback>threshBW);
    BW = bwareaopen(BW,threshSize);
    
    % close gaps in the tail (image dilation + erosion)
    BW = imclose(BW,se);

    % plot the result
    subplot(2,1,1);
    imagesc(noback);
    axis image
    subplot(2,1,2);
    imagesc(BW);
    axis image
    pause
end
close(f)


%% STEP 2 : Compute curvature
%--------------------------------------------------------------------------

Curv=nan(1,numFrames);
Ang=nan(1,numFrames);
Area=nan(1,numFrames);
perc_disp = 5; % display progression each X percent

mov = VideoReader(movieFile); % rewind at the beginning of the movie
current_frame = 0;
while mov.hasFrame()

    img = mov.readFrame();
    current_frame = current_frame+1;

    % display progression
    if (mod(current_frame,round(numFrames*perc_disp/100))==0)
        disp([num2str(round(100*current_frame/numFrames)) ' %'])
    end
    
    imgGrayScaled = im2single(img(:,:,1));  

    % remove background abd apply an exponent
    noback = (abs(imgGrayScaled-bckg)).^gamma;

    % spatial gaussian filer to smooth the image
    noback = imfilter(noback,h,'replicate');

    % binarize and keep only big blobs
    BW = (noback>threshBW);
    BW = bwareaopen(BW,threshSize);
    
    % close gaps in the tail (image dilation + erosion)
    BW = imclose(BW,se);

    Area(current_frame) = sum(BW(:));
    [Curv(current_frame),Ang(current_frame)] = Curvature(BW,...
                                                        xOrigin,...
                                                        yOrigin,...
                                                        0,... % plot flag
                                                        imgGrayScaled,...
                                                        4);
end

TailOri=Curv*Len;

%% STEP 3 : Extract tail bouts
% -------------------------------------------------------------------------
Thresh = 0.05; %0.7
InterMvt = 20;
Durmin = 0; %5*5ms=0.0025s
DurationMvt = 50; % 50*5ms=0.250s
FusionMvt = 20; % 20*5ms=200ms
MinStrength = 0.04; %0.06
PlotFlag = 1;

[A,...
TailMvt,...
IndOnsetMvt,...
IndOffsetMvt,...
TimeCam,...
Tail,...
NumberOfMvt,...
ActivityTail,...
ActivityTailFinal] = ProcessTailMvtSPIM(TailOri,...
                                        timestamps,...
                                        Thresh,...
                                        DurationMvt,...
                                        FusionMvt,...
                                        MinStrength,...
                                        PlotFlag,...
                                        Durmin);


%% STEP 4 : Classify movements
% -------------------------------------------------------------------------

load('LabeledMvt.mat')
kNN = 10;
exp = 1.5;

Membership = nan(5,size(TailMvt,1));
Bias = nan(1,size(TailMvt,1));
Outlier = nan(1,size(TailMvt,1));
for i=1:size(TailMvt,1)
    [m,b,o] = ClassifyMvtkNN(TailMvt(i,:),LabeledMvt,kNN,exp);
    Membership(:,i) = m;
    Bias(i) = b;
    Outlier(i) = o;
end

% Find Category of Tail Mvt (1: Scoot, 2: JTurn, 3: Routine Turn, 4: C Bend, 5: Burst):
[~,Cat] = max(Membership);
[NbCat,~] = hist(Cat,[1,2,3,4,5]);

% Display Mvt for each category:
for c=1:5
    figure(c);
    set(gcf,'WindowStyle','docked');
    id=find(Cat==c);
    plot(TailMvt(id,:)');
end

%% STEP 5 : Save
%--------------------------------------------------------------------------
clear Mvt

Mvt.timestamps = timestamps;
Mvt.Tail = Tail;
Mvt.IndOnset = IndOnsetMvt;
Mvt.IndOffset = IndOffsetMvt;
Mvt.TailMvt = TailMvt;
Mvt.Cat = Cat;
Mvt.Membership = Membership;
Mvt.Bias = Bias;
Mvt.Outlier = Outlier;

[ofile,opath] = uiputfile('.mat','Save results as');
outfile = fullfile(opath,ofile);
save(outfile,'Mvt')
