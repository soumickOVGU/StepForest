% Main File for Segmenting (Prediction/Testing)
% Select path of the dataset, trained classfiers and to store output from the dialog
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

DSPath = uigetdir(pwd,'Select the path where the dataset is located'); %select the folder with the dataset
TrainedClassifierPath = uigetdir(pwd,'Select the path where the dataset is located'); %select the folder with the dataset
OutputPath = uigetdir(pwd,'Select the folder to store the trained calssifiers'); %select the folder to store the output
TypeOfNormalization = 'Reinhard';
NormalizationRefImage = 'NormalizationReference.png';
binSize = 10; %For 2D Histogram
windowSizes = [21 11 5]; %For the patches
windowSliderSizes = [7 5 3]; %For the mean and SD filter (2D Histogram)

%% Load trained classifiers
savedFile1 = fullfile(TrainedClassifierPath,'Tree1Trainned.mat');
load(savedFile1,'TB1');
savedFile2 = fullfile(TrainedClassifierPath,'Tree2Trainned.mat');
load(savedFile2,'TB2');
savedFile3 = fullfile(TrainedClassifierPath,'Tree3Trainned.mat');
load(savedFile3,'TB3');
timerLoadingCompete = toc();
disp('Classifier Load Complete');
srcFiles= dir(DSPath);
GradeTable = readtable(fullfile(DSPath,'Grade.csv'));

%% Classsification for windowSizes(1), here 40
w=windowSizes(1);%Window Size.
wSlider = windowSliderSizes(1);
ind=1;%comibed index , concatenating pathces of all images
count=1;%index of each image
for i = 3 : length(srcFiles)
    if(strncmpi(srcFiles(i).name,'test',4))
        if(strfind(srcFiles(i).name, 'anno'))
            continue;
        end;
        C = strsplit(srcFiles(i).name,'.');
        D = char(strcat(C(1),'_anno.',C(2)));
        filename = fullfile(DSPath,srcFiles(i).name);
        filenameGroundTruth = fullfile(DSPath,D);
        I = imread(filename);
        J = imread(filenameGroundTruth);
        %figure, subplot 121, imshow(I,[]), subplot 122, imshow(J,[])
        %normalize I and store it to Ni
%         Ni = Preprocessing(I);
        Ni = Normalize(I,NormalizationRefImage,TypeOfNormalization);
        Marker(count,:)= ind; 
        Images(count,:)= C(1);
        
        fileName = C(1);
        for j=1:1:size(GradeTable)
            n = char(GradeTable.name(j));
            if (strcmp(fileName,n) == 1)
                Gr(count,:)= GradeTable.grade_GlaS_(j);
                break;
            end
        end
        
        k=J>0;
        [a,b]=size(I);
        b = b/3;
        
        for x=1:w:b
            for y=1:w:a
                im=imcrop(Ni,[x y w w]);                
                cr(ind,:)=[x y]; %% different                
                [ Fr(ind,:), Fg(ind,:), Fb(ind,:),FvHist2DR(ind,:),FvHaraR(ind,:),FvHist2DG(ind,:),FvHaraG(ind,:),FvHist2DB(ind,:),FvHaraB(ind,:) ]  = FeaturesGeneration( im,wSlider,binSize );
                imk=imcrop(k,[x y w w]);
                GTPatches{ind} = imk; %different
                Patches{ind} = im; %different                
                if((max(imk(:))==min(imk(:))) && (min(imk(:))==1))
                    Lt(ind,:)=1; %Gland
                elseif(max(imk(:))~=min(imk(:)))
                    Lt(ind,:)=3; %Mix
                elseif((max(imk(:))==min(imk(:))) && (min(imk(:))==0))
                    Lt(ind,:)=2; %Non Gland
                else
                    Lt(ind,:)=0; %Error
                end
                ind = ind +1;
            end
        end
        count = count + 1;
    end
end

Ft=[Fr Fg Fb FvHist2DR FvHist2DG FvHist2DB FvHaraR FvHaraG FvHaraB];
[Lpredict,scores] = predict(TB1,Ft);%Predict using the traind classifier.
Linterm = sprintf('%s*', Lpredict{:}); %this and next line is used to convert cell array to double array
Lout = sscanf(Linterm, '%f*');

Out=zeros(size(J));
Out = RegenerateGT( Out,Lout,cr,w,C(1),OutputPath );

timerTestTree1 = toc();
saveFile = fullfile(OutputPath,'Tree1Ttested.mat');
save(saveFile,'-v7.3');%Saving the trained tree.

%% replace all mix values in Lt. using different windows sizes, except the first window size. For Ground Truth

