% Main File for Training
% Select path of the dataset and to store output from the dialog
% boxes. Settings (window size, bin size etc.) can be adjusted in this first section
% Author: Rupali Khatun (rupali.khatun@live.com)
%         and Soumick Chatterjee (contact@soumick.com)
% Website: http://www.soumick.com
% Sep 2017; Last revision: 11-Dec-2018

% load function files from subfolders as well, add the subfolder to the path
addpath (genpath ('.'));
tic();
clear all;
close all;

path = uigetdir(pwd,'Select the path where the dataset is located'); %select the folder with the dataset
OutputPath = uigetdir(pwd,'Select the folder to store the trained calssifiers'); %select the folder to store the output
srcFiles= dir(path);%To get info of all file in that path.
GradeTable = readtable(fullfile(path,'Grade.csv')); %Replaced the next line, Replaced <strcat(path,'\','> with <fullfile(path,'> 
TypeOfNormalization = 'Reinhard';
NormalizationRefImage = 'NormalizationReference.png';
NumOfTrees = 100; %in the Random Forest
binSize = 10; %For 2D Histogram
windowSizes = [21 11 5]; %For the patches
windowSliderSizes = [7 5 3]; %For the mean and SD filter (2D Histogram)

%% Preprocess and then train with windows size windowSizes(1), here 21

w=windowSizes(1);%Window Size.
wSlider = windowSliderSizes(1);
mixInd=1;
MixPatches = {};
MixGTPatches = {};
count=1;%index of each image
ind=1;%combined index of all the images

for i = 3 : length(srcFiles)
    if(strncmpi(srcFiles(i).name,'train',5))
        if(strfind(srcFiles(i).name, 'anno'))
            continue;
        end
        C = strsplit(srcFiles(i).name,'.');%Spliting the file name and extension.
        D = char(strcat(C(1),'_anno.',C(2)));%Concat _anno. with the file name followed by extension.
        filename = fullfile(path,srcFiles(i).name);
        filenameGroundTruth = fullfile(path,D);
        disp(strcat('Reading:', srcFiles(i).name));
        I = imread(filename);
        J = imread(filenameGroundTruth);
        Ni = Normalize(I,NormalizationRefImage,TypeOfNormalization);
        Marker(count,:)= ind;%Marks the start index of feature vectors(Fr,Fg,Fb) for each image.
        Images(count,:)= C(1);%Holds names of each image.
        
        fileName = C(1);
        for j=1:1:size(GradeTable)
            n = char(GradeTable.name(j));
            if (strcmp(fileName,n) == 1)
                Gr(count,:)= GradeTable.grade_GlaS_(j);%Finding out and storing grade from Grade.csv using linear search
                break;
            end
        end
        
        k=J>0;%Binarise
        [a,b]=size(I);
        b = b/3;%Because size of color image is 3times the no of pixels.
        
        [Limg,FrImg,FgImg,FbImg,FvHist2DImgR,FvHaraImgR,FvHist2DImgG,FvHaraImgG,FvHist2DImgB,FvHaraImgB,MixPatches,MixGTPatches,ind,mixInd] = TrainProcess(Ni,k,a,b,w,binSize,wSlider,ind,mixInd,MixPatches,MixGTPatches);
        if(exist('L','var') == 1) %Ltotal already created in previous iterations.
            L = cat(1, L, Limg); %Vertically Concatenating
            Fr = cat(1, Fr, FrImg);
            Fg = cat(1, Fg, FgImg);
            Fb = cat(1, Fb, FbImg);
            FvHist2DR = cat(1, FvHist2DR, FvHist2DImgR);
            FvHaraR = cat(1, FvHaraR, FvHaraImgR);
            FvHist2DG = cat(1, FvHist2DG, FvHist2DImgG);
            FvHaraG = cat(1, FvHaraG, FvHaraImgG);
            FvHist2DB = cat(1, FvHist2DB, FvHist2DImgB);
            FvHaraB = cat(1, FvHaraB, FvHaraImgB);
        else
            L = Limg;
            Fr = FrImg;
            Fg = FgImg;
            Fb = FbImg;
            FvHist2DR = FvHist2DImgR;
            FvHaraR = FvHaraImgR;
            FvHist2DG = FvHist2DImgR;
            FvHaraG = FvHaraImgR;
            FvHist2DB = FvHist2DImgG;
            FvHaraB = FvHaraImgG;
        end
        count = count + 1;
    end
end


Fv=[Fr Fg Fb FvHist2DR FvHist2DG FvHist2DB FvHaraR FvHaraG FvHaraB];
disp('Feature vector with windows size 40 created');
timerFeatureVector1Created = toc();
save(fullfile(OutputPath,'FeatureVector1Created.mat'));%Saving all Workplace variable.

[ TB1,minErr ] = GrowForest( Fv,L,NumOfTrees );
fprintf('Minimum error for TB1 is %f\n',minErr);
saveFile = fullfile(OutputPath,'Tree1Trainned.mat');
save(saveFile,'TB1');%Saving the trained tree.
disp('Forest with window size 40 created');

%% train with windows size windowSizes(2), here 11

w = windowSizes(2);
wSlider = windowSliderSizes(2);
mixInd=1;
MixPatches2 = {};
MixGTPatches2 = {};
disp(strcat(num2str(length(MixPatches)), 'Mix patches found in windows size 40'));

for i = 1 : length(MixPatches)
    mp = cell2mat(MixPatches(i));
    [a,b]=size(mp);
    b=b/3;
    if(mod(i,100)==0)
        disp(strcat(num2str(i), ' number mix patch is worked on for w20 of ',num2str(length(MixPatches))));
    end
    
    [Limg,FrImg,FgImg,FbImg,FvHist2DImgR,FvHaraImgR,FvHist2DImgG,FvHaraImgG,FvHist2DImgB,FvHaraImgB,MixPatches2,MixGTPatches2,ind,mixInd] = TrainProcess(mp,cell2mat(MixGTPatches(i)),a,b,w,binSize,wSlider,ind,mixInd,MixPatches2,MixGTPatches2);
    if(exist('L2','var') == 1) %Ltotal already created in previous iterations.
        L2 = cat(1, L2, Limg);
        Fr2 = cat(1, Fr2, FrImg);
        Fg2 = cat(1, Fg2, FgImg);
        Fb2 = cat(1, Fb2, FbImg);
        FvHist2DR2 = cat(1, FvHist2DR2, FvHist2DImgR);
        FvHaraR2 = cat(1, FvHaraR2, FvHaraImgR);
        FvHist2DG2 = cat(1, FvHist2DG2, FvHist2DImgG);
        FvHaraG2 = cat(1, FvHaraG2, FvHaraImgG);
        FvHist2DB2 = cat(1, FvHist2DB2, FvHist2DImgB);
        FvHaraB2 = cat(1, FvHaraB2, FvHaraImgB);
    else
        L2 = Limg;
        Fr2 = FrImg;
        Fg2 = FgImg;
        Fb2 = FbImg;
        FvHist2DR2 = FvHist2DImgR;
        FvHaraR2 = FvHaraImgR;
        FvHist2DG2 = FvHist2DImgR;
        FvHaraG2 = FvHaraImgR;
        FvHist2DB2 = FvHist2DImgG;
        FvHaraB2 = FvHaraImgG;
    end
end

Fv2=[Fr2 Fg2 Fb2 FvHist2DR2 FvHist2DG2 FvHist2DB2 FvHaraR2 FvHaraG2 FvHaraB2];
disp('Feature vector for windows size 20 created');
timerFeatureVector2Created = toc();
save(fullfile(OutputPath,'FeatureVector2Created.mat'));%Saving all Workplace variable.

[ TB2,minErr ] = GrowForest( Fv2,L2,NumOfTrees );
fprintf('Minimum error for TB2 is %f\n',minErr);
saveFile = fullfile(OutputPath,'Tree2Trainned.mat');
save(saveFile,'TB2');%Saving the trained tree.
disp('Forest with window size 20 trained');

%% train with windows size windowSizes(3), here 5

w = windowSizes(3);
wSlider = windowSliderSizes(3);
mixInd=1;
MixPatches3 = {};
MixGTPatches3 = {};
disp(strcat(num2str(length(MixPatches2)), 'Mix patches found in windows size 20'));
for i = 1 : length(MixPatches2)
    [a,b]=size(cell2mat(MixPatches2(i)));
    b=b/3;
    if(mod(i,100)==0)
        disp(strcat(num2str(i), ' number mix patch is worked on for w10 of ',num2str(length(MixPatches2))));
    end        
    
    [Limg,FrImg,FgImg,FbImg,FvHist2DImgR,FvHaraImgR,FvHist2DImgG,FvHaraImgG,FvHist2DImgB,FvHaraImgB,MixPatches3,MixGTPatches3,ind,mixInd,GTPatchesImg] = TrainProcess(cell2mat(MixPatches2(i)),cell2mat(MixGTPatches2(i)),a,b,w,binSize,wSlider,ind,mixInd,MixPatches3,MixGTPatches3);
    if(exist('L3','var') == 1) %Ltotal already created in previous iterations.
        L3 = cat(1, L3, Limg);
        Fr3 = cat(1, Fr3, FrImg);
        Fg3 = cat(1, Fg3, FgImg);
        Fb3 = cat(1, Fb3, FbImg);
        FvHist2DR3 = cat(1, FvHist2DR3, FvHist2DImgR);
        FvHaraR3 = cat(1, FvHaraR3, FvHaraImgR);
        FvHist2DG3 = cat(1, FvHist2DG3, FvHist2DImgG);
        FvHaraG3 = cat(1, FvHaraG3, FvHaraImgG);
        FvHist2DB3 = cat(1, FvHist2DB3, FvHist2DImgB);
        FvHaraB3 = cat(1, FvHaraB3, FvHaraImgB);
        GTPatches3 = cat(2, GTPatches3, GTPatchesImg);
    else
        L3 = Limg;
        Fr3 = FrImg;
        Fg3 = FgImg;
        Fb3 = FbImg;
        FvHist2DR3 = FvHist2DImgR;
        FvHaraR3 = FvHaraImgR;
        FvHist2DG3 = FvHist2DImgR;
        FvHaraG3 = FvHaraImgR;
        FvHist2DB3 = FvHist2DImgG;
        FvHaraB3 = FvHaraImgG;
        GTPatches3 = GTPatchesImg;
    end
end

Fv3=[Fr3 Fg3 Fb3 FvHist2DR3 FvHist2DG3 FvHist2DB3 FvHaraR3 FvHaraG3 FvHaraB3];
disp('Feature vector for windows size 10 created');
indM = find(L3==3);
for i=1:length(indM)
    mp=cell2mat(GTPatches3(indM(i)));
    numberOfPixels = numel(mp);
    numberOfWPixels = sum(mp(:));
    numberOfBPixels = numberOfPixels - numberOfWPixels;
    if(numberOfBPixels>numberOfWPixels)
        L3(indM(i),:) = 2; %Non-gland
    else
        L3(indM(i),:) = 1; %gland
    end
end
timerFeatureVector3Created = toc();
save(fullfile(OutputPath,'FeatureVector3Created.mat'));%Saving all Workplace variable.

[ TB3,minErr ] = GrowForest( Fv3,L3,NumOfTrees );
fprintf('Minimum error for TB2 is %f\n',minErr);
saveFile = fullfile(OutputPath,'Tree3Trainned.mat');
save(saveFile,'TB3');%Saving the trained tree.
disp('Forest with window size 10 trained');

timerFinished = toc();
rmpath (genpath ('.'));% removes subfolders from the path