%%%%%%%%%%%%%%%%windowSizes(2), here 20
w=windowSizes(2);
indM = find(Lt==3);
for i=1:length(indM)
    ind = indM(i);
    mp=cell2mat(GTPatches(ind));
    [a,b]=size(mp);
    k=1;
    for x=1:w:b
        for y=1:w:a
            imk=imcrop(mp,[x y w w]);
            
            if((max(imk(:))==min(imk(:))) && (min(imk(:))==1))
                Ltemp(k,:)=1; %Gland
            elseif(max(imk(:))~=min(imk(:)))
                Ltemp(k,:)=3; %Mix
            elseif((max(imk(:))==min(imk(:))) && (min(imk(:))==0))
                Ltemp(k,:)=2; %Non Gland
            else
                Ltemp(k,:)=0; %Error
            end
            k = k +1;
        end
    end
    ng = length(find(Ltemp==1));
    nng = length(find(Ltemp==2));
    nm = length(find(Ltemp==3));
    if(ng > nng)
        if(nm>ng)
            Lt(ind,:)=3;
        else
            Lt(ind,:)=1;
        end
    else
        if(nm>nng)
            Lt(ind,:)=3;
        else
            Lt(ind,:)=2;
        end
    end
end

%%%%%%%%%%%%%%%%windowSizes(3), here 10
w=windowSizes(3);
indM = find(Lt==3);
for i=1:length(indM)
    ind = indM(i);
    mp=cell2mat(GTPatches(ind));
    [a,b]=size(mp);
    k=1;
    for x=1:w:b
        for y=1:w:a
            imk=imcrop(mp,[x y w w]);
            
            if((max(imk(:))==min(imk(:))) && (min(imk(:))==1))
                Ltemp2(k,:)=1;
                %disp('Gland');
            elseif(max(imk(:))~=min(imk(:)))
                numberOfPixels = numel(imk);
                numberOfWPixels = sum(imk(:));
                numberOfBPixels = numberOfPixels - numberOfWPixels;
                if(numberOfBPixels>numberOfWPixels)
                    Ltemp2(k,:)= 2; %Non-gland
                else
                    Ltemp2(k,:)= 1; %gland
                end       
            elseif((max(imk(:))==min(imk(:))) && (min(imk(:))==0))
                Ltemp2(k,:)=2; %Non Gland
            else
                Ltemp2(k,:)=0; %Error
            end
            k = k +1;
        end
    end
    ng = length(find(Ltemp2==1));
    nng = length(find(Ltemp2==2));
    if(ng > nng)
        Lt(ind,:)=1;
    else
        Lt(ind,:)=2;
    end
end

%% replace all mix values in Lout. using different windows sizes, except the first one. For random forest prediction

%%%%%%%%%%%%%%%%
%%% Predict using windowSizes(2), here 20.
%%%%%%%%%%%%%%%%
w=windowSizes(2);%Window Size.
wSlider = windowSliderSizes(2);
indM = find(Lout==3);
for i=1:length(indM)
    ind = indM(i);
    mp=cell2mat(Patches(ind));
    LoutTemp = TestProcess( TB2,mp,w,wSlider,binSize );
    ng = length(find(LoutTemp==1));
    nng = length(find(LoutTemp==2));
    nm = length(find(LoutTemp==3));
    if(ng > nng)
        if(nm>ng)
            Lout(ind,:)=3;
        else
            Lout(ind,:)=1;
        end
    else
        if(nm>nng)
            Lout(ind,:)=3;
        else
            Lout(ind,:)=2;
        end
    end
end

%Out=zeros(size(J));
Out = RegenerateGT( Out,Lout,cr,w,C(1),OutputPath );

timerTestTree2 = toc();
saveFile = fullfile(OutputPath,'Tree2Ttested.mat');
save(saveFile,'-v7.3');%Saving the workspace


%%%%%%%%%%%%%%%%
%%% Predict using windowSizes(3), here 10.
%%%%%%%%%%%%%%%%
w=windowSizes(3);%Window Size.
wSlider = windowSliderSizes(3);
indM = find(Lout==3);
for i=1:length(indM)
    ind = indM(i);
    mp=cell2mat(Patches(ind));
    LoutTemp2 = TestProcess( TB3,mp,w,wSlider,binSize );
    ng = length(find(LoutTemp2==1));
    nng = length(find(LoutTemp2==2));
    if(ng > nng)
        Lout(ind,:)=1;
    else
        Lout(ind,:)=2;
    end
end

%%%%%%%%%%%%%%

%Out=zeros(size(J));
Out = RegenerateGT( Out,Lout,cr,w,C(1),OutputPath );

timerTestTree2 = toc();
saveFile = fullfile(OutputPath,'Tree3Ttested.mat');
save(saveFile,'-v7.3');%Saving the worksapce

%% Accuracy Calculation
match = find(Lt == Lout);%Correctly predicted values.
matched = size(match);%No of correctly predicted items.
accuracy = length(match)/length(Lt);
missClassification = 1 - accuracy;
outputFileName = char(fullfile(OutputPath,strcat(C(1), '_accuracy', 'withRGBnHaralik.txt'))); 
fileID = fopen(outputFileName,'w');
fprintf(fileID,'%f',accuracy);
fclose(fileID);

timerTestTree3 = toc();
rmpath (genpath ('.'));% removes subfolders from the path